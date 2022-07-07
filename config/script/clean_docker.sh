#!/bin/sh
green='\e[0;32m' # 绿色  
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
NC='\e[0m' # 没有颜色

image_name=""
if [ $# -ge 2 ]; then
    repository=$1
    tag=$2
else
	echo -e "\n\n${YELLOW}please input docker image repository and tag!!! ${NC}"
	exit 0
fi

# 停止容器
image_name=$repository:$tag
# sudo docker ps -a | grep -w $image_name
ret=`sudo docker ps -a | grep -w $image_name | wc -l`
if [ $ret -gt 0 ]; then
    echo -e "${YELLOW}======================start remove container=================${NC}"
    sudo docker stop $(sudo docker ps -a | grep $image_name | awk '{print $1 }')
    # 删除容器
    sudo docker rm $(sudo docker ps -a | grep $image_name | awk '{print $1 }')
    # sudo docker container prune 
fi

# sudo docker images | grep -w $repository | grep -w $tag
ret=`sudo docker images | grep -w $repository | grep -w $tag | wc -l`
if [ $ret -gt 0 ]; then
    #删除镜像
    echo -e "${YELLOW}======================start remove images=================${NC}"
    sudo docker rmi -f $(sudo docker images | grep -w $repository | grep -w $tag | awk '{print $3}')
fi

echo -e "${GREEN}=======================list docker images=====================${NC}"
sudo docker images

echo -e "${GREEN}=======================list docker processes=====================${NC}"
sudo docker ps -a

echo -e "\n\n"