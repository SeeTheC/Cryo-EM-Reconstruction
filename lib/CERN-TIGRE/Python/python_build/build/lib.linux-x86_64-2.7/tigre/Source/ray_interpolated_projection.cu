/*-------------------------------------------------------------------------
 *
 * CUDA functions for texture-memory interpolation based projection
 *
 * This file has the necesary fucntiosn to perform X-ray CBCT projection 
 * operation given a geaometry, angles and image. It uses the 3D texture 
 * memory linear interpolation to uniformily sample a path to integrate the 
 * X-rays.
 *
 * CODE by       Ander Biguri
 *
---------------------------------------------------------------------------
---------------------------------------------------------------------------
Copyright (c) 2015, University of Bath and CERN- European Organization for 
Nuclear Research
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
 ---------------------------------------------------------------------------

Contact: tigre.toolbox@gmail.com
Codes  : https://github.com/CERN/TIGRE
--------------------------------------------------------------------------- 
 */

#include <algorithm>
#include <cuda_runtime_api.h>
#include <cuda.h>
#include "ray_interpolated_projection.hpp"
//#include "mex.h"
#include <math.h>
#include "projection.hpp"


//        if (__err != cudaSuccess) { \
//                  printf("%s \n", msg);\
//                  printf("%s \n", cudaGetErrorString(__err));\
//        } \
// TODO: Error logging
#define cudaCheckErrors(msg) \
do { \
        cudaError_t __err = cudaGetLastError(); \
} while (0)

// Declare the texture reference.
    texture<float, cudaTextureType3D , cudaReadModeElementType> tex;

#define MAXTREADS 1024
/*GEOMETRY DEFINITION
 *
 *                Detector plane, behind
 *            |-----------------------------|
 *            |                             |
 *            |                             |
 *            |                             |
 *            |                             |
 *            |      +--------+             |
 *            |     /        /|             |
 *   A Z      |    /        / |*D           |
 *   |        |   +--------+  |             |
 *   |        |   |        |  |             |
 *   |        |   |     *O |  +             |
 *    --->y   |   |        | /              |
 *  /         |   |        |/               |
 * V X        |   +--------+                |
 *            |-----------------------------|
 *
 *           *S
 *
 *
 *
 *
 *
 **/


__global__ void kernelPixelDetector( Geometry geo,
        float* detector,
        Point3D source ,
        Point3D deltaU,
        Point3D deltaV,
        Point3D uvOrigin,
        float maxdist){
    
    unsigned long  y = blockIdx.y * blockDim.y + threadIdx.y;
    unsigned long x = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned long  idx =  x  * geo.nDetecV + y;

    if ((x>= geo.nDetecU) | (y>= geo.nDetecV))
        return;
    
    

    
    /////// Get coordinates XYZ of pixel UV
    int pixelV = geo.nDetecV-y-1;
    int pixelU = x;
    
    
    
    float vectX,vectY,vectZ;
    Point3D P;
    P.x=(uvOrigin.x+pixelU*deltaU.x+pixelV*deltaV.x);
    P.y=(uvOrigin.y+pixelU*deltaU.y+pixelV*deltaV.y);
    P.z=(uvOrigin.z+pixelU*deltaU.z+pixelV*deltaV.z);
    
    // Length is the ray length in normalized space
    float length=sqrt((source.x-P.x)*(source.x-P.x)+(source.y-P.y)*(source.y-P.y)+(source.z-P.z)*(source.z-P.z));
    //now legth is an integer of Nsamples that are required on this line
    length=ceil(length/geo.accuracy);//Divide the directional vector by an integer
    vectX=(P.x -source.x)/(length);
    vectY=(P.y -source.y)/(length);
    vectZ=(P.z -source.z)/(length);
    
    
//     //Integrate over the line
    float tx,ty,tz;
    float sum=0;
    float i;
    
    
    // limit the amount of mem access after the cube, but before the detector.
    if ((geo.DSO/min(geo.dVoxelX,geo.dVoxelY)+maxdist)/geo.accuracy  <   length)
        length=ceil((geo.DSO/min(geo.dVoxelX,geo.dVoxelY)+maxdist)/geo.accuracy);  
    //Length is not actually a length, but the amount of memreads with given accuracy ("samples per voxel")
    for (i=floor(maxdist/geo.accuracy); i<=length; i=i+1){
        tx=vectX*i+source.x;
        ty=vectY*i+source.y;
        tz=vectZ*i+source.z;
        
        sum += tex3D(tex, tx+0.5, ty+0.5, tz+0.5); // this line is 94% of time.
    }
    float deltalength=sqrt((vectX*geo.dVoxelX)*(vectX*geo.dVoxelX)+
            (vectY*geo.dVoxelY)*(vectY*geo.dVoxelY)+(vectZ*geo.dVoxelZ)*(vectZ*geo.dVoxelZ) );
    unsigned long  idxC =  y  * geo.nDetecU + x;
    detector[idx]=sum*deltalength;
}



int interpolation_projection(float const * const img, Geometry geo, float** result,float const * const alphas,int nalpha){
    
    
    // copy data to CUDA memory

    cudaArray *d_imagedata = 0;
    
    const cudaExtent extent = make_cudaExtent(geo.nVoxelX, geo.nVoxelY, geo.nVoxelZ);
    cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc<float>();
    cudaMalloc3DArray(&d_imagedata, &channelDesc, extent);
    cudaCheckErrors("cudaMalloc3D error 3D tex");
    
    cudaMemcpy3DParms copyParams = { 0 };
    copyParams.srcPtr = make_cudaPitchedPtr((void*)img, extent.width*sizeof(float), extent.width, extent.height);
    copyParams.dstArray = d_imagedata;
    copyParams.extent = extent;
    copyParams.kind = cudaMemcpyHostToDevice;
    cudaMemcpy3D(&copyParams);
    
    cudaCheckErrors("cudaMemcpy3D fail");
    
    // Configure texture options
    tex.normalized = false;
    tex.filterMode = cudaFilterModeLinear;
    tex.addressMode[0] = cudaAddressModeBorder;
    tex.addressMode[1] = cudaAddressModeBorder;
    tex.addressMode[2] = cudaAddressModeBorder;
    
    cudaBindTextureToArray(tex, d_imagedata, channelDesc);
    
    cudaCheckErrors("3D texture memory bind fail");
    
    
    //Done! Image put into texture memory.
    
    
    size_t num_bytes = geo.nDetecU*geo.nDetecV * sizeof(float);
    float* dProjection;
    cudaMalloc((void**)&dProjection, num_bytes);
    cudaMemset(dProjection,0,num_bytes);
    cudaCheckErrors("cudaMalloc fail");

    
//     If we are going to time
    bool timekernel=false;
    cudaEvent_t start, stop;
    float elapsedTime;
    if (timekernel){
        cudaEventCreate(&start);
        cudaEventRecord(start,0);
    } 
   
    
    int divU,divV;
    divU=32;
    divV=32;
    dim3 grid((geo.nDetecU+divU-1)/divU,(geo.nDetecV+divV-1)/divV,1);
    dim3 block(divU,divV,1); 
    
    
    Point3D source, deltaU, deltaV, uvOrigin;
    float maxdist;
    for (unsigned int i=0;i<nalpha;i++){
        
        geo.alpha=alphas[i];
        //precomute distances for faster execution
        maxdist=maxDistanceCubeXY(geo,geo.alpha,i);
        //Precompute per angle constant stuff for speed
        computeDeltas(geo,geo.alpha,i, &uvOrigin, &deltaU, &deltaV, &source);
        //Interpolation!!
        
        kernelPixelDetector<<<grid,block>>>(geo,dProjection, source, deltaU, deltaV, uvOrigin,floor(maxdist));
        cudaCheckErrors("Kernel fail");
        // copy result to host
        cudaMemcpy(result[i], dProjection, num_bytes, cudaMemcpyDeviceToHost);
        cudaCheckErrors("cudaMemcpy fail");
        
           

    }
    if (timekernel){
        cudaEventCreate(&stop);
        cudaEventRecord(stop,0);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&elapsedTime, start,stop);
        //mexPrintf("%f\n" ,elapsedTime);
    }

    cudaUnbindTexture(tex);
    cudaCheckErrors("Unbind  fail");
    
    cudaFree(dProjection);
    cudaFreeArray(d_imagedata);
    cudaCheckErrors("cudaFree d_imagedata fail");
    
    
    
    //cudaDeviceReset();
    
    return 0;
}




/* This code precomputes The location of the source and the Delta U and delta V (in the warped space)
 * to compute the locations of the x-rays. While it seems verbose and overly-optimized,
 * it does saves about 30% of each of the kernel calls. Thats something!
 **/
void computeDeltas(Geometry geo, float alpha,int i, Point3D* uvorigin, Point3D* deltaU, Point3D* deltaV, Point3D* source){
    Point3D S;
    S.x=geo.DSO;
    S.y=0;
    S.z=0;
    
    //End point
    Point3D P,Pu0,Pv0;
    
    P.x  =-(geo.DSD-geo.DSO);   P.y  = geo.dDetecU*(0-((float)geo.nDetecU/2)+0.5);       P.z  = geo.dDetecV*(((float)geo.nDetecV/2)-0.5-0);
    Pu0.x=-(geo.DSD-geo.DSO);   Pu0.y= geo.dDetecU*(1-((float)geo.nDetecU/2)+0.5);       Pu0.z= geo.dDetecV*(((float)geo.nDetecV/2)-0.5-0);
    Pv0.x=-(geo.DSD-geo.DSO);   Pv0.y= geo.dDetecU*(0-((float)geo.nDetecU/2)+0.5);       Pv0.z= geo.dDetecV*(((float)geo.nDetecV/2)-0.5-1);
    // Geomtric trasnformations:
    
    
    // Now we have the Real world (OXYZ) coordinates of the bottom corner and its two neighbours.
    // The obkjective is to get a position of the detector in a coordinate system where:
    // 1-units are voxel size (in each direction can be different)
    // 2-The image has the its first voxel at (0,0,0)
    // 3-The image never rotates
    
    // To do that, we need to compute the "deltas" the detector, or "by how much 
    // (in new xyz) does the voxels change when and index is added". To do that 
    // several geometric steps needs to be changed
    
    //1.Roll,pitch,jaw
    // The detector can have a small rotation. 
    // according to 
    //"A geometric calibration method for cone beam CT systems" Yang K1, Kwan AL, Miller DF, Boone JM. Med Phys. 2006 Jun;33(6):1695-706.
    // Only the Z rotation will have a big influence in the image quality when they are small.
    // Still all rotations are supported
    
    // To roll pitch jaw, the detector has to be in centered in OXYZ. 
    P.x=0;Pu0.x=0;Pv0.x=0;
    
    // Roll pitch yaw
    rollPitchYaw(geo,i,&P);
    rollPitchYaw(geo,i,&Pu0);
    rollPitchYaw(geo,i,&Pv0);
    //Now ltes translate the points where they shoudl be:
    P.x=P.x-(geo.DSD-geo.DSO);
    Pu0.x=Pu0.x-(geo.DSD-geo.DSO);
    Pv0.x=Pv0.x-(geo.DSD-geo.DSO);
    //2: Offset detector
    
    //P.x
    P.y  =P.y  +geo.offDetecU[i];    P.z  =P.z  +geo.offDetecV[i];
    Pu0.y=Pu0.y+geo.offDetecU[i];    Pu0.z=Pu0.z+geo.offDetecV[i];
    Pv0.y=Pv0.y+geo.offDetecU[i];    Pv0.z=Pv0.z+geo.offDetecV[i];
    //S doesnt need to chagne
    
    
    //3: Rotate (around z)!
    Point3D Pfinal, Pfinalu0, Pfinalv0;
    
    Pfinal.x  =P.x*cos(geo.alpha)-P.y*sin(geo.alpha);       Pfinal.y  =P.y*cos(geo.alpha)+P.x*sin(geo.alpha);       Pfinal.z  =P.z;
    Pfinalu0.x=Pu0.x*cos(geo.alpha)-Pu0.y*sin(geo.alpha);   Pfinalu0.y=Pu0.y*cos(geo.alpha)+Pu0.x*sin(geo.alpha);   Pfinalu0.z=Pu0.z;
    Pfinalv0.x=Pv0.x*cos(geo.alpha)-Pv0.y*sin(geo.alpha);   Pfinalv0.y=Pv0.y*cos(geo.alpha)+Pv0.x*sin(geo.alpha);   Pfinalv0.z=Pv0.z;
    
    Point3D S2;
    S2.x=S.x*cos(geo.alpha)-S.y*sin(geo.alpha);
    S2.y=S.y*cos(geo.alpha)+S.x*sin(geo.alpha);
    S2.z=S.z;
    
    //3: Offset image (instead of offseting image, -offset everything else)
    
    Pfinal.x  =Pfinal.x-geo.offOrigX[i];     Pfinal.y  =Pfinal.y-geo.offOrigY[i];     Pfinal.z  =Pfinal.z-geo.offOrigZ[i];
    Pfinalu0.x=Pfinalu0.x-geo.offOrigX[i];   Pfinalu0.y=Pfinalu0.y-geo.offOrigY[i];   Pfinalu0.z=Pfinalu0.z-geo.offOrigZ[i];
    Pfinalv0.x=Pfinalv0.x-geo.offOrigX[i];   Pfinalv0.y=Pfinalv0.y-geo.offOrigY[i];   Pfinalv0.z=Pfinalv0.z-geo.offOrigZ[i];
    S2.x=S2.x-geo.offOrigX[i];               S2.y=S2.y-geo.offOrigY[i];               S2.z=S2.z-geo.offOrigZ[i];
    
    // As we want the (0,0,0) to be in a corner of the image, we need to translate everything (after rotation);
    Pfinal.x  =Pfinal.x+geo.sVoxelX/2-geo.dVoxelX/2;      Pfinal.y  =Pfinal.y+geo.sVoxelY/2-geo.dVoxelY/2;          Pfinal.z  =Pfinal.z  +geo.sVoxelZ/2-geo.dVoxelZ/2;
    Pfinalu0.x=Pfinalu0.x+geo.sVoxelX/2-geo.dVoxelX/2;    Pfinalu0.y=Pfinalu0.y+geo.sVoxelY/2-geo.dVoxelY/2;        Pfinalu0.z=Pfinalu0.z+geo.sVoxelZ/2-geo.dVoxelZ/2;
    Pfinalv0.x=Pfinalv0.x+geo.sVoxelX/2-geo.dVoxelX/2;    Pfinalv0.y=Pfinalv0.y+geo.sVoxelY/2-geo.dVoxelY/2;        Pfinalv0.z=Pfinalv0.z+geo.sVoxelZ/2-geo.dVoxelZ/2;
    S2.x      =S2.x+geo.sVoxelX/2-geo.dVoxelX/2;          S2.y      =S2.y+geo.sVoxelY/2-geo.dVoxelY/2;              S2.z      =S2.z      +geo.sVoxelZ/2-geo.dVoxelZ/2;
    
    //4. Scale everything so dVoxel==1
    Pfinal.x  =Pfinal.x/geo.dVoxelX;      Pfinal.y  =Pfinal.y/geo.dVoxelY;        Pfinal.z  =Pfinal.z/geo.dVoxelZ;
    Pfinalu0.x=Pfinalu0.x/geo.dVoxelX;    Pfinalu0.y=Pfinalu0.y/geo.dVoxelY;      Pfinalu0.z=Pfinalu0.z/geo.dVoxelZ;
    Pfinalv0.x=Pfinalv0.x/geo.dVoxelX;    Pfinalv0.y=Pfinalv0.y/geo.dVoxelY;      Pfinalv0.z=Pfinalv0.z/geo.dVoxelZ;
    S2.x      =S2.x/geo.dVoxelX;          S2.y      =S2.y/geo.dVoxelY;            S2.z      =S2.z/geo.dVoxelZ;
    
    
    //mexPrintf("COR: %f \n",geo.COR[i]);
    //5. apply COR. Wherever everything was, now its offesetd by a bit
    float CORx, CORy;
    CORx=-geo.COR[i]*sin(geo.alpha)/geo.dVoxelX;
    CORy= geo.COR[i]*cos(geo.alpha)/geo.dVoxelY;
    Pfinal.x+=CORx;   Pfinal.y+=CORy;
    Pfinalu0.x+=CORx;   Pfinalu0.y+=CORy;
    Pfinalv0.x+=CORx;   Pfinalv0.y+=CORy;
    S2.x+=CORx; S2.y+=CORy;
    
    // return
    
    *uvorigin=Pfinal;
    
    deltaU->x=Pfinalu0.x-Pfinal.x;
    deltaU->y=Pfinalu0.y-Pfinal.y;
    deltaU->z=Pfinalu0.z-Pfinal.z;
    
    deltaV->x=Pfinalv0.x-Pfinal.x;
    deltaV->y=Pfinalv0.y-Pfinal.y;
    deltaV->z=Pfinalv0.z-Pfinal.z;
    
    *source=S2;
}
