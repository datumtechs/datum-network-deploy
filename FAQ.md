# FAQ

报错问题及解决方案：

1. 没有 pip 命令，执行 `sudo apt install python-pip` 安装 pip。

2. `pip install -r ./requirements.txt` 之后 ansible 命令无法使用（环境变量未生效，退出当前终端，打开新的终端，才可以执行ansible命令。

3. 报错"msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"，执行 `sudo apt install sshpass` 安装 sshpass。

4. 报错/usr/bin/python: not found和msg: No setuptools found in remote host, please install it first. 手工到目标机上执行 `sudo apt install -y python3 python3-pip python python-pip`。

5. 数据或者计算服务第一次安装 whl 文件的时候会用到 http://pypi.douban.com，http://pypi.douban.com 这个主要是 python 用来下载相关依赖包时用来进行加速的，如果目标机所在的机器访问不了pypi.douban.com ，则会报错下载第三方模块失败，如果出现这个问题直接把这个-i http://pypi.douban.com拿掉就好了，小概率出现。

6. playbook 是支持可重入的，第一次执行失败，可以第二次重复执行。