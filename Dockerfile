FROM amazonlinux:2 as build

ENV PYTHON_VERSION=3.9.9

ARG PIP_INDEX_URL
ARG NPM_CONFIG__AUTH
ARG NPM_CONFIG_REGISTRY=https://workivaeast.jfrog.io/workivaeast/api/npm/npm-prod/
ARG NPM_CONFIG_ALWAYS_AUTH=true
ARG GIT_TAG

WORKDIR /build/
ADD . /build/

RUN yum install -y \
        gcc \
        openssl-devel \
        bzip2-devel \
        libffi-devel \
        wget \
        tar \
        gzip \
        make && \
    rm -rf /var/cache/yum && \
    # Download and install python manually
    # This is because the amazonlinux yum registry is currently pinning to python 3.7
    wget -nv https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make install && \
    rm -r ../Python-${PYTHON_VERSION} && \
    rm ../Python-${PYTHON_VERSION}.tgz

# Assemble xule  plugin files
RUN mkdir /build/xule/
RUN mkdir /build/xule/rulesets/
RUN cp -r /build/plugin/xule/ /build/
RUN mv /build/xule/rulesetMap.json /build/xule/xuleRulesetMap.json

# Assemble xule config files
RUN cp -r /build/dqc_us_rules/resources/ /build/xule/resources/
RUN rm -r /build/xule/resources/META-INF

# Assemble xule rule sets
RUN cp `find /build/dqc_us_rules/ -name \*.zip` /build/xule/rulesets/
RUN rm -r /build/xule/rulesets/resources.zip

# pypi package creation
# The following command replaces the @VERSION@ string in setup.py with the tagged version number from GIT_TAG
RUN sed -i s/@VERSION@/$GIT_TAG/ setup.py
ARG BUILD_ARTIFACTS_PYPI=/build/dist/*.tar.gz
RUN python3 setup.py sdist

ARG BUILD_ARTIFACTS_AUDIT=/audit/*
RUN mkdir /audit/
RUN pip3 freeze > /audit/pip.lock

FROM drydock-prod.workiva.net/workiva/wf_arelle:latest-release AS wf-arelle-test-consumption
USER root
ARG BUILD_ID
RUN yum update -y && \
    yum upgrade -y && \
    yum autoremove -y && \
    yum clean all && \
    rm -rf /var/cache/yum
COPY --from=build /build/dist/*.tar.gz /test.tar.gz
RUN pip3 install /test.tar.gz
USER nobody
