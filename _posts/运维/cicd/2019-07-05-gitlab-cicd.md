---
layout: post
category: 运维
---

>Gitlab CICD

# 1 概述
## 1.1 gitlab CICD install

- Open Pipelnies
 Settings->General->permissions->Open Pipelines
 
 ![-w1261](/assets/img//15622965053552.jpg)

## 1.2 install Runner
>https://docs.gitlab.com/runner/install/linux-manually.html

```
Run command [x86-64]:
 sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

sudo chmod +x /usr/local/bin/gitlab-runner

sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
 
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
 
sudo gitlab-runner start 
``` 
## 1.3 runner register 
>https://docs.gitlab.com/runner/register/index.html

```
sudo gitlab-runner register
Runtime platform                                    arch=amd64 os=linux pid=26734 revision=0e5417a3 version=12.0.1
Running in system-mode.

Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
https://git.gitlab.com  ##输入自己gitlab服务地址
Please enter the gitlab-ci token for this runner:
xxxxxx  ## 输入仓库token
Please enter the gitlab-ci description for this runner:
[t-awsbj-sqe-cdh-gw-001]: exporter ##description
Please enter the gitlab-ci tags for this runner (comma separated):
hdfs ##tags
Registering runner... succeeded                     runner=1kt19cDo
Please enter the executor: shell, docker-ssh+machine, kubernetes, docker, docker-ssh, parallels, ssh, virtualbox, docker+machine:
shell
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```
## 1.4  configure File: .gitlab-ci.yml
## 1.5  gitlab web console Pipline status
  commit master branch,auto running CICD
![-w1106](/assets/img//15622989849890.jpg)
![-w1430](/assets/img//15623004669779.jpg)
## 1.6 GitLab 自定义环境变量以及内置变量
 - 内置变量: 
  https://docs.gitlab.com/ee/ci/variables/
 - 自定义变量,比如：docker login key不暴露在仓库中，可以在这里定义，yml文件中引用 
> Settings->CI/CD->Secret variables

![-w1017](/assets/img//15628141906648.jpg)
![](/assets/img//15628142294706.jpg)
![-w399](/assets/img//15628142784036.jpg)
