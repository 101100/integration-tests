# Use an official Python runtime as a parent image
FROM microsoft/mssql-server-linux:2017-latest

# Set environment variables for SQL server
ENV ACCEPT_EULA "Y"
ENV SA_PASSWORD "p@ssw0rd"

# Install Samba for integration test linking
RUN apt-get update && apt-get install -y \
    samba \
    supervisor

# Configure Samba shared directory
RUN mkdir -p /temp
RUN chmod 777 /temp
COPY smb.conf /etc/samba/smb.conf

# Expose SMB ports
EXPOSE 137/udp 138/udp 139 445

# Configure supervisor to run SQL and Samba
RUN mkdir -p /var/log/supervisord
COPY supervisor.d/*.conf /etc/supervisor/conf.d/

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]

