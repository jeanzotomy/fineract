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
RUN mkdir -p /app/plugins && \
    addgroup -g 65534 nogroup && \
    adduser -u 65534 -G nogroup -s /bin/sh -D nobody

# Set working directory
WORKDIR /app

# Copy the built jar - this should be built prior to Docker build
# For example: ./gradlew clean bootJar
COPY fineract-provider/build/libs/fineract-provider-*.jar /app/fineract-provider.jar

# Download JDBC drivers for database connectivity
RUN wget -O /app/mariadb-java-client.jar https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.2/mariadb-java-client-3.5.2.jar && \
    wget -O /app/postgresql.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.4/postgresql-42.7.4.jar

# Set user to nobody for security
USER nobody:nogroup

# Expose ports for HTTP and HTTPS
EXPOSE 8080 8443

# Set environment variables and JVM options
ENV JAVA_TOOL_OPTIONS="-Duser.home=/tmp -Dfile.encoding=UTF-8 -Duser.timezone=UTC -Djava.security.egd=file:/dev/./urandom"

# Set the entry point with plugin support and JDBC drivers in classpath
ENTRYPOINT ["java", "-Dloader.path=/app/plugins/,/app/mariadb-java-client.jar,/app/postgresql.jar", "-jar", "/app/fineract-provider.jar"]