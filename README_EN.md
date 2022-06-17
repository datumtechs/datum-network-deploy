# datum-network-deploy

Datum-network Operation and maintenance script and tool set

# Datum  Deployment [[中文](./README.md)]

## Datum Network Topology

The datum network consists of multiple Datum-network Nodes, each of which is actually a logical general term for an organization. The network topology of the Datum-network Node is as follows:

- ### *Network topology between Datum-network Nodes*

 ![organizations][OrganizationNetworkTopologyOfDatumNetworkNode]

The network topology between Datum-network Nodes (that is, between organizations) is connected to each other through a p2p network; the carrier of each Datum-network Node is linked with the carrier of the Datum-network Nodes outside for p2p connection.

- ### *Network topology of each service within a single Datum-network Node*

 ![inside organization][InternalServiceNetworkTopologyOfASingleDatumNetworkNode]

For each service in the closed beta test of Datum-network Node, there are such role services as admin, Glacier2, IceGrid, carrier, fighter(data), fighter(compute), and consul. Admin, carrier, Glacier2, IceGrid, and fighter all have their information automatically registered to consul, and each internal service discovers each other through other internal service information in consul. The specific functions of each service within the organization are as follows:

**ice_via node**: The ICE VIA nodes include Glacier2 and IceGrid services. Glacier2 can be used as a router, with the function of penetrating the firewall, and forwarding client requests to the server through Glacier2; IceGrid can be used as a registrar to register server-related information and services with IceGrid services; Glacier2 services and IceGrid services provide organizational and external The only external network port for multi-party assistance tasks (the internal and external network ports are the same).

**carrier node**: It provides task scheduling services for the entire organization. An organization can deploy (only) one scheduling service. Carrier acts as the brain of the entire Datum-network Node and is responsible for task scheduling, resource service scheduling, metadata and internal resource information management within the organization, as well as data synchronization, p2p, etc.

**admin node**: It provides the web backend service for the management console of the entire organization. An organization has one management console service (there can be multiple, and it is advised to start one). Admin is the management console of the carrier, which is convenient for users to manage internal data, resources and data statistics reports.

**data node**: [fighter(data)] is the storage resource node of the entire organization, and you can configure as many as you like.

**compute node**: [figter(compute)] is the computing resource node of the entire organization, and you can configure as many as you like.

**consul node**: It serves the registry of the entire organization. An organization is advised to configure an odd number (1, 3, 5, etc.) of consul nodes to facilitate the raft consensus algorithm to select leaders.

- ### *Services that must exist inside Datum-network Node and the order in which they are deployed*

> From the above figure, we get to know the network topology of each service inside Datum-network Node. It is thus clear that consul, carrier, and admin are the services required in the organization, and other services are deployed as needed; if you need to provide data capabilities or computing services for multi-party collaborative computing, you must also have ice_via(Glacier2/IceGrid) and fighter. In the former case, you need to deploy fighter (data), and in the latter case, you need to deploy fighter (compute).

**The order of service deployment:**

> (1) Services that must be deployed (whether involved in task computing or not): [1] consul service -> [2] carrier service -> [3] admin service.
> 
> (2) Optional services (only needed for task computing): [4] ice_via service(Glacier2/IceGrid) -> [5] fighter(data) service and fighter(compute) service.

- ### *Relationship between DatumPlatform and Datum-network Node*

![DatumPlatform and DatumNetworkNode][TopologyBetweenDatumPlatformAndDatumNetworkNode]

DatumPlatform can be seen as a platform that provides a data market, network-wide data statistics, and task workflow management. It can be built within your own organization, in which case it's in a one-to-one relationship with the organization's Datum-network Node; you can also add the carrier extranet ip and port of an external Datum-network Node through the DatumPlatform interface to connect to other external Datum-network Nodes, which means a one-to-many relationship. For instructions of the specific operation of DatumPlatform, please refer to the relevant documentation of DatumPlatform.

## Description of Datum-network Node Deployment Script

This script is an ansible automated deployment script, including admin, ice_via, carrier, fighter(data), fighter(compute), and consul role services within a single organization. The ansible script can **deploy, start, stop , and destroy** each role node.

## Environment Requirements


### Deploying a datum network node using ansible

1. *Download the script on the master computer:* 


```shell
#Download the script project using git
git clone https://github.com/datumtechs/datum-network-deploy.git

#Enter the project directory
cd datum-network-deploy

#Switch project to the ansible branch
git checkout ansible

#View `README.md`
```


## Network of Each Service in the Organization

Network requirements: [Network](./doc/EN/NetworkConfiguration.md)


## Instructions for Use

After the deployment of Datum-network Node is completed, please refer to: [Instructions for Use](./doc/EN/InstructionsForUseOfDatumNetwork.md)

## Task event type code comparison table

[Click to view](./doc/EN/eventCodeDetails.md)

## FAQ

For common problems and solutions in deployment, refer to: [FAQ](./doc/EN/FAQ_EN.md)

[OrganizationNetworkTopologyOfDatumNetworkNode]: ./img/OrganizationNetworkTopologyOfDatumNetworkNode.jpg
[InternalServiceNetworkTopologyOfASingleDatumNetworkNode]: ./img/InternalServiceNetworkTopologyOfASingleDatumNetworkNode.jpg
[TopologyBetweenDatumPlatformAndDatumNetworkNode]: ./img/TopologyBetweenDatumPlatformAndDatumNetworkNode.jpg
