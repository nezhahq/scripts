#!/bin/sh
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

NZ_BASE_PATH="/opt/nezha"
NZ_DASHBOARD_PATH="${NZ_BASE_PATH}/dashboard"
NZ_DASHBOARD_SERVICE="/etc/systemd/system/nezha-dashboard.service"
NZ_DASHBOARD_SERVICERC="/etc/init.d/nezha-dashboard"
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

err() {
printf "${red}%s${plain}\n" "$*" >&2
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

success() {
printf "${green}%s${plain}\n" "$*"
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

info() {
printf "${yellow}%s${plain}\n" "$*"
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

sudo() {
myEUID=$(id -ru)
if [ "$myEUID" -ne 0 ]; then
if command -v sudo > /dev/null 2>&1; then
command sudo "$@"
else
err _("ERROR: sudo is not installed on the system, the action cannot be proceeded.")
exit 1
fi
else
"$@"
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

mustn() {
set -- "$@"
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if ! "$@" >/dev/null 2>&1; then
err _("Run '$*' failed.")
exit 1
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

deps_check() {
deps="curl wget unzip grep"
set -- "$api_list"
for dep in $deps; do
if ! command -v "$dep"; then
err _("$dep not found, please install it first.")
exit 1
fi
done
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

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
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

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
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

env_check() {
uname=$(uname -m)
case "$uname" in
amd64)
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
err _("Unknown architecture: $uname")
exit 1
;;
esac
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

installation_check() {
if docker compose version >/dev/null 2>&1; then
DOCKER_COMPOSE_COMMAND="docker compose"
if sudo $DOCKER_COMPOSE_COMMAND ls | grep -qw "$NZ_DASHBOARD_PATH/docker-compose.yaml" >/dev/null 2>&1; then
NEZHA_IMAGES=$(sudo docker images --format "{{"{{.Repository}}"}}:{{"{{.Tag}}"}}" | grep -w "nezha-dashboard")
if [ -n "$NEZHA_IMAGES" ]; then
echo _("Docker image with nezha-dashboard repository exists:")
echo "$NEZHA_IMAGES"
IS_DOCKER_NEZHA=1
FRESH_INSTALL=0
return
else
echo _("No Docker images with the nezha-dashboard repository were found.")
fi
fi
elif command -v docker-compose >/dev/null 2>&1; then
DOCKER_COMPOSE_COMMAND="docker-compose"
if sudo $DOCKER_COMPOSE_COMMAND -f "$NZ_DASHBOARD_PATH/docker-compose.yaml" config >/dev/null 2>&1; then
NEZHA_IMAGES=$(sudo docker images --format "{{"{{.Repository}}"}}:{{"{{.Tag}}"}}" | grep -w "nezha-dashboard")
if [ -n "$NEZHA_IMAGES" ]; then
echo _("Docker image with nezha-dashboard repository exists:")
echo "$NEZHA_IMAGES"
IS_DOCKER_NEZHA=1
FRESH_INSTALL=0
return
else
echo _("No Docker images with the nezha-dashboard repository were found.")
fi
fi
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ -f "$NZ_DASHBOARD_PATH/app" ]; then
IS_DOCKER_NEZHA=0
FRESH_INSTALL=0
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

select_version() {
if [ -z "$IS_DOCKER_NEZHA" ]; then
info _("Select your installation method:")
info "1. Docker"
info _("2. Standalone")
while true; do
printf _("Please enter [1-2]: ")
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
err _("Please enter the correct number [1-2]")
;;
esac
done
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

init() {
deps_check
check_init
env_check
installation_check
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

## China_IP
if [ -z "$CN" ]; then
geo_check
if [ -n "$isCN" ]; then
echo _("According to the information provided by various geoip api, the current IP may be in China")
printf _("Will the installation be done with a Chinese Mirror? [Y/n] (Custom Mirror Input 3): ")
read -r input
case $input in
[yY][eE][sS] | [yY])
echo _("Use Chinese Mirror")
CN=true
;;
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

[nN][oO] | [nN])
echo _("Do Not Use Chinese Mirror")
;;
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

[3])
echo _("Use Custom Mirror")
printf _("Please enter a custom image (e.g. :dn-dao-github-mirror.daocloud.io). If left blank, it won't be used: ")
read -r input
case $input in
*)
CUSTOM_MIRROR=$input
;;
esac
;;
*)
echo _("Do Not Use Chinese Mirror")
;;
esac
fi
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ -n "$CUSTOM_MIRROR" ]; then
GITHUB_RAW_URL="gitee.com/naibahq/scripts/raw/main"
GITHUB_URL=$CUSTOM_MIRROR
Get_Docker_URL="get.docker.com"
Get_Docker_Argu=" -s docker --mirror Aliyun"
Docker_IMG="registry.cn-shanghai.aliyuncs.com\/naibahq\/nezha-dashboard"
else
if [ -z "$CN" ]; then
GITHUB_RAW_URL="raw.githubusercontent.com/nezhahq/scripts/main"
GITHUB_URL="github.com"
Get_Docker_URL="get.docker.com"
Get_Docker_Argu=" "
Docker_IMG="ghcr.io\/naiba\/nezha-dashboard"
else
GITHUB_RAW_URL="gitee.com/naibahq/scripts/raw/main"
GITHUB_URL="gitee.com"
Get_Docker_URL="get.docker.com"
Get_Docker_Argu=" -s docker --mirror Aliyun"
Docker_IMG="registry.cn-shanghai.aliyuncs.com\/naibahq\/nezha-dashboard"
fi
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

update_script() {
echo _("> Update Script")
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

curl -sL _("https://${GITHUB_RAW_URL}/install_en.sh") -o /tmp/nezha.sh
mv -f /tmp/nezha.sh ./nezha.sh && chmod a+x ./nezha.sh
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

echo _("Execute new script after 3s")
sleep 3s
clear
exec ./nezha.sh
exit 0
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

before_show_menu() {
echo && info _("* Press Enter to return to the main menu *") && read temp
show_menu
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

install() {
check_systemd
install_base
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

echo _("> Install")
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

# Nezha Monitoring Folder
if [ ! "$FRESH_INSTALL" = 0 ]; then
sudo mkdir -p $NZ_DASHBOARD_PATH
else
echo _("You may have already installed the dashboard, repeated installation will overwrite the data, please pay attention to backup.")
printf _("Exit the installation? [Y/n]")
read -r input
case $input in
[yY][eE][sS] | [yY])
echo _("Exit the installation")
exit 0
;;
[nN][oO] | [nN])
echo _("Continue")
exit 0
;;
*)
echo _("Exit the installation")
exit 0
;;
esac
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$IS_DOCKER_NEZHA" = 1 ]; then
install_docker
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

modify_config 0
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ $# = 0 ]; then
before_show_menu
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

install_docker() {
if [ ! "$FRESH_INSTALL" = 0 ]; then
if ! command -v docker >/dev/null 2>&1; then
echo _("Installing Docker")
if [ "$os_alpine" != 1 ]; then
if ! curl -sL https://${Get_Docker_URL} | sudo bash -s "${Get_Docker_Argu}"; then
err "{{.ErrorFetchScript}} ${Get_Docker_URL}"
return 0
fi
sudo systemctl enable docker.service
sudo systemctl start docker.service
else
sudo apk add docker docker-compose
sudo rc-update add docker
sudo rc-service docker start
fi
success _("Docker installed successfully")
installation_check
fi
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

modify_config() {
echo _("Modify Configuration")
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$IS_DOCKER_NEZHA" = 1 ]; then
if [ -n "$DOCKER_COMPOSE_COMMAND" ]; then
echo _("Download Docker Script")
_cmd="wget -t 2 -T 60 -O /tmp/nezha-docker-compose.yaml https://${GITHUB_RAW_URL}/extras/docker-compose.yaml >/dev/null 2>&1"
if ! eval "$_cmd"; then
err _("Script failed to get, please check if the network can link ${GITHUB_RAW_URL}")
return 0
fi
else
err _("Please install docker-compose manually. https://docs.docker.com/compose/install/linux/")
before_show_menu
fi
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

_cmd="wget -t 2 -T 60 -O /tmp/nezha-config.yaml https://${GITHUB_RAW_URL}/extras/config.yaml >/dev/null 2>&1"
if ! eval "$_cmd"; then
err _("Script failed to get, please check if the network can link ${GITHUB_RAW_URL}")
return 0
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

printf _("Please enter the site title: ")
read -r nz_site_title
printf _("Please enter the exposed port: (default 8008)")
read -r nz_port
info _("Please specify the backend locale")
info "1. 中文（简体）"
info "2. 中文（台灣）"
info "3. English"
while true; do
printf _("Please enter [1-3]: ")
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
err _("Please enter the correct number [1-3]")
;;
esac
done
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ -z "$nz_lang" ] || [ -z "$nz_site_title" ]; then
err _("All options cannot be empty")
before_show_menu
return 1
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ -z "$nz_port" ]; then
nz_port=8008
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

sed -i "s/nz_port/${nz_port}/" /tmp/nezha-config.yaml
sed -i "s/nz_language/${nz_lang}/" /tmp/nezha-config.yaml
sed -i "s/nz_site_title/${nz_site_title}/" /tmp/nezha-config.yaml
if [ "$IS_DOCKER_NEZHA" = 1 ]; then
sed -i "s/nz_port/${nz_port}/" /tmp/nezha-docker-compose.yaml
sed -i "s/nz_image_url/${Docker_IMG}/" /tmp/nezha-docker-compose.yaml
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

sudo mkdir -p $NZ_DASHBOARD_PATH/data
sudo mv -f /tmp/nezha-config.yaml ${NZ_DASHBOARD_PATH}/data/config.yaml
if [ "$IS_DOCKER_NEZHA" = 1 ]; then
sudo mv -f /tmp/nezha-docker-compose.yaml ${NZ_DASHBOARD_PATH}/docker-compose.yaml
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$IS_DOCKER_NEZHA" = 0 ]; then
echo _("Downloading service file")
if [ "$init" = "systemd" ]; then
_download="sudo wget -t 2 -T 60 -O $NZ_DASHBOARD_SERVICE https://${GITHUB_RAW_URL}/services/nezha-dashboard.service >/dev/null 2>&1"
if ! eval "$_download"; then
err _("File failed to get, please check if the network can link ${GITHUB_RAW_URL}")
return 0
fi
elif [ "$init" = "openrc" ]; then
_download="sudo wget -t 2 -T 60 -O $NZ_DASHBOARD_SERVICERC https://${GITHUB_RAW_URL}/services/nezha-dashboard >/dev/null 2>&1"
if ! eval "$_download"; then
err _("File failed to get, please check if the network can link ${GITHUB_RAW_URL}")
return 0
fi
sudo chmod +x $NZ_DASHBOARD_SERVICERC
fi
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

success _("Dashboard configuration modified successfully, please wait for Dashboard self-restart to take effect")
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

restart_and_update
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ $# = 0 ]; then
before_show_menu
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

restart_and_update() {
echo _("> Restart and Update")
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$IS_DOCKER_NEZHA" = 1 ]; then
_cmd="restart_and_update_docker"
elif [ "$IS_DOCKER_NEZHA" = 0 ]; then
_cmd="restart_and_update_standalone"
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if eval "$_cmd"; then
success _("Nezha Monitoring Restart Successful")
info _("Default address: domain:site_access_port")
else
err _("The restart failed, probably because the boot time exceeded two seconds, please check the log information later")
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ $# = 0 ]; then
before_show_menu
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

restart_and_update_docker() {
sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml pull
sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml down
sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml up -d
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

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
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ -z "$_version" ]; then
err _("Fail to obtain Dashboard version, please check if the network can link https://api.github.com/repos/nezhahq/nezha/releases/latest")
return 1
else
echo _("The current latest version is: ${_version}")
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$os_alpine" != 1 ]; then
sudo systemctl daemon-reload
sudo systemctl stop nezha-dashboard
else
sudo rc-service nezha-dashboard stop
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ -z "$CN" ]; then
NZ_DASHBOARD_URL="https://${GITHUB_URL}/nezhahq/nezha/releases/download/${_version}/dashboard-linux-${os_arch}.zip"
else
NZ_DASHBOARD_URL="https://${GITHUB_URL}/naibahq/nezha/releases/download/${_version}/dashboard-linux-${os_arch}.zip"
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

sudo wget -qO $NZ_DASHBOARD_PATH/app.zip "$NZ_DASHBOARD_URL" >/dev/null 2>&1 && sudo unzip -qq -o $NZ_DASHBOARD_PATH/app.zip -d $NZ_DASHBOARD_PATH && sudo mv $NZ_DASHBOARD_PATH/dashboard-linux-$os_arch $NZ_DASHBOARD_PATH/app && sudo rm $NZ_DASHBOARD_PATH/app.zip
sudo chmod +x $NZ_DASHBOARD_PATH/app
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$os_alpine" != 1 ]; then
sudo systemctl enable nezha-dashboard
sudo systemctl restart nezha-dashboard
else
sudo rc-update add nezha-dashboard
sudo rc-service nezha-dashboard restart
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

find "$NZ_DASHBOARD_PATH" -type d -exec chmod 700 {} \;
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

show_dashboard_log() {
echo _("> View Log")
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$IS_DOCKER_NEZHA" = 1 ]; then
show_dashboard_log_docker
elif [ "$IS_DOCKER_NEZHA" = 0 ]; then
show_dashboard_log_standalone
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ $# = 0 ]; then
before_show_menu
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

show_dashboard_log_docker() {
sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml logs -f
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

show_dashboard_log_standalone() {
if [ "$os_alpine" != 1 ]; then
sudo journalctl -xf -u nezha-dashboard.service
else
sudo tail -n 10 /var/log/nezha-dashboard.err
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

uninstall_dashboard() {
echo _("> Uninstall")
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$IS_DOCKER_NEZHA" = 1 ]; then
uninstall_dashboard_docker
elif [ "$IS_DOCKER_NEZHA" = 0 ]; then
uninstall_dashboard_standalone
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

clean_all
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ $# = 0 ]; then
before_show_menu
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

uninstall_dashboard_docker() {
sudo $DOCKER_COMPOSE_COMMAND -f ${NZ_DASHBOARD_PATH}/docker-compose.yaml down
sudo rm -rf $NZ_DASHBOARD_PATH
sudo docker rmi -f ghcr.io/naiba/nezha-dashboard >/dev/null 2>&1
sudo docker rmi -f registry.cn-shanghai.aliyuncs.com/naibahq/nezha-dashboard >/dev/null 2>&1
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

uninstall_dashboard_standalone() {
sudo rm -rf $NZ_DASHBOARD_PATH
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$os_alpine" != 1 ]; then
sudo systemctl disable nezha-dashboard
sudo systemctl stop nezha-dashboard
else
sudo rc-update del nezha-dashboard
sudo rc-service nezha-dashboard stop
fi
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ "$os_alpine" != 1 ]; then
sudo rm $NZ_DASHBOARD_SERVICE
else
sudo rm $NZ_DASHBOARD_SERVICERC
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

clean_all() {
if [ -z "$(ls -A ${NZ_DASHBOARD_PATH})" ]; then
sudo rm -rf ${NZ_DASHBOARD_PATH}
fi
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

show_usage() {
echo _("Nezha Monitor Management Script Usage: ")
echo "--------------------------------------------------------"
echo _("./nezha.sh                            - Show Menu")
echo _("./nezha.sh install_dashboard          - Install Dashboard")
echo _("./nezha.sh modify_dashboard_config    - Modify Dashboard Configuration")
echo _("./nezha.sh restart_and_update         - Restart and Update the Dashboard")
echo _("./nezha.sh show_dashboard_log         - View Dashboard Log")
echo _("./nezha.sh uninstall_dashboard        - Uninstall Dashboard")
echo "--------------------------------------------------------"
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

show_menu() {
printf _("${green}Nezha Monitor Management Script${plain}\n")
printf "--- https://github.com/naiba/nezha ---\n"
printf _("${green}1.${plain}  Install Dashboard\n")
printf _("${green}2.${plain}  Modify Dashbaord Configuration\n")
printf _("${green}3.${plain}  Restart and Update Dashboard\n")
printf _("${green}4.${plain}  View Dashboard Log\n")
printf _("${green}5.${plain}  Uninstall Dashboard\n")
printf "————————————————-\n"
printf _("${green}6.${plain} Update Script\n")
printf "————————————————-\n"
printf _("${green}0.${plain}  Exit Script\n")
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

echo && printf _("Please enter [0-6]: ") && read -r num
case "${num}" in
0)
exit 0
;;
1)
install_dashboard
;;
2)
modify_dashboard_config
;;
3)
restart_and_update
;;
4)
show_dashboard_log
;;
5)
uninstall_dashboard
;;
6)
update_script
;;
*)
err _("Please enter the correct number [0-6]")
;;
esac
}
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

init
Project-Id-Version: 
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2024-11-29 18:07+0800
Last-Translator: 
Language-Team: 
Language: zh_CN
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5

if [ $# -gt 0 ]; then
case $1 in
"install_dashboard")
install_dashboard 0
;;
"modify_dashboard_config")
modify_dashboard_config 0
;;
"restart_and_update")
restart_and_update 0
;;
"show_dashboard_log")
show_dashboard_log 0
;;
"uninstall_dashboard")
uninstall_dashboard 0
;;
"update_script")
update_script 0
;;
*) show_usage ;;
esac
else
select_version
show_menu
fi
