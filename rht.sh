#!/bin/bash
NODE=$1
cat <<eof
####################
1. backup
2. reset
3. quit
####################
eof
read -p "please enter [1|2|3]:" re
case $re in
1|backup)   # 这里可以同时判断输入的是1还是backup , 区别于if 判断
        echo "backup $NODE"
        sudo virsh dumpxml $NODE |awk -F"'" '/source file/{print $(NF-1)}'
				IMG=`sudo virsh dumpxml $NODE |awk -F"'" '/source file/{print $(NF-1)}'`
				OVL=/var/lib/libvirt/ovl/$NODE.ovl
				sudo virsh list |grep host10 && sudo virsh destroy $NODE
				sudo qemu-img create -q -f qcow2 -b $IMG $OVL
				sudo sed -i.bak "s#$IMG#$OVL#g" /etc/libvirt/qemu/$NODE.xml
				sudo virsh define /etc/libvirt/qemu/$NODE.xml
				;;
2|reset)
        echo "reset";;
3|quit)
        echo "quit" && exit
        ;;
*)
        echo "attention your input!!!"
        echo "USAGE: $0 {1|2|3}"
esac
