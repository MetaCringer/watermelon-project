#!/bin/bash -x
#java -Xms${java_memory_min} -Xmx${java_memory_max} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar patina.jar
set -e
WAIT_TIME=${WAIT_TIME:-10}
WAIT_INIT_LAUNCHSERVER=${WAIT_INIT_LAUNCHSERVER:-2}
WAIT_DOWNLOADING_MINECRAFT_CACHE=${WAIT_DOWNLOADING_MINECRAFT_CACHE:-30}
SERVER_CORE=${SERVER_CORE:-multipaper.jar}
ONLINE_MODE=${ONLINE_MODE:-true}
DISABLE_LAUNCHER=${DISABLE_LAUNCHER:-false}
cp -r /app/* /pv && rm /app/${SERVER_CORE}
cd /pv
if [ "${DISABLE_LAUNCHER}" == "false" ]; then
    if [ ! -e ServerWrapper.jar ]; then 
        until [ -f /app/shared/ServerWrapper.jar ]
        do
            sleep ${WAIT_TIME}
        done
        cp /app/shared/ServerWrapper.jar .
    fi
    if [ ! -e ServerWrapperConfig.json ]; then
        echo "${SERVER_CORE}" > input.stdin
        echo ${server_name} >> input.stdin
        echo "${LAUNCHSERVER_WEB_SOKET}" >> input.stdin
        until [ -f /app/shared/token.txt ]
        do
            sleep ${WAIT_TIME}
        done
        awk "BEGIN{ FS=\": \" } \$1==\"${LAUNCHER_PROFILE:-1.18.2-fabric}\" { printf \"%s\n\", \$2 }" /app/shared/token.txt >> input.stdin
        sleep ${WAIT_INIT_LAUNCHSERVER}
        java -jar ServerWrapper.jar setup < input.stdin
        set +e
        timeout ${WAIT_DOWNLOADING_MINECRAFT_CACHE} java -jar ${SERVER_CORE}
        set -e
        java -jar ServerWrapper.jar installAuthlib ${AUTHLIB_URL}
    fi
fi
exec java \
    -DbungeecordName=${server_name} \
    -Dserver.address=${server_name} \
    -DmultipaperMasterAddress=${master_address}:35353 \
    -Dproperties.online-mode=${ONLINE_MODE} \
    -Dpaper.settings.velocity-support.secret=${velocity_secret} \
    -jar \
    $(if [ "${DISABLE_LAUNCHER}" == "false" ] ; then echo ServerWrapper.jar ; else echo ${SERVER_CORE} ; fi) \
    $@