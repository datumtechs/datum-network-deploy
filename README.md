# metis 部署 [[English](./README_EN.md)]

## metis 网络拓扑

metis 网络由多个 metisNode 组成，一个 MetisNode 其实是一个组织的逻辑总称，关于 MetisNode 的网络拓扑具体如下所示：

- ### *各个MetisNode间的网络拓扑*

 ![organizations][MetisNode的各组织网络拓扑]

 MetisNode 间的网络拓扑，其中在各个 MetisNode 之间 (也就是各个组织之间)是通过 p2p 网络互相建立起连接的；每个 MetisNode 通过自身的 carrier 和外界的 MetisNode 的 carrier 进行 p2p 连接。

- ### *单个MetisNode 内部各个服务的网络拓扑*

 ![inside organization][单个MetisNode的内部各服务网络拓扑]

在 MetisNode 内测的各个服务划分 admin, via, carrier, fighter(data), fighter(compute), consul 等角色服务。admin、carrier、via、fighter都将自身的信息自动注册到 consul，各个内部服务间通过 consul 中的其他内部服务信息做服务间相互发现。对于组织内部的各服务具体功能如下：

**via 节点**：为整个组织的 task 消息网关，一个组织只能部署一个网关(只能有一个)。via 服务提供组织和外部进行多方协助 task 时的唯一外网端口 (内外网端口一致)。

**carrier 节点**：为整个组织的任务调度服务，一个组织只能部署一个调度服务(只能有一个)。carrier 担当起整个 MetisNode 的大脑负责任务调度、资源服务调度和元数据及组织内部资源信息管理以及数据同步、p2p等等。

**admin 节点**：为整个组织的管理台 web 后端服务，一个组织有一个管理台服务(可以有多个，建议启一个)。admin 则是 carrier 的管理台方便用户管理内部数据和资源及数据统计报表等。

**data 节点**：[fighter(data)]为整个组织的存储资源节点，可以根据自己的情况配置任意多个。

**compute 节点**：[figter(compute)]为整个组织的算力资源节点，可以根据自己的情况配置任意多个。

**consul 节点**：为整个组织的注册中心服务，一个组织建议配置奇数个（1，3，5等），方便 raft 共识算法选择 leader。

- ### *MetisNode 内部必须存在的服务，以及部署时的顺序*

> 从上述图中我们已经知道了 MetisNode 内部各个服务的网络拓扑，那么显而易见组织内部必须要有的服务为 consul、 carrier、 admin，其他的服务根据自身情况而定；如果需要提供数据能力或者提供算力能力去参与多方协同计算，那么还必须有 via 和 fighter，其中需要提供数据能力时需部署 fighter(data)、需要提供算力能力时部署 fighter(compute)。

**服务部署的顺序为:**

> (一)、必须部署部分(不管是否参与任务计算都要部署的):  [1] consul服务 -> [2] carrier 服务 -> [3] admin服务。
> (二)、非必须部署部分(如需要参与任务计算都要部署的): [4] via 服务 -> [5] fighter(data)服务、fighter(compute)服务。

- ### *Moirea 和 MetisNode 的关系*

![Moirea and MetisNode][Moirea和MetisNode间的拓扑]

Moirea 可以理解为是一个提供数据市场、全网数据统计、任务工作流管理的平台。 可以搭建在自己组织内部，那么它和自身组织的 MetisNode 是一对一关系； 也可以通过 moirea 界面添加外部 MetisNode 的carrier 外网 ip 和 port 对接其他外部 MetisNode 这样是一对多关系，moirea 的具体操作说明请参照 moirea 的相关文档。

## MetisNode 部署脚本说明

本脚本为 ansible 自动化部署脚本，包括单组织内部 admin, via, carrier, fighter(data), fighter(compute), consul 角色服务，ansible 脚本支持**部署**，**启动**，**停止**，**销毁**各个角色节点。

## 环境要求

主控机 (ansible 下发命令的机器) 和目标机 (各服务部署的机器)。

1. 稳定版 ansible 主控机和目标机仅支持 Ubuntu 18.04 操作系统。

2. 处理器架构仅支持 x86_64 架构的处理器 (仅目标机要求)。

3. 主机资源要求建议

|服务名称|机器配置建议|
|---|---|
|Via|4C、8G内存 、高效云盘200GB|
|Fighter|8C、16G内存 、高效云盘200GB|
|Carrier|8C、16G内存 、高效云盘200GB|
|Admin（自建MySQL） + Consul|8C、16G内存 、高效云盘200GB|

### 主控机部署前准备工作

*1. 在主控机上下载脚本：*

```shell
# 使用 git 下载脚本项目
git clone https://github.com/Metisnetwork/Metis-Deploy.git

# 进入项目目录
cd Metis-Deploy

# 切换项目到 ansible 分支
git checkout ansible

# 创建日志目录
mkdir log
```

*2. 主控机上安装指定版本的 `ansible` 和 `依赖模块`, 执行命令 (如果已经安装过 ansible, 请先卸载)：*

```shell
# 先进入本项目目录
cd Metis-Deploy

# 安装 python 相关工具(Ubuntu 18.04 默认的 python 版本为 python2.7， python3 版本为 python3.6)
sudo apt install -y python python-pip python3 python3-pip

# 安装 ansible 和 依赖模块
pip install -r ./requirements.txt
```

*3. 主控机环境检查和安装包下载：*

```shell

# 检查 ansible 版本(>2.4.2, 建议2.7.11)，检查 jinja2 安装和版本(>=2.9.6)信息。
# 创建下载目录，检查网络连接，无法连接外网直接报错退出，下载安装包需要可以连接外网。
# 下载依赖的工具和组件（需要输入 sudo 密码）。
# 下载安装包到下载目录(go 二进制文件，jar 包，web 静态资源文件，python 的 whl 文件，shell 脚本)，下载任务最多尝试 3 次，每次尝试的延迟是10之内的随机值。

ansible-playbook --ask-sudo-pass local_prepare.yml
```

## 工程各文件功能简介

inventory.ini: 主机清单文件，组织中各个服务的主机ip (内网) 和变量，由用户根据自己情况定义。

group_vars/all.yml: 公共变量，不建议修改。

ansible.cfg: ansible 配置文件，建议不要乱动。

config 目录: 配置文件，不建议修改。

roles 目录: ansible roles 的集合，建议不要乱动。

local_prepare.yml: 主控机执行环境检查，下载安装包等任务的剧本，建议不要乱动。

bootstrap.yml: 初始化集群各个节点等任务的剧本，建议不要乱动。

deploy.yml: 安装各个服务的剧本，建议不要乱动。

start.yml: 启动所有服务的剧本，建议不要乱动。

stop.yml: 停止所有服务的剧本，建议不要乱动。

cleanup.yml: 销毁集群的剧本，建议不要乱动。

## 单组织内部主机清单文件 `inventory.ini`

`inventory.ini` 主机清单文件，配置部署主机IP (内网) 和 变量。

配置有两种常见的形式：

【一】所有服务部署在一台机器上(即: 单个宿主机部署单个组织所有服务, 建议只在测试阶段使用)。

【二】每台宿主机仅部署一个服务 (生产阶段建议使用这种)。

目前远程主机 ssh 登录不支持 root 用户，只支持普通用户，且这个普通用户要支持 sudo 提权。

> 为简化操作，避免在执行 playbook 时输入密码，可以配置如下密码 `ansible_ssh_user` 设置为要登录目标主机的 ssh 用户名, `ansible_ssh_pass` 为用户的 ssh 密码, `ansible_sudo_pass` 为目标主机上的用户进行提权时的密码。也可以根据实际情况不配置，在执行 playbook 时输入密码。

### `inventory.ini` 文件模板

```ini
# 库存文件，主要用来配置主机列表和主机组

# 任务网关，一个组织有一个网关服务
[via]
${目标机内网IP} ansible_ssh_user="${ ssh 账户名称 }" ansible_ssh_pass="${ ss 账户密码 }" ansible_sudo_pass="${ sudo 提权密码 }"

# 调度，一个组织有一个调度服务
[carrier]
${目标机内网IP} ansible_ssh_user="${ ssh 账户名称 }" ansible_ssh_pass="${ ss 账户密码 }" ansible_sudo_pass="${ sudo 提权密码 }"

# 管理台，一个组织有一个管理台服务
[admin]
${目标机内网IP} ansible_ssh_user="${ ssh 账户名称 }" ansible_ssh_pass="${ ss 账户密码 }" ansible_sudo_pass="${ sudo 提权密码 }"

# 资源节点，一个组织可以配置多个资源服务
[data]
${目标机内网IP} ansible_ssh_user="${ ssh 账户名称 }" ansible_ssh_pass="${ ss 账户密码 }" ansible_sudo_pass="${ sudo 提权密码 }"

# 计算节点，一个组织可以配置多个计算服务
[compute]
${目标机内网IP} ansible_ssh_user="${ ssh 账户名称 }" ansible_ssh_pass="${ ss 账户密码 }" ansible_sudo_pass="${ sudo 提权密码 }"

# 注册中心，一个组织要配置奇数个(1, 3, 5个等）注册中心，方便 raft 选择leader
[consul]
${目标机内网IP} ansible_ssh_user="${ ssh 账户名称 }" ansible_ssh_pass="${ ss 账户密码 }" ansible_sudo_pass="${ sudo 提权密码 }"


[all:vars]
# 集群的名称，自定义即可
cluster_name = demo-cluster

# 部署服务开关
enable_deploy_via = True      # 是否部署、启动、关闭、销毁 via，部署为 True，不部署设置为 False
enable_deploy_carrier = True  # 是否部署、启动、关闭、销毁 carrier，部署为 True，不部署设置为 False。
enable_deploy_admin = True    # 是否部署、启动、关闭、销毁 admin，部署为 True，不部署设置为 False。
enable_deploy_data = True     # 是否部署、启动、关闭、销毁 data，部署为 True，不部署设置为 False。
enable_deploy_compute = True  # 是否部署、启动、关闭、销毁 compute，部署为 True，不部署设置为 False。
enable_deploy_consul = True   # 是否部署、启动、关闭、销毁 consul，部署为 True，不部署设置为 False。

# consul 服务的端口，根据自己的部署情况进行设置，数量要和 consul 组里面的 ip 数量一致。
consul_server_port = [8200, 8201, 8202]
consul_serf_lan_port = [8300, 8301, 8302]
consul_serf_wan_port = [8400, 8401, 8402]
consul_http_port = [8500, 8501, 8502]
consul_dns_port = [8600, 8601, 8602]

# admin web 服务证书相关配置信息
enable_tls = False # 是否启用 https，启用设置为 True，需要配置证书和相应的域名，证书里面的密码套件等，不启用设置为 False，忽略下面的配置。
admin_server_name = metis-admin.demo.network
admin_ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers = ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password = metis_root
amin_user = metis_admin
admin_password = admin_123456

# admin web 服务端口号
admin_web_port = 9090

# carrier 外网 ip 地址
carrier_external_ip = ${carrier 目标机外网 IP}

# carrier 服务端口号
carrier_pprof_port = 10032
carrier_rpc_port = 10033
carrier_grpc_gateway_port = 10034
carrier_p2p_udp_port = 10035
carrier_p2p_tcp_port = 10036

# via 外网 ip 地址
via_external_ip = ${via 目标机外网 IP}

# via 服务端口号
via_port = 10031

# data 端口号，根据自己的部署情况进行设置，数量要和 data 组里面的 ip 数量一致。
data_port = [8700, 8701, 8702]

# compute 端口号，根据自己的部署情况进行设置，数量要和 compute 组里面的 ip 数量一致。
compute_port = [8700, 8701, 8702]
```

### `inventory.ini` 中各变量说明

#### 1. ssh 相关配置（非必须，不配置在执行 playbook 时手动输入密码）

ansible_ssh_user：目标机 ssh 账户名称

ansible_ssh_pass：目标机 ssh 账户密码

ansible_sudo_pass：目标机 ssh 账户 sudo 提权密码

#### 2. 集群名称变量

cluster_name：整个组织的名称

#### 3. 部署服务开关选项

enable_deploy_via: 是否部署、启动、关闭、销毁 via，部署为 True，不部署设置为 False。

enable_deploy_carrier: 是否部署、启动、关闭、销毁 carrier，部署为 True，不部署设置为 False。

enable_deploy_admin: 是否部署、启动、关闭、销毁 admin，部署为 True，不部署设置为 False。

enable_deploy_data: 是否部署、启动、关闭、销毁 data，部署为 True，不部署设置为 False。

enable_deploy_compute: 是否部署、启动、关闭、销毁 compute，部署为 True，不部署设置为 False。

enable_deploy_consul: 是否部署、启动、关闭、销毁 consul，部署为 True，不部署设置为 False。

#### 4. 配置 consul 服务端口号 (建议只开通内网端口策略)

consul_server_port: consul服务的端口，数组形式[8200, 8201, 8202], 端口号根据自己的部署情况进行设置，数量要和 consul 组的成员数量一致。

consul_serf_lan_port: Serf LAN gossip 通信应该绑定的端口，数组形式[8300, 8301, 8302], 端口号根据自己的部署情况进行设置，数量要和 consul 组的成员数量一致。

consul_serf_wan_port: Serf WAN gossip 通信应该绑定的端口，数组形式[8400, 8401, 8402], 端口号根据自己的部署情况进行设置，数量要和 consul 组的成员数量一致。

consul_http_port: HTTP API 端口，数组形式[8500, 8501, 8502], 端口号根据自己的部署情况进行设置，数量要和 consul 组的成员数量一致。

consul_dns_port:  DNS 服务器端口，数组形式[8600, 8601, 8602], 端口号根据自己的部署情况进行设置，数量要和 consul 组的成员数量一致。

#### 5. admin web 证书相关配置

enable_tls: 是否启用 https，启用设置为 True，需要配置证书和相应的域名，证书里面的密码套件等，不启用设置为 False，同时忽略下面的配置。

admin_server_name: ngnix 配置项 server_name，admin 服务部署的机器的域名。

admin_ssl_protocols: ngnix 配置项 ssl_protocols，证书支持的 tls 版本。

admin_ssl_ciphers: ngnix 配置项 ssl_ciphers，证书支持的密码算法。

#### 6. admin mysql 相关配置 (需要用户自行修改)

mysql_root_password: mysql root 账户密码。

amin_user: mysql 创建业务库的普通用户名称。

admin_password: mysql 普通用户的密码。

#### 7. 配置 admin web 端口号 (建议只开通内网端口策略)

admin_web_port: 为 admin 提供 web 服务的端口。

#### 8. carrier 服务的外网 ip 地址

carrier_external_ip: carrier 的 p2p 服务开通的外网 ip (具体的外网 ip，给外部组织发现本组织用)。

#### 9. carrier 服务的端口号配置

carrier_pprof_port: carrier 的 golang 语言调试 pprof 服务监听 port，开发调试使用，建议开通内网端口策略即可，用户根据具体情况定义。

carrier_rpc_port: carrier 的 rpc server 监听的 port，开通内外网端口策略，用户根据具体情况定义。

carrier_grpc_gateway_port: carrier的 rpc api 的 restful server监听port，开通内外网端口策略，用户根据具体情况定义。

carrier_p2p_udp_port: carrier 的 p2p udp server 监听 port，开通内外网端口策略，用户根据具体情况定义。

carrier_p2p_tcp_port: carrier 的 p2p tcp server 监听 port，开通内外网端口策略，用户根据具体情况定义。

#### 10. via 服务的外网 ip 地址

via_external_ip: via 服务需要开通外网 ip，其他组织需要通过此 ip 地址和组织内 data，compute 服务通信。

#### 11. via 服务端口号

via_port: via 服务监听的 port。

#### 12. fighter(data) 服务端口号 (建议只开通内网端口策略)

data_port: 数据服务监听的端口，数组形式[8700, 8701, 8702], 端口号根据自己的部署情况进行设置，数量要和 data 组的成员数量一致。

#### 13. fighter(compute) 服务端口号 (建议只开通内网端口策略)

compute_port: 数据服务监听的端口，数组形式[8801, 8802, 8803], 端口号根据自己的部署情况进行设置，数量要和 compute 组的成员数量一致。

## 配置文件示例

`inventory.ini` 配置例子参考：[配置demo示例](./doc/ZH/配置demo示例.md)

## 组织内各个服务的网络情况

网络要求参考：[网络情况](./doc/ZH/network.md)

## 脚本的各个操作说明 (主控机准备、 初始化、部署、启动、关闭、销毁等操作)

> **请务必检查以上配置是否正确，确认正确之后再进行以下操作**

### 1. 首次部署前的准备工作 (下面两个命令是前期准备工作，只用在首次部署时执行一次，后续都不用执行)

```shell
# 在主控机上执行的准备工作，主要是下载部署相关的二进制文件，在脚本 `Metis-Deploy` 根目录执行(需要输入 sudo 密码）：

ansible-playbook --ask-sudo-pass local_prepare.yml


# 初始化集群各个节点，主要是检查目标机的环境信息（操作系统版本，python 和 python3 安装），在脚本 `Metis-Deploy` 根目录执行：

ansible-playbook -i inventory.ini bootstrap.yml
```

### 2. 安装相关服务

```shell
# 在主控机上给各个目标机安装二进制文件和配置文件 (安装对应的服务)，在脚本 `Metis-Deploy` 根目录执行：

ansible-playbook -i inventory.ini deploy.yml
```

### 3. 启动相关服务

```shell
# 在主控机上启动各个目标主机上的相关服务 (后台守护态运行)，在脚本 `Metis-Deploy` 根目录执行：

ansible-playbook -i inventory.ini start.yml
```

### 4. 停止服务

```shell
# 在主控机上停止各个目标主机上的相关服务 (用信号优雅停机)，在脚本 `Metis-Deploy` 根目录执行：

ansible-playbook -i inventory.ini stop.yml 
```

### 5. 销毁服务

> **此操作需要先停止服务，此操作为危险操作，会清除全部的数据包括 mysql 数据库里面的 admin 业务库数据，如果当前 MetisNode (组织)之前已经在 admin 管理台操作过【注册过身份信息】，那么需要先在 admin 管理台执行【注销身份】再做cleanup操作。**

```shell
# 先在主控机上停止各个目标主机上的相关服务 (用信号优雅停机)，在脚本 `Metis-Deploy` 根目录执行：

ansible-playbook -i inventory.ini stop.yml 

# 然后再在主控机上清除各个目标机上的相关服务的数据和安装的二进文件配置等信息 (清除所有数据)，在脚本 `Metis-Deploy` 根目录执行：
ansible-playbook -i inventory.ini cleanup.yml
```

## 使用说明

MetisNode 部署完成后参考：[使用说明](./doc/ZH/MetisNetwork使用说明.md)

## FAQ

部署中常见问题及解决方法参考：[FAQ](./doc/ZH/FAQ.md)


[MetisNode的各组织网络拓扑]: ./img/MetisNode的各组织网络拓扑.jpg
[单个MetisNode的内部各服务网络拓扑]: ./img/单个MetisNode的内部各服务网络拓扑.jpg
[Moirea和MetisNode间的拓扑]: ./img/Moirea和MetisNode间的拓扑.jpg