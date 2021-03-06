FROM python:3.6.8-alpine3.9

RUN apk update

RUN apk add musl-dev
RUN apk add g++
RUN apk add gcc

RUN apk --update add libxml2-dev libxslt-dev libffi-dev gcc musl-dev libgcc curl
RUN apk add jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev openblas-dev
RUN apk add ghostscript python3-tkinter
RUN apk add --allow-untrusted make hdf5 git hdf5-dev libc6-compat --repository http://nl.alpinelinux.org/alpine/edge/testing

RUN apk add gcc gfortran build-base wget freetype-dev libpng-dev openblas-dev


RUN echo -e '@edgunity http://nl.alpinelinux.org/alpine/edge/community\n\
@edge http://nl.alpinelinux.org/alpine/edge/main\n\
@testing http://nl.alpinelinux.org/alpine/edge/testing\n\
@community http://dl-cdn.alpinelinux.org/alpine/edge/community'\
  >> /etc/apk/repositories

RUN apk add --update --no-cache \
  # --virtual .build-deps \
      build-base \
      openblas-dev \
      unzip \
      wget \
      cmake \

      #Intel® TBB, a widely used C++ template library for task parallelism'
      libtbb@testing  \
      libtbb-dev@testing   \

      # Wrapper for libjpeg-turbo
      libjpeg  \

      # accelerated baseline JPEG compression and decompression library
      libjpeg-turbo-dev \

      # Portable Network Graphics library
      libpng-dev \

      # A software-based implementation of the codec specified in the emerging JPEG-2000 Part-1 standard (development files)
      jasper-dev \

      # Provides support for the Tag Image File Format or TIFF (development files)
      tiff-dev \

      # Libraries for working with WebP images (development files)
      libwebp-dev \

      # A C language family front-end for LLVM (development files)
      clang-dev \

      linux-headers \

      && pip install numpy

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

ENV OPENCV_VERSION=3.4.4

RUN mkdir /opt && cd /opt && \
  wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && \
  rm -rf ${OPENCV_VERSION}.zip

RUN mkdir -p /opt/opencv-${OPENCV_VERSION}/build && \
  cd /opt/opencv-${OPENCV_VERSION}/build && \
  cmake \
  -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D WITH_FFMPEG=NO \
  -D WITH_IPP=NO \
  -D WITH_OPENEXR=NO \
  -D WITH_TBB=YES \
  -D BUILD_EXAMPLES=NO \
  -D BUILD_ANDROID_EXAMPLES=NO \
  -D INSTALL_PYTHON_EXAMPLES=NO \
  -D BUILD_DOCS=NO \
  -D BUILD_opencv_python2=NO \
  -D BUILD_opencv_python3=ON \
  -D PYTHON3_EXECUTABLE=/usr/local/bin/python \
  -D PYTHON3_INCLUDE_DIR=/usr/local/include/python3.6m/ \
  -D PYTHON3_LIBRARY=/usr/local/lib/libpython3.so \
  -D PYTHON_LIBRARY=/usr/local/lib/libpython3.so \
  -D PYTHON3_PACKAGES_PATH=/usr/local/lib/python3.6/site-packages/ \
  -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/local/lib/python3.6/site-packages/numpy/core/include/ \
  .. && \
  make VERBOSE=1 && \
  make && \
  make install && \
  rm -rf /opt/opencv-${OPENCV_VERSION}

RUN pip install -U pip

RUN pip install numpy
RUN pip install scipy
RUN pip install scikit-learn
RUN pip install pandas
RUN pip install spacy
RUN pip install spacy_cld
RUN apk add qt-dev
RUN pip install git+https://github.com/skvark/opencv-python.git
ADD requirements.txt /pydata/


RUN echo "|--> Updating" \
    && echo "|--> Install PyTorch" \
    && git clone --recursive https://github.com/pytorch/pytorch \
    && cd pytorch && python setup.py install \
    && echo "|--> Install Torch Vision" \
    && git clone --recursive https://github.com/pytorch/vision \
    && cd vision && python setup.py install \
    && echo "|--> Cleaning" \
    && rm -rf /pytorch 


RUN pip install -r /pydata/requirements.txt

