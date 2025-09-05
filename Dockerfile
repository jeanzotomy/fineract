# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.

# Apache Fineract Dockerfile for AKS deployment
# This Dockerfile packages a pre-built Fineract JAR file for deployment
FROM azul/zulu-openjdk-alpine:21

# Set maintainer label
LABEL maintainer="Aleksandar Vidakovic <aleks@apache.org>"

# Create app directory and plugins directory
# Note: The nogroup group and nobody user already exist in Alpine Linux
RUN mkdir -p /app/plugins

# Set working directory
WORKDIR /app

# Copy the built jar - this should be built prior to Docker build
# For example: ./gradlew clean bootJar
COPY fineract-provider/build/libs/fineract-provider-*.jar /app/fineract-provider.jar

# Set user to nobody for security
USER nobody:nogroup

# Expose ports for HTTP and HTTPS
EXPOSE 8080 8443

# Set environment variables and JVM options
ENV JAVA_TOOL_OPTIONS="-Duser.home=/tmp -Dfile.encoding=UTF-8 -Duser.timezone=UTC -Djava.security.egd=file:/dev/./urandom"

# Set the entry point with plugin support
# Note: JDBC drivers should be provided via external mounts or init containers in K8s
ENTRYPOINT ["java", "-Dloader.path=/app/plugins/", "-jar", "/app/fineract-provider.jar"]