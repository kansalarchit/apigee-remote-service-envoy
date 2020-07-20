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

# Keep Dockerfile* files in sync!

# use following to build using Go with Boring Crypto:
# --build-arg CGO_ENABLED=1
# --build-arg GO_CONTAINER=goboring/golang:1.14.4b4

# Build binary in golang container
ARG GO_CONTAINER=golang:1.14
FROM ${GO_CONTAINER} as builder

ARG CGO_ENABLED=0

WORKDIR /app
ADD . .

# Build service (-ldflags '-s -w' strips debugger info)
RUN go mod download
RUN CGO_ENABLED=$CGO_ENABLED go build -a -ldflags '-s -w' -o apigee-remote-service-envoy .

# Build runtime container
FROM scratch

# Add certs
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Add service
COPY --from=builder /app/apigee-remote-service-envoy .

# Run
ENTRYPOINT ["/apigee-remote-service-envoy"]
EXPOSE 5000/tcp 5001/tcp
