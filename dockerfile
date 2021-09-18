FROM openjdk:8

#######################################################################################################
# Select kafka version: https://kafka.apache.org/downloads
# and jmx exporter version: https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/
#######################################################################################################
ENV KAFKA_VERSION=kafka_2.12-0.11.0.3
ENV JMX_VERSION=0.16.1

# Setup Kafka
ARG KAFKA_VERSION=kafka_2.12-0.11.0.3
ADD https://archive.apache.org/dist/kafka/0.11.0.3/${KAFKA_VERSION}.tgz .
RUN tar -xzf ${KAFKA_VERSION}.tgz
RUN rm ${KAFKA_VERSION}.tgz

# Setup JMX
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_VERSION}/jmx_prometheus_javaagent-${JMX_VERSION}.jar /${KAFKA_VERSION}/
ADD https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/kafka-0-8-2.yml /${KAFKA_VERSION}/prometheus-config.yml

WORKDIR /${KAFKA_VERSION}
EXPOSE 7071

ENTRYPOINT /${KAFKA_VERSION}/bin/zookeeper-server-start.sh /${KAFKA_VERSION}/config/zookeeper.properties & KAFKA_OPTS="$KAFKA_OPTS -javaagent:/${KAFKA_VERSION}/jmx_prometheus_javaagent-${JMX_VERSION}.jar=7071:/${KAFKA_VERSION}/prometheus-config.yml" /${KAFKA_VERSION}/bin/kafka-server-start.sh /${KAFKA_VERSION}/config/server.properties
