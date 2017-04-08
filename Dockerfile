FROM alpine:3.5

################################################################################
# 1. SETUP GLIBC
#
################################################################################
# blatantly stolen from: https://github.com/frol/docker-alpine-glibc
#   Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
################################################################################
ENV LANG=C.UTF-8

RUN \
  ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
  ALPINE_GLIBC_PACKAGE_VERSION="2.25-r0" && \
  ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  apk add --no-cache --virtual=.build-dependencies wget ca-certificates py-pip && \
  wget \
      "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
      -O "/etc/apk/keys/sgerrand.rsa.pub" && \
  wget \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
  apk add --no-cache \
      "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
  \
  rm "/etc/apk/keys/sgerrand.rsa.pub" && \
  /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
  echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
  \
  apk del glibc-i18n && \
  \
  rm "/root/.wget-hsts" && \
  rm \
      "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \

################################################################################
# 2. SETUP h2o.ai
# https://github.com/h2oai/h2o-3/blob/master/Dockerfile
################################################################################
  mkdir /opt && \
  /usr/bin/wget --no-check-certificate $(wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -qO -) -O /opt/h2o.zip && \
  unzip -d /opt /opt/h2o.zip && \
  rm /opt/h2o.zip && \
  cd $(dirname $(find /opt -name h2o.jar -print)) && \
  cp h2o.jar /opt && \
  /usr/bin/pip install `find . -name "*.whl"` && \
  wget https://raw.githubusercontent.com/h2oai/h2o-3/master/docker/start-h2o-docker.sh && \

# Get Content
  wget http://s3.amazonaws.com/h2o-training/mnist/train.csv.gz && \
  gunzip train.csv.gz && \
  /usr/bin/wget --no-check-certificate https://raw.githubusercontent.com/laurendiperna/Churn_Scripts/master/Extraction_Script.py  && \
  /usr/bin/wget --no-check-certificate https://raw.githubusercontent.com/laurendiperna/Churn_Scripts/master/Transformation_Script.py && \
  /usr/bin/wget --no-check-certificate https://raw.githubusercontent.com/laurendiperna/Churn_Scripts/master/Modeling_Script.py && \

  apk del .build-dependencies
