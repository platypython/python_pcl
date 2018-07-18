FROM ubuntu:16.04

RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install build-essential cmake devscripts dh-exec doxygen doxygen-latex freeglut3-dev git \
    libavformat-dev libjasper-dev libjpeg-dev libopencv-dev libpcl-* libpng-dev \
    libpq-dev libqt4-opengl-dev libswscale-dev libtbb-dev libtbb2 libtiff-dev libusb-1.0-0-dev \
    libvtk6-qt-dev libxmu-dev pkg-config qt5-default software-properties-common unzip vim wget yasm -y && \
    #
    add-apt-repository ppa:jonathonf/python-3.6 && apt-get update && \
    apt-get install python3.6 python3.6-dev python3-pip python-sphinx python3.6-venv -y && \
    rm -rf /var/lib/apt/lists/* && \
    python3.6 -m pip install pip --upgrade && python3.6 -m pip install wheel

#install python-pcl from its git repository
RUN git clone https://github.com/strawlab/python-pcl.git && pip3.6 install --upgrade pip && \
    pip3.6 install cython==0.25.2 && pip3.6 install numpy
RUN cd /python-pcl && python3.6 setup.py build_ext -i && \
    python3.6 setup.py install --user

ENV OPENCV_VERSION="3.4.1"
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& unzip ${OPENCV_VERSION}.zip \
&& mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DENABLE_AVX=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.6) \
  -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
&& make install \
&& rm /${OPENCV_VERSION}.zip \
&& rm -r /opencv-${OPENCV_VERSION}
