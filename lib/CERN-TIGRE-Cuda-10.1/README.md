TIGRE: Tomographic Iterative GPU-based Reconstruction Toolbox
======

TIGRE is a MATLAB and Python/CUDA toolbox for fast and accurate 3D tomographic 
reconstruction (any geometry), created jointly by University of Bath's Engineering Tomography Lab and CERN. 

The aim of TIGRE is to provide a wide range of easy-to-use iterative algorithms to the tomographic research community. 
We would like to build a stronger bridge between algorithm researchers and
imaging researchers, by encouraging and supporting contributions from both sides into
TIGRE. 

TIGRE is free to use and distribute, use it, modify it, break it, share it; 
the only requirement is proper referencing to the authors.


If you wish to be added to the mailing list of TIGRE, please send an email to tigre.toolbox@gmail.com. 
We will only contact you whenever a new version of TIGRE is released or with important news.

TIGRE is still being developed and we are still adding new features to it. If you have any request for your specific application, do not hesitate to contact us!


[Read the PhD Thesis of Ander Biguri](https://github.com/AnderBiguri/PhDThesis) for a detailed description of TIGRE, iterative algorithms and GPU computing, among other things. 



Donwload: [https://github.com/CERN/TIGRE/releases][7]


## **NEWS**

There is a somehow working version of Python that still needs a bit of work regarding setup.
If you are interested in contributing, please contact us. 


## **TIGRE features**:

  - Fast, state of the art projection using two modes of ray tracing (interpolation or Siddon (Jacob))

  - Fast, state of the art backprojection using two modes (FDK weight or matched weight (for krylov subspace algorithms)) 
  
  - Wide geometric flexibility, being possible to change most parameters per-projeciton

  - A wide range of algorithms with multiple configurations for each 
      - FDK
      - Gradien descend family
        - SART                    
        - OS-SART                
        - SIRT
      - Krylov Subspace
        - CGLS
      - Statistical methods
        - MLEM
      - Total Variation
        - ADS-POCS               
        - OSC-POCS              
        - B-ADS-POCS-&#946;       
        - SART-TV
        - PCSD
        - AwASD-POCS
        - AwPCSD
      

  - TV denoising for 3D images

  - A variety of basic plotting functions

  - Quality measures


## How to install TIGRE

(Tested on win 64 and Linux 64 machines, please [report any 
issue][2] if it doesnt work in other arch/OS)
 
   - Download TIGRE from the downloads page
   
   - Install  CUDA Toolkit (the later, the better)
     Download [here][1]
     
   - Install a compatible compiler (the Best option Visual Studio 2013 - if you use VS2017 it may cause problems because VSCOMMTOOLS14 in VS2017 has completely different directory structure)
   
   - Run Compile.m

If it doesn't work
   
   - Make sure a compiler is set up in your MATLAB. run `mex -setup`. If a 
     compiler is not set up, make sure you download one (some are free)
     and run mex -setup again.
   
   - Make sure the xml file for compiling is properly set up. E.g. in Linux 64 bit machines
     mex_CUDA_glnxa64.xml should be present, and inside it the proper links to CUDA will have to be set up.

   - On linux machines, make sure you modify `mex_CUDA_glnxa64.xml` line 44 to the correct path to libcudart on your system.
   
   - Try `getenv('CUDA_PATH')`. If it doesn't return the path of the compiler, then try `setenv('CUDA_PATH','C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0')` (change with your CUDA path)
   
   - Run Compile.m

   - TIGRE should be ready to use!


## Some fancy images

TIGRE gets this:

![Imgur](http://i.imgur.com/ahnFc05.gif?1)

And transforms it to this:

![this image](http://i.imgur.com/NcVEac2.gif?1)
 
And much more! There are 11 algorithms that will behave differently for different data!
Just get it, and try your data! 



## Getting started & Documentation


The first thing you need to do is run `InitTIGRE`, to initialize all the 
folders and subfolders if the toolbox.

Currently the documentation is included in each of the functions. You can access it 
by typing `help function_name` or by selecting the function in the editor and pressing F1.
Additionally, the demos should include all the necessary documentation and examples of use.



## Issues

If you have any issues with compiling/running TIGRE, or you found a bug in
the code, please report it on [the issues page][2]<sup>&#8727;</sup>.

Please, be as clear as  possible with the description of the problem.
If it is a specific problem in a specific scenario, provide a *Minimum 
Complete Verifiable Example* of the problem (see [Stackoverflow.com's definition][3]);

<sup>&#8727;</sup> **Protip** you can [label the Issues by topic][4]

## I want to contribute! 

Wow! We are glad you do! Please, if you want to contribute new methods, 
algorithms, pre- or post- processing techniques, bug-fixes, documentation, or
*anything* you thing it can help the community, please, do! We encourage
this behaviour!

*But how?* 

Easy! you can download the git repo, and make a pull request with your 
contribution. We will review it and add it if its suited for TIGRE. 

If you don't know how git
works<sup>1</sup> you can also send an email us to tigre.toolbox@gmail.com 
with your contribution, and an explanation of what it does and how. We will
review and add the contribution if suited.

If your contribution can be linked to a published, peer-reviewed article or
an arXiv entry, please let us know so we can make sure the `citeme` function
includes your contributions.

## FAQ

**Q: I get "the launch timed out and was terminated" error when I run big images
in my computer**

*A: This happens because your GPU takes too long (according to the OS) to finish
running the code. Don't worry, too long means about 100ms or so. However, you need
to make sure to change the OS's GPU watchdog time. 
If you are working on a TESLA, setting the TESLA to TCC mode will fix the problem.*

**Q: After running something I got an error in Ax or Atb and now nothing works**

*A: Unfortunately when CUDA has an error, it hungs. You need to restart MATLAB to fix
this. Hopefully we can find a solution for this without the need of restarting MATLAB*

**Q: Does it work in MATLAB XXXX with Compiler XXXX in OS XXXX**

*A: In general, it should, as long as you are following both CUDAs and MATLABs supportedcompilers.
The truth is that there are few compilers that fit the eligibility criteria for both. MATLAB version and OS 
should not be a problem.*

**Q: I get a fair amount of warnings when I compile the code, what is happening?**

*A: Do not worry about the warnings. We are perfectly aware of them and know that they will have no 
effect whatsoever in the correct execution (both in computational time and accuracy) of the code.*

## Licensing

TIGRE toolbox is released under the BSD License, meaning you can use and modify 
the software freely in any case, but you **must** give attribution to the original authors.
For more information, read the license file or the [BSD License Definition][5] or [the license file][6]

## Contact

*Before contacting* consider that you might be able to let us know any problem TIGRE may have by
[raising an issue][2] and [labeling accordingly][4]. 

If you want to contact us for other reasons than an issue with the tool, please send us an email to

tigre.toolbox@gmail.com

or contact the author directly in

ander.biguri@gmail.com

We will make an effort to answer as soon as we can.

## Referencing TIGRE

If you use TIGRE in any publications, please reference the following paper:

**TIGRE: A MATLAB-GPU toolbox for CBCT image reconstruction**
*Ander Biguri, Manjit Dosanjh, Steven Hancock, and Manuchehr Soleimani*
**Biomedical Physics & Engineering Express, Volume 2, Number 5**
[Read the article (Open Access)][8]

Also, if you use any algorithm, you should reference the corresponding creator
of the algorithms. If you don't know the article, use `citeme('NameOfFunction')`
and the right reference will appear.


---

<sup>1</sup> You can learn, it is very useful!


[1]: https://developer.nvidia.com/cuda-downloads
[2]: https://github.com/CERN/TIGRE/issues
[3]: https://stackoverflow.com/help/mcve
[4]: https://help.github.com/articles/applying-labels-to-issues-and-pull-requests/
[5]: http://www.linfo.org/bsdlicense.html
[6]: https://github.com/CERN/TIGRE/blob/master/LICENSE
[7]: https://github.com/CERN/TIGRE/releases
[8]: http://iopscience.iop.org/article/10.1088/2057-1976/2/5/055010
