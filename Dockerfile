FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
ubuntu-desktop \
ubuntu-server

RUN apt-get update && \
apt-get install -y wget software-properties-common &&\
add-apt-repository ppa:ubuntu-toolchain-r/test &&\
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add - &&\
apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main" &&\
apt-get update &&\
apt-get install -y build-essential clang-8 lld-8 g++-7 cmake ninja-build libvulkan1 python python-pip python-dev python3-dev python3-pip libpng-dev libtiff5-dev libjpeg-dev tzdata sed curl unzip autoconf libtool rsync libxml2-dev &&\
pip2 install --user setuptools &&\
pip3 install --user setuptools 

RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-8/bin/clang++ 180 &&\
update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-8/bin/clang 180

RUN apt-get update && apt-get install -y \
lrzip

#copy UnrealEngine_4.24 /UnrealEngine_4.24

#copy UnrealEngine_4.24.tar.lrz /UnrealEngine_4.24.tar.lrz
#run lrztar -d /UnrealEngine_4.24.tar.lrz 
copy UnrealEngine /UnrealEngine

ARG unreal_engine_version='4.24'
run cd UnrealEngine; git checkout "$unreal_engine_version"


#Add UnrealEngine_4.24.tar.lrz /UnrealEngine_4.24.tar.lrz
#RUN lrztar -d UnrealEngine_4.24.tar.lrz

RUN apt-get update && apt-get install -y \
sudo
RUN groupadd -g 99 appuser && \
    useradd -r -u 99 -g appuser appuser

ENV unreal_dir=/UnrealEngine
RUN cd /UnrealEngine && ./Setup.sh
run echo Generating project files ...
RUN cd /UnrealEngine && ./GenerateProjectFiles.sh
run echo Changing ownership of $unreal_dir ...
run chown -R appuser:appuser $unreal_dir
run mkdir /home/appuser
run chmod -R 777 /home/appuser
USER appuser
RUN cd /UnrealEngine && make
USER root

RUN apt-get update && apt-get install -y \
aria2

RUN git clone https://github.com/carla-simulator/carla
ARG carla_version='0.9.9'
run cd carla &&\
git checkout $carla_version
RUN cd carla &&\
./Update.sh

env UE4_ROOT=~/UnrealEngine

run add-apt-repository ppa:deadsnakes/ppa &&\
apt-get update
ARG python_version='3.6'
#run apt-get remove -y python3.6 && \
#apt-get install -y python"$python_version"
run bash -ic 'if [[ "$carla_version" < "0.9.6" ]]; then \
    apt-get update && apt-get install -y \
    clang-6.0 clang-tools-6.0 clang-6.0-doc libclang-common-6.0-dev libclang-6.0-dev libclang1-6.0 clang-format-6.0 python-clang-6.0; \
else \
    apt-get update && apt-get install -y \
    clang-7 clang-tools-7 clang-7-doc libclang-common-7-dev libclang-7-dev libclang1-7 clang-format-7 python-clang-7; \
fi'
run apt-get install -y python"$python_version"

run apt-get install -y \
python3-pip
run pip3 install setuptools
workdir /usr/bin
run rm python3; ln -s python"$python_version" python3
workdir /
run python3 -V
RUN apt-get update && apt-get install -y \
python"$python_version"-dev

#run cd carla && make LibCarla
run cd carla && make PythonAPI
#run echo Successfully build docker image!


