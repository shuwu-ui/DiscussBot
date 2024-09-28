# discuss论坛 保活脚本配置与运行指南

## 简介

这个脚本用于自动化操作以保持 discuss论坛 网站的活跃状态，包括浏览帖子并进行点赞，以及通过 WxPusher 推送消息到微信(可选)、自动回复帖子(可选)、自动加入书签(可选)。

---

# 注意事项

虽然此功能支持自动回复，但不建议启用(变量视环境而言 REPLY_PROBABILITY 或 reply_probability 回复概率配置为 0 即可关闭)。

因为论坛禁止 AI 生成的内容，自动回复功能可能也被包含在内。

从技术上讲，确实有办法规避检测，想要搞的可以自己研究，但是后果也需要自己承担。

---

## 变量检查与说明(重要)

### [credentials]
- **username**: 
  - 说明: 登录Discuss论坛的用户名。
  - 示例: `john_doe123`

- **password**: 
  - 说明: 登录Discuss论坛的密码。
  - 示例: `password123`

---

### [settings]
- **like_probability**: 
  - 说明: 点赞的概率，取值在0到1之间。例如，`0.02`表示有2%的概率为某个主题点赞。
  - 示例: `0.02`

- **reply_probability**: 
  - 说明: 回复的概率，取值在0到1之间。例如，`0.02`表示有2%的概率回复某个主题。
  - 示例: `0.02`

- **collect_probability**: 
  - 说明: 收藏（加入书签）的概率，取值在0到1之间。例如，`0.02`表示有2%的概率将某个主题加入书签。
  - 示例: `0.02`

- **max_retries**: 
  - 说明: 定义脚本在运行失败后的最大重试次数。如果脚本运行失败，程序会根据此设置重试指定的次数。若重试超过此次数，脚本将停止重试并跳过当前运行。
  - 示例: `3` 表示脚本最多会重试3次。

- **daily_run_range**: 
  - 说明: 设置每天脚本运行次数的范围，格式为`min-max`。程序会在这个范围内随机选择一个运行次数。例如，设置为 `10-50` 表示每天运行10到50次。如果生成的随机数小于10，则默认设置为10；如果大于50，则默认设置为50。
  - 示例: `10-50`

- **sleep_time_range**: 
  - 说明: 每次运行后的随机休眠时间范围，格式为`min-max`，单位为分钟。程序会在这个范围内随机选择一个时间进行休眠，确保运行间隔不会太短或太长。例如，设置为 `10-25`，表示每次运行后休眠10到25分钟。休眠时间如果小于10分钟，将默认设为10分钟；大于25分钟，则设为25分钟。
  - 示例: `10-25`

- **max_topics**: 
  - 说明: 最大处理的主题数量。如果超过此数量，程序将只处理前`max_topics`个主题。
  - 示例: `20000`

---

### [urls]
- **home_url**: 
  - 说明: Discuss论坛的主页URL。
  - 示例: `https://discussforum.com/`

- **connect_url**: 
  - 说明: 连接信息页面的URL。
  - 示例: `https://discussforum.com/connect`

---

#### [wxpusher]
- **use_wxpusher**: 
  - 说明: 是否使用wxpusher发送消息通知。可以为 `true` 或 `false`。
  - 示例: `true`

- **app_token**: 
  - 说明: wxpusher的应用appToken，当`use_wxpusher`为`true`时需要配置。
  - 示例: `your_app_token`

- **topic_id**: 
  - 说明: wxpusher的topicId，当`use_wxpusher`为`true`时需要配置。
  - 示例: `your_topic_id`

---


# 注意
### 账号与密码必须配置正确,以及关闭2FA验证
### 如果账号或者密码错误,以及2FA验证未关闭导致程序运行不当
### 程序不会自动停止,会一直重试的运行下去,运行后请前往log文件夹下查看日志或者前往web端查看日志!!!

---


# 一、使用 Docker Compose运行项目

## 1.1 使用 Docker Compose

如果你有多个服务需要一起运行，或者想更方便地管理容器，可以使用 `docker-compose`。首先确保你的项目中有 `docker-compose.yml` 文件。

## 拉取项目,修改配置

```bash
git clone https://github.com/yourrepo/bot.git  # 替换为实际的Git地址
cd bot
```
## 1.2 配置文件

在项目根目录下的 `config/` 目录中打开 `config.ini` 文件，并根据实际情况进行配置。文件内容如下：

```ini
[credentials]
username = john_doe123
password = password123

[settings]
like_probability = 0.02
reply_probability = 0.02
collect_probability = 0.02
max_retries = 3
daily_run_range = 10-50
sleep_time_range = 10-25
max_topics = 20000

[urls]
home_url = https://linux.do/
connect_url = https://connect.linux.do/

[wxpusher]
use_wxpusher = true
app_token = your_app_token
topic_id = your_topic_id
```
参数说明:[变量检查与说明(重要)](#变量检查与说明重要)

## 1.3执行以下命令启动 Docker Compose 服务：

```
docker-compose up -d
```

这将基于 `docker-compose.yml` 文件中的配置，自动构建并运行多个容器。可以通过 `docker-compose logs` 查看容器的日志输出。

---

## 1.2 停止和查看容器状态

在项目运行过程中，可能需要停止或查看容器的状态。以下是一些常用的 Docker Compose 命令：

### 1.2.1 停止所有容器

如果你想停止正在运行的所有容器，可以使用以下命令：

```bash
docker-compose down
```

该命令将停止并删除所有由 `docker-compose` 启动的容器，但不会删除数据卷和网络。如果你希望连同数据卷和网络一起删除，可以添加 `-v` 参数：

```bash
docker-compose down -v
```

这样可以确保彻底清理容器、数据卷和网络，以防止后续启动时出现冲突。

### 1.2.2 停止特定服务

如果你只想停止某个特定的服务，可以运行以下命令：

```bash
docker-compose stop [service_name]
```

`[service_name]` 替换为你在 `docker-compose.yml` 文件中定义的具体服务名称。例如，如果你想停止 `web_panel` 服务，命令将是：

```bash
docker-compose stop web_panel
```

### 1.2.3 查看容器状态

要查看当前所有服务的运行状态，可以使用以下命令：

```bash
docker-compose ps
```

该命令将列出所有容器的名称、状态以及端口映射情况。如果某些服务没有按预期启动或停止，可以通过查看状态信息快速定位问题。

### 1.2.4 查看服务日志

可以通过 `docker-compose logs` 查看所有容器的日志输出，帮助诊断错误或调试应用程序。为了查看特定服务的日志，可以使用以下命令：

```bash
docker-compose logs [service_name]
```

例如，要查看 `web_panel` 服务的日志，命令如下：

```bash
docker-compose logs web_panel
```

如果希望实时查看日志并自动刷新，可以加上 `-f` 参数：

```bash
docker-compose logs -f
```

这样你就可以跟踪服务的实时日志输出，便于调试和监控应用运行情况。

### 1.2.5 重启服务

如果想要重启所有或特定的服务，可以使用以下命令：

```bash
docker-compose restart [service_name]
```
如果省略 `[service_name]`，则会重启所有服务。

通过这些命令，你可以轻松地管理、监控和控制 Docker Compose 容器的运行状态。

---

## 完整配置顺序

1. **使用 Docker 运行项目**：
   1.1 使用 Docker Compose
   1.2 停止和查看容器状态  


