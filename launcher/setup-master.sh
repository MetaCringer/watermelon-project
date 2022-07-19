#!/bin/bash -e
REPO_LAUNCHER=${REPO_LAUNCHER:-https://github.com/MetaCringer/mcLauncher.git}
COMMIT_LAUNCHER=${COMMIT_LAUNCHER:-dev}
REPO_RUNTIME=${REPO_RUNTIME:-https://github.com/MetaCringer/LauncherRuntime.git}
COMMIT_RUNTIME=${COMMIT_RUNTIME:-master}
#COMMIT_MODULES=master

# INST_ROOT override root for install
if [[ -n $INST_ROOT ]]; then pushd $INST_ROOT; fi;


# Checks
set -e;
echo -e "\033[32mPhase 0: \033[33mChecking\033[m";
which java || ( echo -e "\033[31mCheck failed: java not found. May be install \033[32mapt-get install openjdk-17-jdk\033[m" && exit 1 );
which javac || ( echo -e "\033[31mCheck failed: java compiler not found. May be install \033[32mapt-get install openjdk-17-jdk\033[m" && exit 1 );
which git || ( echo -e "\033[31mCheck failed: git not found. May be install \033[32mapt-get install git\033[m" && exit -1 );
which curl || ( echo -e "\033[31mCheck failed: curl not found. May be install \033[32mapt-get install curl\033[m" && exit -1 );
(javac -version | grep " 17") || \
    ( echo -e "\033[31mCheck failed: javac version unknown. Supported 17+. May be install \033[32mapt-get install openjdk-17-jdk\033[m" && exit 1 );
which ldd || ( echo -e "\033[31mCheck failed: ldd not found. May be install \033[32mapt-get install libc-bin\033[m" && exit -1 );
# TODO: optionally install software (Arch, Debian, later Ubuntu)

# Clone repo
echo -e "\033[32mPhase 1: \033[33mClone main repository\033[m";
git clone -b $COMMIT_LAUNCHER  ${REPO_LAUNCHER} src;
pushd src;
sed -i 's/git@github.com:/https:\/\/github.com\//' .gitmodules;
git submodule sync;
git submodule update --init --recursive;
if [[ -n $COMMIT_MODULES ]]; then
    pushd modules;
    git checkout $COMMIT_MODULES;
    popd;
fi;
echo -e "\033[32mPhase 2: \033[33mBuild\033[m";
./gradlew -Dorg.gradle.daemon=false assemble || ( echo -e "\033[31mBuild failed. Stopping\033[m" && exit 101 );
popd;

# Clone runtime
echo -e "\033[32mPhase 3: \033[33mClone runtime repository\033[m";
git clone -b $COMMIT_RUNTIME ${REPO_RUNTIME} srcRuntime;
pushd srcRuntime;
./gradlew -Dorg.gradle.daemon=false assemble || ( echo -e "\033[31mBuild failed. Stopping\033[m" && exit 102 );
popd;

# Links
echo -e "\033[32mPhase 4: \033[33mLinks\033[m";
## LaunchServer
ln -s src/LaunchServer/build/libs/LaunchServer.jar .;
ln -s src/LaunchServer/build/libs/libraries .;
ln -s src/LaunchServer/build/libs/launcher-libraries .;
ln -s src/LaunchServer/build/libs/launcher-libraries-compile .;
chmod -R +x libraries/launch4j;
## Modules
mkdir modules;
#ln -s ../src/modules/LauncherModuleLoader_module/build/libs/LauncherModuleLoader_module.jar modules/;
ln -s srcRuntime/runtime .;
mkdir launcher-modules;
ln -s ../$(echo srcRuntime/build/libs/JavaRuntime*.jar) launcher-modules/;
## Compat
mkdir compat;
ln -s ../src/compat compat/core;
ln -s ../srcRuntime/compat compat/runtime;
ln -s ../src/ServerWrapper/build/libs/ServerWrapper.jar compat/;
ln -s ../src/LauncherAuthlib/build/libs/LauncherAuthlib.jar compat/;

# Generate scripts
## Start
echo -e "\033[32mPhase 5: \033[33mCreate start.sh, startscreen.sh, update.sh, client.sh\033[m";
echo "#!/bin/bash" > start.sh;
echo "java -javaagent:LaunchServer.jar -jar LaunchServer.jar;" >> start.sh;
echo "#!/bin/bash" > startscreen.sh;
echo "screen -S launchserver java -javaagent:LaunchServer.jar -jar LaunchServer.jar;" >> startscreen.sh;
## Update
echo "#!/bin/bash -e" > update.sh;
echo "pushd src || ( echo \"Directory src not found\" && exit 4);" >> update.sh;
echo "git reset --hard HEAD || ( echo \"git reset error\" && exit 6);" >> update.sh;
echo "git checkout $COMMIT_LAUNCHER;" >> update.sh;
echo "git pull;" >> update.sh;
echo "sed -i 's/git@github.com:/https:\/\/github.com\//' .gitmodules;" >> update.sh;
echo "git submodule sync;" >> update.sh;
echo "git submodule update --init --recursive;" >> update.sh;
if [[ -n $COMMIT_MODULES ]]; then
    echo "pushd modules;" >> update.sh;
    echo "git checkout $COMMIT_MODULES;" >> update.sh;
    echo "popd;" >> update.sh;
fi;
echo "./gradlew -Dorg.gradle.daemon=false build || ( echo -e \"\033[31mBuild failed. Stopping\033[m\" && exit 101 );" >> update.sh;
echo "popd;" >> update.sh;
echo "pushd srcRuntime || ( echo \"Directory srcRuntime not found\" && exit 5);" >> update.sh;
echo "git stash;" >> update.sh;
echo "git pull;" >> update.sh;
echo "./gradlew -Dorg.gradle.daemon=false build || ( echo -e \"\033[31mBuild failed. Stopping\033[m\" && exit 102 );" >> update.sh;
echo "git stash apply;" >> update.sh;
echo "popd;" >> update.sh;
## Client
echo "#!/bin/bash -e" > client.sh;
echo "if [ -z \"\$1\" ]; then echo \"Usage ./client.sh ClientName\"; exit 103; fi;" >> client.sh;
echo "ls updates/\$1 || (echo \"Client \$1 not found\" && exit 104);" >> client.sh;
echo "(ls updates/\$1 | grep forge) && rm updates/\$1/libraries/forge/launchwrapper*.jar && curl -o updates/\$1/libraries/forge/launchwrapper-5.1.x.jar https://mirror.gravit.pro/compat/launchwrapper-1.12-5.1.x-clientonly.jar;" >> client.sh;
echo "cp compat/core/authlib/authlib-clean.jar updates/\$1/libraries/;" >> client.sh;
echo "cp compat/LauncherAuthlib.jar updates/\$1/libraries/;" >> client.sh;
echo "echo \"Successfully! Use syncUpdates and go\";" >> client.sh;
## Chmod
chmod +x start.sh;
chmod +x startscreen.sh;
chmod +x update.sh;
chmod +x client.sh;

# Finished small help and simpliest check of launch4j
echo -e "\033[32mUsage: \033[33m./start.sh or ./startscreen.sh for start LaunchServer\033[m";
echo -e "\033[32mUsage: \033[33m./client.sh CLIENTNAME for copy authlib to client\033[m";
echo -e "\033[31mNOT DELETE DIRECTORIES src AND srcRuntime\033[m";
ldd libraries/launch4j/bin/windres > /dev/null || ( echo -e "\033[31mWARNING: ldd windres failed. Launch4j may be not worked\033[m" && exit 10 );


# INST_ROOT override root for install
if [[ -n $INST_ROOT ]]; then popd; fi;
