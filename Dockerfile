# Use an official SQL Server runtime as a parent image
FROM mcr.microsoft.com/mssql/server:2019-GA-ubuntu-16.04

# Set environment variables for SQL server
ENV ACCEPT_EULA "Y"
ENV SA_PASSWORD "p@ssw0rd"
ENV MSSQL_PID "Standard"
ENV MSSQL_BACKUP_DIR "/sqlbackups"

# Install Samba for integration test linking
USER root
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        samba \
        supervisor \
    && rm -rf /var/lib/apt/lists/*

# Configure Samba shared directory
COPY smb.conf /etc/samba/smb.conf
RUN mkdir -p /sqlbackups && chmod 777 /sqlbackups && chmod 644 /etc/samba/smb.conf

# Expose SMB ports
EXPOSE 137/udp 138/udp 139 445

# Configure supervisor to run SQL and Samba
COPY supervisor.d/*.conf /etc/supervisor/conf.d/
RUN mkdir -p /var/log/supervisor && chmod 644 /etc/supervisor/conf.d/*.conf

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
