# FAQ

Errors and solutions:

1. Without the pip command, execute `sudo apt install python-pip` to install pip.

2. After `pip install -r ./requirements.txt`, the ansible command is invalid (as the environment variable does not take effect, exit the current terminal, open a new terminal, and then execute the ansible command).

3. When the error "msg" is reported: "to use the 'ssh' connection type with passwords, you must install the sshpass program", execute `sudo apt install sshpass` to install sshpass.

4. Errors /usr/bin/python: not found and msg: No setuptools found in remote host, please install it first. Manually execute `sudo apt install -y python3 python3-pip python python-pip` on the target computer.

5. When the whl file is installed for the first time for the data or computing service, http://pypi.douban.com, http://pypi.douban.com will be used, which is mainly to accelerate the downloading of related dependencies for python. If the machine where the target computer is located cannot access pypi.douban.com, it will report an error that the download of the third-party module fails. If this problem occurs, despite a small chance, just remove -i http://pypi.douban.com. 

6. The playbook supports reentrancy. If it fails in the first execution, it can be executed again.

7. When fail update apt cache is reported during deployment, the solution: `sudo apt update` on the target computer.

8. If the execution result is found to be Failed to fetch http://nginx.org/packages/mainline/ubuntu/dists/bionic/InRelease Cannot initiate the connection to nginx.org:80:, delete the nginx source file. Refer to: https:/ /www.jianshu.com/p/3545c446fd27.

9. If the keyword public key is not available appears in the execution result, please refer to: https://chrisjean.com/fix-apt-get-update-the-following-signatures-couldnt-be-verified-because-the-public-key-is-not-available/.

10. Uninstall MySQL8 on the target computer completely, if any. For the solution, refer to: https://blog.csdn.net/iehadoop/article/details/82961264.

11. For the solution to the error in importing the libmysqlclient.so.21 dynamic library, please refer to: https://www.1024sou.com/article/555887.html.

12. The openssl component is not installed, and execute `sudo apt-get install libssl-dev` on the target computer.

