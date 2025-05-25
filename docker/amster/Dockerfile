FROM allinformatix/amster:7.5.1

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV APT_OPTS="--no-install-recommends --yes"

# Installiere Python, pip und requests
RUN apt-get update \
    && apt-get install $APT_OPTS openldap-utils jq inotify-tools python3 python3-pip curl \
    && pip3 install requests \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

USER forgerock

ENV SERVER_URI /am

ARG CONFIG_PROFILE=allinformatix-gidp
RUN echo "\033[0;36m*** Building '${CONFIG_PROFILE}' profile ***\033[0m"

COPY --chown=forgerock:root config-profiles/${CONFIG_PROFILE}/ /opt/amster
COPY --chown=forgerock:root scripts /opt/amster

# Erlaube Schreibrechte für Amster-Shell-Logs und -Prefs
RUN chmod 777 /opt/amster

ENTRYPOINT [ "/opt/amster/docker-entrypoint.sh" ]