FROM java:8-alpine
MAINTAINER Benny Gaechter <benny.gaechter@gmail.com>

# The Scala 2.12 build is currently recommended by the project.
ENV KAFKA_VERSION=0.11.0.0 KAFKA_SCALA_VERSION=2.12 JMX_PORT=7203
ENV KAFKA_RELEASE_ARCHIVE kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN mkdir /kafka /data /logs && \
	apk update && \
	apk add --no-cache ca-certificates busybox-suid bash wget dpkg-dev gpgme

# Download Kafka binary distribution
ADD http://www.us.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE} /tmp/
ADD https://dist.apache.org/repos/dist/release/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE}.md5 /tmp/

WORKDIR /tmp

# Check artifact digest integrity
RUN echo VERIFY CHECKSUM: && \
  gpg --print-md MD5 ${KAFKA_RELEASE_ARCHIVE} 2>/dev/null && \
  cat ${KAFKA_RELEASE_ARCHIVE}.md5

# Install Kafka to /kafka
RUN tar -zx -C /kafka -f ${KAFKA_RELEASE_ARCHIVE} && \
  rm -rf kafka_*

ADD config /kafka/config
ADD start.sh /start.sh

# Set up a user to run Kafka
RUN addgroup -S kafka && \ 
  adduser -S -h /kafka -G kafka kafka && \
  chown -R kafka:kafka /kafka /data /logs
USER kafka
ENV PATH /kafka/bin:$PATH
WORKDIR /kafka

# broker, jmx
EXPOSE 9092 ${JMX_PORT}
VOLUME [ "/data", "/logs" ]

CMD ["/start.sh"]

