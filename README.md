# 功能介绍

ansible.cfg: ansible 配置文件
inventory.ini: 组和主机的相关配置
conf:  相关配置模版
local_prepare.yml: 用来下载相关安装包
bootstrap.yml: 初始化集群各个节点
deploy.yml: 在各个节点安装相应服务
roles: ansible tasks 的集合
start.yml: 启动所有服务
stop.yml: 停止所有服务
editConfig.yml: 变更配置
update.yml： 升级组件版本
cleanup.yml: 销毁集群

## 下载相关安装包

```shell
ansible-playbook -i inventory.ini local_prepare.yml
```

## 初始化集群各个节点

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