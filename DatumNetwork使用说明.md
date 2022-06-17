# MetisNetwork使用说明

## 打开MetisNode管理台

操作 MetisNode 相关数据、算力等资源信息，可通过管理台的页面操作。

1、在浏览器输入 admin服务外网Ip:80， 如： http://39.10.10.10:80

2、账号密码均为默认的 admin, 验证码随便输入字符即可登录管理台。


## 打开consul控制台

查看 内部 各个服务注册到 consul server 的情况，可以通过 consul控制台查看(建议不要在上面手动修改内容)。


1、 在浏览器输入 consul服务外网Ip:${consul_http_port}， 如： http://39.10.10.10:8500


**注意**： 登录 consul控制台 查看各个服务的注册情况，确保 admin、 carrier 服务都注册了才可以做后续操作，如： 注册身份、 发布元数据、 发布算力等一些列操作。 确保 via、 fighter(data)或者fighter(compute) 服务都注册了才可以参与多方协作计算任务操作。