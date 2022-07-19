FROM redhat/ubi8 as velocity_build
ARG GIT_TOKEN=
ARG VELOCITY_PATCHED_REPO=github.com/PaperMC/Velocity.git
ARG VELOCITY_PATCHED_BRANCH=dev/3.0.0
RUN dnf install -y java-17-openjdk-devel git
RUN chmod 777 /tmp
RUN git clone --branch ${VELOCITY_PATCHED_BRANCH} https://docker:${GIT_TOKEN}@${VELOCITY_PATCHED_REPO} build
WORKDIR /build
COPY Velocity.patch .
RUN git config --global user.name "docker" \
    && git config --global user.email "docker@not.exits" \
    && git am Velocity.patch \
    && ./gradlew assemble
FROM redhat/ubi8
RUN \
  groupadd -g 1001 velocity && \
  useradd -mu 1001 -g velocity velocity
RUN chmod 777 /tmp
RUN dnf install -y java-17-openjdk
COPY --chown=1001:1001 docker-entrypoint.sh /
WORKDIR  /app
ARG VELOCITY_URL=https://api.papermc.io/v2/projects/velocity/versions/3.1.2-SNAPSHOT/builds/161/downloads/velocity-3.1.2-SNAPSHOT-161.jar
ARG MASTER_JAR_URL=https://multipaper.io/api/v2/projects/multipaper/versions/1.18.2/builds/95/downloads/MultiPaper-Master-2.8.8-all.jar
ARG DISABLE_LAUNCHER=false
COPY --from=velocity_build /build/proxy/build/libs/velocity-*-SNAPSHOT-all.jar velocity.jar
COPY velocity.toml .
COPY forwarding.secret .
RUN  if [ "${DISABLE_LAUNCHER}" == "true" ]; then \
  curl -o velocity.jar https://api.papermc.io/v2/projects/velocity/versions/3.1.2-SNAPSHOT/builds/161/downloads/velocity-3.1.2-SNAPSHOT-161.jar ;\
  fi && \
  mkdir plugins && \
  curl -o plugins/MultiPaper-Master.jar ${MASTER_JAR_URL} && \
  mkdir /pv && \
  chown 1001:1001 -R ./ /pv/
WORKDIR /pv
USER velocity
EXPOSE 25565
EXPOSE 35353
ENTRYPOINT ["/docker-entrypoint.sh"]