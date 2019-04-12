#FROM ubuntu:xenial
FROM nvidia/cuda:9.2-devel-ubuntu16.04

MAINTAINER Andrei Gherghescu <gandrein@gmail.com>

LABEL Description="Ubuntu Xenial 16.04 with mapped NVIDIA driver from the host" Version="1.0"

# ------------------------------------------ Install required (&useful) packages --------------------------------------
RUN apt-get update && apt-get install -y \
  software-properties-common python-software-properties \
  lsb-release \
  mesa-utils \
  wget \
  curl \
  sudo vim \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# nvidia-docker hooks: Map host's NVIDIA driver to container
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# In the newly loaded container sometimes you can't do `apt install <package>
# unless you do a `apt update` first.  So run `apt update` as last step
# NOTE: bash auto-completion may have to be enabled manually from /etc/bash.bashrc RUN apt-get update -y
CMD ["/bin/bash"]


####################################
## install SuMA
####################################
RUN apt-get update
RUN apt-get install -y build-essential cmake libgtest-dev libeigen3-dev libboost-all-dev qtbase5-dev libglew-dev libqt5libqgtk2 catkin git cmake
RUN apt install -y python-pip
RUN pip install catkin_tools catkin_tools_fetch empy
RUN mkdir /code && cd /code && git clone https://tseanliu@bitbucket.org/gtborg/gtsam.git && cd gtsam && mkdir build && cd build && cmake ../ && make -j4 && make install -j4

RUN ldconfig

RUN cd && mkdir -p catkin_ws/src && cd catkin_ws && catkin init
RUN cd ~/catkin_ws/src && git clone https://github.com/ros/catkin.git
RUN cd ~/catkin_ws/src && git clone https://github.com/jbehley/SuMa.git
RUN cd ~/catkin_ws/ && catkin deps fetch; exit 0
RUN cd ~/catkin_ws/ && catkin build --save-config -i --cmake-args -DCMAKE_BUILD_TYPE=Release -DOPENGL_VERSION=450 -DENABLE_NVIDIA_EXT=YES





