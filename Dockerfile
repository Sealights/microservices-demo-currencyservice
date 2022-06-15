# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM node:16-alpine as base

ARG RM_DEV_SL_TOKEN=local
ARG IS_PR=""
ARG TARGET_BRANCH=""
ARG LATEST_COMMIT=""
ARG PR_NUMBER=""
ARG TARGET_REPO_URL=""

ENV RM_DEV_SL_TOKEN ${RM_DEV_SL_TOKEN}
ENV IS_PR ${IS_PR}
ENV TARGET_BRANCH ${TARGET_BRANCH}
ENV LATEST_COMMIT ${LATEST_COMMIT}
ENV PR_NUMBER ${PR_NUMBER}
ENV TARGET_REPO_URL ${TARGET_REPO_URL}

RUN echo "========================================================="
RUN echo "targetBranch: ${TARGET_BRANCH}"
RUN echo "latestCommit: ${LATEST_COMMIT}"
RUN echo "pullRequestNumber ${PR_NUMBER}"
RUN echo "repositoryUrl ${TARGET_REPO_URL}"
RUN echo "========================================================="


FROM base as builder

# Some packages (e.g. @google-cloud/profiler) require additional
# deps for post-install scripts
RUN apk add --update --no-cache \
    python3 \
    make \
    g++

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --only=production

FROM base

RUN GRPC_HEALTH_PROBE_VERSION=v0.4.7 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules

COPY . .

RUN npm install http://sl-repo-dev.s3.amazonaws.com/sl-otel-0.2.9.tgz
RUN npm install http://sl-repo-dev.s3.amazonaws.com/slnodejs-otel-1.0.4.tgz

ENV SL_useOtelAgent=true
ENV OTEL_AGENT_TEST_STAGE="Unit Tests"
ENV OTEL_AGENT_COLLECTOR_PATH=grpc://ingest.risk-management.dev.sealights.co:443

ENV OTEL_AGENT_ENVIRONMENT_TYPE=production 
ENV OTEL_AGENT_SERVICE_NAME=currencyservice
ENV OTEL_AGENT_AUTH_TOKEN=$RM_DEV_SL_TOKEN 
ENV OTEL_AGENT_SECURE_CONNECTION=1

#ENV BUILD_NAME=$(date +%F_%T)
#RUN export BUILD_NAME=$(date +%F_%T)
#RUN echo "$(date +%F_%T)"
RUN BUILD_NAME=$(date +%F_%T) && echo "BUILD NAME: ${BUILD_NAME}"

#RUN if [[ $IS_PR -eq 0 ]]; then \
#    echo "Check-in to repo"; \
#    BUILD_NAME=$(date +%F_%T) && ./node_modules/.bin/slnodejs Config --token $RM_DEV_SL_TOKEN --appname "currencyservice" --branch "master" --build "${BUILD_NAME}"; \
#else \ 
#    echo "Pull request"; \
#    BUILD_NAME=$(date +%F_%T) && ./node_modules/.bin/slnodejs prConfig --token $RM_DEV_SL_TOKEN --appname "currencyservice" --targetBranch "${TARGET_BRANCH}" \
#    --latestCommit "${LATEST_COMMIT}" --pullRequestNumber "${PR_NUMBER}" --repositoryUrl "${TARGET_REPO_URL}"; \
#fi

#RUN BUILD_NAME=$(date +%F_%T) && ./node_modules/.bin/slnodejs prConfig --token $RM_DEV_SL_TOKEN --appname "currencyservice" --targetBranch "master" \
#    --latestCommit "abc" --pullRequestNumber "1" --repositoryUrl "http";

#RUN ./node_modules/.bin/slnodejs Config --token $RM_DEV_SL_TOKEN --appname "currencyservice" --branch "master" --build "${BUILD_NAME}"
RUN BUILD_NAME=$(date +%F_%T) && ./node_modules/.bin/slnodejs config --token $RM_DEV_SL_TOKEN --appname "currencyservice" --branch "master" --build "abc"

#if
#RUN if (IS_PR) BUILD_NAME=$(date +%F_%T) && ./node_modules/.bin/slnodejs Config --token $RM_DEV_SL_TOKEN --appname "currencyservice" --branch "master" --build "${BUILD_NAME}"
#else
#RUN BUILD_NAME=$(date +%F_%T) && ./node_modules/.bin/slnodejs prConfig --token $RM_DEV_SL_TOKEN --appname "currencyservice" 
#    --targetBranch <targetBranch>            Target branch of the pull request
#  --latestCommit <latestCommit>            Head SHA of the pull request source
#  --pullRequestNumber <pullRequestNumber>  Pull request number
#  --repositoryUrl <repositoryUrl>          Repository url of the target branch
#  + WHETHER IS PR


RUN ./node_modules/.bin/slnodejs build --token $RM_DEV_SL_TOKEN --buildsessionidfile buildSessionId --workspacepath "." --scm none --es6Modules

RUN ./node_modules/.bin/slnodejs mocha --token $RM_DEV_SL_TOKEN --buildsessionidfile buildSessionId --failbuild true --teststage "Unit Tests" --useslnode2 -- --recursive test

EXPOSE 7000

ENTRYPOINT ./node_modules/.bin/slnodejs run --token $RM_DEV_SL_TOKEN --buildsessionidfile buildSessionId --labid integ_master_813e_SLBoutique -- --require ./tracing.js server.js
