FROM ubuntu

RUN apt-get update && \
    apt-get install ansible -y && \
    apt-get install unzip -y && \
    apt-get install sshpass -y

RUN ansible-galaxy collection install grafana.grafana

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]