#!/bin/bash

#set -eo pipefail

#config var added
1= #devicecodename
2= #twrp branch(eg twrp-10.0)
GITHUB_REPOSITORY= #repo link of your dt
3= #build type
4= #recovery type/variant (eg: userdebug/eng)

if [[ -z $* ]]; then
	echo "Usage:"
	echo "	./twrp.sh <devicecodename> <twrpbranch> <buildtype> <recoverytype>"
	echo ""
	echo "<devicecodename>: Device codename. Ex: a51, j4lte, kenzo."
	echo ""
	echo "<twrpbranch>: TWRP branch number. Ex: 10.0, 9.0, 8.1."
	echo ""
	echo "<buildtype>: Build type. Ex: eng, userdebug."
	echo ""
	echo "<recoverytype>: Recovery type. Ex: recovery, boot. This is based on device. Recovery for recovery partition. Boot for device with only have boot partition."
	echo ""
	echo "Example:"
	echo "	./twrp.sh a51 10.0 userdebug recovery"
	exit 1
fi

# Variables
device=$1 # Device codename
twrp_branch=$2 # TWRP branch version
dt_url="https://github.com/${GITHUB_REPOSITORY}" # Device tree link
buildtype=$3 # Build variant
recoverytype=$4 # Build Type

if [ "${recoverytype}" == "boot" ]; then
	mkatype=bootimage
else
	mkatype=recoveryimage
fi

if [ "$twrp_branch" == "8.1" ] || [ "$twrp_branch" == "9.0" ] || [ "$twrp_branch" == "10.0" ]; then
	export ALLOW_MISSING_DEPENDENCIES=true
fi

# Setup environment
setup_env() {
	sudo DEBIAN_FRONTEND=noninteractive apt-get install \
	openjdk-8-jdk android-tools-adb bc bison \
	build-essential curl flex g++-multilib gcc-multilib \
	gnupg gperf imagemagick lib32ncurses5-dev \
	lib32readline-dev lib32z1-dev liblz4-tool \
	libncurses5-dev libsdl1.2-dev libssl-dev \
	libwxgtk3.0-dev libxml2 libxml2-utils lzop \
	pngcrush rsync schedtool squashfs-tools xsltproc \
	yasm zip zlib1g-dev python2 -y

	export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx3g"

	sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
	sudo chmod a+rx /usr/local/bin/repo

	sudo apt-get clean
	sudo rm -rf /var/cache/apt/*
	sudo rm -rf /var/lib/apt/lists/*
	sudo rm -rf /tmp/*

	sudo ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

	# Claim more diskspace
	# Thanks to @yukosky

	sudo swapoff -av
	sudo rm -f /swapfile

	sudo rm -rf /usr/share/dotnet

	sudo rm -rf "/usr/local/share/boost"
	sudo rm -rf "$AGENT_TOOLSDIRECTORY"
	sudo swapoff -av
	sudo rm -rf /mnt/swapfile
	sudo dpkg --purge '^ghc-8.*' '^dotnet-.*' '^llvm-.*' 'php.*' azure-cli google-cloud-sdk '^google-.*' hhvm google-chrome-stable firefox '^firefox-.*' powershell mono-devel '^account-plugin-.*' account-plugin-facebook account-plugin-flickr account-plugin-twitter account-plugin-windows-live aisleriot brltty duplicity empathy empathy-common example-content gnome-accessibility-themes gnome-contacts gnome-mahjongg gnome-mines gnome-orca gnome-screensaver gnome-sudoku gnome-video-effects gnomine landscape-common libreoffice-avmedia-backend-gstreamer libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-gnome libreoffice-gtk libreoffice-impress libreoffice-math libreoffice-ogltrans libreoffice-pdfimport libreoffice-style-galaxy libreoffice-style-human libreoffice-writer libsane libsane-common python3-uno rhythmbox rhythmbox-plugins rhythmbox-plugin-zeitgeist sane-utils shotwell shotwell-common telepathy-gabble telepathy-haze telepathy-idle telepathy-indicator telepathy-logger telepathy-mission-control-5 telepathy-salut totem totem-common totem-plugins printer-driver-brlaser printer-driver-foo2zjs printer-driver-foo2zjs-common printer-driver-m2300w printer-driver-ptouch printer-driver-splix
	# Bonus
	sudo dd if=/dev/zero of=swap bs=4k count=1048576
	sudo mkswap swap
	sudo swapon swap
}

# Clone source
clone_source() {
	cd ~
	#mkdir shrp && cd shrp
        mkdir ~/twrp
        cd ~/twrp
        repo init  --depth=1 -u https://gitlab.com/OrangeFox/Manifest.git -b fox_${twrp_branch}
        #repo sync -j8 --force-sync
	#repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni -b twrp-${twrp_branch}
	#repo init --depth=1 -u git://github.com/SHRP/platform_manifest_twrp_omni.git -b ${twrp_branch}
        repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all)
}

# Clone DT
clone_tree() {
	cd ~/twrp
	mkdir -p device/xiaomi && cd device/xiaomi
	git clone ${dt_url} ${device}
}

# Start build
start_build() {
       #cd ~/twrp/vendor/omni/build/core
       #rm qcom_utils.mk
       #wget https://raw.githubusercontent.com/CaliBerrr/WorkAround/main/qcom_utils.mk
       cd ~/twrp
       export ALLOW_MISSING_DEPENDENCIES=true
       export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
       export LC_ALL="C"
       #export ALLOW_MISSING_DEPENDENCIES=true
       source build/envsetup.sh

       BUILD_START=$(date +"%s")

       lunch omni_${device}-${buildtype}
       mka ${mkatype} -j$(nproc --all)

	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))
}

# Fancy Telegram function

# Send text (helper)
function tg_sendText() {
	curl -s "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
		-d "parse_mode=html" \
		-d text="${1}" \
		-d chat_id=$CHAT_ID \
		-d "disable_web_page_preview=true"
}

# Send info
tg_sendInfo() {
	tg_sendText "<b>TWRP Build Started!</b>
	<b>💻 Started on:</b> Github Actions
	<b>📱 Device:</b> ${device}
	<b>📃 Commit list:</b> <a href='${dt_url}/commits/master'>Click Here</a>
	<b>📆  Date:</b> $(date +%A,\ %d\ %B\ %Y\ %H:%M:%S)"
}

# Telegram status: Prepare
tg_sendPrepareStatus() {
	tg_sendText "<b>$(date +%H:%M:%S):</b> Preparing Environment"
}

# Telegram status: Download source
tg_sendSyncSourceStatus() {
	tg_sendText "<b>$(date +%H:%M:%S):</b> Syncing source (${twrp_branch})"
}

# Telegram status: Clone tree
tg_sendCloneTreeStatus() {
	tg_sendText "<b>$(date +%H:%M:%S):</b> Cloning Tree"
}

# Telegram status: Build
tg_sendBuildStatus() {
	tg_sendText "<b>$(date +%H:%M:%S):</b> Building"
}

# Telegram status: Done
tg_sendDoneStatus() {
	tg_sendText "<b>Build done successfully! 🎉</b>
	<b>Time build:</b> $(($DIFF / 60))m $(($DIFF % 60))s"
}

# Telegram send file
tg_sendFile() {
	curl -F chat_id=$CHAT_ID -F document=@${1} -F parse_mode=markdown https://api.telegram.org/bot$BOT_TOKEN/sendDocument
}

# Send image
send_image() {
	cd ~/twrp/out/target/product/${device}
	for i in *.img; do
		tg_sendFile $i
	done
        for i in *.zip; do
		tg_sendFile $i
	done
        SBIN="sbin-$(date +%d_%m_%Y_%H_%M).zip"
        sudo zip -r9 $SBIN recovery/root/sbin/*.so
        tg_sendFile $SBIN
        VENDOR="vendor-$(date +%d_%m_%Y_%H_%M).zip"
        sudo zip -r9 $VENDOR recovery/root/vendor
        tg_sendFile $VENDOR
        find .  >> find.txt
        tg_sendFile find.txt

}

# Error function
abort() {
	errorvalue=$?
	tg_sendText "Build error! Check github actions log bruh"
	exit $errorvalue
}
trap 'abort' ERR;

# Finally, call the function
tg_sendInfo;
tg_sendPrepareStatus;
setup_env;
tg_sendSyncSourceStatus;
clone_source;
tg_sendCloneTreeStatus;
clone_tree;
tg_sendBuildStatus;
start_build;
tg_sendDoneStatus;
send_image;
