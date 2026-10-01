#!/bin/bash
sh_v="1.2.0"
# 定义一个暂停函数，用于在操作完成后等待用户按键
function pause(){
  read -p "按任意键继续..." -n1 -s
  echo ""
}

# 系统命令菜单：包含系统更新、组件安装、安装Masscan、安装Node、修改名称、修改密码、重启系统
function system_commands_menu() {
  clear
    printf "+------------------------------------------------------+\n"
    printf "|         1. 系统更新        |        2. 组件安装      |\n"
    printf "+------------------------------------------------------+\n"
    printf "|         3. 安装 Massca     |        4. 安装 Node     |\n"
    printf "+------------------------------------------------------+\n"
    printf "|         5. 安装3X-UI       |        6. 安装BBR       |\n"
    printf "+------------------------------------------------------+\n"
    printf "|         7. 修改名称        |        8. 修改密码      |\n"
    printf "+------------------------------------------------------+\n"
    printf "|         9. 重启系统        |        0. 返回主菜单    |\n"
    printf "+------------------------------------------------------+\n"
  echo
  read -p "请选择: " option
  case $option in
    1)
      echo "正在更新系统..."
      sudo apt update && sudo apt upgrade -y
      ;;
    2)
      echo "正在安装必要组件..."
      apt install -y sudo ; apt install -y curl ; apt install -y wget ; apt install -y screen ; apt install xz-utils ; apt install -y git
      ;;
    3)
      echo "正在安装 Masscan..."
      sudo apt install -y git make gcc clang libpcap-dev
      git clone https://github.com/robertdavidgraham/masscan
      cd masscan
      make -j$(nproc)  # 多线程编译加速
      sudo make install
      masscan --version
      ;;
    4)
      echo "正在安装 Node.js 及 npm..."
      wget https://nodejs.org/dist/v22.3.0/node-v22.3.0-linux-x64.tar.xz && tar -xvf node-v22.3.0-linux-x64.tar.xz && ln -s /root/node-v22.3.0-linux-x64/bin/node /usr/local/bin/node && ln -s /root/node-v22.3.0-linux-x64/bin/npm /usr/local/bin/npm && npm install axios && npm install express && npm install cheerio
      ;;
    5)
      echo "正在安装3X-UI..."
      bash <(curl -Ls https://raw.githubusercontent.com/xeefei/3x-ui/master/install.sh)
      ;;
    6)
      echo "正在安装BBR..."
      if [ ! -f /root/tcp.sh ]; then
      wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh" -O /root/tcp.sh
      chmod +x /root/tcp.sh
      fi
      cd /root && ./tcp.sh
      ;;
    7)
      echo "修改系统名称"
      sudo hostnamectl set-hostname H4ck
      echo -e "\n127.0.0.1 H4ck" | sudo tee -a /etc/hosts
      ;;
    8)
      echo "修改密码"
      sudo passwd
      ;;
    9)
      echo "正在重启系统..."
      sudo reboot
      ;;
    0)
      return 0
      ;;
    *)
      echo "无效选项，请重新输入"
      ;;
  esac
  pause
  system_commands_menu
}

# Proxy 类菜单：包含创建、运行、恢复、销毁 Proxy 窗口
function proxy_menu() {
  clear
    printf "+------------------------------------------------------+\n"
    printf "|     1. 创建 Proxy 窗口     |    2. 恢复 Proxy 窗口   |\n"
    printf "+------------------------------------------------------+\n"
    printf "|     3. 销毁 Proxy 窗口     |    4. 克隆 Proxy 文件   |\n"
    printf "+------------------------------------------------------+\n"
    printf "|                     0. 返回主菜单                    |\n"
    printf "+------------------------------------------------------+\n"
  echo
  read -p "请选择: " choice
  case $choice in
    1)
      echo "正在创建 Proxy 窗口..."
      screen -d -m -S Proxy bash -c "cd /root/Proxy && ./xmrig-proxy"
      ;;
    2)
      echo "正在恢复 Proxy 窗口..."
      screen -r Proxy
      ;;
    3)
      echo "正在销毁 Proxy 窗口..."
      screen -S Proxy -X quit
      ;;
    4)
      echo "正在克隆 Proxy 文件..."
      git clone https://github.com/H4ckChina/Proxy.git && rm -rf /root/Proxy/.git && chmod +wx /root/Proxy/xmrig-proxy
      ;;
    0)
      return 0
      ;;
    *)
      echo "无效选项，请重新输入"
      ;;
  esac
  pause
  proxy_menu
}

# Get 类菜单：包含创建、运行、恢复、销毁 Get 窗口
function get_menu() {
  clear
   printf "+------------------------------------------------------+\n"
    printf "|     1. 创建 Get 窗口      |     2. 恢复 Get 窗口     |\n"
    printf "+------------------------------------------------------+\n"
    printf "|     3. 销毁 Get 窗口      |     4. 克隆 Get 文件     |\n"
    printf "+------------------------------------------------------+\n"
    printf "|                    0. 返回主菜单                     |\n"
    printf "+------------------------------------------------------+\n"
  echo
  read -p "请选择: " choice
  case $choice in
    1)
      echo "正在创建 Get 窗口..."
      screen -d -m -S Get bash -c "cd /root/Get && node Get.js"
      ;;
    2)
      echo "正在恢复 Get 窗口..."
      screen -r Get
      ;;
    3)
      echo "正在销毁 Get 窗口..."
      screen -S Get -X quit
      ;;
    4)
      echo "正在克隆 Get 文件..."
      git clone https://github.com/H4ckChina/Get.git && rm -rf /root/Get/.git && rm -rf /root/Get/README.md && chmod +wx /root/Get/Get.js
      ;;
    0)
      return 0
      ;;
    *)
      echo "无效选项，请重新输入"
      ;;
  esac
  pause
  get_menu
}

# Scan 类菜单：包含创建、运行、恢复、销毁 Scan 窗口
function scan_menu() {
  clear
    printf "+------------------------------------------------------+\n"
    printf "|     1. 创建 Scan 窗口      |     2. 恢复 Scan 窗口   |\n"
    printf "+------------------------------------------------------+\n"
    printf "|     3. 销毁 Scan 窗口      |     4. 克隆 Scan 文件   |\n"
    printf "+------------------------------------------------------+\n"
    printf "|     5. 系统配置优化        |     0. 返回主菜单       |\n"
    printf "+------------------------------------------------------+\n"
  echo
  read -p "请选择: " choice
  case $choice in
    1)
      echo "正在创建 Scan 窗口..."
      screen -d -m -S Scan bash -c "cd /root/Scan && ./Scan.sh"
      ;;
    2)
      echo "正在恢复 Scan 窗口..."
      screen -r Scan
      ;;
    3)
      echo "正在销毁 Scan 窗口..."
      screen -S Scan -X quit
      ;;
    4)
      echo "正在克隆 Scan 文件..."
      git clone https://github.com/H4ckChina/Scan.git && rm -rf /root/Scan/.git && chmod +wx /root/Scan/Scan.sh
      ;;
    5)
      echo "正在优化系统..."
      # 配置 ulimit
      ulimit -n 1000000
      ulimit -u 65535
      ulimit -s 65536
      # 写入 sysctl 配置
      add_sysctl_param() {
      local key=$1
      local value=$2
      if grep -q "^$key" /etc/sysctl.conf; then
      sed -i "s/^$key.*/$key = $value/" /etc/sysctl.conf
      else
      echo "$key = $value" >> /etc/sysctl.conf
      fi
      }
      add_sysctl_param "net.ipv4.tcp_max_syn_backlog" "65536"
      add_sysctl_param "net.core.netdev_max_backlog" "65536"
      add_sysctl_param "net.ipv4.tcp_synack_retries" "2"
      add_sysctl_param "net.ipv4.tcp_fin_timeout" "15"
      add_sysctl_param "net.ipv4.tcp_keepalive_time" "600"
      add_sysctl_param "net.ipv4.tcp_tw_reuse" "1"
      add_sysctl_param "net.ipv4.ip_local_port_range" "1024 65535"
      add_sysctl_param "net.core.rmem_max" "16777216"
      add_sysctl_param "net.core.wmem_max" "16777216"
      add_sysctl_param "net.ipv4.tcp_rmem" "4096 87380 16777216"
      add_sysctl_param "net.ipv4.tcp_wmem" "4096 65536 16777216"
      add_sysctl_param "net.core.somaxconn" "65535"
      add_sysctl_param "fs.file-max" "2097152"
      add_sysctl_param "net.ipv4.tcp_slow_start_after_idle" "0"
      # 使修改生效
      sysctl -p
      ;;
    0)
      return 0
      ;;
    *)
      echo "无效选项，请重新输入"
      ;;
  esac
  pause
  scan_menu
}

# 主菜单：用于选择各个大类
function main_menu() {
  while true; do
    clear
    printf "+------------------------------------------------------+\n"
    printf "|        H4ck China Sh       |          v$sh_v         |\n"
    printf "+------------------------------------------------------+\n"
    printf "|         1. 系统命令        |          2. Proxy       |\n"
    printf "+------------------------------------------------------+\n"
    printf "|         3. Get             |          4. Scan        |\n"
    printf "+------------------------------------------------------+\n"
    printf "|                        0. 退出                       |\n"
    printf "+------------------------------------------------------+\n"
    echo 
    read -p "请选择: " menuChoice
    case $menuChoice in
      1)
        system_commands_menu
        ;;
      2)
        proxy_menu
        ;;
      3)
        get_menu
        ;;
      4)
        scan_menu
        ;;
      0)
        echo "退出脚本"
        exit 0
        ;;
      *)
        echo "无效选项，请重试"
        ;;
    esac
  done
}

# 执行主菜单
main_menu
