# Minecraft

Minecraft（《我的世界》）是一款3D沙盒电子游戏，由Mojang Studios开发。玩家可无拘无束地与由方块、实体构成的3个维度环境互动。多种玩法供玩家选择，带来无限可能。

目前Minecraft可分为Java版、基岩版和教育版。

[Parents' Guide to Minecraft | Minecraft](https://www.minecraft.net/zh-hans/article/parents--guide-minecraft)
[中文Minecraft Wiki - 最详细的我的世界百科](https://minecraft.fandom.com/zh/wiki/Minecraft_Wiki)

## Command

```sh
# 基岩版

# 寻找沙漠神庙 desert temple
/locatebiome

# 使用 /tp 命令查看坐标
# 将玩家传送到当前位置，并在聊天框中显示当前坐标
/tp @s ~ ~ ~
# 38.14,63.00,-365.23

# 基岩版 使坐标显示在屏幕左上角
/gamerule showcoordinates true
```

## Vocabulary

Netherite 下界合金
击退 (Knockback)是一种可以增加剑的击退距离的魔咒。附魔命令：/enchant @p minecraft:knockback 1 [击退 (Knockback)](https://www.mcmod.cn/item/132460.html)

### 坐标

[坐标 - 中文 Minecraft Wiki](https://zh.minecraft.wiki/w/坐标)

世界坐标基于一个由互相垂直且交于一点（即原点）的三条坐标轴形成的网格，即一个空间直角坐标系。

- X轴的正方向为东，其坐标反映了玩家距离原点在东（+）西（-）方向上的距离。调试屏幕中红色指标指向东方。
- Z轴的正方向为南，其坐标反映了玩家距离原点在南（+）北（-）方向上的距离。调试屏幕中蓝色指标指向南方。
- Y轴的正方向为上，其坐标反映了玩家位置的高低程度（其中海平面为63），另见海拔高度。调试屏幕中绿色指标指向上方。
- 坐标系的单位长度为一个方块长，基于测量方法，每一方块的体积为1立方米。

因此，三条坐标轴形成了右手坐标系（拇指为X轴，食指为Y轴，中指为Z轴），通过这样可以更为简单地记住各坐标轴。

使用波浪号（~）来指定相对坐标，使用脱字符（^，也叫插入符）来指定局部坐标。在波浪号和插入符后可以跟一个数字，表示相对基准点的偏移量。

Relative world coordinates 相对坐标: ~10 ~ ~-30（西南偏南方向32格外）是指“向东（+X）10个方块，向北（-Z）30个方块”。而~ ~ ~则指命令执行处坐标。

相对坐标可以与绝对坐标混用：例如，/tp ~ 64 ~可保持执行者X和Z位置不变，并将其传送到64格的绝对高度。

Local coordinates 局部坐标: /tp ^ ^ ^5 会将玩家向前传送5个方块。如果该玩家转过身来重复这个命令，他会被传送到开始的地方。

## Book

Minecraft: Guide to Creative
[Minecraft: Guide to Creative : Jelley, Craig, Milton, Stephanie, Davies, Marsh, Jones, Owen, Marsh, Ryan: Amazon.sg: Books](https://www.amazon.sg/dp/0399182020?ref_=mr_referred_us_sg_sg)

## 版本

- 国际服（非网易代理）
  - 基岩版（Bedrock），pe（portable edition），现在统称基岩版
    - 下载平台：Appstore（大陆账户不支持），Googleplay，微软应用商店（支持某付宝）
  - java版（早期称pc版）
- 国服/我的世界中国版 网易版
  - 基岩版（或者叫移动版）
  - pc/Java版（但实际上也提供基岩版本，是电脑上玩的国服）
- 主机板（如PS4，任天堂switch等，游戏内容可能有些不一样）
- 教育版

[想入手我的世界，但是不清楚各个版本区别，可以给点建议吗？ - 知乎](https://www.zhihu.com/question/363839132)

## 多人联机

- 同一wifi下国际版-》国际服局域网联机
- 不在同一wifi下，都有国际服基岩版-》国际服领域服
- 开个服务器，你不在时候朋友也能玩/一起玩的朋友大于一个/我要加mod和插件-》国际版正版或者盗版（第三方启动器）+租个服务器

国际服领域服，基本同上，基岩版限制比java版多，Java版领域服福利多，提供了很多很棒的预设地图，可以跟朋友玩好久好久，解密，rpg还是好看的建筑。个人感觉比国服贵点，但是不是很离谱，如果你和你朋友都买了国际服，不妨开领域服看看。PS：我玩的那会加入领域服需要12岁以上，如果年龄设置偏小，可能导致白租。

1. 家长允许 [Parental Controls in Minecraft | Minecraft](https://www.minecraft.net/en-us/article/parental-controls)
2. To set or edit parental controls for your child’s account, visit `https://account.xbox.com/settings` and click the account that you want to edit. You should see your child’s gamertag in the top right.
3. [多人游戏 - Minecraft Wiki，最详细的我的世界百科](https://minecraft.fandom.com/zh/wiki/多人游戏)
4. [How to Play Minecraft: Bedrock Edition Multiplayer | Minecraft Help](https://help.minecraft.net/hc/en-us/articles/4410316619533-How-to-Play-Minecraft-Bedrock-Edition-Multiplayer)

### How to host a Bedrock Edition server

[How to play on a Minecraft server | Minecraft](https://www.minecraft.net/en-us/article/how-play-minecraft-server)

Starting your own Bedrock Edition server to play with friends is simple. Start by creating a new world, or load up an existing world you want to play in. Once loaded, open the menu and hit the “Invite to Game” button on the right-hand side.

You’ll see a list of your friends and their gamertags, with those online listed at the top. Click the ones you want to play with and hit the “Send invites” button. If the friend you want to play with isn’t listed, then ask them for their gamertag and hit the “Add Friend” button. Type in their gamertag and you’ll be able to add it.

### How to play on a local area network (LAN)

Before you start:

- Each player that wants to join must be connected to the same network
- The selected host device must be capable of running a server of the chosen world
- Everyone joining must run the same version of the game as the host
- Everyone joining the game must have their own, separate Microsoft Accounts

To start a LAN session:

- Click Play on the Minecraft title screen
- Click the pencil icon on the world you want to play or create a new one
- Go to the Multiplayer tab and make sure that Visible to LAN Players is enabled
- Start the game

To join a LAN session:

- Click Play on the Minecraft title screen
- Go to the Friends tab and look for available LAN Games

## Minecraft Server

[How to Download Dedicated Minecraft Server Software | Minecraft Help](https://help.minecraft.net/hc/en-us/articles/4408873961869-Minecraft-Dedicated-and-Featured-Servers-Bedrock-FAQ-)

[基岩版服务器软件 - Minecraft Wiki，最详细的我的世界百科](https://minecraft.fandom.com/zh/wiki/基岩版服务器软件)

[How to Setup a Minecraft: Java Edition Server | Minecraft Help](https://help.minecraft.net/hc/en-us/articles/360058525452-How-to-Setup-a-Minecraft-Java-Edition-Server)
