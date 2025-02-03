这是一个《潜渊症》的服务端，自动从steamcmd下载服务端文件，并自动部署[LuaCsForBarotrauma](https://github.com/evilfactory/LuaCsForBarotrauma)和[Sakura Frp](https://www.natfrp.com/)。

# 部署

1. 将本仓库`git clone`到你的服务器
```
git clone https://github.com/IAKSH/baro-docker.git --depth=1
```
2. 使用docker compose启动
```
cd baro-docker
docker compose up
# 或者添加-d以在后台执行
# docker compose up -d
```

# 注意事项

## 1，构建

由于需要使用steamcmd匿名登陆并下载游戏文件，以及从Github拉取`LuaCsForBarotrauma`，你的构建环境可能需要科学上网。

## 2，内网穿透

1. 对Query端口的穿透是无效的，即使穿透也不会有数据经过，内网穿透方案会导致客户端无法获得服务器状态信息，也不能直接在服务器列表中找到这个服务器。
2. 不过，对于联机本身Query端口是可有可无的，只是正常运作的Query端口可以进行Steam验证，以及将你的服务器暴露在服务器列表中，吸引路人。
3. 如果你遇到了任何诡异的连接性问题，在确认内网穿透运行正常后，考虑检查是否关闭Steam验证。

下面是对上述Query端口问题的一种猜测，如果你想看的话：

我认为造成上述问题的原因**可能**是服务器需要先向Steam的服务器发送请求，然后Steam的服务器再访问27015和27016端口。但是由于出站请求并不会经过穿透隧道，而是直接从本地网络前往公网，使得Steam服务器最后拿到的源IP是“你的”公网IP（实际上可能是最顶层NAT的），而不是内网穿透服务器的IP。这就导致Steam将找不到内网穿透服务器上穿透出来的游戏数据端口（27015）。

一种可能的解决方案是通过某种操作强行将出站请求转发到27016的穿透隧道中，由穿透服务器发出，且保证27015和27016的两条隧道都在同一个穿透服务器上。

当然，这一切都只是猜测，甚至还有一种可能是，“回访”的地址是出站的UDP/TCP包中的某个字段。

不过我确实用iptables尝试过修改所有出站UDP的源端口为27016，虽然似乎并不行。

## 3，Mod

1. 虽然看起来似乎`Daedalic Entertainment GmbH\Barotrauma\WorkshopMods\Installed`才是正确的Mod存放路径，但是实际上所有Mod都只能放在`LocalMods`里，否则无法被加载。
2. 除了上传Mod文件，你还需要修改`config_player.xml`，这个文件保存了启用的Mod列表，建议在本地客户端启用Mod后，将该文件复制到服务器，并且修改所有Mod路径为`LocalMods`中的对应路径（VSCode可以直接更改所有匹配项）。

## 4，存档

存档的路径为`Daedalic Entertainment GmbH\Barotrauma\Multiplayer`，现版本似乎是有自动备份了，但是感觉差点意思，你可以自建一个。

## 5，Steam验证

0. 不知道为什么，偶尔会无论Query端口状况，都可以正常验证。
1. 【待验证】如果Query端口无法正常连接，且`serversettings.xml`中的`RequireAuthentication`为`True`，则会导致所有玩家均无法验证自身Steam ID，造成无法登录。
2. 解决方案有两个：保证Query端口运行正常，或者在`serversettings.xml`中关闭验证（`RequireAuthentication="False"`）。

## 6，管理权限

1. 对于服主不是管理员的情况，可以将本地游戏目录下的`Data/clientpermissions.xml`复制到服务器中，但是你需要保证服务器此时是**关闭**状态，否则你上传的`Data/clientpermissions.xml`将会被服务器覆盖为旧版本。
2. 对于关闭验证的情况，由于此时无法获取玩家的Steam ID，而本地上传的`Data/clientpermissions.xml`又都是记录的玩家Steam ID，所以可能需要手动添加未验证ID的权限。具体来说就是将`accountid`的值改为`UNAUTHENTICATED_<ID>`，其中的`<ID>`是你的角色名称。
3. 很明显关闭验证以后的这种按照名称来给予权限的做法是很不安全的，但是目前似乎没有更好的解决方案了。

## 7，控制台

默认情况下Docker Compose不会给服务端程序启用输入，也就导致你无法从终端向服务器输入指令，但是可以通过开启tty和stdin来实现这种操作：

在`doccker-compose.yaml`中取消下面两行的注释
```
    stdin_open: true
    tty: true
```

然后使用`docker compose up -d`令服务端后台运行后，可以通过`docker attach <CONTAINER ID>`连接到服务端，此时可以通过终端输入指令，且带有彩色输出和自动补全。

需要注意的是，此时如果使用`Ctrl+C`来退出，将会直接关掉服务端，正确的脱离做法连续按下`Ctrl+P`和`Ctrl+Q`。

另外，启用输入似乎会导致Docker Compose的日志输出异常，建议日常关闭，仅作为应急使用。

~~或者你可以自己再把控制台IO重定向到一个Web UI?~~