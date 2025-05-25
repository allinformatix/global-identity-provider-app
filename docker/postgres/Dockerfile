FROM postgres:16

# Füge eigene SQL-Initialisierungen hinzu
COPY initdb/ /docker-entrypoint-initdb.d/

# Optional: eigene postgresql.conf überschreiben (nicht empfohlen für einfache Setups)
# COPY config/postgresql.conf /etc/postgresql/postgresql.conf
