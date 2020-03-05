---
layout: post
category:  物联网
---
> 树莓派搭建私有云

# 1 owncloud安装
## 1.1 docker owncloud

```
sudo docker pull owncloud
```
## 1.2 docker mysql

```
sudo  docker pull mysql

【ERROR】
pi-raspberrypi ➜  dist-packages sudo docker pull mariadb
Using default tag: latest
latest: Pulling from library/mariadb
no matching manifest for linux/arm/v7 in the manifest list entries

【解决方案】
因为arm架构问题，不用跑，换一个image替代

sudo docker pull hypriot/rpi-mysql
```
## 1.3 启动服务
```
docker run --name my-mysql -e MYSQL_ROOT_PASSWORD="Dwwe+=32H" -d mysql

docker run --name owncloud -p 5679:80   -v /data/db/owncloud:/var/www/html/data --link my-mysql:mysql -d owncloud
```

## 1.4 docker-compose 安装服务

```
#docker-compose.yml 文件

version: '2'
services:
  owncloud:
    image: owncloud
    links:
      - mysql:mysql
    volumes:
      - "/data/data/owncloud/data:/var/www/html/data"
    ports:
      - 5679:80
  mysql:
    image: hypriot/rpi-mysql
    volumes:
      - "/data/data/owncloud/db/mysql:/var/lib/mysql"
    ports:
      - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: "nx91nPLvoPB1Dw3m"
      MYSQL_DATABASE: ownCloud
      

pi-pi1  ➜  owncloud docker-compose up -d
Creating network "owncloud_default" with the default driver
Creating owncloud_mysql_1 ... done
Creating owncloud_owncloud_1 ... done


#docker-compose 后台启动
docker-compose up -d
docker-compose ps


dcoker-compose down
=
# docker-compose stop
# dcoker-compose rm

#以下是创建账号
```

![-w958](/assets/img//15822936513357.jpg)


![-w746](/assets/img//15822938146683.jpg)



```
#登录
```

![-w670](/assets/img//15822939078987.jpg)

![-w1438](/assets/img//15822939234178.jpg)
