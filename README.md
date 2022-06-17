# datum-network-deploy

Datum-network 运维脚本及工具集

# datum 部署 [[English](./README_EN.md)]

## datum 网络拓扑

datum 网络由多个 Datum-network Node 组成，一个 Datum-network Node 其实是一个组织的逻辑总称，关于 Datum-network Node 的网络拓扑具体如下所示：

- ### *各个 Datum-network Node 间的网络拓扑*

 ![organizations][OrganizationNetworkTopologyOfDatumNetworkNode]

 Datum-network Node 间的网络拓扑，其中在各个 Datum-network Node 之间 (也就是各个组织之间)是通过 p2p 网络互相建立起连接的；每个 Datum-network Node 通过自身的 carrier 和外界的 Datum-network Node 的 carrier 进行 p2p 连接。

- ### *单个 Datum-network Node 内部各个服务的网络拓扑*

 ![inside organization][InternalServiceNetworkTopologyOfASingleDatumNetworkNode]

在 Datum-network Node 内测的各个服务划分 admin, ice_via(Glacier2, IceGrid), carrier, fighter(data), fighter(compute), consul 等角色服务。admin、carrier、Glacier2、IceGrid、fighter都将自身的信息自动注册到 consul，各个内部服务间通过 consul 中的其他内部服务信息做服务间相互发现。对于组织内部的各服务具体功能如下：

**ice_via 节点**：ice_via节点包括Glacier2和IceGrid服务, Glacier2可作为一个路由器，有穿透防火墙的功能，通过Glacier2转发客户端的请求到服务器；IceGrid可作为一个注册器，将服务器的相关信息以及服务注册到IceGrid服务；Glacier2服务和IceGrid服务提供组织和外部进行多方协助 task 时的唯一外网端口 (内外网端口一致)。

**carrier 节点**：为整个组织的任务调度服务，一个组织只能部署一个调度服务(只能有一个)。carrier 担当起整个 Datum-network Node 的大脑负责任务调度、资源服务调度和元数据及组织内部资源信息管理以及数据同步、p2p等等。

**admin 节点**：为整个组织的管理台 web 后端服务，一个组织有一个管理台服务(可以有多个，建议启一个)。admin 则是 carrier 的管理台方便用户管理内部数据和资源及数据统计报表等。

**data 节点**：[fighter(data)]为整个组织的存储资源节点，可以根据自己的情况配置任意多个。

**compute 节点**：[figter(compute)]为整个组织的算力资源节点，可以根据自己的情况配置任意多个。

**consul 节点**：为整个组织的注册中心服务，一个组织建议配置奇数个（1，3，5等），方便 raft 共识算法选择 leader。


- ### * Datum-network Node 内部必须存在的服务，以及部署时的顺序*

> 从上述图中我们已经知道了 Datum-network Node 内部各个服务的网络拓扑，那么显而易见组织内部必须要有的服务为 consul、 carrier、 admin，其他的服务根据自身情况而定；如果需要提供数据能力或者提供算力能力去参与多方协同计算，那么还必须有 ice_via(Glacier2/IceGrid)和fighter，其中需要提供数据能力时需部署 fighter(data)、需要提供算力能力时部署 fighter(compute)。

**服务部署的顺序为:**

> (一)、必须部署部分(不管是否参与任务计算都要部署的):  [1] consul服务 -> [2] carrier 服务 -> [3] admin服务。
> (二)、非必须部署部分(如需要参与任务计算都要部署的): [4] ice_via服务(Glacier2/IceGrid) -> [5] fighter(data)服务、fighter(compute)服务。
> 

- ### * Datum-Platform 和 Datum-network Node 的关系*

![DatumPlatform and DatumNetworkNode][TopologyBetweenDatumPlatformAndDatumNetworkNode]

Datum-Platform 可以理解为是一个提供数据市场、全网数据统计、任务工作流管理的平台。 可以搭建在自己组织内部，那么它和自身组织的 Datum-network Node 是一对一关系； 也可以通过 Datum-Platform 界面添加外部 Datum-network Node 的carrier 外网 ip 和 port 对接其他外部 Datum-network Node 这样是一对多关系，Datum-Platform 的具体操作说明请参照 Datum-Platform 的相关文档。



## Datum-network Node 部署说明


### 使用 ansible 部署 Datum-network Node


```sh
# 使用 git 下载脚本项目
git clone https://github.com/datumtechs/datum-network-deploy.git

# 进入项目目录
cd datum-network-deploy

# 切换项目到 ansible_v0.4.0 分支
git checkout ansible_v0.4.0

# 查看`README.md`中的操作说明
```

## 组织内各个服务的网络情况

网络要求参考：[网络情况](./doc/ZH/network.md)

## 使用说明

Datum-network Node 部署完成后参考：[使用说明](./doc/ZH/DatumNetwork使用说明.md)

## 任务事件类型码对照表

[点击查看](./doc/ZH/事件码对照表.md)

## FAQ

部署中常见问题及解决方法参考：[FAQ](./doc/ZH/FAQ.md)


[OrganizationNetworkTopologyOfDatumNetworkNode]: ./img/OrganizationNetworkTopologyOfDatumNetworkNode.jpg
[InternalServiceNetworkTopologyOfASingleDatumNetworkNode]: ./img/InternalServiceNetworkTopologyOfASingleDatumNetworkNode.jpg
[TopologyBetweenDatumPlatformAndDatumNetworkNode]: ./img/TopologyBetweenDatumPlatformAndDatumNetworkNode.jpg