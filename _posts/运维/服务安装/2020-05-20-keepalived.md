---
layout: post
category: 运维
---

> keepalived

# 1 概述

# 2 安装

IP addr | role|
:----------- | :-----------: |
10.10.10.101 | MASTER  |
10.10.10.102 | BACKUP  |
10.10.10.103 | VIP  |



```
yum install -y keepalived
```
# 3 配置文件

- master

```
#MASTER /etc/keepalived/keepalived.conf

vrrp_instance VI_1 {
    state MASTER # MASTER node
    interface eth0
    virtual_router_id 51
    priority 101   # MASTER 权重高于 BACKUP
    advert_int 1
    mcast_src_ip 10.10.10.101 # VRRP MASTER 实体机 IP

    authentication {
        auth_type PASS # Master 认证方式
        auth_pass 1111 # 密码
    }

    #VIP
    virtual_ipaddress {
        10.10.10.103 #虚拟主机IP
    }
}
 
```

- backup


```
vrrp_instance VI_1 {
    state BACKUP # BACKUP node
    interface eth0
    virtual_router_id 51
    priority 100   # MASTER 权重低于 MASTER
    advert_int 1
    mcast_src_ip 10.10.10.102 # VRRP BACKUP 实体机 IP

    authentication {
        auth_type PASS # Master 认证方式
        auth_pass 1111 # 密码
    }

    #VIP
    virtual_ipaddress {
        10.10.10.103 #虚拟主机IP
    }
}
```

- 启动服务

```
systemctl start  keepalived
```

- 验证切换


```
[root@101]# ip addr show eth0
2: eth0:
    ...
    inet 10.10.10.103/32 scope global eth0

[root@102]# ip addr show eth0
2: eth0:
    ...
    
#停止001的服务，ip自动切换到002上面
[root@101]# systemctl stop  keepalived

[root@101]# ip addr show eth0
2: eth0:
    ...

[root@102]# ip addr show eth0
2: eth0:
    ...
    inet 10.10.10.103/32 scope global eth0
# 当001 服务恢复后，VIP自动切回001    
```


- 添加check脚本

```
vrrp_script chk_service {
       script "/etc/keepalived/presto-server.sh"
       interval 2                      # check every 2 seconds
       timouet 10
       fall 2
       rise 2
       weight -5 
}

vrrp_instance VI_1 {
    ...
    # 这里必须调用chk_service方法
    track_script {
       chk_service
   }
   ...
}

cat /etc/keepalived/presto-server.sh

#!/bin/bash

killall -0 presto-server
```