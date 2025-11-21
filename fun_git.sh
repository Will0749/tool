#!/bin/bash

# 输出函数
fungit_echo_content() {
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

# ======= 获取远程某个子目录的最新 commit =======
fungit_get_remote_latest_sha() {
	local dir="$1"
	local app_token="$2"
	local github_path="$3"
	local github_user="$4"
	local github_repo_name="$5"
	local github_repo_branch="$6"

	local path="${github_path}/${dir}"
	local api_url="https://api.github.com/repos/${github_user}/${github_repo_name}/commits?path=${path}&sha=${github_repo_branch}"

	local auth_header=""
	if [ -n "$app_token" ]; then
		auth_header="-H \"Authorization: token $app_token\""
	fi

	eval curl -s $auth_header "$api_url" | jq -r '.[0].sha'
}

# ======= 获取指定目录下的子目录 =======
fungit_get_dir_list() {
	local target_path="${1:-}" # 接收要查看的路径，留空则查看根目录
	local app_token="$2"
	local github_user="$3"
	local github_repo_name="$4"
	local github_repo_branch="$5"
	local api_url="https://api.github.com/repos/${github_user}/${github_repo_name}/contents"

	# 如果指定了目录，则拼接路径
	if [ -n "$target_path" ]; then
		api_url="${api_url}/${target_path}"
	fi

	local auth_header=""
	if [ -n "$app_token" ]; then
		auth_header="-H \"Authorization: token $app_token\""
	fi

	eval curl -s $auth_header "${api_url}?ref=${github_repo_branch}" |
		jq -r '.[] | select(.type=="dir") | .name'

}

# ======= 获取应用目录备注（默认 desc.txt） =======
fungit_get_dir_note() {
	local dir="$1"
	local app_token="$2"
	local github_path="$3"
	local github_user="$4"
	local github_repo_name="$5"
	local github_repo_branch="$6"

	local file_path="${github_path}/${dir}/desc.txt"
	local api_url="https://api.github.com/repos/${github_user}/${github_repo_name}/contents/${file_path}?ref=${github_repo_branch}"

	local auth_header=""
	[ -n "$app_token" ] && auth_header="-H \"Authorization: token $app_token\""

	# 获取文件内容并 base64 解码
	eval curl -s $auth_header "$api_url" | jq -r '.content' | base64 --decode 2>/dev/null
}

# ======= 检查安装状态 =======
fungit_is_installed() {
	local install_dir="$1"
	local app="$2"
	[ -d "$install_dir/$app" ]
}

# ======= 下载应用文件 =======
fungit_download_app() {
	local install_dir="$1"
	local app="$2"
	local app_token="$3"
	local github_path="$4"
	local github_user="$5"
	local github_repo_name="$6"
	local github_repo_branch="$7"

	local dest="$install_dir/$app"
	local repo_subdir="$github_path/$app"

	mkdir -p "$install_dir"

	echo "⬇️ 正在使用 git sparse-checkout 下载 $app ..."

	# 删除旧目录
	[ -d "$dest" ] && rm -rf "$dest"

	local repo_url="https://x-access-token:${app_token}@github.com/${github_user}/${github_repo_name}.git"

	# 临时克隆目录
	local tmp_dir="${install_dir}/.tmp_${app}_repo"
	rm -rf "$tmp_dir"

	# 稀疏克隆只获取 apps/$app
	git clone --depth=1 --filter=blob:none --sparse -b "$github_repo_branch" "$repo_url" "$tmp_dir" >/dev/null 2>&1
	(
		cd "$tmp_dir" || exit 1
		git sparse-checkout set "$repo_subdir" >/dev/null 2>&1
	)

	if [ -d "$tmp_dir/$repo_subdir" ]; then
		mv "$tmp_dir/$repo_subdir" "$dest"
	else
		echo "❌ 未在仓库中找到路径：$repo_subdir"
		rm -rf "$tmp_dir"
		return 1
	fi

	rm -rf "$tmp_dir"

	# 保存版本号
	local latest_sha
	latest_sha=$(fungit_get_remote_latest_sha "$app" "$app_token" "$github_path" "$github_user" "$github_repo_name" "$github_repo_branch")
	echo "$latest_sha" >"$dest/.version"

	echo "✅ 下载完成：$app"
}

fungit_get_local_version() {
	local install_dir="$1"
	local app="$2"
	local dest="$install_dir/$app/.version"
	[ -f "$dest" ] && cat "$dest" || echo ""
}

# ======= 更新应用 =======
fungit_update_app() {
	local install_dir="$1"
	local app="$2"
	local app_token="$3"
	local github_path="$4"
	local github_user="$5"
	local github_repo_name="$6"
	local github_repo_branch="$7"

	local dest="$install_dir/$app"

	if [ ! -d "$dest" ]; then
		echo "⚠️ $app 未安装，无法更新。"
		return
	fi

	echo "🔄 正在更新 $app ..."

	# 临时保存用户配置（比如 .env）
	if [ -f "$dest/.env" ]; then
		cp "$dest/.env" "$dest/.env.bak"
	fi

	# 删除旧目录并重新下载
	rm -rf "$dest"
	fungit_download_app "$install_dir" "$app" "$app_token" "$github_path" "$github_user" "$github_repo_name" "$github_repo_branch"
	# 还原配置
	if [ -f "$dest/.env.bak" ]; then
		mv "$dest/.env.bak" "$dest/.env"
	fi

	# 拉取最新镜像并重启
	if [ -f "$dest/docker-compose.yml" ]; then
		echo "🚀 重新启动服务..."

		local current_dir=$(pwd)
		cd "$dest"
		make up
		cd $current_dir

	fi

	echo "✅ $app 已更新完成"
}

# ======= 安装应用 =======
fungit_install_app() {
	local install_dir="$1"
	local app="$2"
	local dest="$install_dir/$app"

	echo "------------------"
	echo $dest

	if [ ! -f "$dest/docker-compose.yml" ]; then
		echo "⚠️ 未找到 docker-compose.yml，无法启动。"
		return
	fi

	echo "🚀 正在启动 $app ..."

	local current_dir=$(pwd)
	cd "$dest"
	make up
	cd $current_dir

	echo "✅ 已启动 $app"
}

# ======= 卸载应用 =======
fungit_uninstall_app() {
	local install_dir="$1"
	local app="$2"
	local dest="$install_dir/$app"

	if [ ! -d "$dest" ]; then
		echo "⚠️ $app 未安装。"
		return
	fi

	echo "🧹 正在卸载 $app ..."
	if [ -f "$dest/docker-compose.yml" ]; then

		local current_dir=$(pwd)
		cd "$dest"
		make down
		cd $current_dir

	fi
	rm -rf "$dest"
	echo "✅ 已卸载 $app"
}
"$@"
