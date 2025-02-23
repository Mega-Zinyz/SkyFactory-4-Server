FROM openjdk:8-jre-slim

# Set working directory (Railway volume mount point)
WORKDIR /data

# Copy server setup files to a temporary directory
COPY . /server-setup/

# Ensure scripts are executable
RUN chmod +x /server-setup/Install.sh /server-setup/ServerStart.sh

# Expose Minecraft server port
EXPOSE 25565

# Ensure necessary files exist in the volume, then start the server
CMD ["/bin/sh", "-c", "mkdir -p /data && cp -rn /server-setup/* /data/ && chmod +x /data/*.sh /data/*.jar && chmod 777 /data/forge-1.12.2-14.23.5.2860.jar && cd /data && ./ServerStart.sh"]
