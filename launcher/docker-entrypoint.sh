#!/bin/bash -x
#java -Xms${java_memory_min} -Xmx${java_memory_max} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar patina.jar
set -e
if [ ! -e updates/Launcher.exe ] || [ ! -e updates/Launcher.exe ] \
    || [ ! -e /app/shared/ServerWrapper.jar ] || [ ! -e /app/shared/token.txt]
then
    ./start.sh < init.stdin > init.stdout
    cp /app/src/ServerWrapper/build/libs/ServerWrapper.jar /app/shared/ServerWrapper.jar
    grep "Server token .* authId .*: .*\..*\..*" init.stdout | awk 'FS=" " { printf "%s: %s\n", $6, $9 }' > /app/shared/token.txt
fi
exec ./start.sh