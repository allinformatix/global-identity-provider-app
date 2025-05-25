FROM allinformatix/ig:2025.3.0

# Apt aktivieren und curl installieren
COPY debian-buster-sources.list /etc/apt/sources.list
USER root
RUN apt-get update && apt-get install -y curl jq && rm -rf /var/lib/apt/lists/*

# IG-Konfiguration kopieren
ARG CONFIG_PROFILE=allinformatix-gidp
RUN echo "\033[0;36m*** Building '${CONFIG_PROFILE}' profile ***\033[0m"
COPY --chown=forgerock:root config-profiles/${CONFIG_PROFILE}/ /var/ig
COPY --chown=forgerock:root . /var/ig

# Fetcher-Skripte hinzufügen (z. B. nach /opt/scripts)
COPY fetchers/fetch-all-azure.sh /opt/scripts/fetch-all-azure.sh
RUN chmod +x /opt/scripts/fetch-all-azure.sh

USER forgerock
