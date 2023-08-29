#!/bin/bash

#  Copyright (C) 2021 Texas Instruments Incorporated - http://www.ti.com/
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#    Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#    Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the
#    distribution.
#
#    Neither the name of Texas Instruments Incorporated nor the names of
#    its contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


ping bitbucket.itg.ti.co -c 1 > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
    USE_PROXY=1
else
    USE_PROXY=0
fi
#To dwld the src files
./onnxrt_prepare.sh

if [ $# -lt 1 ];then
    echo "usage ./build_onnxrt.sh ubuntu18"
    echo "usage ./build_onnxrt.sh ubuntu20"
    echo "usage ./build_onnxrt.sh debian11"
    exit
else
    echo "cross compiling onnxrt for arago linux" 
fi

DOCKERTAG=$1

docker run -it --rm \
    -v $(pwd)/:/root/dlrt-build \
    -v /:/host \
    --network host \
    --env USE_PROXY=$USE_PROXY \
    $DOCKERTAG \
    /bin/bash -c "~/dlrt-build/onnxrt_build.sh"

#x86 build
cd onnx/onnxruntime/
python3 tools/ci_build/build.py --build_dir build_x86_64 --config Release --build_shared_lib --parallel 8 --skip_tests --skip_onnx_tests --use_tidl --build_wheel
