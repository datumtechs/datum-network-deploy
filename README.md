# 功能介绍

ansible.cfg: ansible 配置文件

inventory.ini: 组和主机的相关配置

config: 相关配置模版

roles: ansible tasks 的集合

local_prepare.yml: 用来下载相关安装包

bootstrap.yml: 初始化集群各个节点

deploy.yml: 在各个节点安装相应服务

start.yml: 启动所有服务

stop.yml: 停止所有服务

editConfig.yml: 变更配置

update.yml： 升级组件版本

cleanup.yml: 销毁集群

## 注意事项

目前主控机和目标机只支持在Ubuntu 18.04

## 安装依赖

**主控机上安装 ansible 和 依赖模块：**

```shell
cd metis-deploy
pip install -r ./requirements.txt
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

目前只支持 ssh 普通用户名登录，ansible_user 设置为目标主机的用户名

**group_vars/all.yml 文件修改**

必改选项为：
1. 静态文件下载 url
2. admin web 服务相关配置信息
3. 部署服务列表，是否 enable。
4. mysql 相关用户名密码
5. 各个服务端口号

**如果只想部署、启动、关闭、销毁某一个或几个服务**

我们只需要将all.yml中下面的相关参数置为False，默认情况下是除了storage服务为False，其它均为True

```shell
enable_deploy_via: True
enable_deploy_carrier: True
enable_deploy_admin: True
enable_deploy_data: True
enable_deploy_compute: True
enable_deploy_storage: False
enable_deploy_consul: True
```

## 主控节点做的准备工作

1. 检查 ansible 版本大于 2.4.2，检查 jinja2 安装和版本信息。
2. 检查主机清单（inventory.ini）配置是否正确。至少包括一个 consul 主机， ssh 账户不支持 root 只能用普通账户。
3. 创建下载目录，检查网络连接，无法连接外网直接报错退出。
4. 下载安装包到下载目录(go 二进制文件， jar 包， web 静态资源文件， whl 文件，shell 脚本)，下载任务最多运行 3 次，每次尝试的延迟是10之内的随机值。

```shell
ansible-playbook -i inventory.ini local_prepare.yml
```

## 初始化集群各个节点

1. 检查配置的集群操作系统是否是 Ubuntu 18.04。
2. 检查 python 和 python3 是否安装，没有安装会进行安装。

```shell
ansible-playbook -i inventory.ini bootstrap.yml -k --ask-sudo-pass
```

## 各个节点安装服务

1. 创建安装需要的目录。
2. 根据 Jinja2 配置文件模板生成配置文件（有变更会把旧的配置文件备份）。
3. 拷贝可执行文件到目标机器。

```shell
ansible-playbook -i inventory.ini deploy.yml -k --ask-sudo-pass
```

## 启动服务

1. 在后台运行服务

```shell
ansible-playbook -i inventory.ini start.yml -k
```

## 关闭服务

1. kill 掉运行的服务

```shell
ansible-playbook -i inventory.ini stop.yml -k --ask-sudo-pass
```

## 销毁服务

1. 先关闭要销毁服务

```shell
ansible-playbook -i inventory.ini stop.yml -k --ask-sudo-pass
```

2. 销毁要销毁的服务

```shell
ansible-playbook -i inventory.ini cleanup.yml -k
```

