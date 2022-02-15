# metis 部署


## metis网络拓扑

metis网络由多个metisNode组成，一个MetisNode其实是一个组织的逻辑总称，关于MetisNode的网络拓扑具体如下所示：

- ### 各个MetisNode间的网络拓扑

 ![][MetisNode的各组织网络拓扑]

 MetisNode间的网络拓扑，其中在各个MetisNode之间 (也就是各个组织之间)是通过p2p网络互相建立起连接的；每个MetisNode通过自身的carrier和外界的MetisNode的carrier进行p2p连接。

- ### 单个MetisNode 内部各个服务的网络拓扑

 ![][单个MetisNode的内部各服务网络拓扑]


在MetisNode内测的各个服务划分admin, via, carrier, fighter(data), fighter(compute), consul 等角色服务。admin、carrier、via、fighter都将自身的信息自动注册到consul，各个服务间通过consul中的其他服务信息做法相互发现。对于组织内部的各服务具体功能如下：

**via 节点**：为整个组织的task消息网关，一个组织只能部署一个网关(只能有一个)。via服务提供组织和外部进行多方协助task时的唯一外网端口 (内外网端口一致)。

**carrier 节点**：为整个组织的任务调度服务，一个组织只能部署一个调度服务(只能有一个)。carrier担当起整个MetisNode 的大脑负责任务调度、资源服务调度和元数据及组织内部资源信息管理以及数据同步、p2p等等。

**admin 节点**：为整个组织的管理台 web 后端服务，一个组织有一个管理台服务(可以有多个，建议启一个)。admin则是carrier的管理台方便用户管理内部数据和资源及数据统计报表等。

**data 节点**：[fighter(data)]为整个组织的存储资源节点，可以根据自己的情况配置任意多个。

**compute 节点**：[figter(compute)]为整个组织的算力资源节点，可以根据自己的情况配置任意多个。

**consul 节点**：为整个组织的注册中心服务，一个组织建议配置奇数个（1，3，5等），方便 raft 共识算法选择 leader。


- ### MetisNode 内部必须存在的服务，以及部署时的顺序

>从上述图中我们已经知道了MetisNode内部各个服务的网络拓扑，那么简而已见 在组织内部我们必须要有的服务为 consul、 carrier、 admin，其他的服务根据自身情况而定；如果需要提供数据能力或者提供算力能力去参与多方协同计算，那么还必须有 via，和fighter，其中需要提供数据能力时需部署fighter(data)、需要提供算力能力时部署fighter(compute)。

**服务部署的顺序为: [1] consul服务 -> [2] carrier 服务 -> [3] admin服务, 然后根据实际情况 部署 [4] via 服务 -> [5] fighter(data)服务、fighter(compute)服务**


- ### Moirea 和 MetisNode 的关系

![][Moirea和MetisNode间的拓扑]

Moirea可以理解为是一个提供数据市场、全网数据统计、任务工作流管理的平台。 可以搭建在自己组织内部，那么它和自身组织的MetisNode是一对一关系； 也可以通过moirea界面添加外部MetisNode的carrier外网ip和port对接其他外部MetisNode这样是一对多关系，moirea的具体操作说明请参照moirea的相关文档。


## MetisNode部署单组织部署说明

本脚本为ansible自动化部署脚本，包括单组织内部 admin, via, carrier, fighter(data), fighter(compute), consul 角色服务，ansible 脚本支持[部署]，[启动]，[停止]，[清理]各个角色节点。



## 环境要求


分为主控机(发布机)和目标机(各服务部署的机器)。

1、 稳定版 ansible 主控机和目标机仅支持 Ubuntu 18.04 操作系统。

2、 处理器架构仅支持 x86_64 架构的处理器。

3、 检查 python2.7 和 python3.6 是否安装，没有安装会进行安装(默认 Ubuntu 18.04自带python2.7 和 python3.6)。


### 主控机的环境和部署前准备工作


1、在主控机上下载脚本：

```sh
# 使用git 下载本脚本项目
git clone http://192.168.9.66/Metisnetwork/metis-deploy.git

# 进入项目目录
cd metis-deploy

# 切换项目到 ansible 分支
git checkout ansible

# 创建日志目录
mkdir log
```


2、 主控机上安装 `ansible` 和 `依赖模块`, 执行命令 (如果已经安装过 ansible, 请先卸载)：

```sh
# 先进入本项目目录
cd metis-deploy

# 安装 ansible 和 依赖模块
pip install -r ./requirements.txt
```


3、检查 ansible 版本(>2.4.2, 建议2.7.11)，检查 jinja2 安装和版本(>=2.9.6)信息。

4、 检查主机(内网)IP清单（inventory.ini）配置是否正确。至少包括一个 consul 主机， ssh 账户不支持 root 只能用普通账户。

5、 创建下载目录，检查网络连接，无法连接外网直接报错退出。

6、 下载安装包(脚本会自动从官方远端仓库)到下载目录(go 二进制文件，jar 包，web 静态资源文件， whl 文件，shell 脚本)，下载任务最多运行 3 次，每次尝试的延迟是10之内的随机值。执行命令：

```sh

# 注意: 这串命令什么时候执行, 后面会有说明, 看到这里的你可先忽略

ansible-playbook -i inventory.ini local_prepare.yml
```


## 配置文件说明


本部署脚本主要需要用户自行配置下述几个文件：

1. 管理组织内部所有服务的网络拓扑的 `inventory.ini` 文件。
 
2. 管理各个服务所需的配置项的 `group_vars/all.yml` 文件。


### 配置文件用途说明

inventory.ini: 组织中各个服务的主机(内网)ip的相关配置，由用户根据自己情况定义。

group_vars/all.yml: 组织各个服务的相关配置项配置，由用户根据自己情况定义。

ansible.cfg: ansible 配置文件，建议不要乱动。

config目录: 相关配置模版，建议不要乱动。

roles目录: ansible tasks 的集合，建议不要乱动。

local_prepare.yml: 用来下载相关安装包的配置，建议不要乱动。

bootstrap.yml: 初始化集群各个节点的配置，建议不要乱动。

deploy.yml: 安装各个服务，建议不要乱动。

start.yml: 启动所有服务，建议不要乱动。

stop.yml: 停止所有服务，建议不要乱动。

cleanup.yml: 销毁集群，建议不要乱动。



### 单组织内部各服务的主机网络拓扑配置文件 `inventory.ini`


在metis-deploy项目的根目录下有一名为`inventory.ini`的配置文件，它管理者单组织内部各个服务所部署的主机(内网)IP情况(注: inventory.ini 不可重新命名)。用户根据自己的网络情况配置各个服务部署机器的 ip 地址。

配置仅支持两种形式，【一】支持所有服务部署在一台机器上(即: 单个宿主机部署单个组织所有服务, 建议只在测试阶段使用); 【二】支持每台宿主机不是一个服务 (生产阶段建议使用这种)。

目前远程主机登录不支持 root 用户，只支持普通用户，且这个用户要支持 sudo 提权。

`ansible_ssh_user` 设置为要登录目标主机的 ssh 用户名, `ansible_ssh_pass` 为ssh 用户对应的密码, `ansible_sudo_pass` 为目标主机上的用户进行提权时的密码。


#### 文件的各个项的说明如下：


```ini
# 库存文件，主要用来配置主机列表和主机组

# 任务网关，一个组织有一个网关服务
[via]
${宿主机IP} ansible_ssh_user="${账户}" ansible_ssh_pass="${密码}" ansible_sudo_pass="${root账户密码}"

# 调度，一个组织有一个调度服务
[carrier]
${宿主机IP} ansible_ssh_user="${账户}" ansible_ssh_pass="${密码}" ansible_sudo_pass="${root账户密码}"

# 管理台，一个组织有一个管理台服务
[admin]
192.168.10.152 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

# 资源节点，一个组织可以配置多个资源服务
[data]
${宿主机IP} ansible_ssh_user="${账户}" ansible_ssh_pass="${密码}" ansible_sudo_pass="${root账户密码}"

# 计算节点，一个组织可以配置多个计算服务
[compute]
${宿主机IP} ansible_ssh_user="${账户}" ansible_ssh_pass="${密码}" ansible_sudo_pass="${root账户密码}"

# 注册中心，一个组织要配置奇数个(1, 3, 5个等）注册中心，方便 raft 选择leader
[consul]
${宿主机IP} ansible_ssh_user="${账户}" ansible_ssh_pass="${密码}" ansible_sudo_pass="${root账户密码}"


## Global variables
[all:vars]

# 在宿主机上启动 binary 或者是 docker (目前只支持 binary)
deployment_method = binary

## Connection (不要乱动)
# 不支持 root 账户 ssh，只支持普通账户
# ssh via normal user
# ansible_user = user1

#集群的名称，自定义即可
cluster_name = demo-cluster

```


### 下面分别是单个宿主机部署单组织所有服务和每台宿主机部署单个服务的`inventory.ini`文件示例：


#### 单个宿主机部署单组织所有服务示例： (建议只在测试阶段使用)

```ini

# 下面是 单组织的一个consul服务、一个via服务(必须)、一个carrier服务(必须)、一个admin服务(必须)、三个data服务(非必须)、三个compute服务(非必须)的网络配置

# 库存文件，主要用来配置主机列表和主机组

# 任务网关，一个组织有一个网关服务
[via]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 调度，一个组织有一个调度服务
[carrier]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 管理台，一个组织有一个管理台服务
[admin]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 资源节点，一个组织可以配置多个资源服务 (单宿主机多data服务的话也只配一个IP即可)
[data]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 计算节点，一个组织可以配置多个计算服务 (单宿主机多data服务的话也只配一个IP即可)
[compute]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 注册中心，一个组织要配置奇数个(1, 3, 5个等）注册中心，方便 raft 选择leader (单宿主机多data服务的话也只配一个IP即可)
[consul]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

## Global variables
[all:vars]

# 在宿主机上启动 binary 或者是 docker
deployment_method = binary

## Connection
# 不支持 root 账户 ssh，只支持普通账户
# ssh via normal user
# ansible_user = user1

#集群的名称，自定义即可
cluster_name = demo-cluster
```


#### 每台宿主机部署单个服务的示例： (建议生产阶段使用这种形式)

```ini

# 下面是 单组织的三个consul服务集群、一个via服务(必须)、一个carrier服务(必须)、一个admin服务(必须)、三个data服务(非必须)、三个compute服务(非必须)的网络配置

# 库存文件，主要用来配置主机列表和主机组

# 任务网关，一个组织有一个网关服务
[via]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 调度，一个组织有一个调度服务
[carrier]
192.168.10.151 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 管理台，一个组织有一个管理台服务
[admin]
192.168.10.152 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 资源节点，一个组织可以配置多个资源服务
[data]
192.168.10.153 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"
192.168.10.154 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"
192.168.10.155 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 计算节点，一个组织可以配置多个计算服务
[compute]
192.168.10.156 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"
192.168.10.157 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"
192.168.10.158 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

# 注册中心，一个组织要配置奇数个(1, 3, 5个等）注册中心，方便 raft 选择leader
[consul]
192.168.10.140 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"
192.168.10.141 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"
192.168.10.142 ansible_ssh_user="user1" ansible_ssh_pass="123456" ansible_sudo_pass="root123456"

## Global variables
[all:vars]

# 在宿主机上启动 binary 或者是 docker
deployment_method = binary

## Connection
# 不支持 root 账户 ssh，只支持普通账户
# ssh via normal user
# ansible_user = user1

#集群的名称，自定义即可
cluster_name = demo-cluster
```

## 配置 `group_vars/all.yml` 中各项说明 (仅对用户可能需要修改的项做说明)：

### 配置项说明

#### 1. 部署服务开关选项

enable_deploy_via: 是否部署、启动、关闭、销毁 via，部署为 true，不部署设置为 false。

enable_deploy_carrier: 是否部署、启动、关闭、销毁 carrier，部署为 true，不部署设置为 false。

enable_deploy_admin: 是否部署、启动、关闭、销毁 admin，部署为 true，不部署设置为 false。

enable_deploy_data: 是否部署、启动、关闭、销毁 data，部署为 true，不部署设置为 false。

enable_deploy_compute: 是否部署、启动、关闭、销毁 compute，部署为 true，不部署设置为 false。

enable_deploy_consul: 是否部署、启动、关闭、销毁 consul, 部署为 true，不部署设置为 false。


#### 2. 设置检查对应的服务的进程是否存在 (可忽略不管)

check_service_status: 需要检查设置为 true， 否则设置为 false。


#### 3. consul的 key-value 选项

via_external_ip: via服务的外网IP (需要用户自行修改)

via_external_port: via服务的外网端口 (需要用户自行修改)

storage_port: (不要乱动)


#### 4. 配置 consul 端口号 (建议只开通内网端口策略)

consul_server_port: consul服务的端口，数组形式[8200, 8201, 8202], 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。

consul_serf_lan_port: Serf LAN gossip 通信应该绑定的端口，数组形式[8300, 8301, 8302], 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。

consul_serf_wan_port: Serf WAN gossip 通信应该绑定的端口，数组形式[8400, 8401, 8402], 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。

consul_http_port: HTTP API 端口，数组形式[8500, 8501, 8502], 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。

consul_dns_port:  DNS 服务器端口，数组形式[8600, 8601, 8602], 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。



#### 5. admin web 证书相关配置  (不要乱动)

enable_tls: 是否启用 https，启用设置为 true，需要配置证书和相应的域名，证书里面的密码套件等，不启用设置为 false，同时忽略下面的配置。

admin_server_name: ngnix 配置项 server_name，admin 服务部署的机器的域名。

admin_ssl_protocols: ngnix 配置项 ssl_protocols，证书支持的 tls 版本。

admin_ssl_ciphers: ngnix 配置项 ssl_ciphers，证书支持的密码算法。



#### 6. admin mysql 相关配置 (需要用户自行修改)

mysql_root_password: mysql root 账户密码。

amin_user: mysql 创建业务库的普通用户名称。

admin_password: mysql 普通用户的密码。


#### 7. 配置 admin web 端口号 (建议只开通内网端口策略)

admin_web_port: 为 admin 提供 web 服务的端口。

#### 8. carrier 服务的启动命令行各个ip配置

carrier_p2p_external_ip: carrier的p2p服务开通的外网ip (写具体的外网ip，给外部组织发现本组织用)。


#### 9. carrier 服务的启动命令行各个port配置

carrier_pprof_port: carrier的golang语言调试pprof服务监听port，开通内外网端口策略，用户根据具体情况定义。

carrier_rpc_port: carrier的rpc server监听的port，开通内外网端口策略，用户根据具体情况定义。

carrier_grpc_gateway_port: carrier的 rpc api 的 restful server监听port，开通内外网端口策略，用户根据具体情况定义。

carrier_p2p_udp_port: carrier的 p2p udp server 监听port，开通内外网端口策略，用户根据具体情况定义。

carrier_p2p_tcp_port: carrier的 p2p tcp server 监听port，开通内外网端口策略，用户根据具体情况定义。


#### 10. carrier 服务连接进metis网络时优先连接的引导节点的nodeId数组 (enr前缀格式)

bootstrap_nodes: 数组形式，如: ["enr:-Jy...CJzM", "enr:-Jy4Q...JzM"] (建议不要自己添加，直接使用官方提供的)



#### 11. via 服务端口号 (建议只开通内网端口策略)

via_port: via服务监听的port。


#### 12. fighter(data) 服务端口号 (建议只开通内网端口策略)

data_port: 数据服务监听的端口，数组形式[8700, 8701, 8702], 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。



#### 13. fighter(compute) 服务端口号 (建议只开通内网端口策略)

compute_port: 数据服务监听的端口，数组形式[8801, 8802, 8803], 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。


### 下面分别是单个宿主机部署单组织所有服务和每台宿主机部署单个服务的`group_vars/all.yml`文件示例：


#### 单个宿主机部署单组织所有服务示例： (配套单宿主机的`inventory.ini`文件使用, 建议只在测试阶段使用)

```yml
---

# ############################################### 部署服务开关选项 ###############################################
enable_deploy_via: true
enable_deploy_carrier: true
enable_deploy_admin: true
enable_deploy_data: true
enable_deploy_compute: true
enable_deploy_consul: true

# 检查服务的状态
check_service_status: true

# ############################################### consul的 key-value 选项 ###############################################

via_external_ip: 39.98.126.50
via_external_port: "{{ via_port | int}}"
storage_port: 9098


# ############################################### 各服务配置项 ###############################################

## ---------------------------- consul 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# consul 端口号
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

## ---------------------------- admin web 服务配置 ----------------------------
# admin web 服务证书相关配置信息
enable_tls: false # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name: metis-admin.platon.network
admin_ssl_protocols: "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers: ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password: 123456
amin_user: metis_admin
admin_password: admin_123456

# admin 端口号
admin_web_port: 9090

## ---------------------------- carrier 服务配置 ----------------------------
# carrier 端口号
carrier_pprof_port: 10032
carrier_rpc_port: 10033
carrier_grpc_gateway_port: 10034
carrier_p2p_udp_port: 10035
carrier_p2p_tcp_port: 10036
# carrier 服务连接进metis网络时优先连接的引导节点的nodeId数组 (enr前缀格式)
bootstrap_nodes: []

## ---------------------------- via 服务配置 ----------------------------

# via 服务端口号
via_port: 10031

## ---------------------------- fighter(data) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# data 端口号
data_port: [8700]

## ---------------------------- fighter(compute) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# compute 端口号
compute_port: [8801]

############################################################################################## 用户不需要改动的、不需要关心的配置项 ##############################################################################################

# #### 下面的变量不建议用户修改 ####

# 服务静态文件下载 url
download_url: "http://192.168.9.150/metis/"
consul_download_url: "http://192.168.9.150/metis/consul_1.10.4_linux_amd64.zip"

# 证书文件，非必改目录
via_cert_dir:   "{{ playbook_dir }}/config/via_cert"
carrier_cert_dir:   "{{ playbook_dir }}/config/carrier_cert"
admin_cert_dir:   "{{ playbook_dir }}/config/admin_cert"
scan_cert_dir:   "{{ playbook_dir }}/config/scan_cert"
storage_cert_dir:   "{{ playbook_dir }}/config/storage_cert"
compute_cert_dir:   "{{ playbook_dir }}/config/compute_cert"
data_cert_dir:   "{{ playbook_dir }}/config/data_cert"

# #### 下面的变量不能进行更改 ####

# 公共变量
listen_all_ip: 0.0.0.0
carrier_pprof_ip: "{{ listen_all_ip }}"
carrier_rpc_ip: "{{ listen_all_ip }}"
carrier_grpc_gateway_ip: "{{ listen_all_ip }}"
carrier_p2p_listen_ip: "{{ listen_all_ip }}"

# 文件下载目录，非必改变量
downloads_dir: "{{ playbook_dir }}/downloads"
avx2: "{{ downloads_dir }}/avx2"
no_avx2: "{{ downloads_dir }}/no_avx2"

# 目标主机文件安装目录
deploy_dir: "/home/{{ansible_ssh_user}}"


# via 相关信息
via_ip: "{{ groups['via'][0] }}"

# storage 相关信息
storage_host: "{{ groups['storage'][0] }}"
storage_ip: "192.168.10.149"

# consul agent 信息
consul_zip_name: "{{ consul_download_url.split('/')[-1] | trim }}"
consul_number_int: "{{ groups['consul'] | length | int}}"
consul_leader_ip: "{{ groups['consul'][0] }}"
consul_leader_port: "{{ consul_http_port[0] }}"
consul_leader_serf_lan_port: "{{ consul_serf_lan_port[0] }}"
consul_http_port_self:   "{% set consul_number_int = consul_number_int | int %}
                          {% for i in range(consul_number_int) %}
                              {% if groups['consul'][i] == inventory_hostname %}
                                {{consul_http_port[i] |int}}
                              {% endif %}
                          {% endfor %}"

# data 相关信息
data_port_self: "{% set data_number_int = groups['data'] | length |int %} 
                  {% for i in range(data_number_int) %}
                    {% if groups['data'][i] == inventory_hostname %}
                      {{data_port[i] |int}}  
                    {% endif %}
                  {% endfor %}"

# compute 相关信息
compute_port_self: "{% set compute_number_int = groups['compute'] | length |int %} 
                    {% for i in range(compute_number_int) %}
                      {% if groups['compute'][i] == inventory_hostname %}
                        {{compute_port[i] |int}}  
                      {% endif %}
                    {% endfor %}"

#目标机系统自带Python版本
self_python_version: 3.6.9

```

#### 每台宿主机部署单个服务的示例： (配套每台宿主机部署单个服务的`inventory.ini`文件使用, 建议生产阶段使用这种形式)


```yml
---

# ############################################### 部署服务开关选项 ###############################################
enable_deploy_via: true
enable_deploy_carrier: true
enable_deploy_admin: true
enable_deploy_data: true
enable_deploy_compute: true
enable_deploy_consul: true

# 检查服务的状态
check_service_status: true

# ############################################### consul的 key-value 选项 ###############################################

via_external_ip: 39.98.126.50
via_external_port: "{{ via_port | int}}"
storage_port: 9098


# ############################################### 各服务配置项 ###############################################

## ---------------------------- consul 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# consul 端口号
consul_server_port: [8200, 8201, 8202]
consul_serf_lan_port: [8300, 8301, 8302]
consul_serf_wan_port: [8400, 8401, 8402]
consul_http_port: [8500, 8501, 8502]
consul_dns_port: [8600, 8601, 8602]

## ---------------------------- admin web 服务配置 ----------------------------
# admin web 服务证书相关配置信息
enable_tls: false # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name: metis-admin.platon.network
admin_ssl_protocols: "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers: ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password: 123456
amin_user: metis_admin
admin_password: admin_123456

# admin 端口号
admin_web_port: 9090

## ---------------------------- carrier 服务配置 ----------------------------
# carrier 服务相关网络配置
carrier_p2p_external_ip: xxx.xxx.xxx.xxx
# carrier 端口号
carrier_pprof_port: 10032
carrier_rpc_port: 10033
carrier_grpc_gateway_port: 10034
carrier_p2p_udp_port: 10035
carrier_p2p_tcp_port: 10036
# carrier 服务连接进metis网络时优先连接的引导节点的nodeId数组 (enr前缀格式)
bootstrap_nodes: []

## ---------------------------- via 服务配置 ----------------------------

# via 服务端口号
via_port: 10031

## ---------------------------- fighter(data) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# data 端口号
data_port: [8700, 8701, 8702]

## ---------------------------- fighter(compute) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# compute 端口号
compute_port: [8801, 8802, 8803]

############################################################################################## 用户不需要改动的、不需要关心的配置项 ##############################################################################################

# #### 下面的变量不建议用户修改 ####

# 服务静态文件下载 url
download_url: "http://192.168.9.150/metis/"
consul_download_url: "http://192.168.9.150/metis/consul_1.10.4_linux_amd64.zip"

# 证书文件，非必改目录
via_cert_dir:   "{{ playbook_dir }}/config/via_cert"
carrier_cert_dir:   "{{ playbook_dir }}/config/carrier_cert"
admin_cert_dir:   "{{ playbook_dir }}/config/admin_cert"
scan_cert_dir:   "{{ playbook_dir }}/config/scan_cert"
storage_cert_dir:   "{{ playbook_dir }}/config/storage_cert"
compute_cert_dir:   "{{ playbook_dir }}/config/compute_cert"
data_cert_dir:   "{{ playbook_dir }}/config/data_cert"

# #### 下面的变量不能进行更改 ####

# 公共变量
listen_all_ip: 0.0.0.0
carrier_pprof_ip: "{{ listen_all_ip }}"
carrier_rpc_ip: "{{ listen_all_ip }}"
carrier_grpc_gateway_ip: "{{ listen_all_ip }}"
carrier_p2p_listen_ip: "{{ listen_all_ip }}"

# 文件下载目录，非必改变量
downloads_dir: "{{ playbook_dir }}/downloads"
avx2: "{{ downloads_dir }}/avx2"
no_avx2: "{{ downloads_dir }}/no_avx2"

# 目标主机文件安装目录
deploy_dir: "/home/{{ansible_ssh_user}}"


# via 相关信息
via_ip: "{{ groups['via'][0] }}"

# storage 相关信息
storage_host: "{{ groups['storage'][0] }}"
storage_ip: "192.168.10.149"

# consul agent 信息
consul_zip_name: "{{ consul_download_url.split('/')[-1] | trim }}"
consul_number_int: "{{ groups['consul'] | length | int}}"
consul_leader_ip: "{{ groups['consul'][0] }}"
consul_leader_port: "{{ consul_http_port[0] }}"
consul_leader_serf_lan_port: "{{ consul_serf_lan_port[0] }}"
consul_http_port_self:   "{% set consul_number_int = consul_number_int | int %}
                          {% for i in range(consul_number_int) %}
                              {% if groups['consul'][i] == inventory_hostname %}
                                {{consul_http_port[i] |int}}
                              {% endif %}
                          {% endfor %}"

# data 相关信息
data_port_self: "{% set data_number_int = groups['data'] | length |int %} 
                  {% for i in range(data_number_int) %}
                    {% if groups['data'][i] == inventory_hostname %}
                      {{data_port[i] |int}}  
                    {% endif %}
                  {% endfor %}"

# compute 相关信息
compute_port_self: "{% set compute_number_int = groups['compute'] | length |int %} 
                    {% for i in range(compute_number_int) %}
                      {% if groups['compute'][i] == inventory_hostname %}
                        {{compute_port[i] |int}}  
                      {% endif %}
                    {% endfor %}"

#目标机系统自带Python版本
self_python_version: 3.6.9


```



## 脚本的各个操作说明 (预准备、部署、启动、关闭、销毁等操作)


**请务必检查以上配置是否正确，确认正确之后再进行以下操作**

### 1. 首次部署前的准备工作 (下面两个命令是前期准备工作，只用在首次部署时执行一次，后续都不用执行)

```shell
# 在主控机上执行的准备工作，主要是下载部署相关的二进制文件，在脚本`metis-deploy`根目录执行：

ansible-playbook -i inventory.ini local_prepare.yml


# 初始化集群各个节点，主要是检查目标机的环境信息（操作系统版本，python 和 python3 安装），在脚本`metis-deploy`根目录执行：

ansible-playbook -i inventory.ini bootstrap.yml
```


### 2. 安装相关服务

```shell
# 在主控机上给各个目标机安装二进制文件和配置文件 (安装对应的服务)，在脚本`metis-deploy`根目录执行：

ansible-playbook -i inventory.ini deploy.yml
```

### 3. 启动相关服务

```shell
# 在主控机上启动(后台运行)各个目标主机上的相关服务 (启动对应的服务)，在脚本`metis-deploy`根目录执行：

ansible-playbook -i inventory.ini start.yml
```

4. 停止服务

```shell
# 在主控机上停止各个目标主机上的相关服务 (停止对应的服务)，在脚本`metis-deploy`根目录执行：

ansible-playbook -i inventory.ini stop.yml 
```

5. 销毁服务

**此操作需要先停止服务，此操作为危险操作，会清除全部的数据包括 mysql 数据库里面的 admin 业务库数据**

```shell
# 先在主控机上停止各个目标主机上的相关服务 (停止对应的服务)，在脚本`metis-deploy`根目录执行：

ansible-playbook -i inventory.ini stop.yml 

# 然后再在主控机上清除各个目标机上的相关服务的数据和安装的二进文件配置等信息 (清除所有数据)，在脚本`metis-deploy`根目录执行：
ansible-playbook -i inventory.ini cleanup.yml
```


## 部署单组织demo

根据上述操作说明，下面我们具体的写个demo来部署我们的网络，根据之前的部署情况我们区分为两种情况，【一】支持所有服务部署在一台机器上 (即: 单个宿主机部署单个组织所有服务, 建议只在测试阶段使用); 【二】支持每台宿主机不是一个服务 (生产阶段建议使用这种)。


### 【一】支持所有服务部署在一台机器 (即: 单个宿主机部署单个组织所有服务, 建议只在测试阶段使用)


#### 1、 一次性部署组织各个服务

假设我们只有 1 台机器 (内网IP为: 192.168.10.150)，则最开始必须只能部署各个服务的MVP模式组织(MVP模式组织即: 一台consul、一台admin、一台via、一台carrier、零台或最多一台fighter(data)和零台或最多一台fighter(compute))。

其中consul的内部端口分别为: `8200`、 `8300`、 `8400`、 `8500`、 `8600`; admin web服务的内网端口`9090`; 

carrier的外网IP为`39.98.126.40`、内网pprof端口`7701`、内网gateway端口`7702`、内外部rpc端口为`10030`、外部udp端口`10031`、外部tcp端口`10032`; 

via的外网IP为`39.98.126.40`、via的内外网端口为`10040`;

fighter(data)服务的内部端口`30000` (注意: 另外需要开通100个内网端口段 31000 ~ 31100);

fighter(compute)服务的内部端口`40000` (注意: 另外需要开通100个内网端口段 41000 ~ 41100)。


那么我们有如下配置: 


- ##### 1.1、 配置 `inventory.ini`文件

```ini
# 库存文件，主要用来配置主机列表和主机组

# 任务网关，一个组织有一个网关服务
[via]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

# 调度，一个组织有一个调度服务
[carrier]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

# 管理台，一个组织有一个管理台服务
[admin]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

# 资源节点，一个组织可以配置多个资源服务
[data]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"


# 计算节点，一个组织可以配置多个计算服务
[compute]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

# 注册中心，一个组织要配置奇数个(3,5,等）注册中心，方便 raft 选择leader
[consul]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

## Global variables
[all:vars]

# 在宿主机上启动 binary 或者是 docker
deployment_method = binary

## Connection
# 不支持 root 账户 ssh，只支持普通账户
# ssh via normal user
# ansible_user = user1

#集群的名称，自定义即可
cluster_name = demo-cluster
```

- #### 1.2、配置 `group_vars/all.yml`文件

```yml
---


# ############################################### 部署服务开关选项 ###############################################
enable_deploy_via: true
enable_deploy_carrier: true
enable_deploy_admin: true
enable_deploy_data: true
enable_deploy_compute: true
enable_deploy_consul: true

# 检查服务的状态
check_service_status: true

# ############################################### consul的 key-value 选项 ###############################################

via_external_ip: 39.98.126.40
via_external_port: "{{ via_port | int}}"
storage_port: 9098


# ############################################### 各服务配置项 ###############################################

## ---------------------------- consul 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# consul 端口号
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

## ---------------------------- admin web 服务配置 ----------------------------
# admin web 服务证书相关配置信息
enable_tls: false # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name: metis-admin.platon.network
admin_ssl_protocols: "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers: ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password: 123456
amin_user: metis_admin
admin_password: admin_123456

# admin 端口号
admin_web_port: 9090

## ---------------------------- carrier 服务配置 ----------------------------
# carrier 服务相关网络配置
carrier_p2p_external_ip: 39.98.126.40
# carrier 端口号
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032
# carrier 服务连接进metis网络时优先连接的引导节点的nodeId数组 (enr前缀格式)
bootstrap_nodes: ["Suggestion: don't touch here"]

## ---------------------------- via 服务配置 ----------------------------

# via 服务端口号
via_port: 10040

## ---------------------------- fighter(data) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# data 端口号
data_port: [30000]

## ---------------------------- fighter(compute) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# compute 端口号
compute_port: [40000]

############################################################################################## 用户不需要改动的、不需要关心的配置项 ##############################################################################################

# #### 下面的变量不建议用户修改 ####

# 服务静态文件下载 url
download_url: "http://192.168.9.150/metis/"
consul_download_url: "http://192.168.9.150/metis/consul_1.10.4_linux_amd64.zip"

# 证书文件，非必改目录
via_cert_dir:   "{{ playbook_dir }}/config/via_cert"
carrier_cert_dir:   "{{ playbook_dir }}/config/carrier_cert"
admin_cert_dir:   "{{ playbook_dir }}/config/admin_cert"
scan_cert_dir:   "{{ playbook_dir }}/config/scan_cert"
storage_cert_dir:   "{{ playbook_dir }}/config/storage_cert"
compute_cert_dir:   "{{ playbook_dir }}/config/compute_cert"
data_cert_dir:   "{{ playbook_dir }}/config/data_cert"

# #### 下面的变量不能进行更改 ####

# 公共变量
listen_all_ip: 0.0.0.0
carrier_pprof_ip: "{{ listen_all_ip }}"
carrier_rpc_ip: "{{ listen_all_ip }}"
carrier_grpc_gateway_ip: "{{ listen_all_ip }}"
carrier_p2p_listen_ip: "{{ listen_all_ip }}"

# 文件下载目录，非必改变量
downloads_dir: "{{ playbook_dir }}/downloads"
avx2: "{{ downloads_dir }}/avx2"
no_avx2: "{{ downloads_dir }}/no_avx2"

# 目标主机文件安装目录
deploy_dir: "/home/{{ansible_ssh_user}}"


# via 相关信息
via_ip: "{{ groups['via'][0] }}"

# storage 相关信息
storage_host: "{{ groups['storage'][0] }}"
storage_ip: "192.168.10.149"

# consul agent 信息
consul_zip_name: "{{ consul_download_url.split('/')[-1] | trim }}"
consul_number_int: "{{ groups['consul'] | length | int}}"
consul_leader_ip: "{{ groups['consul'][0] }}"
consul_leader_port: "{{ consul_http_port[0] }}"
consul_leader_serf_lan_port: "{{ consul_serf_lan_port[0] }}"
consul_http_port_self:   "{% set consul_number_int = consul_number_int | int %}
                          {% for i in range(consul_number_int) %}
                              {% if groups['consul'][i] == inventory_hostname %}
                                {{consul_http_port[i] |int}}
                              {% endif %}
                          {% endfor %}"

# data 相关信息
data_port_self: "{% set data_number_int = groups['data'] | length |int %} 
                  {% for i in range(data_number_int) %}
                    {% if groups['data'][i] == inventory_hostname %}
                      {{data_port[i] |int}}  
                    {% endif %}
                  {% endfor %}"

# compute 相关信息
compute_port_self: "{% set compute_number_int = groups['compute'] | length |int %} 
                    {% for i in range(compute_number_int) %}
                      {% if groups['compute'][i] == inventory_hostname %}
                        {{compute_port[i] |int}}  
                      {% endif %}
                    {% endfor %}"

#目标机系统自带Python版本
self_python_version: 3.6.9


```

- ##### 1.3、 根据[脚本的各个操作说明]出的操作说明将组织内的各个服务启动


#### 2、 动态添加数据服务fighter(data)和计算服务fighter(compute)


例如，根据上面的操作我们在`192.168.10.150`这台机器的各个服务启动了，这时候我们又需要新增数据服务或者计算服务(注意: 每次新增fighter(data)或者fighter(compute)只能先修改相关配置单个新增，然后再修改配置再单个新增，以此类推逐个的去新增)。


其中一台fighter(data)服务的内部端口可以都用`30001` (注意: 因为都部署在一台机器上，而之前已经部署了30000端口的fighter(data)故本次新增的fighter(data)需要用30001以防止端口冲突);

另一台fighter(compute)服务的内部端口可以都用`40001` (注意: 因为都部署在一台机器上，而之前已经部署了40000端口的fighter(compute)故本次新增的fighter(compute)需要用40001以防止端口冲突);

那么我们修改配置如下：


- ##### 2.1、 配置 `inventory.ini`文件

```ini
# 库存文件，主要用来配置主机列表和主机组

# 任务网关，一个组织有一个网关服务
[via]

# 调度，一个组织有一个调度服务
[carrier]

# 管理台，一个组织有一个管理台服务
[admin]

# 资源节点，一个组织可以配置多个资源服务
[data]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"


# 计算节点，一个组织可以配置多个计算服务
[compute]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"


# 注册中心，一个组织要配置奇数个(3,5,等）注册中心，方便 raft 选择leader
[consul]

## Global variables
[all:vars]

# 在宿主机上启动 binary 或者是 docker
deployment_method = binary

## Connection
# 不支持 root 账户 ssh，只支持普通账户
# ssh via normal user
# ansible_user = user1

#集群的名称，自定义即可
cluster_name = demo-cluster
```

- #### 2.2、配置 `group_vars/all.yml`文件

```yml
---

# ############################################### 部署服务开关选项 ###############################################
enable_deploy_via: false
enable_deploy_carrier: false
enable_deploy_admin: false
enable_deploy_data: true
enable_deploy_compute: true
enable_deploy_consul: false

# 检查服务的状态
check_service_status: true

# ############################################### consul的 key-value 选项 ###############################################

via_external_ip: 39.98.126.40
via_external_port: "{{ via_port | int}}"
storage_port: 9098


# ############################################### 各服务配置项 ###############################################

## ---------------------------- consul 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# consul 端口号
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

## ---------------------------- admin web 服务配置 ----------------------------
# admin web 服务证书相关配置信息
enable_tls: false # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name: metis-admin.platon.network
admin_ssl_protocols: "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers: ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password: 123456
amin_user: metis_admin
admin_password: admin_123456

# admin 端口号
admin_web_port: 9090

## ---------------------------- carrier 服务配置 ----------------------------
# carrier 服务相关网络配置
carrier_p2p_external_ip: 39.98.126.40
# carrier 端口号
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032
# carrier 服务连接进metis网络时优先连接的引导节点的nodeId数组 (enr前缀格式)
bootstrap_nodes: ["Suggestion: don't touch here"]

## ---------------------------- via 服务配置 ----------------------------

# via 服务端口号
via_port: 10040

## ---------------------------- fighter(data) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# data 端口号
data_port: [30001]

## ---------------------------- fighter(compute) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# compute 端口号
compute_port: [40001]

############################################################################################## 用户不需要改动的、不需要关心的配置项 ##############################################################################################

# #### 下面的变量不建议用户修改 ####

# 服务静态文件下载 url
download_url: "http://192.168.9.150/metis/"
consul_download_url: "http://192.168.9.150/metis/consul_1.10.4_linux_amd64.zip"

# 证书文件，非必改目录
via_cert_dir:   "{{ playbook_dir }}/config/via_cert"
carrier_cert_dir:   "{{ playbook_dir }}/config/carrier_cert"
admin_cert_dir:   "{{ playbook_dir }}/config/admin_cert"
scan_cert_dir:   "{{ playbook_dir }}/config/scan_cert"
storage_cert_dir:   "{{ playbook_dir }}/config/storage_cert"
compute_cert_dir:   "{{ playbook_dir }}/config/compute_cert"
data_cert_dir:   "{{ playbook_dir }}/config/data_cert"

# #### 下面的变量不能进行更改 ####

# 公共变量
listen_all_ip: 0.0.0.0
carrier_pprof_ip: "{{ listen_all_ip }}"
carrier_rpc_ip: "{{ listen_all_ip }}"
carrier_grpc_gateway_ip: "{{ listen_all_ip }}"
carrier_p2p_listen_ip: "{{ listen_all_ip }}"

# 文件下载目录，非必改变量
downloads_dir: "{{ playbook_dir }}/downloads"
avx2: "{{ downloads_dir }}/avx2"
no_avx2: "{{ downloads_dir }}/no_avx2"

# 目标主机文件安装目录
deploy_dir: "/home/{{ansible_ssh_user}}"


# via 相关信息
via_ip: "{{ groups['via'][0] }}"

# storage 相关信息
storage_host: "{{ groups['storage'][0] }}"
storage_ip: "192.168.10.149"

# consul agent 信息
consul_zip_name: "{{ consul_download_url.split('/')[-1] | trim }}"
consul_number_int: "{{ groups['consul'] | length | int}}"
consul_leader_ip: "{{ groups['consul'][0] }}"
consul_leader_port: "{{ consul_http_port[0] }}"
consul_leader_serf_lan_port: "{{ consul_serf_lan_port[0] }}"
consul_http_port_self:   "{% set consul_number_int = consul_number_int | int %}
                          {% for i in range(consul_number_int) %}
                              {% if groups['consul'][i] == inventory_hostname %}
                                {{consul_http_port[i] |int}}
                              {% endif %}
                          {% endfor %}"

# data 相关信息
data_port_self: "{% set data_number_int = groups['data'] | length |int %} 
                  {% for i in range(data_number_int) %}
                    {% if groups['data'][i] == inventory_hostname %}
                      {{data_port[i] |int}}  
                    {% endif %}
                  {% endfor %}"

# compute 相关信息
compute_port_self: "{% set compute_number_int = groups['compute'] | length |int %} 
                    {% for i in range(compute_number_int) %}
                      {% if groups['compute'][i] == inventory_hostname %}
                        {{compute_port[i] |int}}  
                      {% endif %}
                    {% endfor %}"

#目标机系统自带Python版本
self_python_version: 3.6.9


```

- ##### 2.3、 修改role下面的ansible的task的配置文件内容

> 如果新增 fighter(compute) 那么需要修改 `roles/compute_deploy/tasks/main.yml`文件

```
2.3.1、 在第一个`with_items`项中的路径中的compute修改为computeN, 如: 

    - '{{ deploy_dir }}/compute'
    - '{{ deploy_dir }}/compute/config'
    - '{{ deploy_dir }}/compute/contract_work_dir'
    - '{{ deploy_dir }}/compute/result_root'

    修改为:

    - '{{ deploy_dir }}/compute2'
    - '{{ deploy_dir }}/compute2/config'
    - '{{ deploy_dir }}/compute2/contract_work_dir'
    - '{{ deploy_dir }}/compute2/result_root'

2.3.2、在`set_fact`下的各个路径中的compute修改为computeN, 如: 

    code_root_dir2: '{{ deploy_dir }}/compute2/contract_work_dir'
    results_root_dir2: '{{ deploy_dir }}/compute2/result_root'

    修改为:

    code_root_dir2: '{{ deploy_dir }}/compute2/contract_work_dir'
    results_root_dir2: '{{ deploy_dir }}/compute2/result_root'


2.3.3、 以及 `- name: "copy configuration file"` 下的各个路径中的compute修改为computeN, 如:   

    - name: copy configuration file
     template:
       backup: true
       dest: '{{ deploy_dir }}/compute/config/compute.yml'
       mode: 0600
       src: compute.yml.j2

    修改成:
    
    - name: copy configuration file
     template:
       backup: true
       dest: '{{ deploy_dir }}/compute2/config/compute.yml'
       mode: 0600
       src: compute.yml.j2


2.3.4、 以及 `- name: "copy start.sh file"` 下的各个路径中的compute修改为computeN, 如:   

    # copy start.sh file
    - name: "copy start.sh file"
      copy:
        src: "{{ downloads_dir }}/start_v3_service.sh"
        dest: "{{ deploy_dir }}/compute/start_v3_service.sh"
        mode: 0755
        backup: yes
    
    修改成: 
    
    # copy start.sh file
    - name: "copy start.sh file"
      copy:
        src: "{{ downloads_dir }}/start_v3_service.sh"
        dest: "{{ deploy_dir }}/compute2/start_v3_service.sh"
        mode: 0755
        backup: yes    
```


> 如果新增 fighter(data) 那么需要修改 `roles/data_deploy/tasks/main.yml`文件

```
2.3.1、 在第一个`with_items`项中的路径中的data修改为dataN, 如: 

    - "{{ deploy_dir }}/data"
    - "{{ deploy_dir }}/data/config"
    - "{{ deploy_dir }}/data/cert"
    - "{{ deploy_dir }}/data/whl"
    - "{{ deploy_dir }}/data/data_root"
    - "{{ deploy_dir }}/data/contract_work_dir"
    - "{{ deploy_dir }}/data/result_root"

    修改为:

    - "{{ deploy_dir }}/data2"
    - "{{ deploy_dir }}/data2/config"
    - "{{ deploy_dir }}/data2/cert"
    - "{{ deploy_dir }}/data2/whl"
    - "{{ deploy_dir }}/data2/data_root"
    - "{{ deploy_dir }}/data2/contract_work_dir"
    - "{{ deploy_dir }}/data2/result_root"

2.3.2、在`set_fact`下的各个路径中的data修改为dataN, 如: 

    data_root: "{{ deploy_dir }}/data/data_root"
    code_root_dir: "{{ deploy_dir }}/data/contract_work_dir"
    results_root_dir: "{{ deploy_dir }}/data/result_root"

    修改为:

    data_root: "{{ deploy_dir }}/data2/data_root"
    code_root_dir: "{{ deploy_dir }}/data2/contract_work_dir"
    results_root_dir: "{{ deploy_dir }}/data2/result_root"


2.3.3、 以及 `- name: "copy configuration file"` 下的各个路径中的data修改为dataN, 如:    

    - name: "copy configuration file"
      template:
        src: "data.yml.j2"
        dest: "{{ deploy_dir }}/data/config/data.yml"
        mode: 0600
        backup: yes
    
    修改成:
    
    - name: "copy configuration file"
      template:
        src: "data.yml.j2"
        dest: "{{ deploy_dir }}/data2/config/data.yml"
        mode: 0600
        backup: yes


2.3.4、 以及 `- name: "copy start.sh file"` 下的各个路径中的data修改为dataN, 如:   

    # copy start.sh file
    - name: "copy start.sh file"
      copy:
        src: "{{ downloads_dir }}/start_v3_service.sh"
        dest: "{{ deploy_dir }}/data/start_v3_service.sh"
        mode: 0755
        backup: yes
    
    修改成: 
    
    # copy start.sh file
    - name: "copy start.sh file"
      copy:
        src: "{{ downloads_dir }}/start_v3_service.sh"
        dest: "{{ deploy_dir }}/data2/start_v3_service.sh"
        mode: 0755
        backup: yes  
```

- ##### 2.4、 start.yml文件的修改


> 如果新增 fighter(compute) 那么需要如下修改:

```

将 `- name: start compute` 下的 `tasks` 下的相关路径中的compute修改为computeN, 如:   


    hosts: compute
    tags:
      - compute_servers
    tasks:
      - name: start compute
        shell: "nohup {{ deploy_dir }}/compute/start_v3_service.sh {{ deploy_dir }}/compute/config/compute.yml compute {{deploy_dir}}/miniconda/envs/python375/bin/python &"
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_compute|default(false)

    修改为:


    hosts: compute
    tags:
      - compute_servers
    tasks:
      - name: start compute
        shell: "nohup {{ deploy_dir }}/compute2/start_v3_service.sh {{ deploy_dir }}/compute2/config/compute.yml compute2 {{deploy_dir}}/miniconda/envs/python375/bin/python &"
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_compute|default(false)    

```

> 如果新增 fighter(data) 那么需要如下修改:

```


将 `- name: start data` 下的 `tasks` 下的相关路径中的data修改为dataN, 如:   


    hosts: data
    tags:
      - data_servers
    tasks:
      - name: start data
        shell: "nohup {{ deploy_dir }}/data/start_v3_service.sh {{ deploy_dir }}/data/config/data.yml data {{deploy_dir}}/miniconda/envs/python375/bin/python &"
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_data|default(false)


    修改为:


    hosts: data
    tags:
      - data_servers
    tasks:
      - name: start data
        shell: "nohup {{ deploy_dir }}/data2/start_v3_service.sh {{ deploy_dir }}/data2/config/data.yml data2 {{deploy_dir}}/miniconda/envs/python375/bin/python &"
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_data|default(false)
        

```



- ##### 2.4、 stop.yml文件的修改



> 如果新增 fighter(compute) 那么需要如下修改:

```

将 `- hosts: compute` 下的 `tasks` 下的相关路径中的compute修改为computeN, 如:   


    tags:
      - compute
    tasks:
      - name: stop compute
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m metis.compute_svc.main {{ deploy_dir }}/compute/config/compute.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_compute|default(false)



    修改为:


    tags:
      - compute
    tasks:
      - name: stop compute
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m metis.compute_svc.main {{ deploy_dir }}/compute2/config/compute.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_compute|default(false)


将 `- hosts: compute` 下的 `- name: check service compute status` 下的相关路径中的compute修改为computeN, 如: 


    - name: check service compute status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m metis.compute_svc.main {{ deploy_dir }}/compute/config/compute.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status


    修改为:

    - name: check service compute status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m metis.compute_svc.main {{ deploy_dir }}/compute2/config/compute.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status



```

> 如果新增 fighter(data) 那么需要如下修改:

```

将 `- hosts: data` 下的 `tasks` 下的相关路径中的data修改为dataN, 如:   


    tags:
      - data
    tasks:
      - name: stop data
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m metis.data_svc.main {{ deploy_dir }}/data/config/data.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_data|default(false)




    修改为:


    tags:
      - data
    tasks:
      - name: stop data
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m metis.data_svc.main {{ deploy_dir }}/data2/config/data.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_data|default(false)



将 `- hosts: data` 下的 `- name: check service data status` 下的相关路径中的data修改为dataN, 如: 


    - name: check service data status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m metis.data_svc.main {{ deploy_dir }}/data/config/data.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status


    修改为:

    - name: check service data status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m metis.data_svc.main {{ deploy_dir }}/data2/config/data.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status


```



- ##### 2.4、 cleanup.yml文件的修改




> 如果新增 fighter(compute) 那么需要如下修改:

```

将 `- hosts: compute` 下的相关路径中的compute修改为computeN, 如:   


    tags:
      - compute_servers
    tasks:
      - name: clean compute
        file:
          path: "{{ deploy_dir }}/compute"
          state: absent
        when: enable_deploy_compute|default(false)



    修改为:


    tags:
      - compute_servers
    tasks:
      - name: clean compute
        file:
          path: "{{ deploy_dir }}/compute2"
          state: absent
        when: enable_deploy_compute|default(false)


```

> 如果新增 fighter(data) 那么需要如下修改:

```

将 `- hosts: data` 下的相关路径中的data修改为dataN, 如:   


    tags:
      - data_servers
    tasks:
      - name: clean data
        file:
          path: "{{ deploy_dir }}/data"
          state: absent
        when: enable_deploy_data|default(false)




    修改为:


    tags:
      - data_servers
    tasks:
      - name: clean data
        file:
          path: "{{ deploy_dir }}/data2"
          state: absent
        when: enable_deploy_data|default(false)



```


- ##### 2.5、 根据[脚本的各个操作说明]出的操作说明将组织内的各个服务启动


>**[注意]:** 不管是[启动`start`]、[停止`stop`]、[清理`cleanup`]相应的数据服务fighter(data)或者计算服务fighter(compute)都只能每次操作一个服务都需要重复 2.1 -> 2.4 步骤中对应的 ip、port 和文件路径进行修改后，再进行[启动`start`]、[停止`stop`]、[清理`cleanup`]等操作。另外单个数据服务fighter(data)和计算服务fighter(compute)可以在同一次操作中进行。




### 【二】支持每台宿主机不是一个服务时的添加数据服务和计算服务 (生产阶段建议使用这种)


#### 1、 一次性部署组织各个服务

假设我们有 8 台机器 (内网IP为: 192.168.10.150 ~ 192.168.10.157)，每台机器部署一个服务，其中一台consul、一台admin、一台via、一台carrier、fighter(data)和fighter(compute)各两台。

其中consul的内部端口分别为: `8200`、 `8300`、 `8400`、 `8500`、 `8600`; admin web服务的内网端口`9090`; 

carrier的外网IP为`39.98.126.40`、内网pprof端口`7701`、内网gateway端口`7702`、内外部rpc端口为`10030`、外部udp端口`10031`、外部tcp端口`10032`; 

via的外网IP为`39.98.126.50`、via的内外网端口为`10040`;

两台fighter(data)服务的内部端口可以都用`30000` (注意: 另外需要开通100个内网端口段 31000 ~ 31100);

两台fighter(compute)服务的内部端口可以都用`40000` (注意: 另外需要开通100个内网端口段 41000 ~ 41100)。


那么我们有如下配置: 


- ##### 1.1、 配置 `inventory.ini`文件

```ini
# 库存文件，主要用来配置主机列表和主机组

# 任务网关，一个组织有一个网关服务
[via]
192.168.10.150 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

# 调度，一个组织有一个调度服务
[carrier]
192.168.10.151 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

# 管理台，一个组织有一个管理台服务
[admin]
192.168.10.152 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

# 资源节点，一个组织可以配置多个资源服务
[data]
192.168.10.153 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"
192.168.10.154 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"


# 计算节点，一个组织可以配置多个计算服务
[compute]
192.168.10.155 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"
192.168.10.156 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

# 注册中心，一个组织要配置奇数个(3,5,等）注册中心，方便 raft 选择leader
[consul]
192.168.10.157 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"

## Global variables
[all:vars]

# 在宿主机上启动 binary 或者是 docker
deployment_method = binary

## Connection
# 不支持 root 账户 ssh，只支持普通账户
# ssh via normal user
# ansible_user = user1

#集群的名称，自定义即可
cluster_name = demo-cluster
```

- #### 1.2、配置 `group_vars/all.yml`文件

```yml
---

# ############################################### 部署服务开关选项 ###############################################
enable_deploy_via: true
enable_deploy_carrier: true
enable_deploy_admin: true
enable_deploy_data: true
enable_deploy_compute: true
enable_deploy_consul: true

# 检查服务的状态
check_service_status: true

# ############################################### consul的 key-value 选项 ###############################################

via_external_ip: 39.98.126.50
via_external_port: "{{ via_port | int}}"
storage_port: 9098


# ############################################### 各服务配置项 ###############################################

## ---------------------------- consul 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# consul 端口号
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

## ---------------------------- admin web 服务配置 ----------------------------
# admin web 服务证书相关配置信息
enable_tls: false # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name: metis-admin.platon.network
admin_ssl_protocols: "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers: ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password: 123456
amin_user: metis_admin
admin_password: admin_123456

# admin 端口号
admin_web_port: 9090

## ---------------------------- carrier 服务配置 ----------------------------
# carrier 服务相关网络配置
carrier_p2p_external_ip: 39.98.126.40
# carrier 端口号
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032
# carrier 服务连接进metis网络时优先连接的引导节点的nodeId数组 (enr前缀格式)
bootstrap_nodes: ["Suggestion: don't touch here"]

## ---------------------------- via 服务配置 ----------------------------

# via 服务端口号
via_port: 10040

## ---------------------------- fighter(data) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# data 端口号
data_port: [30000, 30000]

## ---------------------------- fighter(compute) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# compute 端口号
compute_port: [40000, 40000]

############################################################################################## 用户不需要改动的、不需要关心的配置项 ##############################################################################################

# #### 下面的变量不建议用户修改 ####

# 服务静态文件下载 url
download_url: "http://192.168.9.150/metis/"
consul_download_url: "http://192.168.9.150/metis/consul_1.10.4_linux_amd64.zip"

# 证书文件，非必改目录
via_cert_dir:   "{{ playbook_dir }}/config/via_cert"
carrier_cert_dir:   "{{ playbook_dir }}/config/carrier_cert"
admin_cert_dir:   "{{ playbook_dir }}/config/admin_cert"
scan_cert_dir:   "{{ playbook_dir }}/config/scan_cert"
storage_cert_dir:   "{{ playbook_dir }}/config/storage_cert"
compute_cert_dir:   "{{ playbook_dir }}/config/compute_cert"
data_cert_dir:   "{{ playbook_dir }}/config/data_cert"

# #### 下面的变量不能进行更改 ####

# 公共变量
listen_all_ip: 0.0.0.0
carrier_pprof_ip: "{{ listen_all_ip }}"
carrier_rpc_ip: "{{ listen_all_ip }}"
carrier_grpc_gateway_ip: "{{ listen_all_ip }}"
carrier_p2p_listen_ip: "{{ listen_all_ip }}"

# 文件下载目录，非必改变量
downloads_dir: "{{ playbook_dir }}/downloads"
avx2: "{{ downloads_dir }}/avx2"
no_avx2: "{{ downloads_dir }}/no_avx2"

# 目标主机文件安装目录
deploy_dir: "/home/{{ansible_ssh_user}}"


# via 相关信息
via_ip: "{{ groups['via'][0] }}"

# storage 相关信息
storage_host: "{{ groups['storage'][0] }}"
storage_ip: "192.168.10.149"

# consul agent 信息
consul_zip_name: "{{ consul_download_url.split('/')[-1] | trim }}"
consul_number_int: "{{ groups['consul'] | length | int}}"
consul_leader_ip: "{{ groups['consul'][0] }}"
consul_leader_port: "{{ consul_http_port[0] }}"
consul_leader_serf_lan_port: "{{ consul_serf_lan_port[0] }}"
consul_http_port_self:   "{% set consul_number_int = consul_number_int | int %}
                          {% for i in range(consul_number_int) %}
                              {% if groups['consul'][i] == inventory_hostname %}
                                {{consul_http_port[i] |int}}
                              {% endif %}
                          {% endfor %}"

# data 相关信息
data_port_self: "{% set data_number_int = groups['data'] | length |int %} 
                  {% for i in range(data_number_int) %}
                    {% if groups['data'][i] == inventory_hostname %}
                      {{data_port[i] |int}}  
                    {% endif %}
                  {% endfor %}"

# compute 相关信息
compute_port_self: "{% set compute_number_int = groups['compute'] | length |int %} 
                    {% for i in range(compute_number_int) %}
                      {% if groups['compute'][i] == inventory_hostname %}
                        {{compute_port[i] |int}}  
                      {% endif %}
                    {% endfor %}"

#目标机系统自带Python版本
self_python_version: 3.6.9


```

- ##### 1.3、 根据[脚本的各个操作说明]出的操作说明将组织内的各个服务启动

#### 2、 动态添加数据服务fighter(data)和计算服务fighter(compute)

例如，根据上面的操作我们已经将8台机器的各个服务启动了，这时候我们又有了2台新机器(内网IP为: 192.168.10.161, 192.168.10.162)，我们想分别添加一台数据服务fighter(data)和计算服务fighter(compute)。


其中一台fighter(data)服务的内部端口可以都用`30000` (注意: 另外需要开通100个内网端口段 31000 ~ 31100);

另一台fighter(compute)服务的内部端口可以都用`40000` (注意: 另外需要开通100个内网端口段 41000 ~ 41100)。

那么我们修改配置如下：


- - ##### 2.1、 配置 `inventory.ini`文件

```ini
# 库存文件，主要用来配置主机列表和主机组

# 任务网关，一个组织有一个网关服务
[via]

# 调度，一个组织有一个调度服务
[carrier]

# 管理台，一个组织有一个管理台服务
[admin]

# 资源节点，一个组织可以配置多个资源服务
[data]
192.168.10.161 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"


# 计算节点，一个组织可以配置多个计算服务
[compute]
192.168.10.162 ansible_ssh_user="user1" ansible_ssh_pass="Abc@123!" ansible_sudo_pass="Abc@123!"


# 注册中心，一个组织要配置奇数个(3,5,等）注册中心，方便 raft 选择leader
[consul]

## Global variables
[all:vars]

# 在宿主机上启动 binary 或者是 docker
deployment_method = binary

## Connection
# 不支持 root 账户 ssh，只支持普通账户
# ssh via normal user
# ansible_user = user1

#集群的名称，自定义即可
cluster_name = demo-cluster
```

- #### 2.2、配置 `group_vars/all.yml`文件

```yml
---

# ############################################### 部署服务开关选项 ###############################################
enable_deploy_via: false
enable_deploy_carrier: false
enable_deploy_admin: false
enable_deploy_data: true
enable_deploy_compute: true
enable_deploy_consul: false

# 检查服务的状态
check_service_status: true

# ############################################### consul的 key-value 选项 ###############################################

via_external_ip: 39.98.126.50
via_external_port: "{{ via_port | int}}"
storage_port: 9098


# ############################################### 各服务配置项 ###############################################

## ---------------------------- consul 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# consul 端口号
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

## ---------------------------- admin web 服务配置 ----------------------------
# admin web 服务证书相关配置信息
enable_tls: false # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name: metis-admin.platon.network
admin_ssl_protocols: "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers: ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password: 123456
amin_user: metis_admin
admin_password: admin_123456

# admin 端口号
admin_web_port: 9090

## ---------------------------- carrier 服务配置 ----------------------------
# carrier 服务相关网络配置
carrier_p2p_external_ip: 39.98.126.40
# carrier 端口号
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032
# carrier 服务连接进metis网络时优先连接的引导节点的nodeId数组 (enr前缀格式)
bootstrap_nodes: ["Suggestion: don't touch here"]

## ---------------------------- via 服务配置 ----------------------------

# via 服务端口号
via_port: 10040

## ---------------------------- fighter(data) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# data 端口号
data_port: [30000]

## ---------------------------- fighter(compute) 服务配置 ----------------------------
# 端口号根据自己的部署情况进行设置，数量要和库存`inventory.ini`文件里面ip数量一致。
# compute 端口号
compute_port: [40000]

############################################################################################## 用户不需要改动的、不需要关心的配置项 ##############################################################################################

# #### 下面的变量不建议用户修改 ####

# 服务静态文件下载 url
download_url: "http://192.168.9.150/metis/"
consul_download_url: "http://192.168.9.150/metis/consul_1.10.4_linux_amd64.zip"

# 证书文件，非必改目录
via_cert_dir:   "{{ playbook_dir }}/config/via_cert"
carrier_cert_dir:   "{{ playbook_dir }}/config/carrier_cert"
admin_cert_dir:   "{{ playbook_dir }}/config/admin_cert"
scan_cert_dir:   "{{ playbook_dir }}/config/scan_cert"
storage_cert_dir:   "{{ playbook_dir }}/config/storage_cert"
compute_cert_dir:   "{{ playbook_dir }}/config/compute_cert"
data_cert_dir:   "{{ playbook_dir }}/config/data_cert"

# #### 下面的变量不能进行更改 ####

# 公共变量
listen_all_ip: 0.0.0.0
carrier_pprof_ip: "{{ listen_all_ip }}"
carrier_rpc_ip: "{{ listen_all_ip }}"
carrier_grpc_gateway_ip: "{{ listen_all_ip }}"
carrier_p2p_listen_ip: "{{ listen_all_ip }}"

# 文件下载目录，非必改变量
downloads_dir: "{{ playbook_dir }}/downloads"
avx2: "{{ downloads_dir }}/avx2"
no_avx2: "{{ downloads_dir }}/no_avx2"

# 目标主机文件安装目录
deploy_dir: "/home/{{ansible_ssh_user}}"


# via 相关信息
via_ip: "{{ groups['via'][0] }}"

# storage 相关信息
storage_host: "{{ groups['storage'][0] }}"
storage_ip: "192.168.10.149"

# consul agent 信息
consul_zip_name: "{{ consul_download_url.split('/')[-1] | trim }}"
consul_number_int: "{{ groups['consul'] | length | int}}"
consul_leader_ip: "{{ groups['consul'][0] }}"
consul_leader_port: "{{ consul_http_port[0] }}"
consul_leader_serf_lan_port: "{{ consul_serf_lan_port[0] }}"
consul_http_port_self:   "{% set consul_number_int = consul_number_int | int %}
                          {% for i in range(consul_number_int) %}
                              {% if groups['consul'][i] == inventory_hostname %}
                                {{consul_http_port[i] |int}}
                              {% endif %}
                          {% endfor %}"

# data 相关信息
data_port_self: "{% set data_number_int = groups['data'] | length |int %} 
                  {% for i in range(data_number_int) %}
                    {% if groups['data'][i] == inventory_hostname %}
                      {{data_port[i] |int}}  
                    {% endif %}
                  {% endfor %}"

# compute 相关信息
compute_port_self: "{% set compute_number_int = groups['compute'] | length |int %} 
                    {% for i in range(compute_number_int) %}
                      {% if groups['compute'][i] == inventory_hostname %}
                        {{compute_port[i] |int}}  
                      {% endif %}
                    {% endfor %}"

#目标机系统自带Python版本
self_python_version: 3.6.9


```

- ##### 2.3、 根据[脚本的各个操作说明]出的操作说明将组织内的各个服务启动



## FAQ





[MetisNode的各组织网络拓扑]: ./img/MetisNode的各组织网络拓扑.jpg
[单个MetisNode的内部各服务网络拓扑]: ./img/单个MetisNode的内部各服务网络拓扑.jpg
[Moirea和MetisNode间的拓扑]: ./img/Moirea和MetisNode间的拓扑.jpg