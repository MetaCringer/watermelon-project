FROM redhat/ubi8
RUN \
  groupadd -g 1001 paper && \
  useradd -mu 1001 -g paper paper && \
  chmod 777 /tmp && \
  dnf install -y java-17-openjdk 
COPY --chown=1001:1001 docker-entrypoint.sh /
WORKDIR /app
COPY config/ ./
ARG slave_jar_url=https://multipaper.io/api/v2/projects/multipaper/versions/1.18.2/builds/95/downloads/multipaper-1.18.2-95.jar
RUN  \
  curl -o multipaper.jar ${slave_jar_url} && \
  mkdir /pv && \
  chown 1001:1001 -R ./ /pv/
USER paper
WORKDIR /pv
EXPOSE 25565
ENV server_name=slave#null
ENV master_address=master
ENV AUTHLIB_URL=https://mirror.gravit.pro/compat/authlib/5.2.9/3/LauncherAuthlib3.jar
ENTRYPOINT ["/docker-entrypoint.sh"]