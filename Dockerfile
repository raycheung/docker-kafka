FROM openjdk:8-alpine
LABEL maintainer="Ray Cheung <dev@masking.work>"

ENV KAFKA_VERSION=1.1.0 KAFKA_SCALA_VERSION=2.12 JMX_PORT=7203
ENV KAFKA_RELEASE_ARCHIVE kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN mkdir /kafka /data

ADD http://www-us.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE} /tmp/
ADD https://dist.apache.org/repos/dist/release/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE}.md5 /tmp/

WORKDIR /tmp

RUN apk add --no-cache gnupg

RUN echo VERIFY CHECKSUM: && \
  gpg --print-md MD5 ${KAFKA_RELEASE_ARCHIVE} 2>/dev/null && \
  cat ${KAFKA_RELEASE_ARCHIVE}.md5 && \
  tar -zx -C /kafka --strip-components=1 -f ${KAFKA_RELEASE_ARCHIVE} && \
  rm -rf kafka_* && \
  find /kafka/bin -type f -exec \
  sed -i 's/#!\/bin\/bash/#!\/bin\/sh/g' {} +

ADD config /kafka/config
ADD start.sh /start.sh

ENV PATH /kafka/bin:$PATH
WORKDIR /kafka

EXPOSE 9092 ${JMX_PORT}
VOLUME [ "/data", "/kafka/logs" ]

CMD ["/start.sh"]
