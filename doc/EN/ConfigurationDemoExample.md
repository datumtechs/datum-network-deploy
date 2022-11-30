# Configuration demo example

## All services are deployed on one machine (ie: a single host deploys all services of a single organization, it is recommended to use it only in the testing phase).



#### 1. One-time deployment of each service of the organization

Assuming we only have 1 machine (intranet IP: 192.168.10.150), we must only deploy the MVP mode organization of each service at the beginning (MVP mode organization is: one consul, one admin, one via, one carrier, zero or at most one fighter(data) and zero or at most one fighter(compute)).

The internal ports of consul are: `8200`, `8300`, `8400`, `8500`, `8600`; admin web service's internal network port `9090`;

The external network IP of the carrier is `39.98.126.40`, the internal network pprof port `7701`, the internal network gateway port `7702`, the internal and external rpc port `10030`, the external udp port `10031`, the external tcp port `10032` ; 

The external network IP of via is `39.98.126.40`, and the internal and external network port of via is `10040`;


Internal port `30000` of fighter(data) service (Note: In addition, 100 internal network port segments 31000 ~ 31100 need to be opened);

The internal port `40000` of the fighter(compute) service (Note: In addition, 100 internal network port segments 41000 ~ 41100 need to be opened).


Then we have the following configuration:


- ##### 1.1. Configure the `inventory.ini` file

```ini
# Inventory file, mainly to configure the host list and host group

# Task gateway. An organization has a gateway service
[via]

# Scheduling. An organization has a scheduling service
[carrier]

# Management console. An organization has a management console service
[admin]

# Resource node. An organization can configure multiple resource services
[data]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# Computing nodes. An organization can configure multiple computing services
[compute]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# Registration center. An organization needs to configure an odd number (1, 3, 5, etc.) of registration centers to facilitate raft to choose the leader
[consul]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

## Global variables
[all:vars]
# The name of the cluster, which you can customize 
cluster_name = demo-cluster

# Deploy service switch
enable_deploy_via = True
enable_deploy_carrier = True
enable_deploy_admin = True
enable_deploy_data = True
enable_deploy_compute = True
enable_deploy_consul = True

# The port of the consul service, set according to your deployment. 
# The number should be consistent with the number of ips in the consul group.
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

# admin web service certificate related configuration information.
enable_tls = False # Whether to enable https. If yes, True, and you need to configure the certificate and the corresponding domain name, the cipher suite in the certificate, etc. If 
admin_server_name = datum-admin.demo.network
admin_ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers = ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# mysql related username and password of admin web
mysql_root_password = datum_root
admin_user = datum_admin
admin_password = admin_123456

# admin web service port number
admin_web_port = 9090

# carrier extranet ip address
carrier_external_ip = 39.98.126.40

# carrier service port number
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032

# via extranet ip address
via_external_ip = 39.98.126.40

# via service port number
via_port = 10040

# data port number, set according to your deployment. 
# The number should be consistent with the number of ips in the data group.
data_port = [30000]

# compute port number, set according to your deployment. 
# The number should be consistent with the number of ips in the compute group.
compute_port = [40000]
```

- ##### 1.2、 Start each service within the organization according to the instructions at [Instructions for each operation of the script]


#### 2、 Dynamically add data service fighter(data) and computing service fighter(compute)


For example, according to the above operations, we have started the various services of the machine `192.168.10.150`. At this time, we need to add data services or computing services (note: each time you add fighter(data) or fighter(compute) You can only modify the relevant configuration to add a single addition, and then modify the configuration to add a single addition, and so on to add one by one).


One of the internal ports of the fighter(data) service can all use `30001` (Note: Because they are all deployed on the same machine, and the fighter(data) of port 30000 has been deployed before, this time the newly added fighter(data) ) needs to use 30001 to prevent port conflicts);

The internal ports of another fighter(compute) service can all use `40001` (Note: Because they are all deployed on one machine, and the fighter(compute) with port 40000 has been deployed before, this time the newly added fighter(compute) ) needs to use 40001 to prevent port conflicts);

Then we modify the configuration as follows:

- ##### 2.1、 Configure the `inventory.ini` file

```ini
# Inventory file, mainly to configure the host list and host group

# Task gateway. An organization has a gateway service
[via]

# Scheduling. An organization has a scheduling service
[carrier]

# Management console. An organization has a management console service
[admin]

# Resource node. An organization can configure multiple resource services
[data]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# Computing nodes. An organization can configure multiple computing services
[compute]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# Registration center. An organization needs to configure an odd number (1, 3, 5, etc.) of registration centers to facilitate raft to choose the leader
[consul]

## Global variables
[all:vars]
# The name of the cluster, which you can customize 
cluster_name = demo-cluster

# Deploy service switch
enable_deploy_via = False
enable_deploy_carrier = False
enable_deploy_admin = False
enable_deploy_data = True
enable_deploy_compute = True
enable_deploy_consul: False

# The port of the consul service, set according to your deployment. 
# The number should be consistent with the number of ips in the consul group.
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

# admin web service certificate related configuration information.
enable_tls = False # Whether to enable https. If yes, True, and you need to configure the certificate and the corresponding domain name, the cipher suite in the certificate, etc. If 
admin_server_name = datum-admin.demo.network
admin_ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers = ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# mysql related username and password of admin web
mysql_root_password = datum_root
admin_user = datum_admin
admin_password = admin_123456

# admin web service port number
admin_web_port = 9090

# carrier extranet ip address
carrier_external_ip = 39.98.126.40

# carrier service port number
carrier_pprof_port = 10032
carrier_rpc_port = 10033
carrier_grpc_gateway_port = 10034
carrier_p2p_udp_port = 10035
carrier_p2p_tcp_port = 10036

# via extranet ip address
via_external_ip = 39.98.126.40

# via service port number
via_port = 10031

# data port number, set according to your deployment. 
# The number should be consistent with the number of ips in the data group.
data_port = [30001]

# compute port number, set according to your deployment. 
# The number should be consistent with the number of ips in the compute group.
compute_port = [40001]
```


- ##### 2.2、 修改role下面的ansible的task的配置文件内容

> 如果新增 fighter(compute) 那么需要修改 `roles/compute_deploy/tasks/main.yml`文件

```
2.2.1、 In the first `with_items` item, the path of compute is changed to computeN, such as: 

    - '{{ deploy_dir }}/compute'
    - '{{ deploy_dir }}/compute/config'
    - '{{ deploy_dir }}/compute/contract_work_dir'
    - '{{ deploy_dir }}/compute/result_root'

    change into:

    - '{{ deploy_dir }}/compute2'
    - '{{ deploy_dir }}/compute2/config'
    - '{{ deploy_dir }}/compute2/contract_work_dir'
    - '{{ deploy_dir }}/compute2/result_root'

2.2.2、 The compute in each path under `set_fact` is modified to computeN, such as:

    code_root_dir2: '{{ deploy_dir }}/compute2/contract_work_dir'
    results_root_dir2: '{{ deploy_dir }}/compute2/result_root'

    change into:

    code_root_dir2: '{{ deploy_dir }}/compute2/contract_work_dir'
    results_root_dir2: '{{ deploy_dir }}/compute2/result_root'


2.2.3、 And the compute in each path under `- name: "copy configuration file"` is modified to computeN, such as:  

    - name: copy configuration file
     template:
       backup: true
       dest: '{{ deploy_dir }}/compute/config/compute.yml'
       mode: 0600
       src: compute.yml.j2

    change into:
    
    - name: copy configuration file
     template:
       backup: true
       dest: '{{ deploy_dir }}/compute2/config/compute.yml'
       mode: 0600
       src: compute.yml.j2


2.2.4、 And the compute in each path under `- name: "copy start.sh file"` is modified to computeN, such as:  

    # copy start.sh file
    - name: "copy start.sh file"
      copy:
        src: "{{ downloads_dir }}/start_v3_service.sh"
        dest: "{{ deploy_dir }}/compute/start_v3_service.sh"
        mode: 0755
        backup: yes
    
    change into: 
    
    # copy start.sh file
    - name: "copy start.sh file"
      copy:
        src: "{{ downloads_dir }}/start_v3_service.sh"
        dest: "{{ deploy_dir }}/compute2/start_v3_service.sh"
        mode: 0755
        backup: yes    
```


> If you add fighter(data) then you need to modify the `roles/data_deploy/tasks/main.yml` file

```
2.2.1、 The data in the path in the first `with_items` item is changed to dataN, such as:

    - "{{ deploy_dir }}/data"
    - "{{ deploy_dir }}/data/config"
    - "{{ deploy_dir }}/data/cert"
    - "{{ deploy_dir }}/data/whl"
    - "{{ deploy_dir }}/data/data_root"
    - "{{ deploy_dir }}/data/contract_work_dir"
    - "{{ deploy_dir }}/data/result_root"

    change into:

    - "{{ deploy_dir }}/data2"
    - "{{ deploy_dir }}/data2/config"
    - "{{ deploy_dir }}/data2/cert"
    - "{{ deploy_dir }}/data2/whl"
    - "{{ deploy_dir }}/data2/data_root"
    - "{{ deploy_dir }}/data2/contract_work_dir"
    - "{{ deploy_dir }}/data2/result_root"

2.2.2、 The data in each path under `set_fact` is modified to dataN, such as:

    data_root: "{{ deploy_dir }}/data/data_root"
    code_root_dir: "{{ deploy_dir }}/data/contract_work_dir"
    results_root_dir: "{{ deploy_dir }}/data/result_root"

    change into:

    data_root: "{{ deploy_dir }}/data2/data_root"
    code_root_dir: "{{ deploy_dir }}/data2/contract_work_dir"
    results_root_dir: "{{ deploy_dir }}/data2/result_root"


2.2.3、 And the data in each path under `- name: "copy configuration file"` is modified to dataN, such as: 

    - name: "copy configuration file"
      template:
        src: "data.yml.j2"
        dest: "{{ deploy_dir }}/data/config/data.yml"
        mode: 0600
        backup: yes
    
    change into:
    
    - name: "copy configuration file"
      template:
        src: "data.yml.j2"
        dest: "{{ deploy_dir }}/data2/config/data.yml"
        mode: 0600
        backup: yes


2.2.4、 And the data in each path under `- name: "copy start.sh file"` is changed to dataN, such as:  

    # copy start.sh file
    - name: "copy start.sh file"
      copy:
        src: "{{ downloads_dir }}/start_v3_service.sh"
        dest: "{{ deploy_dir }}/data/start_v3_service.sh"
        mode: 0755
        backup: yes
    
    change into:
    
    # copy start.sh file
    - name: "copy start.sh file"
      copy:
        src: "{{ downloads_dir }}/start_v3_service.sh"
        dest: "{{ deploy_dir }}/data2/start_v3_service.sh"
        mode: 0755
        backup: yes  
```

- ##### 2.3、 Modification of start.yml file


> If you add fighter(compute), you need to modify as follows:

```

 Modify compute in the relevant path under `tasks` under `- name: start compute` to computeN, such as:   


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

    change into:


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

> If you add fighter(data), you need to modify as follows:

```


 Modify data in the relevant path under `tasks` under `- name: start data` to dataN, such as: 


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


    change into:


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



- ##### 2.4、 Modification of stop.yml file



> If you add fighter(compute), you need to modify as follows:

```

 Modify compute in the relevant path under `tasks` under `- hosts: compute` to computeN, such as:   


    tags:
      - compute
    tasks:
      - name: stop compute
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.compute_svc.main {{ deploy_dir }}/compute/config/compute.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_compute|default(false)



    change into:


    tags:
      - compute
    tasks:
      - name: stop compute
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.compute_svc.main {{ deploy_dir }}/compute2/config/compute.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_compute|default(false)


 Change the compute in the relevant path under `- hosts: compute` under `- name: check service compute status` to computeN, for example:


    - name: check service compute status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.compute_svc.main {{ deploy_dir }}/compute/config/compute.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status


    change into:

    - name: check service compute status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.compute_svc.main {{ deploy_dir }}/compute2/config/compute.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status



```

> If you add fighter(data), you need to modify as follows:

```

 Modify the data in the relevant path under `tasks` under `- hosts: data` to dataN, such as:  


    tags:
      - data
    tasks:
      - name: stop data
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.data_svc.main {{ deploy_dir }}/data/config/data.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_data|default(false)




    change into:


    tags:
      - data
    tasks:
      - name: stop data
        shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.data_svc.main {{ deploy_dir }}/data2/config/data.yml" | grep -v "grep" | awk '{print $2}' | xargs -r kill -s TERM
        register: result
        changed_when: false
        failed_when: result.rc != 0
        when: enable_deploy_data|default(false)



 Modify the data in the relevant path under `- hosts: data` under `- name: check service data status` to dataN, such as:


    - name: check service data status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.data_svc.main {{ deploy_dir }}/data/config/data.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status


    change into:

    - name: check service data status
      shell: ps -ef | grep "{{ deploy_dir }}/miniconda/envs/python375/bin/python -u -m fighter_project.data_svc.main {{ deploy_dir }}/data2/config/data.yml" | grep -v "grep" | awk '{print $2}'
      register: check_result
      when: check_service_status


```



- ##### 2.5、 Modification of cleanup.yml file




> If you add fighter(compute), you need to modify as follows:

```

 Modify compute in the relevant path under `- hosts: compute` to computeN, such as:  


    tags:
      - compute_servers
    tasks:
      - name: clean compute
        file:
          path: "{{ deploy_dir }}/compute"
          state: absent
        when: enable_deploy_compute|default(false)



    change into:


    tags:
      - compute_servers
    tasks:
      - name: clean compute
        file:
          path: "{{ deploy_dir }}/compute2"
          state: absent
        when: enable_deploy_compute|default(false)


```

> If you add fighter(data), you need to modify as follows:

```

 Modify the data in the relevant path under `- hosts: data` to dataN, such as:


    tags:
      - data_servers
    tasks:
      - name: clean data
        file:
          path: "{{ deploy_dir }}/data"
          state: absent
        when: enable_deploy_data|default(false)




    change into:


    tags:
      - data_servers
    tasks:
      - name: clean data
        file:
          path: "{{ deploy_dir }}/data2"
          state: absent
        when: enable_deploy_data|default(false)



```


- ##### 2.6、 Start each service within the organization according to the instructions at [Instructions for each operation of the script]


**[Note]:** Whether it is [start `start`], [stop `stop`], [clean up `cleanup`] the corresponding data service fighter(data) or computing service fighter(compute) can only be used every time To operate a service, you need to repeat the corresponding ip, port and file path in steps 2.1 -> 2.4 to modify, and then perform operations such as [start `start`], [stop `stop`], [clean up `cleanup`]. In addition a single data service fighter(data) and a computing service fighter(compute) can be performed in the same operation.



## Deploy only one service per host (recommended for production).


#### 1、 One-time deployment of each organization's services


Suppose we have 8 machines (intranet IP: 192.168.10.150 ~ 192.168.10.157), each machine deploys a service, one consul, one admin, one via, one carrier, fighter(data) and fighter (compute) two each.

The internal ports of consul are: `8200`, `8300`, `8400`, `8500`, `8600`; admin web service's internal network port `9090`;

The external network IP of the carrier is `39.98.126.40`, the internal network pprof port `7701`, the internal network gateway port `7702`, the internal and external rpc port `10030`, the external udp port `10031`, the external tcp port `10032` ;

The external network IP of via is `39.98.126.50`, and the internal and external network port of via is `10040`;

The internal ports of the two fighter (data) services can both use `30000` (Note: In addition, 100 internal network port segments 31000 ~ 31100 need to be opened);

The internal ports of the two fighter (compute) services can both use `40000` (Note: In addition, 100 internal network port segments 41000 ~ 41100 need to be opened).


Then we have the following configuration:

- ##### 1.1、 Configure the `inventory.ini` file

```ini
# Inventory file, mainly to configure the host list and host group

# Task gateway. An organization has a gateway service
[via]
192.168.10.150 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

# Scheduling. An organization has a scheduling service
[carrier]
192.168.10.151 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

# Management console. An organization has a management console service
[admin]
192.168.10.152 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

# Resource node, an organization can configure multiple resource services
[data]
192.168.10.153 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"
192.168.10.154 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# Computing nodes. An organization can configure multiple computing services
[compute]
192.168.10.155 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"
192.168.10.156 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# Registration center. An organization needs to configure an odd number (1, 3, 5, etc.) of registration centers to facilitate raft to choose the leader
[consul]
192.168.10.157 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"

## Global variables
[all:vars]
# The name of the cluster, which you can customize 
cluster_name = demo-cluster

# Deploy service switch
enable_deploy_via = True
enable_deploy_carrier = True
enable_deploy_admin = True
enable_deploy_data = True
enable_deploy_compute = True
enable_deploy_consul = True

# The port of the consul service, set according to your deployment. 
# The number should be consistent with the number of ips in the consul group.
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

# admin web service certificate related configuration information.
enable_tls = False # Whether to enable https. If yes, True, and you need to configure the certificate and the corresponding domain name, the cipher suite in the certificate, etc. If no, False, and just ignore the 
admin_server_name = datum-admin.demo.network
admin_ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers = ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# mysql related username and password of admin web
mysql_root_password = datum_root
admin_user = datum_admin
admin_password = admin_123456

# admin web service port number
admin_web_port = 9090

# carrier extranet ip address
carrier_external_ip = 39.98.126.40

# carrier service port number
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032

# via extranet ip address
via_external_ip = 39.98.126.50

# via service port number
via_port = 10040

# data port number, set according to your deployment. 
# The number should be consistent with the number of ips in the data group.
data_port = [30000, 30000]

# compute port number, set according to your deployment. 
# The number should be consistent with the number of ips in the compute group.
compute_port = [40000, 40000]
```

- ##### 1.2、 Start each service within the organization according to the instructions at [Instructions for each operation of the script]

#### 2、 Dynamically add data service fighter(data) and computing service fighter(compute)

For example, according to the above operation, we have started each service of 8 machines. At this time, we have 2 new machines (intranet IP: 192.168.10.161, 192.168.10.162), we want to add a data service respectively fighter(data) and computing service fighter(compute).


One of the internal ports of the fighter(data) service can use `30000` (Note: In addition, 100 internal network port segments 31000 ~ 31100 need to be opened);

The internal ports of another fighter (compute) service can all use `40000` (Note: In addition, 100 internal network port segments 41000 ~ 41100 need to be opened).

Then we modify the configuration as follows:


- ##### 2.1、 Configure the `inventory.ini` file

```ini
# Inventory file, mainly to configure the host list and host group

# Task gateway. An organization has a gateway service
[via]

# Scheduling. An organization has a scheduling service
[carrier]

# Management console. An organization has a management console service
[admin]

# Resource node. An organization can configure multiple resource services
[data]
192.168.10.161 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# Computing nodes. An organization can configure multiple computing services
[compute]
192.168.10.162 ansible_ssh_user="user" ansible_ssh_pass="123456" ansible_sudo_pass="123456"


# Registration center. An organization needs to configure an odd number (1, 3, 5, etc.) of registration centers to facilitate raft to choose the leader
[consul]

## Global variables
[all:vars]
# The name of the cluster, which you can customize 
cluster_name = demo-cluster

# Deploy service switch
enable_deploy_via: False
enable_deploy_carrier: False
enable_deploy_admin: False
enable_deploy_data: True
enable_deploy_compute: True
enable_deploy_consul: False

# The port of the consul service, set according to your deployment. 
# The number should be consistent with the number of ips in the consul group.
consul_server_port: [8200]
consul_serf_lan_port: [8300]
consul_serf_wan_port: [8400]
consul_http_port: [8500]
consul_dns_port: [8600]

# admin web service certificate related configuration information.
enable_tls = False # Whether to enable https. If yes, True, and you need to configure the certificate and the corresponding domain name, the cipher suite in the certificate, etc. If no, False, and just ignore the 
admin_server_name = datum-admin.demo.network
admin_ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2"
admin_ssl_ciphers = ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4

# mysql related username and password of admin web
mysql_root_password = datum_root
admin_user = datum_admin
admin_password = admin_123456

# admin web service port number
admin_web_port = 9090

# carrier extranet ip address
carrier_external_ip = 39.98.126.40

# carrier service port number
carrier_pprof_port: 7701
carrier_rpc_port: 10030
carrier_grpc_gateway_port: 7702
carrier_p2p_udp_port: 10031
carrier_p2p_tcp_port: 10032

# via extranet ip address
via_external_ip = 39.98.126.50

# via service port number
via_port = 10040

# data port number, set according to your deployment. 
# The number should be consistent with the number of ips in the data group.
data_port = [30000]

# compute port number, set according to your deployment. 
# The number should be consistent with the number of ips in the compute group.
compute_port = [40000]
```

- ##### 2.2、 Start each service within the organization according to the instructions at [Instructions for each operation of the script]