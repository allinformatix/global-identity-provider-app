FROM allinformatix/ds-empty:7.5.1

USER 0

COPY debian-buster-sources.list /etc/apt/sources.list

RUN apt-get update -y && apt-get install -y curl

USER 11111

COPY --chown=forgerock:root *.sh /opt/opendj
RUN chmod +x /opt/opendj/*.sh

COPY --chown=forgerock:root *.ldif /opt/opendj

ENTRYPOINT /opt/opendj/start.sh
