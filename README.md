### 主要特性

- linux kernel version :V5.17.x    感谢：[@ubuntu-jammy](https://code.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/jammy) [@pve-kernel](https://github.com/proxmox/pve-kernel) [@pve-edge-kernel](https://github.com/fabianishere/pve-edge-kernel)
- 添加FULLCONE-NAT    原项目：[@Chion82](https://github.com/Chion82/netfilter-full-cone-nat)
- 添加ppp拨号组件
- 添加BCM578XX 2.5G支持
- 开启了FLOW_OFFLOAD 支持

## 安装
> 如有使用DKMS外挂安装fullcone,先暂停自动更新
```
touch /etc/dkms/no-autoinstall
```

在[[Releases]](https://github.com/fw867/pve-edge-kernel/releases"[Releases]")下载Releasedebs.tar.gz后上传到PVE
```
tar xzf Releasedebs.tar.gz
dpkg -i *.deb
```

[Openwrt rootfs下载](http://fw.koolcenter.com/LEDE_X64_fw867/openwrt-koolshare-router-v3.2-r19470-2f7d60f0e5-x86-64-generic-rootfs.tar.gz)

## 配置和模版
[一些Shell](https://github.com/fw867/pve-edge-kernel/releases/download/V1.0/shell.tar.gz)脚本介绍
> PVE下

| 脚本名称  |  功能介绍 |  放置目录 | 开启命令|
| :------------: | :------------: | :------------: | :------------: |
| rps  | 增加网卡的并发能力  | /etc/init.d  |update-rc.d rps defaults
| net-sriov  | 开机自动设置sriov网卡  |/etc/init.d   |systemctl enable net-sriov
| device_hook.sh  | lxc op启动后设置ppp tun  | /var/lib/lxc/{ct id}  |修改199.conf里的目录
| hookscript.pl  | lxc op启动后设置ppp tun  | {存储目录}/snippets  | 修改199.conf 里的目录
| openwrt.conf  | 开机自启openwrt需要的模块  | /etc/modules-load.d/  |无需
| 199.conf  | lxc op的配置模版  |  /etc/pve/lxc/{ct id}/ |根据实际修改硬盘目录和网卡 |

> 直通网卡配置

```
lxc.net.0.type: phys
lxc.net.0.link: eno1v0
lxc.net.0.flags: up
lxc.net.0.name: eth0
lxc.net.0.hwaddr: 00:11:22:33:44:1A
 ```   

> *如直通sriov创建的网卡，无法为openwrt创建的br-lan所互通

------------

> LXC openwrt下

| 脚本名称  |  功能介绍 |  放置目录 | 开启命令|
| :------------: | :------------: | :------------: | :------------: |
| 99_firewall_lxc_workaround  | 解决lxc下op偶发开机时卡防火墙问题  | /lib/preinit  |无需


## 一些网络调优参数
> nano /etc/sysctl.conf
```shell
net.netfilter.nf_conntrack_icmp_timeout=10
net.netfilter.nf_conntrack_tcp_timeout_syn_recv=5
net.netfilter.nf_conntrack_tcp_timeout_syn_sent=5
net.netfilter.nf_conntrack_tcp_timeout_established=600
net.netfilter.nf_conntrack_tcp_timeout_fin_wait=10
net.netfilter.nf_conntrack_tcp_timeout_time_wait=10
net.netfilter.nf_conntrack_tcp_timeout_close_wait=10
net.netfilter.nf_conntrack_tcp_timeout_last_ack=10
net.core.somaxconn=65535
```
## x550开启NBASE-T协商2.5G 5G
> 1.使用ethtool配置
```shell
ethtool -s ens2f0 advertise 0x1800000001028
```
> 2.配置自动开启
```shell
echo "options ixgbe enable_nbase_t_suppression_hack=0" > /etc/modprobe.d/ixgbe.conf

update-initramfs -u
```
## 自编译
> 最少10G空闲硬盘空间
```shell
sudo  apt install devscripts debhelper equivs git
git clone https://github.com/fw867/pve-edge-kernel.git
cd pve-edge-kernel
git submodule update --init --depth=1 --recursive linux
git submodule update --init --recursive
debian/rules debian/control
sudo mk-build-deps -i
debuild -ePVE* --jobs=auto -b -uc -us
```


### End
