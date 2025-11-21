#!/bin/bash

# 输出函数
fundeps_echo_content() {
	ECHO_TYPE="echo -e"
	case $1 in
	"red")
		${ECHO_TYPE} "\033[31m$2\033[0m"
		;;
	"green")
		${ECHO_TYPE} "\033[32m$2\033[0m"
		;;
	"yellow")
		${ECHO_TYPE} "\033[33m$2\033[0m"
		;;
	"blue")
		${ECHO_TYPE} "\033[34m$2\033[0m"
		;;
	"purple")
		${ECHO_TYPE} "\033[35m$2\033[0m"
		;;
	"skyBlue")
		${ECHO_TYPE} "\033[36m$2\033[0m"
		;;
	"white")
		${ECHO_TYPE} "\033[37m$2\033[0m"
		;;
	esac
}

# ======= 工具检查 =======
# jq
# curl
# make
# unzip

fundeps_check_install_deps() {
	for cmd in jq curl make unzip; do
		if ! command -v "$cmd" &>/dev/null; then
			echo "❌ 缺少依赖：$cmd"
			echo "请先安装：sudo apt install $cmd -y"
			sudo apt install $cmd -y
			# exit 1
		fi
	done
}

fundeps_check_install_nodejs() {
	fundeps_echo_content "green" "🔍 正在检测 Node.js 是否已安装..."

	if command -v node >/dev/null 2>&1; then
		echo "✅ Node.js 已安装，版本：$(node -v)"
	else
		echo "❌ 未检测到 Node.js，正在安装 Node.js 20.x..."

		# 更新系统包索引
		sudo apt update

		# 下载并执行 NodeSource 安装脚本
		curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

		# 安装 Node.js
		sudo apt install -y nodejs

		# 检查安装是否成功
		if command -v node >/dev/null 2>&1; then
			echo "✅ Node.js 安装成功，版本：$(node -v)"
		else
			echo "❌ Node.js 安装失败，请检查网络或手动安装。"
			exit 1
		fi
	fi

	# 检测 npm 是否安装
	if command -v npm >/dev/null 2>&1; then
		echo "✅ npm 已安装，版本：$(npm -v)"
	else
		echo "❌ npm 未安装，尝试重新安装 Node.js 可能修复此问题。"
	fi

}

fundeps_check_install_pm2() {
	fundeps_echo_content "green" "🔍 检测 Node.js & PM2 是否已安装..."
	fundeps_echo_content "blue" "    🔍 检测 Node.js 是否已安装..."
	if command -v node >/dev/null 2>&1; then
		echo "✅ Node.js 已安装，版本：$(node -v)"
	else
		echo "❌ Node.js 未安装，正在安装 Node.js 20.x..."

		sudo apt update
		curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
		sudo apt install -y nodejs

		if command -v node >/dev/null 2>&1; then
			echo "✅ Node.js 安装成功，版本：$(node -v)"
		else
			echo "❌ Node.js 安装失败，请检查网络。"
			exit 1
		fi
	fi

	fundeps_echo_content "blue" "    🔍 检测 npm 是否已安装..."
	if command -v npm >/dev/null 2>&1; then
		echo "✅ npm 已安装，版本：$(npm -v)"
	else
		echo "❌ npm 未安装，尝试重新安装 Node.js 或手动安装 npm。"
		exit 1
	fi

	fundeps_echo_content "blue" "    🔍 检测 PM2 是否已安装..."
	if command -v pm2 >/dev/null 2>&1; then
		echo "✅ PM2 已安装，版本：$(pm2 -v)"
	else
		echo "❌ PM2 未安装，正在全局安装 PM2..."
		sudo npm install -g pm2

		if command -v pm2 >/dev/null 2>&1; then
			echo "✅ PM2 安装成功，版本：$(pm2 -v)"
		else
			echo "❌ PM2 安装失败，请检查 npm 环境。"
			exit 1
		fi
	fi

	echo "🎉 Node.js & PM2 环境准备完成！"
}

# 函数：检查并安装 Docker
fundeps_check_install_docker() {

	fundeps_echo_content "green" "检查并安装 Docker..."
	if ! [[ $(docker -v 2>/dev/null) ]]; then
		sh <(curl -sL https://get.docker.com)
	fi
	if ! [[ $(docker -v 2>/dev/null) ]]; then
		curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
	fi

	if ! [[ $(docker -v 2>/dev/null) ]]; then
		curl -sSL https://get.daocloud.io/docker | sh
	fi

	#!/bin/bash

	if ! command -v docker-compose &>/dev/null; then
		# 下载 docker-compose
		sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

		# 设置执行权限
		sudo chmod +x /usr/local/bin/docker-compose

		# 检查是否安装成功
		if ! command -v docker-compose &>/dev/null; then
			echo "docker-compose 安装失败。"
			exit 1
		fi
	fi

}

"$@"
