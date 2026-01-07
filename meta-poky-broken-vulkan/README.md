# Why?

All this mess for https://docs.mesa3d.org/drivers/powervr.html

PVR_I_WANT_A_BROKEN_VULKAN_DRIVER=1

# meta-poky-broken-vulkan

This layer provides a post processing step
instead of having to manually edit /etc/default/weston

Hoping to see this disappear soon.

## Dependencies

This layer depends on:
- openembedded-core (meta)

## Usage

1. Add this layer to your `bblayers.conf or kas yml file
