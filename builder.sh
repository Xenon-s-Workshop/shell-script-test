#!/usr/bin/env bash

printf "\e[1;32m \u2730 XenonTheInertG\e[0m\n\n"

mkdir -p work &>/dev/null
cd work &>/dev/null || exit 1

echo "::group::Source Repo Sync"
printf "Initializing Repo\n"
repo init -q -u $MANIFEST --depth=1 --groups=all,-notdefault,-device,-darwin,-x86,-mips
repo sync -c -q --force-sync --no-clone-bundle --no-tags -j6 &>/dev/null
echo "::endgroup::"

echo "::group::Device and Kernel Tree Cloning"
printf "Cloning Device Tree\n"
git clone $DT_LINK --depth=1 device/${VENDOR}/${CODENAME}
# omni.dependencies file is a must inside DT, otherwise lunch fails
[[ ! -f device/${VENDOR}/${CODENAME}/omni.dependencies ]] && printf "[\n]\n" > device/${VENDOR}/${CODENAME}/omni.dependencies

if [[ ! -z "$KERNEL_LINK" ]]; then
	printf "Using Manual Kernel Compilation\n"
	git clone $KERNEL_LINK --depth=1 kernel/${VENDOR}/${CODENAME}
else
	printf "Using Prebuilt Kernel For The Build.\n"
fi
echo "::endgroup::"

echo "::group::Fixups"
if [[ "$REQ_QCOM_COMMONSYS" == "true" ]]; then
	printf "Cloning QCOM commonsys\n"
	git clone -q https://github.com/omnirom/android_vendor_qcom_opensource_commonsys -b android-9.0 vendor/qcom/opensource/commonsys
else
	printf "QCOM commonsys not required. Clone skipped.\n"
fi

if [[ "$CRYPTFS_FIX" == "true" ]]; then
	printf "Fixing CryptFS\n"
	cd vendor/qcom/opensource/commonsys/ || exit 1
	rm -rf cryptfs_hw Android.bp
	wget -q https://raw.githubusercontent.com/ElytrA8/cryptfs_fixup/main/Android.bp
	cd ../../../.. || exit 1
else
	printf "CryptFS Fix Not Required. Clone Skipped.\n"
fi
echo "::endgroup::"

echo "::group::Pre-Compilation"
printf "Compiling Recovery...\n"
export ALLOW_MISSING_DEPENDENCIES=true

# If lunch throws error for roomservice, saying `device tree not found` or `fetching device already present`,
# replace the `roomservice.py` with appropriate one from here
# and then `source` and `lunch` again

source build/envsetup.sh
lunch omni_${CODENAME}-$FLAVOR
echo "::endgroup::"

echo "::group::Compilation"
mka $TARGET
echo "::groupend::"
