# Apply PVR broken Vulkan workaround to any image that includes weston-init

ROOTFS_POSTPROCESS_COMMAND:append = " force_broken_pvr_vulkan; "

force_broken_pvr_vulkan () {
    weston_default="${IMAGE_ROOTFS}${sysconfdir}/default/weston"

    # Only touch it if it exists or if weston is present
    if [ -e "$weston_default" ]; then
        bbnote "force-broken-pvr-vulkan: setting PVR_I_WANT_A_BROKEN_VULKAN_DRIVER=1 in $weston_default"
    else
        # If the file doesn't exist, do nothing (avoids creating stray config on non-weston images)
        bbnote "force-broken-pvr-vulkan: $weston_default not present; skipping"
        exit 0
    fi

    if grep -q '^PVR_I_WANT_A_BROKEN_VULKAN_DRIVER=' "$weston_default"; then
        sed -i 's/^PVR_I_WANT_A_BROKEN_VULKAN_DRIVER=.*/PVR_I_WANT_A_BROKEN_VULKAN_DRIVER=1/' \
            "$weston_default"
    else
        echo 'PVR_I_WANT_A_BROKEN_VULKAN_DRIVER=1' >> "$weston_default"
    fi
}
