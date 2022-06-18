#!/bin/bash -x
#java -Xms${java_memory_min} -Xmx${java_memory_max} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar patina.jar
set -e
cp -r /app/* /pv && rm /app/multipaper.jar
cd /pv
exec java \
    -DbungeecordName=${server_name} \
    -Dserver.address=${server_name} \
    -DmultipaperMasterAddress=${master_address}:35353 \
    -Dproperties.online-mode=false \
    -Dpaper.settings.velocity-support.secret=${velocity_secret} \
    -jar multipaper.jar $@