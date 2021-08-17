#/bin/bash!

# TWRP Compiler for ci/cd services by @XenonTheInertG

MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

# Setup colour for the script
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'


# put device product/device name/device codename
VENDOR="xiaomi"
DEVICE="Pocophone F1"
CODENAME="beryllium"

# Put the url for the device tree on github and branch
DEVICE_TREE="https://github.com/TeamWin/android_device_xiaomi_beryllium"
DEVICE_BRANCH="android-9.0"

# Check https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni branches for that
TWRP_VERSION="twrp-9.0"

# Telgram env setup
export BOT_MSG_URL="https://api.telegram.org/bot$BOT_API/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$BOT_API/sendDocument"

tg_post_msg() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d text="$1"
}

tg_post_build() {
        #Post MD5Checksum alongwith for easeness
        MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

        #Show the Checksum alongwith caption
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3 build finished in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds | <b>MD5 Checksum : </b><code>$MD5CHECK</code>"
}

tg_error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3Failed to build , check <code>error.log</code>"
}

# Setup build process

build_twrp() {
Start=$(date +"%s")

. build/envsetup.sh && lunch omni_"$CODENAME"-eng && export ALLOW_MISSING_DEPENDENCIES=true
mka recoveryimage | tee error.log

End=$(date +"%s")
Diff=$(($End - $Start))
}

export IMG="$MY_DIR"/out/target/product/"$CODENAME"/recovery.img

# Init TWRP repo
mkdir TWRP && cd TWRP
repo init https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni -b "$TWRP_VERSION" --depth=1
repo sync

# Clone device tree
git clone "$DEVICE_TREE" -b "$DEVICE_BRANCH" device/"$VENDOR"/"$CODENAME"/

# let's start building the image

tg_post_msg "<b>🛠️TWRP CI Build Triggered for $CODENAME</b>" "$CHAT_ID"
build_twrp || error=true
DATE=$(date +"%Y%m%d-%H%M%S")

	if [ -f "$IMG" ]; then
		echo -e "$green << Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds >> \n $white"
	else
		echo -e "$red << Failed to compile the TWRP image , Check up error.log >>$white"
		tg_error "error.log" "$CHAT_ID"
		rm -rf out
		rm -rf error.log
		exit 1
	fi

	if [ -f "$IMG" ]; then
		TWRP_IMGAGE="twrp-3.4.0-0_$CODENAME_$DATE.img"
		mkdir sender
		mv "$IMG" sender/"$TWRP_IMGAGE"
		cd sender
		tg_post_build "$TWRP_IMGAGE" "$CHAT_ID"
		exit
	fi
