#!/bin/bash -x
#java -Xms${java_memory_min} -Xmx${java_memory_max} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar patina.jar
set -e
DISABLE_LAUNCHER=${DISABLE_LAUNCHER:-false}
VELOCITY_URL=${VELOCITY_URL:-"https://api.papermc.io/v2/projects/velocity/versions/3.1.2-SNAPSHOT/builds/161/downloads/velocity-3.1.2-SNAPSHOT-161.jar"}
cp -r /app/* /pv && rm /app/velocity.jar
cd /pv
if [ "${DISABLE_LAUNCHER}" == "true" ]; then 
    curl -o velocity.jar ${VELOCITY_URL}
fi
exec java -jar velocity.jar $@