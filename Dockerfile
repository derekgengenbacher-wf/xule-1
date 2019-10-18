FROM python:3.6 as build

ARG PIP_INDEX_URL
ARG NPM_CONFIG__AUTH
ARG NPM_CONFIG_REGISTRY=https://workivaeast.jfrog.io/workivaeast/api/npm/npm-prod/
ARG NPM_CONFIG_ALWAYS_AUTH=true
ARG GIT_TAG

WORKDIR /build/
ADD . /build/

# Assemble xule  plugin files
RUN mkdir /build/xule/
RUN mkdir /build/xule/rulesets/
RUN cp -r /build/plugin/xule/ /build/
RUN mv /build/xule/rulesetMap.json /build/xule/xuleRulesetMap.json

# Assemble xule config files
RUN cp -r /build/dqc_us_rules/resources/ /build/xule/resources/
RUN rm -r /build/xule/resources/META-INF

# Assemble xule rule sets
WORKDIR /build/dqc_us_rules/
RUN cp `find -name \*.zip` /build/xule/rulesets/
WORKDIR /build/
RUN rm -r /build/xule/rulesets/resources.zip

# pypi package creation
# The following command replaces the @VERSION@ string in setup.py with the tagged version number from GIT_TAG
RUN sed -i s/@VERSION@/$GIT_TAG/ setup.py
ARG BUILD_ARTIFACTS_PYPI=/build/dist/*.tar.gz
RUN python setup.py sdist

ARG BUILD_ARTIFACTS_AUDIT=/audit/*
RUN mkdir /audit/
RUN pip freeze > /audit/pip.lock

FROM scratch
