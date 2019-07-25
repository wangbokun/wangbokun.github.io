---
layout: post
category: 运维
---
> serverless

# 1 概述

# 2 nuclio
## 2.1  nuclio dashboard

```
docker  pull  nuclio/dashboard:stable-amd64
docker run -p 8070:8070 -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp nuclio/dashboard:stable-amd64
```
- Open web console http://127.0.0.1:8070/welcome
![](/assets/img//15640431272952.jpg)

## 2.2 Create Project

![](/assets/img//15640432816237.jpg)

![](/assets/img//15640433453419.jpg)

## 2.3 Create function

![](/assets/img//15640433841797.jpg)

![](/assets/img//15640435153044.jpg)

![](/assets/img//15640435946981.jpg)

## 2.3 Deploying
![-w202](/assets/img//15640437145534.jpg)
![](/assets/img//15640437294253.jpg)

![](/assets/img//15640437457922.jpg)

## 2.4 Running Test
![](/assets/img//15640438263735.jpg)

![](/assets/img//15640451966993.jpg)
