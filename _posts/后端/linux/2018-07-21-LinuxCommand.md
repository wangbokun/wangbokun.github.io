---
layout: post
category: 后端
---


# 1. Command
## 1.1 SSH
### ssh Proxy
```
ssh -fTnN -p 2222 -i /root/.ssh/key -D 0.0.0.0:8157 $User@$Ip
```
### ssh configure

```
...
```
## 2 Git

|  名称| 命令 |备注  |
| --- | --- | --- |
| 强制提交 | git push -u origin dev -f |  |
|checkout分支|git checkout dev|
|Pull分支|git pull origin dev|
|查看本地分支|git branch||
|查看远程分支|git branch -a||
|提交远程分支|git push origin test  |
|删除远程分支|git branch -r -d origin/branch-name |




