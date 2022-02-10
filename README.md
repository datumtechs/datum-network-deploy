# Metis-Deploy

Metis 运维脚本及工具集

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



## metis 部署说明


### 使用 ansible 部署 metis


```sh
# 使用git 下载本脚本项目
git clone http://192.168.9.66/Metisnetwork/metis-deploy.git

# 进入项目目录
cd metis-deploy

# 切换项目到 ansible 分支
git checkout ansible

# 查看`README.md`中的操作说明
```



[MetisNode的各组织网络拓扑]: ./img/MetisNode的各组织网络拓扑.jpg
[单个MetisNode的内部各服务网络拓扑]: ./img/单个MetisNode的内部各服务网络拓扑.jpg
[Moirea和MetisNode间的拓扑]: ./img/Moirea和MetisNode间的拓扑.jpg