FROM netflixoss/exhibitor:1.5.2

USER root

RUN apt-get update && \
    apt-get install -y curl awscli

ADD run-exhibitor.sh /exhibitor
ADD exhibitor.properties /exhibitor

ENTRYPOINT ["./run-exhibitor.sh"]
