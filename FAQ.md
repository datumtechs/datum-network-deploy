# FAQ

报错问题
1、没有pip命令，需要安装sudo apt install python-pip
2、pip install -r ./requirements.txt（需要重新登陆，才可以执行ansible命令）
3、download storage jar package需要删除
4、报错"msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"需要安装 apt install sshpass
5、admin.tar解压需要安装unzip
6、ansible报错msg: No setuptools found in remote host, please install it first.需要在目标机上需要修改pip的模块执行命令为pip3，修改位置roles/admin_deploy/tasks/main.yml
7、bootstrap_nodes变量下发后会出现u字符，应优化，不应该用户二次修改