# poky-imagination
Let us see what it takes to get Poky working with upstream imagination for AM62x

This is a collection of kas yml files used to demonstrate if we can
get upstream kernel, Mesa, zink etc working out of pure poky for
IMAGINATION GPUs on AM62x (AXE).

# Status:

Poky, master branch, commit 64ad67cf6955cdaebbb3aec65318399013e09ce1
("bitbake: toaster/tests: Fix kirkstone test") 2025-05-07

| Device    | Board       | Hardware IP | Status   | Status Date |
| --------- | ----------- | ------------| -------- | ----------- |
| AM62x     | BeaglePlay  | AXE         | NO       | 2025-05-07 |


# Kas config Files:

Pure poky:

* **poky-generic-arm64-min.yml** - minimal genericarm64 build

We would like these to work (GUI):

* **poky-generic-arm64-sato.yml** - sato build with X11 (and attempt at enabling imagination components)
* **poky-generic-arm64-weston.yml** - weston build (and attempt at enabling imagination components)

Contribution by Darren:

* **img-generic-arm64-weston.yml** (Thanks Darren)- Force update of
  weston with clang and enable imagination components. this will give
  you Mesa 24.1 + IMG vulkan and Zink patches that I can run Vulkan/GLES
  stuff on.


# BeaglePlay steps:

* Update the board with https://rcn-ee.net/rootfs/debian-arm64-12-bookworm-xfce-v6.12-ti/2025-03-05/beagleplay-emmc-flasher-debian-12.9-xfce-arm64-2025-03-05-12gb.img.xz (in bootloader in emmc) or newer image
* Build the corresponding kas configuration file (```kas build poky-generic-arm64-min.yml```)
* just flash the wic image in ```build/tmp/deploy/images/genericarm64``` to sdcard.
* Two manual modifications needed at the moment (cma=128M should dissappear with v6.15 or newer kernels)

```
boot/loader/entries/boot.conf -> add cma=128M to options
root/etc/default/weston -> add PVR_I_WANT_A_BROKEN_VULKAN_DRIVER=1
```

Just put the sdcard, hdmi, keyboard etc, and power on, the board will automatically
boot from the sdcard. No need to press any buttons.
