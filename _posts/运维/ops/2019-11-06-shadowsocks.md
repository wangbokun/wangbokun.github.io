---
layout: post
category: 运维
---

# 1 OverView

# 2 Cloud EC2

```
可以选择海外aws ec2等方案，这里不详细介绍
```

# 3 shadowsocks install 

## 3.1 安装shadowsocks2.8.2
```
$sudo -s
$apt-get update
$apt-get install python-setuptools
$apt-get install python-pip
$pip install shadowsocks
The directory '/home/ubuntu/.cache/pip/http' or its parent directory is not owned by the current user and the cache has been disabled. Please check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.
The directory '/home/ubuntu/.cache/pip' or its parent directory is not owned by the current user and caching wheels has been disabled. check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.
Collecting shadowsocks
  Downloading https://files.pythonhosted.org/packages/02/1e/e3a5135255d06813aca6631da31768d44f63692480af3a1621818008eb4a/shadowsocks-2.8.2.tar.gz
Installing collected packages: shadowsocks
  Running setup.py install for shadowsocks ... done
Successfully installed shadowsocks-2.8.2
```
## 3.2 修改配置文件
```
$mkdir -p /etc/shadowsocks/
$vim /etc/shadowsocks/ss.json

{
    "server":"0.0.0.0",
    "server_port":443,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"xxxxx",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open":false,
    "workers": 1
}
```

## 3.3 启动服务
```
#启动服务
$sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d start
启动报错.
...
    func = self.__getitem__(name)
  File "/usr/lib/python2.7/ctypes/__init__.py", line 384, in __getitem__
    func = self._FuncPtr((name_or_ordinal, self))
AttributeError: /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1: undefined symbol: EVP_CIPHER_CTX_cleanup
```
## 3.4 启动报错修复
```
#尝试修复

- 52     libcrypto.EVP_CIPHER_CTX_cleanup.argtypes = (c_void_p,)
+ 52     libcrypto.EVP_CIPHER_CTX_reset.argtypes = (c_void_p,)


- 111             libcrypto.EVP_CIPHER_CTX_cleanup(self._ctx)
+ 111             libcrypto.EVP_CIPHER_CTX_reset(self._ctx)
```
## 3.5 再次启动服务
```
#然后执行start命令
sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d start
INFO: loading config from /etc/shadowsocks/ss.json
2019-11-06 14:00:16 INFO     loading libcrypto from libcrypto.so.1.1
started

#stop
sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d stop
#restart
sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d restart
```
## 3.6 加入开机启动
```
#加入开机启动
$sudo vim /etc/rc.local
sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d start
```

# 4 Client
## 4.1 Mac

- 失败

```
系统版本macOS Mojave 10.14.5
尝试各种版本ShadowsocksX-NG 上网失败，这里就不详细写教程了
https://github.com/shadowsocks/ShadowsocksX-NG/releases

```

- 成功， V2rayU
 
```
github Url： https://github.com/yanue/V2rayU 

#install 
brew cask install v2rayu
```
![](/assets/img//15730953833559.jpg)

- 安装成功后打开APP

![-w142](/assets/img//15730953960173.jpg)

![-w240](/assets/img//15730954396762.jpg)

![-w589](/assets/img//15730954941666.jpg)


```
{
  "log": {
    "error": "",
    "loglevel": "info",
    "access": ""
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": {
        "ip": "",
        "userLevel": 0,
        "timeout": 360,
        "udp": false,
        "auth": "noauth"
      },
      "port": "1080"
    },
    {
      "listen": "127.0.0.1",
      "protocol": "http",
      "settings": {
        "timeout": 360
      },
      "port": "1087"
    }
  ],
  "outbounds": [
    {
      "protocol": "shadowsocks",
      "streamSettings": {
        "tcpSettings": {
          "header": {
            "type": "none"
          }
        },
        "tlsSettings": {
          "allowInsecure": true
        },
        "security": "none",
        "network": "tcp"
      },
      "tag": "agentout",
      "settings": {
        "servers": [
          {
            "port": 888,              // 端口
            "method": "aes-256-cfb",  // 加密方式
            "password": "xxxxx",  // 填上自己的密码
            "address": "10.10.10.1",  //填上自己的IP
            "level": 0,
            "email": "",
            "ota": false
          }
        ]
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "AsIs",
        "redirect": "",
        "userLevel": 0
      }
    },
    {
      "tag": "blockout",
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "none"
        }
      }
    }
  ],
  "dns": {
    "servers": [
      ""
    ]
  },
  "routing": {
    "strategy": "rules",
    "settings": {
      "domainStrategy": "IPIfNonMatch",
      "rules": [
        {
          "outboundTag": "direct",
          "type": "field",
          "ip": [
            "geoip:cn",
            "geoip:private"
          ],
          "domain": [
            "geosite:cn",
            "geosite:speedtest"
          ]
        }
      ]
    }
  },
  "transport": {}
}
```

- 然后选择一下三个红框
![-w294](/assets/img//15730955996166.jpg)

- 然后可实现科学上网

![-w701](/assets/img//15730956864076.jpg)
- Q&A

```
记得DNS新增8.8.8.8
```

## 4.2 Android 

- 下载App

```
https://github.com/shadowsocks/shadowsocks-android/releases
手机下载4.6.5 apk,并安装
https://github.com/shadowsocks/shadowsocks-android/releases/download/v4.6.5/shadowsocks--universal-4.6.5.apk
```
- 打开APP

![-w68](/assets/img//15730958518041.jpg)
- 启用google play服务，会有提示，跟着提示开启就可以

![](/assets/img//15730959236879.jpg)

- 配置

```
点击新增配置
```
![-w265](/assets/img//15730959989273.jpg)


```
填入服务器ip、port、pasword，加密方式
路由->绕过局域网及中国大陆地址
远程DNS->8.8.8.8
其他默认即可
```
![](/assets/img//15730959649041.jpg)

## 4.3 iOS
https://crifan.github.io/scientific_network_summary/website/server_client_mode/ss_client/client_ios.html