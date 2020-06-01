---
layout: post
category: 运维
---
> OpenSSL



![-w692](/assets/img//15904813179573.jpg)



# 2 证书生成


```
#文件结构:
├── https-client.js
├── https-server.js
├── keys
│   ├── openssl.cnf
│   ├── run.sh

cd keys&& sh run.sh
#运行后目录结构
├── https-client.js
├── https-server.js
├── keys
│   ├── ca.crt
│   ├── ca.csr
│   ├── ca.key
│   ├── ca.pem
│   ├── client.crt
│   ├── client.csr
│   ├── client.key
│   ├── client.pem
│   ├── openssl.cnf
│   ├── run.sh
│   ├── server.crt
│   ├── server.csr
│   ├── server.key
│   └── server.pem
```
## 2.1 证书生成脚本
- openssl.cnf

```
[req] 
prompt = no 
default_bits = 4096
default_md = sha256
distinguished_name = dn 
x509_extensions = v3_req

[dn] 
C=CN
ST=Beijing
L=Beijing
O=TEST
OU=Testing Domain
CN=localhost
emailAddress=admin@localhost

[v3_req]
keyUsage=keyEncipherment, dataEncipherment
extendedKeyUsage=serverAuth
subjectAltName=@alt_names

[alt_names]
DNS.1=localhost
```

- run.sh


```
#!/bin/bash
# 生成服务器端私钥
openssl genrsa -out server.key 1024
# 生成服务器端公钥
openssl rsa -in server.key -pubout -out server.pem


# 生成客户端私钥
openssl genrsa -out client.key 1024
# 生成客户端公钥
openssl rsa -in client.key -pubout -out client.pem


# 生成 CA 私钥
openssl genrsa -out ca.key 1024
# X.509 Certificate Signing Request (CSR) Management.
openssl req -new -key ca.key -out ca.csr  -config openssl.cnf  -days 3650
# X.509 Certificate Data Management.
openssl  x509 -req -in ca.csr -signkey ca.key  -out ca.crt

openssl rsa -in ca.key -pubout -out ca.pem

# =====================服务器端
# 通过 .cnf 生成server.key、server.crt 的命令
openssl req \
-new \
-newkey rsa:2048 \
-sha1 \
-days 3650 \
-nodes \
-x509 \
-keyout server.key \
-out server.crt \
-config openssl.cnf

# 通过 .cnf 生成 server.csr
openssl req \
-new \
-config openssl.cnf \
-key server.key \
-out server.csr


# =====================client 端
# 通过 .cnf 生成 client.key、client.crt 的命令
openssl req \
-new \
-newkey rsa:2048 \
-sha1 \
-days 3650 \
-nodes \
-x509 \
-keyout client.key \
-out client.crt \
-config openssl.cnf

# 通过 .cnf 生成 client.csr
openssl req \
-new \
-config openssl.cnf \
-key client.key \
-out client.csr
```
![](/assets/img//15904888396921.jpg)


## 2.2 验证

- https-server.js


```
// file http-server.js
var https = require('https');
var fs = require('fs');

var options = {
  key: fs.readFileSync('./keys/server.key'),
  cert: fs.readFileSync('./keys/server.crt')
};

https.createServer(options, function(req, res) {
  res.writeHead(200);
  res.end('hello world');
}).listen(8001);

```

- https-client.js


```
// file http-client.js
var https = require('https');
var fs = require('fs');

process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0;

var options = {
  hostname: "localhost",
  port: 8001,
  path: '/',
  methed: 'GET',
  key: fs.readFileSync('./keys/client.key'),
  cert: fs.readFileSync('./keys/client.crt'),
  ca: [fs.readFileSync('./keys/ca.crt')]
};

options.agent = new https.Agent(options);

var req = https.request(options, function(res) {
  res.setEncoding('utf-8');
  res.on('data', function(d) {
    console.log(d);
  });
});
req.end();

req.on('error', function(e) {
  console.log(e);
});

```

- run


```
node https-server.js

node https-client.js
hello world
```
# Q&A
## 1 Subject Alternative Name missing

```
【ERROR】
    Certificate - Subject Alternative Name missing
    
    This server could not prove that it is localhost; its security certificate is from [missing_subjectAltName]. This may be caused by a misconfiguration or an attacker intercepting your connection.
【solution】
 # http://wiki.cacert.org/FAQ/subjectAltName
 在生成 .csr 的时候填入的很多信息中，包含了一个叫做 Common Name（CN）的 field，以前这个 CN 可以直接填写 server name 或者 IP，但之后规定了需要使用 Subject Alternative Name（SAN） 来指定 server name, IP1。

同时需要指出， 文档 中最后一部分「Verify the Signed (Public) Keyfile with OpenSSL」生成的范例证书，仔细观察，对比上文生成 certs 内容，会发现，范例中的 version 是 3，而上文中我们生成的证书是 1，其对应的是 x509 证书的版本。
```

![-w1069](/assets/img//15904847106863.jpg)


![](/assets/img//15904867796738.jpg)


![](/assets/img//15904868014181.jpg)

## 2 ERR_CERT_AUTHORITY_INVALID
```
【ERROR】
This page is not secure (broken HTTPS).
Certificate - missing
This site is missing a valid, trusted certificate (net::ERR_CERT_AUTHORITY_INVALID).

【solution】
#MAC
sudo security add-trusted-cert \
-d -r trustRoot \
-k /Library/Keychains/System.keychain \
server.crt
```

![-w1125](/assets/img//15904865217312.jpg)
