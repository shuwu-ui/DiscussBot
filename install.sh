#!/bin/bash

# setup.sh - 自动化 Docker Compose 项目设置脚本

set -e  # 当发生错误时，立即退出

# 捕获Ctrl+C中断信号，提示用户
trap 'echo "脚本被中断，正在退出..."; exit 1;' INT

# 函数：检查命令是否存在
command_exists () {
    command -v "$1" >/dev/null 2>&1
}

# 中文提示
declare -A MSG_ZH

MSG_ZH["check_dependencies"]="检查必要的依赖项..."
MSG_ZH["dependency_missing"]="错误: %s 未安装。请先安装 %s。"
MSG_ZH["all_dependencies_installed"]="所有依赖项均已安装。"
MSG_ZH["cloning_repository"]="正在克隆仓库: %s..."
MSG_ZH["clone_completed"]="克隆完成。"
MSG_ZH["directory_exists"]="目录 %s 已存在。跳过克隆步骤。"
MSG_ZH["docker_compose_missing"]="错误: 未找到 docker-compose.yml 文件。请确保项目中包含该文件。"
MSG_ZH["creating_config_dir"]="创建配置目录 %s..."
MSG_ZH["config_created"]="配置文件已创建。"
MSG_ZH["display_config"]="当前配置文件内容："
MSG_ZH["start_docker_compose"]="启动 Docker Compose 服务..."
MSG_ZH["docker_compose_started"]="Docker Compose 服务已启动。"
MSG_ZH["check_service_status"]="您可以使用以下命令查看服务状态：\n  docker-compose ps"
MSG_ZH["chmod_config"]="设置 config.ini 权限为仅用户可读。"

# 函数：输出消息
msg() {
    local key=$1
    echo -e "${MSG_ZH[$key]}"
}

# 检查依赖项
msg "check_dependencies"

for cmd in git docker docker-compose; do
    if ! command_exists $cmd ; then
        printf "${MSG_ZH["dependency_missing"]}\n" "$cmd" "$cmd"
        exit 1
    fi
done

msg "all_dependencies_installed"

# 克隆项目仓库
REPO_URL="https://github.com/shuwu-ui/DiscussBot.git"
PROJECT_DIR="DiscussBot"

if [ -d "$PROJECT_DIR" ]; then
    printf "${MSG_ZH["directory_exists"]}\n" "$PROJECT_DIR"
else
    printf "${MSG_ZH["cloning_repository"]}\n" "$REPO_URL"
    git clone $REPO_URL
    msg "clone_completed"
fi

cd $PROJECT_DIR

# 检查 docker-compose.yml 是否存在
if [ ! -f "docker-compose.yml" ]; then
    msg "docker_compose_missing"
    exit 1
fi

# 配置 config.ini
CONFIG_DIR="config"
CONFIG_FILE="$CONFIG_DIR/config.ini"

# 强制删除旧的 config.ini 文件，确保每次运行都要求用户输入新的配置
if [ -f "$CONFIG_FILE" ]; then
    rm -f $CONFIG_FILE
fi

if [ ! -d "$CONFIG_DIR" ]; then
    printf "${MSG_ZH["creating_config_dir"]}\n" "$CONFIG_DIR"
    mkdir $CONFIG_DIR
fi

# 创建新的配置文件
msg "creating_config"

# 读取配置项，用户可以输入，未输入则使用默认值
read -p "请输入用户名 (credentials.username) [默认: john_doe123]: " username
username=${username:-john_doe123}

read -sp "请输入密码 (credentials.password) [默认: password123]: " password
echo
password=${password:-password123}

read -p "请输入 like_probability (settings.like_probability) [默认: 0.02]: " like_probability
like_probability=${like_probability:-0.02}

read -p "请输入 reply_probability (settings.reply_probability) [默认: 0.02]: " reply_probability
reply_probability=${reply_probability:-0.02}

read -p "请输入 collect_probability (settings.collect_probability) [默认: 0.02]: " collect_probability
collect_probability=${collect_probability:-0.02}

read -p "请输入 max_retries (settings.max_retries) [默认: 3]: " max_retries
max_retries=${max_retries:-3}

read -p "请输入 daily_run_range (settings.daily_run_range) [默认: 10-50]: " daily_run_range
daily_run_range=${daily_run_range:-10-50}

read -p "请输入 sleep_time_range (settings.sleep_time_range) [默认: 10-25]: " sleep_time_range
sleep_time_range=${sleep_time_range:-10-25}

read -p "请输入 max_topics (settings.max_topics) [默认: 20000]: " max_topics
max_topics=${max_topics:-20000}

# wxpusher 部分
read -p "是否使用 wxpusher (use_wxpusher) [默认: false] (y/n): " use_wxpusher_input
case "$use_wxpusher_input" in
    y|Y|yes|YES)
        use_wxpusher=true
        read -p "请输入 wxpusher app_token (wxpusher.app_token): " app_token
        read -p "请输入 wxpusher topic_id (wxpusher.topic_id): " topic_id
        ;;
    *)
        use_wxpusher=false
        app_token=""
        topic_id=""
        ;;
esac

# 生成 config.ini 文件
cat > $CONFIG_FILE <<EOL
[credentials]
username = $username
password = $password

[settings]
like_probability = $like_probability
reply_probability = $reply_probability
collect_probability = $collect_probability
max_retries = $max_retries
daily_run_range = $daily_run_range
sleep_time_range = $sleep_time_range
max_topics = $max_topics

[wxpusher]
use_wxpusher = $use_wxpusher
EOL

# 仅在 use_wxpusher 为 true 时添加 app_token 和 topic_id
if [ "$use_wxpusher" = "true" ]; then
    cat >> $CONFIG_FILE <<EOL
app_token = $app_token
topic_id = $topic_id
EOL
fi

msg "config_created"

# 显示配置文件内容
msg "display_config"
cat $CONFIG_FILE

# 设置 config.ini 文件权限为仅用户可读
msg "chmod_config"
chmod 600 $CONFIG_FILE

# 启动 Docker Compose 服务
msg "start_docker_compose"
docker-compose up -d

msg "docker_compose_started"

# 提示用户检查服务状态
msg "check_service_status"
