#!/bin/bash

# Mediatek MT7922 RZ616
  sudo mkdir -p /lib/firmware/mediatek
  sudo wget -O /lib/firmware/mediatek/WIFI_MT7922_patch_mcu_1_1_hdr.bin https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/WIFI_MT7922_patch_mcu_1_1_hdr.bin
  sudo wget -O /lib/firmware/mediatek/WIFI_RAM_CODE_MT7922_1.bin https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/WIFI_RAM_CODE_MT7922_1.bin
