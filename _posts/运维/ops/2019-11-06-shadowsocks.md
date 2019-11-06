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

#启动服务
$sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d start
启动报错.
...
    func = self.__getitem__(name)
  File "/usr/lib/python2.7/ctypes/__init__.py", line 384, in __getitem__
    func = self._FuncPtr((name_or_ordinal, self))
AttributeError: /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1: undefined symbol: EVP_CIPHER_CTX_cleanup
#尝试修复

- 52     libcrypto.EVP_CIPHER_CTX_cleanup.argtypes = (c_void_p,)
+ 52     libcrypto.EVP_CIPHER_CTX_reset.argtypes = (c_void_p,)


- 111             libcrypto.EVP_CIPHER_CTX_cleanup(self._ctx)
+ 111             libcrypto.EVP_CIPHER_CTX_reset(self._ctx)

#然后执行start命令
sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d start
INFO: loading config from /etc/shadowsocks/ss.json
2019-11-06 14:00:16 INFO     loading libcrypto from libcrypto.so.1.1
started

#stop
sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d stop
#restart
sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d restart

#加入开机启动
$sudo vim /etc/rc.local
sudo /usr/local/bin/ssserver -c /etc/shadowsocks/ss.json -d start
```

# 4 Client
## 4.1 Mac
https://github.com/shadowsocks/ShadowsocksX-NG/releases

## 4.2 Android 
https://github.com/shadowsocks/shadowsocks-android/releases

## 4.3 iOS
https://crifan.github.io/scientific_network_summary/website/server_client_mode/ss_client/client_ios.html