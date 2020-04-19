#!/bin/bash
NUM=$1 
pre_check()
{
virsh list --all|grep node$NUM
if [ $? -eq 0 ];then
    virsh destroy node$NUM
    virsh undefine node$NUM
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
network  --bootproto=static --device=eth0 --gateway=9.111.105.1 --ip=9.111.105.$NUM --nameserver=9.115.17.20 --netmask=255.255.255.0 --ipv6=auto --activate
network  --hostname=node$NUM.9.111.105.$NUM.nip.io

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
cd /home/VM/; qemu-img create -f qcow2 node$NUM.img 50G
}
vm_create()
{
virt-install --os-variant rhel7 --name node$NUM --vcpu 4 --memory 8196 --disk /home/VM/node$NUM.img --mac=00:16:3e:50:9b:a1 --location /home/CentOS-7-x86_64-DVD-1908.iso --initrd-inject=/tmp/ks$NUM.cfg --network bridge=br1 --extra-args "ks=file:/ks$NUM.cfg" -x "ip=192.168.122.$NUM netmask=255.255.255.0 dns=9.115.17.20 gateway=9.111.105.1"
}
pre_check $NUM
ks_create $NUM
img_create $NUM
vm_create $NUM

