FROM redhat/ubi8
RUN \
  groupadd -g 1001 paper && \
  useradd -mu 1001 -g paper paper && \
  chmod 777 /tmp && \
  dnf install -y java-17-openjdk 
COPY --chown=1001:1001 docker-entrypoint.sh /
WORKDIR /app
COPY config/ ./
ARG slave_jar_url=https://multipaper.io/api/v2/projects/multipaper/versions/1.18.2/builds/70/downloads/multipaper-1.18.2-70.jar
RUN  \
  curl -o multipaper.jar ${slave_jar_url} && \
  mkdir /pv && \
  chown 1001:1001 -R ./ /pv/
USER paper
EXPOSE 25565
ENV server_name=slave#null
ENV master_address=master

ENTRYPOINT ["/docker-entrypoint.sh"]