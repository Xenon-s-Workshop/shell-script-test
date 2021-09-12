#!/bin/bash
# Uploading
telegram -f lol/$ROM_NAME-SystemOverlay.zip "$ROM_NAME System Overlay"

telegram -f lol/$ROM_NAME-VendorOverlay.zip "$ROM_NAME Vendor Overlay"

telegram -f lol/$ROM_NAME-OneplusFolder.zip "$ROM_NAME feature_list and build.prop"
