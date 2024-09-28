#!/bin/bash

# setup.sh - 自动化 Docker Compose 项目设置脚本
# setup.sh - Automated Docker Compose Project Setup Script

set -e  # 当发生错误时，立即退出

# 函数：检查命令是否存在
command_exists () {
    command -v "$1" >/dev/null 2>&1
}

# 定义多语言提示
declare -A MSG_EN
declare -A MSG_ZH

# 英文提示
MSG_EN["check_dependencies"]="Checking necessary dependencies..."
MSG_EN["dependency_missing"]="Error: %s is not installed. Please install %s first."
MSG_EN["all_dependencies_installed"]="All dependencies are installed."
MSG_EN["cloning_repository"]="Cloning repository: %s..."
MSG_EN["clone_completed"]="Cloning completed."
MSG_EN["directory_exists"]="Directory %s already exists. Skipping clone step."
MSG_EN["docker_compose_missing"]="Error: docker-compose.yml file not found. Please ensure the project contains this file."
MSG_EN["creating_config_dir"]="Creating configuration directory %s..."
MSG_EN["config_exists"]="Configuration file %s already exists."
MSG_EN["overwrite_prompt"]="Do you want to overwrite the existing configuration file? (y/n): "
MSG_EN["using_existing_config"]="Using the existing configuration file."
MSG_EN["overwriting_config"]="Overwriting the configuration file..."
MSG_EN["creating_config"]="Creating configuration file %s..."
MSG_EN["enter_username"]="Enter username (credentials.username) [default: john_doe123]: "
MSG_EN["enter_password"]="Enter password (credentials.password) [default: password123]: "
MSG_EN["enter_like_prob"]="Enter like_probability (settings.like_probability) [default: 0.02]: "
MSG_EN["enter_reply_prob"]="Enter reply_probability (settings.reply_probability) [default: 0.02]: "
MSG_EN["enter_collect_prob"]="Enter collect_probability (settings.collect_probability) [default: 0.02]: "
MSG_EN["enter_max_retries"]="Enter max_retries (settings.max_retries) [default: 3]: "
MSG_EN["enter_daily_run_range"]="Enter daily_run_range (settings.daily_run_range) [default: 10-50]: "
MSG_EN["enter_sleep_time_range"]="Enter sleep_time_range (settings.sleep_time_range) [default: 10-25]: "
MSG_EN["enter_max_topics"]="Enter max_topics (settings.max_topics) [default: 20000]: "
MSG_EN["use_wxpusher_prompt"]="Do you want to use wxpusher? (use_wxpusher) [default: false] (y/n): "
MSG_EN["enter_app_token"]="Enter wxpusher app_token (wxpusher.app_token): "
MSG_EN["enter_topic_id"]="Enter wxpusher topic_id (wxpusher.topic_id): "
MSG_EN["config_created"]="Configuration file has been created."
MSG_EN["display_config"]="Current configuration file content:"
MSG_EN["start_docker_compose"]="Starting Docker Compose services..."
MSG_EN["docker_compose_started"]="Docker Compose services have been started."
MSG_EN["check_service_status"]="You can check the service status with the following command:\n  docker-compose ps"
MSG_EN["chmod_config"]="Setting permissions for config.ini to be readable only by the user."
MSG_EN["error_language"]="Invalid selection. Defaulting to English."

# 中文提示
MSG_ZH["check_dependencies"]="检查必要的依赖项..."
MSG_ZH["dependency_missing"]="错误: %s 未安装。请先安装 %s。"
MSG_ZH["all_dependencies_installed"]="所有依赖项均已安装。"
MSG_ZH["cloning_repository"]="正在克隆仓库: %s..."
MSG_ZH["clone_completed"]="克隆完成。"
MSG_ZH["directory_exists"]="目录 %s 已存在。跳过克隆步骤。"
MSG_ZH["docker_compose_missing"]="错误: 未找到 docker-compose.yml 文件。请确保项目中包含该文件。"
MSG_ZH["creating_config_dir"]="创建配置目录 %s..."
MSG_ZH["config_exists"]="配置文件 %s 已存在。"
MSG_ZH["overwrite_prompt"]="是否要覆盖现有的配置文件？ (y/n): "
MSG_ZH["using_existing_config"]="使用现有的配置文件。"
MSG_ZH["overwriting_config"]="正在覆盖配置文件..."
MSG_ZH["creating_config"]="正在创建配置文件 %s..."
MSG_ZH["enter_username"]="请输入用户名 (credentials.username) [默认: john_doe123]: "
MSG_ZH["enter_password"]="请输入密码 (credentials.password) [默认: password123]: "
MSG_ZH["enter_like_prob"]="请输入 like_probability (settings.like_probability) [默认: 0.02]: "
MSG_ZH["enter_reply_prob"]="请输入 reply_probability (settings.reply_probability) [默认: 0.02]: "
MSG_ZH["enter_collect_prob"]="请输入 collect_probability (settings.collect_probability) [默认: 0.02]: "
MSG_ZH["enter_max_retries"]="请输入 max_retries (settings.max_retries) [默认: 3]: "
MSG_ZH["enter_daily_run_range"]="请输入 daily_run_range (settings.daily_run_range) [默认: 10-50]: "
MSG_ZH["enter_sleep_time_range"]="请输入 sleep_time_range (settings.sleep_time_range) [默认: 10-25]: "
MSG_ZH["enter_max_topics"]="请输入 max_topics (settings.max_topics) [默认: 20000]: "
MSG_ZH["use_wxpusher_prompt"]="是否使用 wxpusher? (use_wxpusher) [默认: false] (y/n): "
MSG_ZH["enter_app_token"]="请输入 wxpusher app_token (wxpusher.app_token): "
MSG_ZH["enter_topic_id"]="请输入 wxpusher topic_id (wxpusher.topic_id): "
MSG_ZH["config_created"]="配置文件已创建。"
MSG_ZH["display_config"]="当前配置文件内容："
MSG_ZH["start_docker_compose"]="启动 Docker Compose 服务..."
MSG_ZH["docker_compose_started"]="Docker Compose 服务已启动。"
MSG_ZH["check_service_status"]="您可以使用以下命令查看服务状态：\n  docker-compose ps"
MSG_ZH["chmod_config"]="设置 config.ini 权限为仅用户可读。"
MSG_ZH["error_language"]="选择无效。默认使用英文。"

# 选择语言
echo "Select language / 选择语言:"
echo "1. English"
echo "2. 中文"
read -p "Enter choice (1/2): " lang_choice

if [ "$lang_choice" == "2" ]; then
    lang="ZH"
else
    lang="EN"
    if [ "$lang_choice" != "1" ]; then
        # 默认使用英文
        printf "${MSG_ZH["error_language"]}\n"
    fi
fi

# 函数：输出消息
msg() {
    local key=$1
    if [ "$lang" == "ZH" ]; then
        echo -e "${MSG_ZH[$key]}"
    else
        echo -e "${MSG_EN[$key]}"
    fi
}

# 检查依赖项
msg "check_dependencies"

for cmd in git docker docker-compose; do
    if ! command_exists $cmd ; then
        if [ "$lang" == "ZH" ]; then
            printf "${MSG_ZH["dependency_missing"]}\n" "$cmd" "$cmd"
        else
            printf "${MSG_EN["dependency_missing"]}\n" "$cmd" "$cmd"
        fi
        exit 1
    fi
done

msg "all_dependencies_installed"

# 克隆项目仓库
REPO_URL="https://github.com/shuwu-ui/DiscussBot.git"
PROJECT_DIR="DiscussBot"

if [ -d "$PROJECT_DIR" ]; then
    if [ "$lang" == "ZH" ]; then
        printf "${MSG_ZH["directory_exists"]}\n" "$PROJECT_DIR"
    else
        printf "${MSG_EN["directory_exists"]}\n" "$PROJECT_DIR"
    fi
else
    if [ "$lang" == "ZH" ]; then
        printf "${MSG_ZH["cloning_repository"]}\n" "$REPO_URL"
    else
        printf "${MSG_EN["cloning_repository"]}\n" "$REPO_URL"
    fi
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

if [ ! -d "$CONFIG_DIR" ]; then
    if [ "$lang" == "ZH" ]; then
        printf "${MSG_ZH["creating_config_dir"]}\n" "$CONFIG_DIR"
    else
        printf "${MSG_EN["creating_config_dir"]}\n" "$CONFIG_DIR"
    fi
    mkdir $CONFIG_DIR
fi

if [ -f "$CONFIG_FILE" ]; then
    if [ "$lang" == "ZH" ]; then
        printf "${MSG_ZH["config_exists"]}\n" "$CONFIG_FILE"
    else
        printf "${MSG_EN["config_exists"]}\n" "$CONFIG_FILE"
    fi
    read -p "$( [ "$lang" == "ZH" ] && echo "${MSG_ZH["overwrite_prompt"]}" || echo "${MSG_EN["overwrite_prompt"]}")" choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        msg "using_existing_config"
    else
        msg "overwriting_config"
        rm -f $CONFIG_FILE
        touch $CONFIG_FILE
    fi
fi

if [ ! -f "$CONFIG_FILE" ]; then
    msg "creating_config"

    # 读取配置项，提供默认值
    if [ "$lang" == "ZH" ]; then
        read -p "${MSG_ZH["enter_username"]}" username
    else
        read -p "${MSG_EN["enter_username"]}" username
    fi
    username=${username:-john_doe123}

    if [ "$lang" == "ZH" ]; then
        read -sp "${MSG_ZH["enter_password"]}" password
        echo
    else
        read -sp "${MSG_EN["enter_password"]}" password
        echo
    fi
    password=${password:-password123}

    if [ "$lang" == "ZH" ]; then
        read -p "${MSG_ZH["enter_like_prob"]}" like_probability
    else
        read -p "${MSG_EN["enter_like_prob"]}" like_probability
    fi
    like_probability=${like_probability:-0.02}

    if [ "$lang" == "ZH" ]; then
        read -p "${MSG_ZH["enter_reply_prob"]}" reply_probability
    else
        read -p "${MSG_EN["enter_reply_prob"]}" reply_probability
    fi
    reply_probability=${reply_probability:-0.02}

    if [ "$lang" == "ZH" ]; then
        read -p "${MSG_ZH["enter_collect_prob"]}" collect_probability
    else
        read -p "${MSG_EN["enter_collect_prob"]}" collect_probability
    fi
    collect_probability=${collect_probability:-0.02}

    if [ "$lang" == "ZH" ]; then
        read -p "${MSG_ZH["enter_max_retries"]}" max_retries
    else
        read -p "${MSG_EN["enter_max_retries"]}" max_retries
    fi
    max_retries=${max_retries:-3}

    if [ "$lang" == "ZH" ]; then
        read -p "${MSG_ZH["enter_daily_run_range"]}" daily_run_range
    else
        read -p "${MSG_EN["enter_daily_run_range"]}" daily_run_range
    fi
    daily_run_range=${daily_run_range:-10-50}

    if [ "$lang" == "ZH" ]; then
        read -p "${MSG_ZH["enter_sleep_time_range"]}" sleep_time_range
    else
        read -p "${MSG_EN["enter_sleep_time_range"]}" sleep_time_range
    fi
    sleep_time_range=${sleep_time_range:-10-25}

    if [ "$lang" == "ZH" ]; then
        read -p "${MSG_ZH["enter_max_topics"]}" max_topics
    else
        read -p "${MSG_EN["enter_max_topics"]}" max_topics
    fi
    max_topics=${max_topics:-20000}

    # URLs 部分使用默认值，不提供修改选项
    home_url="https://linux.do/"
    connect_url="https://connect.linux.do/"

    # wxpusher 部分
    if [ "$lang" == "ZH" ]; then
        read -p "${MSG_ZH["use_wxpusher_prompt"]}" use_wxpusher_input
    else
        read -p "${MSG_EN["use_wxpusher_prompt"]}" use_wxpusher_input
    fi
    case "$use_wxpusher_input" in
        y|Y|yes|YES)
            use_wxpusher=true
            if [ "$lang" == "ZH" ]; then
                read -p "${MSG_ZH["enter_app_token"]}" app_token
                read -p "${MSG_ZH["enter_topic_id"]}" topic_id
            else
                read -p "${MSG_EN["enter_app_token"]}" app_token
                read -p "${MSG_EN["enter_topic_id"]}" topic_id
            fi
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

[urls]
home_url = $home_url
connect_url = $connect_url

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
fi

# 显示配置文件内容
msg "display_config"
cat $CONFIG_FILE

# 设置 config.ini 文件权限为仅用户可读
if [ "$lang" == "ZH" ]; then
    printf "${MSG_ZH["chmod_config"]}\n"
else
    printf "${MSG_EN["chmod_config"]}\n"
fi
chmod 600 config/config.ini

# 启动 Docker Compose 服务
msg "start_docker_compose"
docker-compose up -d

msg "docker_compose_started"

# 提示用户检查服务状态
msg "check_service_status"
