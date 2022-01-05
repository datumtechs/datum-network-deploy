# 功能介绍

ansible.cfg: ansible 配置文件

inventory.ini: 组和主机的相关配置

conf: 相关配置模版

local_prepare.yml: 用来下载相关安装包

bootstrap.yml: 初始化集群各个节点

deploy.yml: 在各个节点安装相应服务

roles: ansible tasks 的集合

start.yml: 启动所有服务

stop.yml: 停止所有服务

editConfig.yml: 变更配置

update.yml： 升级组件版本

cleanup.yml: 销毁集群

## 注意事项

目前主控机和目标机只支持在Ubuntu 18.04

## 安装依赖

**主控机上安装 ansible 和 其他依赖模块：**

```shell
cd metis-deploy
pip install -r ./requirements.txt
```

**目标机上面安装 python3**

```shell
# 安装 python3
sudo apt-get install python3

# 安装 pip3
sudo apt install -y python3-pip
```

**下载脚本：**

```shell
git clone http://192.168.9.66/Metisnetwork/metis-deploy.git
cd metis-deploy
git checkout ansible

# 创建日志目录
mkdir log
```

## 修改配置

**inventory.ini 文件修改**

inventory.ini 库存文件根据自己的实际情况配置各个服务的 ip 地址

目前只支持 ssh 用户名登录，ansible_user 设置为目标主机的用户名

**group_vars/all.yml 文件修改**

必改选项为：
1. 静态文件下载 url
2. admin web 服务相关配置信息
3. mysql 相关用户名密码
4. 各个服务端口号

## 主控节点做的准备工作

1. 检查 ansible 版本大于 2.4.2
2. 创建下载相关目录，检查网络连接
3. 下载安装包

```shell
ansible-playbook -i inventory.ini local_prepare.yml
```

## 初始化集群各个节点

1. 检查配置的集群操作系统是否是 Ubuntu 18.04

```shell
ansible-playbook -i inventory.ini bootstrap.yml -k --ask-sudo-pass
```

## 各个节点安装服务

```shell
ansible-playbook -i inventory.ini deploy.yml -k --ask-sudo-pass
```

## 启动服务

```shell
ansible-playbook -i inventory.ini start.yml -k --ask-sudo-pass
```

## 关闭服务

```shell
ansible-playbook -i inventory.ini stop.yml -k --ask-sudo-pass
```
