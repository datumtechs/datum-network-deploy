# 配置demo示例

## 所有服务部署在一台机器上(即: 单个宿主机部署单个组织所有服务, 建议只在测试阶段使用)。




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
# 库存文件，主要用来配置主机列表和主机组 (注: 下列IP均需为内网IP)

# 任务网关，一个组织有一个网关服务
[via]

# 调度，一个组织有一个调度服务
[carrier]

# 管理台，一个组织有一个管理台服务
[admin]

# 资源节点，一个组织可以配置多个资源服务
[data]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# 计算节点，一个组织可以配置多个计算服务
[compute]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# 注册中心，一个组织要配置奇数个(1,3,5,等）注册中心，方便 raft 选择leader
[consul]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

## Global variables
[all:vars]
# 集群的名称，自定义即可
cluster_name = demo-cluster

# 部署服务开关
enable_deploy_via = True
enable_deploy_carrier = True
enable_deploy_admin = True
enable_deploy_data = True
enable_deploy_compute = True
enable_deploy_consul = True

# consul 服务的端口号配置
# 端口号根据自己的部署情况进行设置，数量要和 consul 组里面的 ip 数量一致。
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

# admin web 服务证书相关配置信息
enable_tls = False # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name = datum-admin.demo.network
admin_ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers = ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password = datum_root
admin_user = datum_admin
admin_password = admin_123456

# admin 端口号
admin_web_port = 9090
nginx_listen_port = 80
nginx_listen_port_ssl = 443
mysql_listen_port = 3306

# carrier 外网
carrier_external_ip = 39.98.126.40

# carrier 端口号
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032

# via 外网 
via_external_ip = 39.98.126.40

# via 服务端口号
via_port = 10040

# 端口号根据自己的部署情况进行设置，数量要和 data 组里面的 ip 数量一致。
# data 端口号
data_port = [30000]

# 端口号根据自己的部署情况进行设置，数量要和 compute 组里面的 ip 数量一致。
# compute 端口号
compute_port = [40000]
```

- ##### 1.2、 根据[脚本的各个操作说明]处的操作说明将组织内的各个服务启动


#### 2、 动态添加数据服务fighter(data)和计算服务fighter(compute)


例如，根据上面的操作我们在`192.168.10.150`这台机器的各个服务启动了，这时候我们又需要新增数据服务或者计算服务(注意: 每次新增fighter(data)或者fighter(compute)只能先修改相关配置单个新增，然后再修改配置再单个新增，以此类推逐个的去新增)。


其中一台fighter(data)服务的内部端口可以都用`30001` (注意: 因为都部署在一台机器上，而之前已经部署了30000端口的fighter(data)故本次新增的fighter(data)需要用30001以防止端口冲突);

另一台fighter(compute)服务的内部端口可以都用`40001` (注意: 因为都部署在一台机器上，而之前已经部署了40000端口的fighter(compute)故本次新增的fighter(compute)需要用40001以防止端口冲突);

那么我们修改配置如下：


- ##### 2.1、 配置 `inventory.ini`文件

```ini
# 库存文件，主要用来配置主机列表和主机组 (注: 下列IP均需为内网IP)

# 任务网关，一个组织有一个网关服务
[via]

# 调度，一个组织有一个调度服务
[carrier]

# 管理台，一个组织有一个管理台服务
[admin]

# 资源节点，一个组织可以配置多个资源服务
[data]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# 计算节点，一个组织可以配置多个计算服务
[compute]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# 注册中心，一个组织要配置奇数个(3,5,等）注册中心，方便 raft 选择leader
[consul]

## Global variables
[all:vars]
# 集群的名称，自定义即可
cluster_name = demo-cluster

# 部署服务开关
enable_deploy_via = False
enable_deploy_carrier = False
enable_deploy_admin = False
enable_deploy_data = True
enable_deploy_compute = True
enable_deploy_consul: False

# consul 服务的端口号配置
# 端口号根据自己的部署情况进行设置，数量要和 consul 组里面的 ip 数量一致。
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

# admin web 服务证书相关配置信息
enable_tls = False # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name = datum-admin.demo.network
admin_ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers = ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password = datum_root
admin_user = datum_admin
admin_password = admin_123456

# admin 端口号
admin_web_port = 9090
nginx_listen_port = 8080
nginx_listen_port_ssl = 443
mysql_listen_port = 3307

# carrier 外网
carrier_external_ip = 39.98.126.40

# carrier 端口号
carrier_pprof_port = 10032
carrier_rpc_port = 10033
carrier_grpc_gateway_port = 10034
carrier_p2p_udp_port = 10035
carrier_p2p_tcp_port = 10036

# via 外网 
via_external_ip = 39.98.126.40

# via 服务端口号
via_port = 10031

# 端口号根据自己的部署情况进行设置，数量要和 data 组里面的 ip 数量一致。
# data 端口号
data_port = [30001]

# 端口号根据自己的部署情况进行设置，数量要和 compute 组里面的 ip 数量一致。
# compute 端口号
compute_port = [40001]
```


- ##### 2.2、 修改role下面的ansible的task的配置文件内容

> 如果新增 fighter(compute) 那么需要修改 `roles/compute_deploy/tasks/main.yml`文件

```
2.2.1、 在第一个`with_items`项中的路径中的compute修改为computeN, 如: 

    - '{{ deploy_dir }}/compute'
    - '{{ deploy_dir }}/compute/config'
    - '{{ deploy_dir }}/compute/contract_work_dir'
    - '{{ deploy_dir }}/compute/result_root'

    修改为:

    - '{{ deploy_dir }}/compute2'
    - '{{ deploy_dir }}/compute2/config'
    - '{{ deploy_dir }}/compute2/contract_work_dir'
    - '{{ deploy_dir }}/compute2/result_root'

2.2.2、在`set_fact`下的各个路径中的compute修改为computeN, 如: 

    code_root_dir2: '{{ deploy_dir }}/compute2/contract_work_dir'
    results_root_dir2: '{{ deploy_dir }}/compute2/result_root'

    修改为:

    code_root_dir2: '{{ deploy_dir }}/compute2/contract_work_dir'
    results_root_dir2: '{{ deploy_dir }}/compute2/result_root'


2.2.3、 以及 `- name: "copy configuration file"` 下的各个路径中的compute修改为computeN, 如:   

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


2.2.4、 以及 `- name: "copy start.sh file"` 下的各个路径中的compute修改为computeN, 如:   

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
2.2.1、 在第一个`with_items`项中的路径中的data修改为dataN, 如: 

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

2.2.2、在`set_fact`下的各个路径中的data修改为dataN, 如: 

    data_root: "{{ deploy_dir }}/data/data_root"
    code_root_dir: "{{ deploy_dir }}/data/contract_work_dir"
    results_root_dir: "{{ deploy_dir }}/data/result_root"

    修改为:

    data_root: "{{ deploy_dir }}/data2/data_root"
    code_root_dir: "{{ deploy_dir }}/data2/contract_work_dir"
    results_root_dir: "{{ deploy_dir }}/data2/result_root"


2.2.3、 以及 `- name: "copy configuration file"` 下的各个路径中的data修改为dataN, 如:    

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


2.2.4、 以及 `- name: "copy start.sh file"` 下的各个路径中的data修改为dataN, 如:   

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

- ##### 2.3、 start.yml文件的修改


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
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.compute_svc.main {{ deploy_dir }}/compute/config/compute.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_compute|default(false)



    修改为:


    tags:
      - compute
    tasks:
      - name: stop compute
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.compute_svc.main {{ deploy_dir }}/compute2/config/compute.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_compute|default(false)


将 `- hosts: compute` 下的 `- name: check service compute status` 下的相关路径中的compute修改为computeN, 如: 


    - name: check service compute status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.compute_svc.main {{ deploy_dir }}/compute/config/compute.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status


    修改为:

    - name: check service compute status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.compute_svc.main {{ deploy_dir }}/compute2/config/compute.yml" | grep -v "grep" | awk '{print $2}'
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
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.data_svc.main {{ deploy_dir }}/data/config/data.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_data|default(false)




    修改为:


    tags:
      - data
    tasks:
      - name: stop data
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.data_svc.main {{ deploy_dir }}/data2/config/data.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_data|default(false)



将 `- hosts: data` 下的 `- name: check service data status` 下的相关路径中的data修改为dataN, 如: 


    - name: check service data status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.data_svc.main {{ deploy_dir }}/data/config/data.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status


    修改为:

    - name: check service data status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.data_svc.main {{ deploy_dir }}/data2/config/data.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status


```



- ##### 2.5、 cleanup.yml文件的修改




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


- ##### 2.6、 根据[脚本的各个操作说明]处的操作说明将组织内的各个服务启动


>**[注意]:** 不管是[启动`start`]、[停止`stop`]、[清理`cleanup`]相应的数据服务fighter(data)或者计算服务fighter(compute)都只能每次操作一个服务都需要重复 2.1 -> 2.4 步骤中对应的 ip、port 和文件路径进行修改后，再进行[启动`start`]、[停止`stop`]、[清理`cleanup`]等操作。另外单个数据服务fighter(data)和计算服务fighter(compute)可以在同一次操作中进行。


## 每台宿主机仅部署一个服务 (生产阶段建议使用这种)。


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
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

# 调度，一个组织有一个调度服务
[carrier]
192.168.10.151 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

# 管理台，一个组织有一个管理台服务
[admin]
192.168.10.152 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

# 资源节点，一个组织可以配置多个资源服务
[data]
192.168.10.153 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"
192.168.10.154 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# 计算节点，一个组织可以配置多个计算服务
[compute]
192.168.10.155 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"
192.168.10.156 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

# 注册中心，一个组织要配置奇数个(3,5,等）注册中心，方便 raft 选择leader
[consul]
192.168.10.157 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

## Global variables
[all:vars]
# 集群的名称，自定义即可
cluster_name = demo-cluster

# 部署服务开关
enable_deploy_via = True
enable_deploy_carrier = True
enable_deploy_admin = True
enable_deploy_data = True
enable_deploy_compute = True
enable_deploy_consul = True

# consul 服务的端口号配置
# 端口号根据自己的部署情况进行设置，数量要和 consul 组里面的 ip 数量一致。
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

# admin web 服务证书相关配置信息
enable_tls = False # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name = datum-admin.demo.network
admin_ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers = ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password = datum_root
admin_user = datum_admin
admin_password = admin_123456

# admin 端口号
admin_web_port = 9090

# carrier 外网
carrier_external_ip = 39.98.126.40

# carrier 端口号
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032

# via 外网 
via_external_ip = 39.98.126.50

# via 服务端口号
via_port = 10040

# 端口号根据自己的部署情况进行设置，数量要和 data 组里面的 ip 数量一致。
# data 端口号
data_port = [30000, 30000]

# 端口号根据自己的部署情况进行设置，数量要和 compute 组里面的 ip 数量一致。
# compute 端口号
compute_port = [40000, 40000]
```

- ##### 1.2、 根据[脚本的各个操作说明]处的操作说明将组织内的各个服务启动

#### 2、 动态添加数据服务fighter(data)和计算服务fighter(compute)

例如，根据上面的操作我们已经将8台机器的各个服务启动了，这时候我们又有了2台新机器(内网IP为: 192.168.10.161, 192.168.10.162)，我们想分别添加一台数据服务fighter(data)和计算服务fighter(compute)。


其中一台fighter(data)服务的内部端口可以都用`30000` (注意: 另外需要开通100个内网端口段 31000 ~ 31100);

另一台fighter(compute)服务的内部端口可以都用`40000` (注意: 另外需要开通100个内网端口段 41000 ~ 41100)。

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
192.168.10.161 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# 计算节点，一个组织可以配置多个计算服务
[compute]
192.168.10.162 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# 注册中心，一个组织要配置奇数个(3,5,等）注册中心，方便 raft 选择leader
[consul]

## Global variables
[all:vars]
# 集群的名称，自定义即可
cluster_name = demo-cluster

# 部署服务开关
enable_deploy_via: False
enable_deploy_carrier: False
enable_deploy_admin: False
enable_deploy_data: True
enable_deploy_compute: True
enable_deploy_consul: False

# consul 服务的端口号配置
# 端口号根据自己的部署情况进行设置，数量要和 consul 组里面的 ip 数量一致。
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

# admin web 服务证书相关配置信息
enable_tls = False # 是否启用 https，启用的需要配置证书和相应的域名，证书里面的密码套件等，不启用的话，忽略下面的配置。
admin_server_name = datum-admin.demo.network
admin_ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers = ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# admin web 的 mysql 相关用户名密码
mysql_root_password = datum_root
admin_user = datum_admin
admin_password = admin_123456

# admin 端口号
admin_web_port = 9090

# carrier 外网
carrier_external_ip = 39.98.126.40

# carrier 端口号
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032

# via 外网 
via_external_ip = 39.98.126.50

# via 服务端口号
via_port = 10040

# 端口号根据自己的部署情况进行设置，数量要和 data 组里面的 ip 数量一致。
# data 端口号
data_port = [30000]

# 端口号根据自己的部署情况进行设置，数量要和 compute 组里面的 ip 数量一致。
# compute 端口号
compute_port = [40000]
```

- ##### 2.2、 根据[脚本的各个操作说明]处的操作说明将组织内的各个服务启动