FROM python:3.6.5-alpine3.7

RUN apk add --update make
RUN apk add --no-cache curl

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN apk --no-cache add musl-dev
RUN apk add g++
RUN apk add gcc

RUN apk --update add libxml2-dev libxslt-dev libffi-dev gcc musl-dev libgcc curl
RUN apk add jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev



RUN apk add gcc gfortran build-base wget freetype-dev libpng-dev openblas-dev

ADD requirements.txt /pydata/

RUN pip install -U pip

RUN pip install numpy==1.15.1
RUN pip install scipy==1.1.0
RUN pip install scikit-learn==0.19.2
RUN pip install pandas
RUN pip install spacy
RUN pip install spacy_cld


RUN pip install -r /pydata/requirements.txt

