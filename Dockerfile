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
ENV RM_DEV_SL_TOKEN ${RM_DEV_SL_TOKEN}

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

RUN npm install https://sl-repo-dev.s3.amazonaws.com/sl-otel-agent-0.3.2.tgz
RUN npm install https://sl-repo-dev.s3.amazonaws.com/slnodejs-1.0.4.tgz

ENV SL_useOtelAgentInReporter=1

RUN BUILD_NAME=$(date +%F_%T) && ./node_modules/.bin/slnodejs config --token $RM_DEV_SL_TOKEN --appname "currencyservice" --branch "master" --build "${BUILD_NAME}"

RUN ./node_modules/.bin/slnodejs build --token $RM_DEV_SL_TOKEN --buildsessionidfile buildSessionId --workspacepath "." --scm none --es6Modules

RUN ./node_modules/.bin/slnodejs mocha --token $RM_DEV_SL_TOKEN --buildsessionidfile buildSessionId --failbuild true --teststage "Unit Tests" --useslnode2 -- --recursive test

EXPOSE 7000

ENTRYPOINT ./node_modules/.bin/slnodejs run --token $RM_DEV_SL_TOKEN --buildsessionidfile buildSessionId --labid integ_master_813e_SLBoutique -- --require ./tracing.js server.js
