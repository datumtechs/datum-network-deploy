# Metis-Deploy

Metis 运维脚本及工具集

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

```
(一)、必须部署部分(不管是否参与任务计算都要部署的):  [1] consul服务 -> [2] carrier 服务 -> [3] admin服务； 

(二)、非必须部署部分(如需要参与任务计算都要部署的): [4] via 服务 -> [5] fighter(data)服务、fighter(compute)服务。
```

- ### *Moirea 和 MetisNode 的关系*

![Moirea and MetisNode][Moirea和MetisNode间的拓扑]

Moirea 可以理解为是一个提供数据市场、全网数据统计、任务工作流管理的平台。 可以搭建在自己组织内部，那么它和自身组织的 MetisNode 是一对一关系； 也可以通过 moirea 界面添加外部 MetisNode 的carrier 外网 ip 和 port 对接其他外部 MetisNode 这样是一对多关系，moirea 的具体操作说明请参照 moirea 的相关文档。



## metis 部署说明


### 使用 ansible 部署 metis


```sh
# 使用git 下载本脚本项目
git clone https://github.com/Metisnetwork/Metis-Deploy.git

# 进入项目目录
cd metis-deploy

# 切换项目到 ansible 分支
git checkout ansible

# 查看`README.md`中的操作说明
```

## 组织内各个服务的网络情况

参考: [network](./network.md)

## 使用说明

在整个 MetisNode 部署完成后，需要根据 [使用说明](./MetisNetwork使用说明.md)

[MetisNode的各组织网络拓扑]: ./img/MetisNode的各组织网络拓扑.jpg
[单个MetisNode的内部各服务网络拓扑]: ./img/单个MetisNode的内部各服务网络拓扑.jpg
[Moirea和MetisNode间的拓扑]: ./img/Moirea和MetisNode间的拓扑.jpg