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
ENV NODE_DEBUG sl

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
    g++ \
    git

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

RUN npm install https://sl-repo-dev.s3.amazonaws.com/sl-otel-agent-0.3.2.tgz
RUN npm install https://sl-repo-dev.s3.amazonaws.com/slnodejs-1.0.4.tgz

ENV SL_useOtelAgentInReporter=1
ENV SL_useOtelAgent=1

RUN if [[ $IS_PR -eq 0 ]]; then \
    echo "Check-in to repo"; \
    BUILD_NAME=$(date +%F_%T) && ./node_modules/.bin/slnodejs config --token $RM_DEV_SL_TOKEN --appname "currencyservice" --branch "master" --build "${BUILD_NAME}" ; \
else \ 
    echo "Pull request"; \
    BUILD_NAME=$(date +%F_%T) && ./node_modules/.bin/slnodejs prConfig --token $RM_DEV_SL_TOKEN --appname "currencyservice" --targetBranch "${TARGET_BRANCH}" \
    --latestCommit "${LATEST_COMMIT}" --pullRequestNumber "${PR_NUMBER}" --repositoryUrl "${TARGET_REPO_URL}"; \
fi

RUN ./node_modules/.bin/slnodejs build --token $RM_DEV_SL_TOKEN --buildsessionidfile buildSessionId --workspacepath "." --scm git --es6Modules

RUN ./node_modules/.bin/slnodejs mocha --token $RM_DEV_SL_TOKEN --buildsessionidfile buildSessionId --failbuild true --teststage "Unit Tests" -- --recursive test

EXPOSE 7000

ENTRYPOINT ./node_modules/.bin/slnodejs run --token $RM_DEV_SL_TOKEN --buildsessionidfile buildSessionId --labid integ_master_813e_SLBoutique -- server.js

