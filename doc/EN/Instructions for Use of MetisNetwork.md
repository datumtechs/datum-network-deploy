# Instructions for Use of MetisNetwork


## Open the MetisNode console

You can operate MetisNode-related data, hashing power and other resource information through the page of the management console.

1. Enter 80, the extranet ip of admin service, in the explorer, such as: http://39.10.10.10:80

2. The account password is admin by default, and you can log in to the management console by entering whatever characters as the verification code.

## Open the consul console

You can view the registration of each internal service to the consul server through the consul console (it is not advised to manually modify the content on the console).

1. Enter ${consul_http_port}, the extranet Ip of consul service, in the explorer, such as: http://39.10.10.10:8500

**Note**: When you log in to the consul console to check the registration status of each service, make sure that the `admin` and `carrier` services are registered before any other operation, such as: registering an identity, publishing metadata or hashing power, etc. Make sure that the via, fighter(data) or fighter(compute) services are all registered before you engage in the multi-party collaborative computing task.

