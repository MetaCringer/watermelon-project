FROM redhat/ubi8
RUN \
  groupadd -g 1001 velocity && \
  useradd -mu 1001 -g velocity velocity
RUN chmod 777 /tmp
RUN dnf install -y java-17-openjdk
COPY --chown=1001:1001 docker-entrypoint.sh /
WORKDIR  /app

COPY velocity*.jar velocity.jar
COPY velocity.toml .
ARG master_jar_url=https://multipaper.io/api/v2/projects/multipaper/versions/1.18.2/builds/70/downloads/MultiPaper-Master-2.8.4-all.jar
RUN  \
  mkdir plugins && \
  curl -o plugins/MultiPaper-Master.jar ${master_jar_url} && \
  mkdir /pv && \
  chown 1001:1001 -R ./ /pv/
WORKDIR /pv
USER velocity
EXPOSE 25565
EXPOSE 35353
ENTRYPOINT ["/docker-entrypoint.sh"]