FROM redhat/ubi8 as builder
COPY docker-entrypoint.sh /
WORKDIR /app
COPY setup-master.sh ./ 
RUN dnf install -y java-17-openjdk-devel git unzip
ARG JMODS_RPM_URL=https://dl.rockylinux.org/pub/rocky/8/AppStream/x86_64/os/Packages/j/java-17-openjdk-jmods-17.0.3.0.7-2.el8_6.x86_64.rpm
ARG OPENJFX_JMOD_URL=https://download2.gluonhq.com/openjfx/17.0.2/openjfx-17.0.2_linux-x64_bin-jmods.zip
RUN curl -o jmods.rpm ${JMODS_RPM_URL} \
  && rpm -i jmods.rpm \
  && rm jmods.rpm \
  && curl -o openjfx.zip ${OPENJFX_JMOD_URL} \
  && unzip openjfx.zip \
  && mv javafx-jmods-17.0.2/* /usr/lib/jvm/java-17-openjdk/jmods/ \
  && rmdir javafx-jmods-17.0.2 \
  && rm -f openjfx.zip
RUN ./setup-master.sh && \
  cp ./src/modules/AdditionalHash_module/build/libs/AdditionalHash_module.jar ./modules/
COPY app/ ./
ARG GIT_TOKEN=
ARG ASSETS_REPO=github.com/MetaCringer/launcher-assets.git
ARG ASSETS_BRANCH=main
RUN git clone --branch ${ASSETS_BRANCH} https://docker:${GIT_TOKEN}@${ASSETS_REPO} temp \
  && rm -rf temp/.git \
  && cp -r temp/* . \
  && rm -rf temp \
  && echo "build" > init.stdin \
  && cat cmd.stdin >> init.stdin \
  && echo "stop" >> init.stdin
EXPOSE 9274
ENTRYPOINT ["/docker-entrypoint.sh"]



