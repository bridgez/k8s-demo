#!/bin/bash
SRC=`echo $1 | cut -d'/' -f1`
IMG=`echo $1 | cut -d'/' -f2`
cat <<eof
####################
1. k8s.gcr.io
2. reset
3. quit
####################
eof
#read -p "please enter [1|2|3]:" re
echo $SRC
case $SRC in
1|k8s.gcr.io)   # 这里可以同时判断输入的是1还是backup , 区别于if 判断
        echo "backup $NODE"
        PROXY=gcr.azk8s.cn/google-containers
        docker pull $PROXY/$IMG
        docker tag $PROXY/$IMG $1
        docker rmi $PROXY/$IMG

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
