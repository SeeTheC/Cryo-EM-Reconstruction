from __future__ import print_function
from __future__ import division
from tigre.Utilities.parkerweight import parkerweight
import numpy as np

import warnings
def filtering(proj,geo,angles,parker):
    if parker:
        proj=parkerweight(proj.transpose(0,2,1),geo,angles,parker).transpose(0,2,1)
        # proj=parkerweight(proj,geo,angles,parker)
    filt_len=max(64,2**nextpow2(2*geo.nDetector[0]))
    ramp_kernel=ramp_flat(filt_len)

    d=1
    filt=filter(geo.filter,ramp_kernel[0],filt_len,d)


    filt=np.kron(np.ones((geo.nDetector[0],1)),filt).transpose()


    for i in range(len(angles)):
        fproj=np.zeros((filt_len,geo.nDetector[0]),dtype=np.float32)

        fproj[int(filt_len/2-geo.nDetector[0]/2):int(filt_len/2+geo.nDetector[0]/2),:]=proj[i]

        fproj=np.fft.fft(fproj,axis=0)

        fproj=fproj*filt

        fproj=np.real(np.fft.ifft(fproj,axis=0))
        end=len(fproj)
        proj[i]=np.transpose(fproj[int(end/2-geo.nDetector[0]/2):int(end/2+geo.nDetector[0]/2),:]/2/geo.dDetector[0]*(2*np.pi/
                                                                                                 len(angles)
                                                                                                 )/2*(geo.DSD/geo.DSO))

    return proj.transpose(0,2,1)

def ramp_flat(n):
    nn=np.arange(-n/2,n/2)
    h=np.zeros(nn.shape,dtype=np.float32)
    h[int(n/2)]=1/4
    odd=nn%2==1
    h[odd]=-1/(np.pi*nn[odd])**2
    return h, nn

def filter(filter,kernel,order,d):
    f_kernel=abs(np.fft.fft(kernel))*2

    filt=f_kernel[:int((order/2)+1)]
    w=2*np.pi*np.arange(len(filt))/order
    if filter not in ['ram_lak','shepp_logan','cosine','hamming','hann',None]:
        raise ValueError('filter not recognised: '+filter)

    if filter in {'ram_lak', None}:
        if filter is None:
            warnings.warn('no filter selected, using default ram_lak')
        pass
    if filter=='shepp_logan':
        filt[1:]*=(np.sin(
                                w[1:]/(2*d))/(w[1:]/(2*d)
                                              )
                           )
    if filter=='cosine':
        filt[1:]*=np.cos(w[1:]/(2*d))
    if filter=='hamming':
        filt[1:]*=(.54+.46*np.cos(w[1:]/d))
    if filter =='hann':
        filt[1:]*=(1+np.cos(w[1:])/d)/2

    filt[w>np.pi*d]=0
    filt=np.hstack((filt,filt[1:-1][::-1]))
    return filt


def nextpow2(n):
    i=1
    while (2**i)<n:
        i+=1
    return i
