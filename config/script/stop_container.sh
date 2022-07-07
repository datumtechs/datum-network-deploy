#!/bin/sh
green='\e[0;32m' # 绿色  
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
NC='\e[0m' # 没有颜色

image_name=""
if [ $# -ge 1 ]; then
    image_name=$1
else
	echo -e "\n\n${YELLOW}please input docker image!!! ${NC}"
	exit 0
fi

echo -e "\n\n${YELLOW}Stop docker container, image:$image_name ${NC}"


# 停止容器 
ret=`sudo docker ps -a | grep -w $image_name | wc -l`
if [ $ret -gt 0 ]; then
    echo -e "${YELLOW}======================start to stop container=================${NC}"
    sudo docker stop $(sudo docker ps -a | grep -w $image_name | awk '{print $1 }')
    # 删除容器
    # sudo docker rm $(sudo docker ps -a | grep -w $image_name | awk '{print $1 }')
fi

echo -e "${GREEN}=======================list docker processes=====================${NC}"
sudo docker ps -a

echo -e "\n\n"
