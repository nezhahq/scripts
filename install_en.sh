#!/bin/sh

NZ_BASE_PATH="/opt/nezha"
NZ_DASHBOARD_PATH="${NZ_BASE_PATH}/dashboard"
NZ_DASHBOARD_SERVICE="/etc/systemd/system/nezha-dashboard.service"
NZ_DASHBOARD_SERVICERC="/etc/init.d/nezha-dashboard"

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

err() {
    printf "${red}%s${plain}\n" "$*" >&2
}

success() {
    printf "${green}%s${plain}\n" "$*"
}

info() {
    printf "${yellow}%s${plain}\n" "$*"
}

println() {
    printf "$*\n"
}

sudo() {
    myEUID=$(id -ru)
    if [ "$myEUID" -ne 0 ]; then
        if command -v sudo > /dev/null 2>&1; then
            command sudo "$@"
        else
            err "ERROR: sudo is not installed on the system, the action cannot be proceeded."
            exit 1
        fi
    else
        "$@"
    fi
}

mustn() {
    set -- "$@"
    
    if ! "$@" >/dev/null 2>&1; then
        err "Run '$*' failed."
        exit 1
    fi
}

deps_check() {
    deps="curl wget unzip grep"
    set -- "$api_list"
    for dep in $deps; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            err "$dep not found, please install it first."
            exit 1
        fi
    done
}

check_init() {
    init=$(readlink /sbin/init)
    case "$init" in
        *systemd*)
            INIT=systemd
            ;;
        *openrc-init*|*busybox*)
            INIT=openrc
            ;;
        *)
            err "Unknown init"
            exit 1
            ;;
    esac
}

geo_check() {
    api_list="https://blog.cloudflare.com/cdn-cgi/trace https://developers.cloudflare.com/cdn-cgi/trace"
    ua="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0"
    set -- "$api_list"
    for url in $api_list; do
        text="$(curl -A "$ua" -m 10 -s "$url")"
        endpoint="$(echo "$text" | sed -n 's/.*h=\([^ ]*\).*/\1/p')"
        if echo "$text" | grep -qw 'CN'; then
            isCN=true
            break
        elif echo "$url" | grep -q "$endpoint"; then
            break
        fi
    done
}

env_check() {
    uname=$(uname -m)
    case "$uname" in
        amd64|x86_64)
            os_arch="amd64"
            ;;
        i386|i686)
            os_arch="386"
            ;;
        aarch64|arm64)
            os_arch="arm64"
            ;;
        *arm*)
            os_arch="arm"
            ;;
        s390x)
            os_arch="s390x"
            ;;
        riscv64)
            os_arch="riscv64"
            ;;
        *)
            err "Unknown architecture: $uname"
            exit 1
            ;;
    esac
}


installation_check() {
    if docker compose version >/dev/null 2>&1; then
        DOCKER_COMPOSE_COMMAND="docker compose"
        if sudo $DOCKER_COMPOSE_COMMAND ls | grep -qw "$NZ_DASHBOARD_PATH/docker-compose.yaml" >/dev/null 2>&1; then
            NEZHA_IMAGES=$(sudo docker images --format "{{.Repository}}":"{{.Tag}}" | grep -w "nezhahq/nezha")
            if [ -n "$NEZHA_IMAGES" ]; then
                echo "Docker image with nezha repository exists:"
                echo "$NEZHA_IMAGES"
                IS_DOCKER_NEZHA=1
                FRESH_INSTALL=0
                return
            else
                echo "No Docker images with the nezha repository were found."
            fi
        fi
    elif command -v docker-compose >/dev/null 2>&1; then
        DOCKER_COMPOSE_COMMAND="docker-compose"
        if sudo $DOCKER_COMPOSE_COMMAND -f "$NZ_DASHBOARD_PATH/docker-compose.yaml" config >/dev/null 2>&1; then
            NEZHA_IMAGES=$(sudo docker images --format "{{.Repository}}":"{{.Tag}}" | grep -w "nezhahq/nezha")
            if [ -n "$NEZHA_IMAGES" ]; then
                echo "Docker image with nezha repository exists:"
                echo "$NEZHA_IMAGES"
                IS_DOCKER_NEZHA=1
                FRESH_INSTALL=0
                return
            else
                echo "No Docker images with the nezha repository were found."
            fi
        fi
    fi

    if [ -f "$NZ_DASHBOARD_PATH/app" ]; then
        IS_DOCKER_NEZHA=0
        FRESH_INSTALL=0
    fi
}

select_version() {
    if [ -z "$IS_DOCKER_NEZHA" ]; then
        info "Select your installation method:"
        info "1. Docker"
        info "2. Standalone"
        while true; do
            printf "Please enter [1-2]: "
            read -r option
            case "${option}" in
                1)
                    IS_DOCKER_NEZHA=1
                    break
                    ;;
                2)
                    IS_DOCKER_NEZHA=0
                    break
                    ;;
                *)
                    err "Please enter the correct number [1-2]"
                    ;;
            esac
        done
    fi
}

init() {
    deps_check
    check_init
    env_check
    installation_check

    ## China_IP
    if [ -z "$CN" ]; then
        geo_check
        if [ -n "$isCN" ]; then
            echo "According to the information provided by various geoip api, the current IP may be in China"
            printf "Will the installation be done with a Chinese Mirror? [Y/n] (Custom Mirror Input 3): "
            read -r input
            case $input in
            [yY][eE][sS] | [yY])
                echo "Use Chinese Mirror"
                CN=true
                ;;

            [nN][oO] | [nN])
                echo "Do Not Use Chinese Mirror"
                ;;

            [3])
                echo "Use Custom Mirror"
                printf "Please enter a custom image (e.g. :dn-dao-github-mirror.daocloud.io). If left blank, it won't be used: "
                read -r input
                case $input in
                *)
                    CUSTOM_MIRROR=$input
                    ;;
                esac
                ;;
            *)
                echo "Do Not Use Chinese Mirror"
                ;;
            esac
        fi
    fi

    if [ -n "$CUSTOM_MIRROR" ]; then
        GITHUB_RAW_URL="gitee.com/naibahq/scripts/raw/main"
        GITHUB_URL=$CUSTOM_MIRROR
        Docker_IMG="registry.cn-shanghai.aliyuncs.com\/naibahq\/nezha-dashboard"
    else
        if [ -z "$CN" ]; then
            GITHUB_RAW_URL="raw.githubusercontent.com/nezhahq/scripts/main"
            GITHUB_URL="github.com"
            Docker_IMG="ghcr.io\/nezhahq\/nezha"
        else
            GITHUB_RAW_URL="gitee.com/naibahq/scripts/raw/main"
            GITHUB_URL="gitee.com"
            Docker_IMG="registry.cn-shanghai.aliyuncs.com\/naibahq\/nezha-dashboard"
        fi
    fi
}

update_script() {
    echo "> Update Script"

    curl -sL "https://${GITHUB_RAW_URL}/install_en.sh" -o /tmp/nezha.sh
    mv -f /tmp/nezha.sh ./nezha.sh && chmod a+x ./nezha.sh

    echo "Execute new script after 3s"
    sleep 3s
    clear
    exec ./nezha.sh
    exit 0
}

install_agent_v0() {
    shell_url="https://raw.githubusercontent.com/nezhahq/scripts/refs/heads/v0/install.sh"
    file_name="nezha_v0.sh"
    if command -v wget >/dev/null 2>&1; then
        wget -O "/tmp/install_v0.sh" "$shell_url"
    elif command -v curl >/dev/null 2>&1; then
        curl -o "/tmp/install_v0.sh" "$shell_url"
    fi
    chmod a+x /tmp/install_v0.sh
    mv -f /tmp/install_v0.sh ./nezha_v0.sh
    echo "Execute new script after 3s"
    sleep 3s
    clear
    exec ./nezha_v0.sh "$@"
    exit 0
}

before_show_menu() {
    echo && info "* Press Enter to return to the main menu *" && read temp
    show_menu
}

install() {
    echo "> Install"

    # Nezha Monitoring Folder
    if [ ! "$FRESH_INSTALL" = 0 ]; then
        sudo mkdir -p $NZ_DASHBOARD_PATH
    else
        echo "You may have already installed the dashboard, repeated installation will overwrite the data, please pay attention to backup."
        printf "Exit the installation? [Y/n]"
        read -r input
        case $input in
        [yY][eE][sS] | [yY])
            echo "Exit the installation"
            exit 0
            ;;
        [nN][oO] | [nN])
            echo "Continue"
            ;;
        *)
            echo "Exit the installation"
            exit 0
            ;;
        esac
    fi

    modify_config 0

    if [ $# = 0 ]; then
        before_show_menu
    fi
}

modify_config() {
    echo "Modify Configuration"

    if [ "$IS_DOCKER_NEZHA" = 1 ]; then
        if [ -n "$DOCKER_COMPOSE_COMMAND" ]; then
            echo "Download Docker Script"
            _cmd="wget -t 2 -T 60 -O /tmp/nezha-docker-compose.yaml https://${GITHUB_RAW_URL}/extras/docker-compose.yaml >/dev/null 2>&1"
            if ! eval "$_cmd"; then
                err "Script failed to get, please check if the network can link ${GITHUB_RAW_URL}"
                return 0
            fi
        else
            err "Please install docker-compose manually. https://docs.docker.com/compose/install/linux/"
            before_show_menu
        fi
    fi

    _cmd="wget -t 2 -T 60 -O /tmp/nezha-config.yaml https://${GITHUB_RAW_URL}/extras/config.yaml >/dev/null 2>&1"
    if ! eval "$_cmd"; then
        err "Script failed to get, please check if the network can link ${GITHUB_RAW_URL}"
        return 0
    fi

    printf "Please enter the site title: "
    read -r nz_site_title
    printf "Please enter the exposed port: (default 8008)"
    read -r nz_port
    printf "Please specify the preset nezha-agent host in install commands: (e.g. example.com:443)"
    read -r nz_hostport
    printf "Do you prefer to connect Agent via TLS? [y/N]"
    read -r input
    case $input in
    [yY][eE][sS] | [yY])
        nz_tls=true
        ;;
    [nN][oO] | [nN])
        nz_tls=false
        ;;
    *)
        nz_tls=false
        ;;
    esac
    println "Please specify the backend locale"
    println "1. 中文（简体）"
    println "2. 中文（台灣）"
    println "3. English"
    while true; do
        printf "Please enter [1-3]: "
        read -r option
        case "${option}" in
            1)
                nz_lang=zh_CN
                break
                ;;
            2)
                nz_lang=zh_TW
                break
                ;;
            3)
                nz_lang=en_US
                break
                ;;
            *)
                err "Please enter the correct number [1-3]"
                ;;
        esac
    done

    if [ -z "$nz_lang" ] || [ -z "$nz_site_title" ] || [ -z "$nz_hostport" ]; then
        err "All options cannot be empty"
        before_show_menu
        return 1
    fi

    if [ -z "$nz_port" ]; then
        nz_port=8008
    fi

    sed -i "s/nz_port/${nz_port}/" /tmp/nezha-config.yaml
    sed -i "s/nz_language/${nz_lang}/" /tmp/nezha-config.yaml
    sed -i "s/nz_site_title/${nz_site_title}/" /tmp/nezha-config.yaml
    sed -i "s/nz_hostport/${nz_hostport}/" /tmp/nezha-config.yaml
    sed -i "s/nz_tls/${nz_tls}/" /tmp/nezha-config.yaml
    if [ "$IS_DOCKER_NEZHA" = 1 ]; then
        sed -i "s/nz_port/${nz_port}/g" /tmp/nezha-docker-compose.yaml
        sed -i "s/nz_image_url/${Docker_IMG}/" /tmp/nezha-docker-compose.yaml
    fi

    sudo mkdir -p $NZ_DASHBOARD_PATH/data
    sudo mv -f /tmp/nezha-config.yaml ${NZ_DASHBOARD_PATH}/data/config.yaml
    if [ "$IS_DOCKER_NEZHA" = 1 ]; then
        sudo mv -f /tmp/nezha-docker-compose.yaml ${NZ_DASHBOARD_PATH}/docker-compose.yaml
    fi

    if [ "$IS_DOCKER_NEZHA" = 0 ]; then
        echo "Downloading service file"
        if [ "$INIT" = "systemd" ]; then
            _download="sudo wget -t 2 -T 60 -O $NZ_DASHBOARD_SERVICE https://${GITHUB_RAW_URL}/services/nezha-dashboard.service >/dev/null 2>&1"
            if ! eval "$_download"; then
                err "File failed to get, please check if the network can link ${GITHUB_RAW_URL}"
                return 0
            fi
        elif [ "$INIT" = "openrc" ]; then
            _download="sudo wget -t 2 -T 60 -O $NZ_DASHBOARD_SERVICERC https://${GITHUB_RAW_URL}/services/nezha-dashboard >/dev/null 2>&1"
            if ! eval "$_download"; then
                err "File failed to get, please check if the network can link ${GITHUB_RAW_URL}"
                return 0
            fi
            sudo chmod +x $NZ_DASHBOARD_SERVICERC
        fi
    fi


    success "Dashboard configuration modified successfully, please wait for Dashboard self-restart to take effect"

    restart_and_update

    if [ $# = 0 ]; then
        before_show_menu
    fi
}

restart_and_update() {
    echo "> Restart and Update"

    if [ "$IS_DOCKER_NEZHA" = 1 ]; then
        _cmd="restart_and_update_docker"
    elif [ "$IS_DOCKER_NEZHA" = 0 ]; then
        _cmd="restart_and_update_standalone"
    fi

    if eval "$_cmd"; then
        success "Nezha Monitoring Restart Successful"
        info "Default address: domain:site_access_port"
    else
        err "The restart failed, probably because the boot time exceeded two seconds, please check the log information later"
    fi

    if [ $# = 0 ]; then
        before_show_menu
    fi
}

restart_and_update_docker() {
    sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml pull
    sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml down
    sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml up -d
}

restart_and_update_standalone() {
    _version=$(curl -m 10 -sL "https://api.github.com/repos/nezhahq/nezha/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
    if [ -z "$_version" ]; then
        _version=$(curl -m 10 -sL "https://fastly.jsdelivr.net/gh/nezhahq/nezha/" | grep "option\.value" | awk -F "'" '{print $2}' | sed 's/nezhahq\/nezha@/v/g')
    fi
    if [ -z "$_version" ]; then
        _version=$(curl -m 10 -sL "https://gcore.jsdelivr.net/gh/nezhahq/nezha/" | grep "option\.value" | awk -F "'" '{print $2}' | sed 's/nezhahq\/nezha@/v/g')
    fi
    if [ -z "$_version" ]; then
        _version=$(curl -m 10 -sL "https://gitee.com/api/v5/repos/naibahq/nezha/releases/latest" | awk -F '"' '{for(i=1;i<=NF;i++){if($i=="tag_name"){print $(i+2)}}}')
    fi

    if [ -z "$_version" ]; then
        err "Fail to obtain Dashboard version, please check if the network can link https://api.github.com/repos/nezhahq/nezha/releases/latest"
        return 1
    else
        echo "The current latest version is: ${_version}"
    fi

    if [ "$INIT" = "systemd" ]; then
        sudo systemctl daemon-reload
        sudo systemctl stop nezha-dashboard
    elif [ "$INIT" = "openrc" ]; then
        sudo rc-service nezha-dashboard stop
    fi

    if [ -z "$CN" ]; then
        NZ_DASHBOARD_URL="https://${GITHUB_URL}/nezhahq/nezha/releases/download/${_version}/dashboard-linux-${os_arch}.zip"
    else
        NZ_DASHBOARD_URL="https://${GITHUB_URL}/naibahq/nezha/releases/download/${_version}/dashboard-linux-${os_arch}.zip"
    fi

    sudo wget -qO $NZ_DASHBOARD_PATH/app.zip "$NZ_DASHBOARD_URL" >/dev/null 2>&1 && sudo unzip -qq -o $NZ_DASHBOARD_PATH/app.zip -d $NZ_DASHBOARD_PATH && sudo mv $NZ_DASHBOARD_PATH/dashboard-linux-$os_arch $NZ_DASHBOARD_PATH/app && sudo rm $NZ_DASHBOARD_PATH/app.zip
    sudo chmod +x $NZ_DASHBOARD_PATH/app

    if [ "$INIT" = "systemd" ]; then
        sudo systemctl enable nezha-dashboard
        sudo systemctl restart nezha-dashboard
    elif [ "$INIT" = "openrc" ]; then
        sudo rc-update add nezha-dashboard
        sudo rc-service nezha-dashboard restart
    fi
}

show_log() {
    echo "> View Log"

    if [ "$IS_DOCKER_NEZHA" = 1 ]; then
        show_dashboard_log_docker
    elif [ "$IS_DOCKER_NEZHA" = 0 ]; then
        show_dashboard_log_standalone
    fi

    if [ $# = 0 ]; then
        before_show_menu
    fi
}

show_dashboard_log_docker() {
    sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml logs -f
}

show_dashboard_log_standalone() {
    if [ "$INIT" = "systemd" ]; then
        sudo journalctl -xf -u nezha-dashboard.service
    elif [ "$INIT" = "openrc" ]; then
        sudo tail -n 10 /var/log/nezha-dashboard.err
    fi
}

uninstall() {
    echo "> Uninstall"

    if [ "$IS_DOCKER_NEZHA" = 1 ]; then
        uninstall_dashboard_docker
    elif [ "$IS_DOCKER_NEZHA" = 0 ]; then
        uninstall_dashboard_standalone
    fi

    if [ $# = 0 ]; then
        before_show_menu
    fi
}

uninstall_dashboard_docker() {
    sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml down
    sudo rm -rf $NZ_DASHBOARD_PATH
    sudo docker rmi -f ghcr.io/nezhahq/nezha >/dev/null 2>&1
    sudo docker rmi -f registry.cn-shanghai.aliyuncs.com/naibahq/nezha-dashboard >/dev/null 2>&1
}

uninstall_dashboard_standalone() {
    sudo rm -rf $NZ_DASHBOARD_PATH

    if [ "$INIT" = "systemd" ]; then
        sudo systemctl disable nezha-dashboard
        sudo systemctl stop nezha-dashboard
    elif [ "$INIT" = "openrc" ]; then
        sudo rc-update del nezha-dashboard
        sudo rc-service nezha-dashboard stop
    fi

    if [ "$INIT" = "systemd" ]; then
        sudo rm $NZ_DASHBOARD_SERVICE
    elif [ "$INIT" = "openrc" ]; then
        sudo rm $NZ_DASHBOARD_SERVICERC
    fi
}

show_usage() {
    echo "Nezha Monitor Management Script Usage: "
    echo "--------------------------------------------------------"
    echo "./nezha.sh                    - Show Menu"
    echo "./nezha.sh install            - Install Dashboard"
    echo "./nezha.sh modify_config      - Modify Dashboard Configuration"
    echo "./nezha.sh restart_and_update - Restart and Update the Dashboard"
    echo "./nezha.sh show_log           - View Dashboard Log"
    echo "./nezha.sh uninstall          - Uninstall Dashboard"
    echo "--------------------------------------------------------"
}

show_menu() {
    println "${green}Nezha Monitor Management Script${plain}"
    echo "--- https://github.com/nezhahq/nezha ---"
    println "${green}1.${plain}  Install Dashboard"
    println "${green}2.${plain}  Modify Dashboard Configuration"
    println "${green}3.${plain}  Restart and Update Dashboard"
    println "${green}4.${plain}  View Dashboard Log"
    println "${green}5.${plain}  Uninstall Dashboard"
    echo "————————————————-"
    println "${green}6.${plain}  Update Script"
    echo "————————————————-"
    println "${green}0.${plain}  Exit Script"

    echo && printf "Please enter [0-6]: " && read -r num
    case "${num}" in
        0)
            exit 0
            ;;
        1)
            install
            ;;
        2)
            modify_config
            ;;
        3)
            restart_and_update
            ;;
        4)
            show_log
            ;;
        5)
            uninstall
            ;;
        6)
            update_script
            ;;
        *)
            err "Please enter the correct number [0-6]"
            ;;
    esac
}

init

if [ $# -gt 0 ]; then
    case $1 in
        "install")
            install 0
            ;;
        "modify_config")
            modify_config 0
            ;;
        "restart_and_update")
            restart_and_update 0
            ;;
        "show_log")
            show_log 0
            ;;
        "uninstall")
            uninstall 0
            ;;
        "update_script")
            update_script 0
            ;;
        "install_agent")
            install_agent_v0 "$@"
            ;;
        *) show_usage ;;
    esac
else
    select_version
    show_menu
fi
