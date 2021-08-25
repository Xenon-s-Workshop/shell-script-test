#!/bin/bash
source of.env
rm /bin/python
ln -s /bin/python2 /bin/python
cd $ANDROID_ROOT
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
lunch omni_spinel-userdebug
#mkdir -p /home/runner/work/orangefox/out/target/product/yggdrasil/system/etc
#touch /home/runner/work/orangefox/out/target/product/yggdrasil/system/etc/ld.config.txt
make -j$(nproc) recoveryimage
