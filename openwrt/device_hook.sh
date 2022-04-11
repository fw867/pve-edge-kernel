mkdir -p ${LXC_ROOTFS_MOUNT}/dev/net
mknod -m 666 /${LXC_ROOTFS_MOUNT}/dev/ppp c 108 0
mknod -m 666 /${LXC_ROOTFS_MOUNT}/dev/net/tun c 10 200
