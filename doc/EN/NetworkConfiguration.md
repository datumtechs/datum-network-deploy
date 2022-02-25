# Network Configuration

![ansible](./img/ansible.png)


1. The ip address configured in the `inventory.ini` configuration file is the intranet ip, and the master computer and the target computer are in the same intranet for the sake of network interoperability.

2. Extranet ip needs to be configured for via and carrier, with via_external_ip configured as the via extranet ip and carrier_external_ip as the carrier extranet ip.

3. Service port information

| Service | Variable | Port | To which service it is open |
|  ----  | ----  |  ----  | ----  |
|   via | via_port  | via grpc service port number  | Open to the whole network. Data or resource services of other organizations are forwarded to internal resources or data services through this service. |
|   data | data_port  |  data grpc service port number  | Open to all services within the organization, not open to the public |
|  compute  | compute_port  |  computer grpc service port number  | Open to all services within the organization, not open to the public |
|  admin  | admin_web_port  |  admin web service port number  | Open to consul services |
|  carrier  | carrier_pprof_port  |  go debugging interface  | Local access only |
|  carrier  | carrier_rpc_port  | carrier rpc service port number |  Open to moirea, via, and consul services  |
|  carrier  | carrier_grpc_gateway_port  | restful server listening port of carrier rpc api | Open to moirea, via, and consul services |
|  carrier  | carrier_p2p_udp_port  |  p2p udp port number  | Open to the whole network |
|  carrier  | carrier_p2p_tcp_port  |  p2p port number  | Open to the whole network |
|  consul  | consul_server_port  | Server RPC port | Open to services within the organization |
|  consul  | consul_serf_lan_port  | Port to which Serf LAN gossip communication should be bound | Open to consul services |
|  consul  | consul_serf_wan_port  |  Port to which Serf WAN gossip communication should be bound  | Open to consul services |
|  consul  | consul_http_port  | HTTP API port | Open to services within the organization |
|  consul  | consul_dns_port  | DNS server port | Open to services within the organization |


**【Notes】:** 

1. In the end, you need to enable the 80 port policy for the explorer

2. For fighter (data), 100 intranet ports in the [31000 ~ 31100] port segment must be opened.

3. For fighter (compute), 100 intranet ports in the [41000 ~ 41100] port segment must be opened.