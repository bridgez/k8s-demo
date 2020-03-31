#!/bin/bash
NUM=$1 
pre_check()
{
virsh list --all|grep host$NUM
if [ $? -eq 0 ];then
    virsh destroy host$NUM
    virsh undefine host$NUM
fi
}
ks_create()
{
cat > /tmp/ks$NUM.cfg << EOF
#install
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
#url --url="http://192.168.122.1/cdrom"
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# Reboot after installation
reboot
# System language
lang en_US.UTF-8


# Network information
network  --bootproto=static --device=eth0 --gateway=192.168.122.1 --ip=192.168.122.$NUM --nameserver=192.168.122.1 --netmask=255.255.255.0 --ipv6=auto --activate
network  --hostname=host$NUM.192.168.122.$NUM.nip.io

# Root password
rootpw --iscrypted \$6\$bkhALDhuppF0ExEU\$5Fa6R40H2j7DuaEQihaNjmqtvtp8dKstTNvjGY3fdsMmvvSoQSQ6CJ.zlZbaMaQrMtTR5ZTvwFOWp1liYSKYN/
# System services
services --enabled="chronyd"
firewall --disabled
selinux --disabled
# System timezone
timezone Asia/Shanghai --isUtc

#System Bootloader configuration
bootloader --location=mbr
#Clear the Master Boot Record
zerombr
#Partition clearing information
clearpart --all --initlabel 
#bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
autopart --type=lvm

%packages
@base
@core
@desktop-debugging
@dial-up
@fonts
@gnome-desktop
@guest-agents
@guest-desktop-agents
@hardware-monitoring
@input-methods
@internet-browser
@multimedia
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

#graphical
#skipx
EOF
}
img_create()
{
cd /var/lib/libvirt/images/; qemu-img create -f qcow2 host$NUM.img 20G
}
vm_create()
{
virt-install --os-variant rhel7 --name host$NUM --vcpu 2 --memory 3072 --disk /var/lib/libvirt/images/host$NUM.img --mac=00:16:3e:50:9b:$NUM --location /tools/CentOS-7-x86_64-DVD-1908.iso --initrd-inject=/tmp/ks$NUM.cfg --extra-args "ks=file:/ks$NUM.cfg" -x "ip=192.168.122.$NUM netmask=255.255.255.0 dns=192.168.122.1 gateway=192.168.122.1"
}
pre_check $NUM
ks_create $NUM
img_create $NUM
vm_create $NUM
