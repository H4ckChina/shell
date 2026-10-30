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
      cd /root
      rm -rf /root/masscan
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
      cd /root && git clone https://github.com/H4ckChina/Scan.git && rm -rf /root/Scan/.git && chmod +wx /root/Scan/Scan.sh
      ;;
    5)
      echo "正在优化系统..."
#!/usr/bin/env bash
# =============================================================================
#  masscan-tune.sh   v1.0
#  Ubuntu 24.04 LTS / Debian 系 —— masscan 扫描性能自动检测 · 调优 · 效果验证
#
#  功能：
#    1) 自动探测：发行版 / 内核 / CPU / 内存 / 网卡 / 驱动 / 链路速率 /
#                 PF_RING / masscan 版本 / 现有内核参数 / 现有网卡参数
#    2) 自动决策：按内存、核数、链路速率推导目标参数（不是无脑抄固定值）
#    3) 自动下发：sysctl / ulimit / ethtool / IRQ / governor / nftables
#    4) 自动测效：调优前后各跑一次同条件发包基准，输出实际 pps 与提升幅度
#    5) 自动备份：所有改动前的状态存盘，支持一键回滚
#
#  用法：
#    sudo ./masscan-tune.sh                 # 默认 safe 级别，自动测效
#    sudo ./masscan-tune.sh --aggressive    # 追加 CPU/IRQ 激进调优
#    sudo ./masscan-tune.sh --dry-run       # 只检测+出方案，不落盘
#    sudo ./masscan-tune.sh --skip-bench    # 不做发包基准
#    sudo ./masscan-tune.sh --restore       # 回滚到最近一次备份
#
#  注意：基准测试会向 192.0.2.0/24 (RFC5737 TEST-NET-1) 发送 SYN 包，
#        仅用于测量本机真实发包能力，可用 --bench-target 改目标。
# =============================================================================
# shellcheck disable=SC2016,SC2086,SC2129,SC1091

set -uo pipefail

SCRIPT_VER="1.0"
TS="$(date +%Y%m%d-%H%M%S)"
LOG_DIR="/var/log/masscan-tune"
BACKUP_ROOT="/var/backups/masscan-tune"
LOG_FILE="${LOG_DIR}/tune-${TS}.log"
BACKUP_DIR="${BACKUP_ROOT}/${TS}"
SYSCTL_CONF="/etc/sysctl.d/99-masscan.conf"
LIMITS_CONF="/etc/security/limits.d/99-masscan.conf"
SYSTEMD_CONF="/etc/systemd/system.conf.d/99-masscan.conf"
EXCLUDE_FILE="/etc/masscan/exclude.conf"

# ---- 运行选项 ---------------------------------------------------------------
MODE="safe"            # safe | aggressive
DRY_RUN=0
RESTORE=0
SKIP_BENCH=0
NO_NIC=0
BENCH_TARGET="192.0.2.0/24"
BENCH_RATE=""
BENCH_SECS=5
BENCH_PORTS="auto"
BENCH_PORTS_ACTUAL=""
REPORT_MD=""

# ---- 颜色 -------------------------------------------------------------------
if [ -t 1 ]; then
  C_R=$'\033[31m'; C_G=$'\033[32m'; C_Y=$'\033[33m'
  C_B=$'\033[36m'; C_D=$'\033[1m';  C_0=$'\033[0m'
else
  C_R=""; C_G=""; C_Y=""; C_B=""; C_D=""; C_0=""
fi

# ---- 全局探测结果 -----------------------------------------------------------
DISTRO="" KERNEL="" ARCH=""
CPU_MODEL="" CPU_LOGICAL=0 CPU_PHYS=0 CPU_MHZ=""
GOVERNOR="" CUR_CSTATE=""
MEM_TOTAL_MB=0 MEM_AVAIL_MB=0
IFACE="" IF_DRIVER="" IF_SPEED="" IF_MAC="" IF_IP="" IF_MTU="" IF_VIRT=""
GW_IP="" GW_MAC=""
HAS_ETHTOOL=0 HAS_NFT=0 HAS_IPT=0 HAS_CONNTRACK=0 HAS_IRQBAL=0
HAS_CPUPOWER=0 HAS_MASSCAN=0 HAS_LSCPU=0 HAS_PFRING=0
MASSCAN_VER="" MASSCAN_PFRING="no"
IRQBAL_ACTIVE=0

# ---- 计划/变更 --------------------------------------------------------------
declare -A SYSCTL_OLD=()
declare -A SYSCTL_NEW=()
declare -A SYSCTL_RESULT=()     # ok | fail | skip | keep
declare -A SYSCTL_KEEP=()       # 现值已达标，无需改动
declare -a CHANGE_ROWS=()       # "键|旧值|新值|说明"
declare -a ACTION_ROWS=()       # "动作|结果|说明"
declare -a NOTES=()

NIC_OLD_RX=0 NIC_OLD_TX=0 NIC_MAX_RX=0 NIC_MAX_TX=0
NIC_NEW_RX=0 NIC_NEW_TX=0 NIC_OLD_Q=0 NIC_MAX_Q=0 NIC_NEW_Q=0
NIC_OLD_TXQ=0 NIC_NEW_TXQ=0
declare -A OFFLOAD_OLD=() OFFLOAD_NEW=()
IRQ_BOUND=0

RECOMMEND_RATE=100000

# ---- 基准测试结果 -----------------------------------------------------------
BENCH_BEFORE_PPS=0 BENCH_BEFORE_OK=0
BENCH_AFTER_PPS=0  BENCH_AFTER_OK=0
BENCH_BEFORE_DROP=0 BENCH_AFTER_DROP=0
BENCH_BEFORE_NICERR=0 BENCH_AFTER_NICERR=0
BENCH_BEFORE_ACH=0 BENCH_AFTER_ACH=0

# =============================================================================
#  基础工具
# =============================================================================
log()  { local m="[$(date +%H:%M:%S)] $*"; printf '%s\n' "$m"; [ -n "${LOG_FILE:-}" ] && printf '%s\n' "$m" >>"$LOG_FILE" 2>/dev/null; }
info() { printf '%s[*]%s %s\n' "$C_B" "$C_0" "$*"; }
ok()   { printf '%s[+]%s %s\n' "$C_G" "$C_0" "$*"; }
warn() { printf '%s[!]%s %s\n' "$C_Y" "$C_0" "$*"; NOTES+=("$*"); }
err()  { printf '%s[x]%s %s\n' "$C_R" "$C_0" "$*"; }
hr()   { printf '%s\n' "-------------------------------------------------------------------------------"; }
have() { command -v "$1" >/dev/null 2>&1; }

# 读取文件首值，失败返回默认
rd() { local f="$1" d="${2:-}"; if [ -r "$f" ]; then cat "$f" 2>/dev/null | head -1; else printf '%s' "$d"; fi; }
num() { printf '%s' "${1:-0}" | tr -cd '0-9' ; }

# 数值夹逼
clamp() { local v=$1 lo=$2 hi=$3; [ "$v" -lt "$lo" ] && v=$lo; [ "$v" -gt "$hi" ] && v=$hi; printf '%s' "$v"; }

usage() {
  awk 'NR>1{ if ($0 ~ /^# =+$/) { if (seen) exit; seen=1; next } sub(/^# ?/,""); print }' "$0"
  cat <<'EOF'

选项:
  --aggressive         追加效果更激进但需重启/影响功耗的调优(governor、IRQ、C-state)
  --dry-run            只检测并打印方案，不修改任何文件
  --skip-bench         跳过调优前后发包基准
  --bench-target CIDR  基准目标网段，默认 192.0.2.0/24
  --bench-rate PPS     基准发包速率，默认自动按链路推导
  --bench-secs N       基准持续秒数，默认 5
  --no-nic             跳过网卡层调优（虚拟机/容器环境）
  --report-md PATH     额外输出 Markdown 报告
  --restore            用最近一次备份回滚
  -h, --help           显示帮助
EOF
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --aggressive) MODE="aggressive" ;;
      --dry-run)    DRY_RUN=1 ;;
      --skip-bench) SKIP_BENCH=1 ;;
      --no-nic)     NO_NIC=1 ;;
      --restore)    RESTORE=1 ;;
      --bench-target) BENCH_TARGET="${2:-}"; shift ;;
      --bench-rate)   BENCH_RATE="${2:-}"; shift ;;
      --bench-secs)   BENCH_SECS="${2:-5}"; shift ;;
      --bench-ports)  BENCH_PORTS="${2:-auto}"; shift ;;
      --report-md)    REPORT_MD="${2:-}"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) err "未知参数: $1"; usage; exit 2 ;;
    esac
    shift
  done
}

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    if have sudo && [ -t 0 ]; then
      info "需要 root 权限，自动提权重执行…"
      exec sudo -E bash "$0" "$@"
    fi
    err "请以 root 运行: sudo $0 $*"
    exit 1
  fi
  mkdir -p "$LOG_DIR" "$BACKUP_ROOT" 2>/dev/null || true
  : >"$LOG_FILE" 2>/dev/null || LOG_FILE=""
}

# =============================================================================
#  阶段一：检测
# =============================================================================
detect_system() {
  info "探测系统信息…"
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO="${PRETTY_NAME:-${NAME:-Linux} ${VERSION_ID:-}}"
  else
    DISTRO="$(uname -s)"
  fi
  KERNEL="$(uname -r)"
  ARCH="$(uname -m)"

  if have lscpu; then HAS_LSCPU=1; fi
  CPU_MODEL="$(awk -F: '/model name/{gsub(/^ +/,"",$2);print $2;exit}' /proc/cpuinfo)"
  [ -z "$CPU_MODEL" ] && CPU_MODEL="$(rd /proc/cpuinfo unknown)"
  CPU_LOGICAL="$(nproc 2>/dev/null || echo 1)"
  if [ "$HAS_LSCPU" -eq 1 ]; then
    CPU_PHYS="$(lscpu -p=Core,Socket 2>/dev/null | grep -v '^#' | sort -u | wc -l | tr -d ' ')"
    CPU_MHZ="$(lscpu 2>/dev/null | awk -F: '/MHz/{gsub(/^ +/,"",$2);print $2;exit}')"
  fi
  [ -z "${CPU_PHYS:-}" ] || [ "$CPU_PHYS" -eq 0 ] 2>/dev/null && CPU_PHYS=$CPU_LOGICAL
  [ -z "$CPU_MHZ" ] && CPU_MHZ="$(awk -F: '/cpu MHz/{gsub(/^ +/,"",$2);print $2;exit}' /proc/cpuinfo)"

  MEM_TOTAL_MB="$(awk '/MemTotal/{printf "%d",$2/1024}' /proc/meminfo)"
  MEM_AVAIL_MB="$(awk '/MemAvailable/{printf "%d",$2/1024}' /proc/meminfo)"
  [ -z "$MEM_TOTAL_MB" ] && MEM_TOTAL_MB=0
  [ -z "$MEM_AVAIL_MB" ] && MEM_AVAIL_MB=$MEM_TOTAL_MB

  GOVERNOR="$(rd /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor "n/a")"
  if [ -r /sys/module/intel_idle/parameters/max_cstate ]; then
    CUR_CSTATE="$(cat /sys/module/intel_idle/parameters/max_cstate 2>/dev/null)"
  elif [ -r /sys/module/processor/parameters/max_cstate ]; then
    CUR_CSTATE="$(cat /sys/module/processor/parameters/max_cstate 2>/dev/null)"
  else
    CUR_CSTATE="n/a"
  fi

  have ethtool   && HAS_ETHTOOL=1
  have nft       && HAS_NFT=1
  have iptables  && HAS_IPT=1
  have conntrack && HAS_CONNTRACK=1
  have cpupower  && HAS_CPUPOWER=1
  have masscan   && HAS_MASSCAN=1
  [ -d /proc/net/pf_ring ] || lsmod 2>/dev/null | grep -q '^pf_ring' && HAS_PFRING=1
  systemctl is-active --quiet irqbalance 2>/dev/null && IRQBAL_ACTIVE=1

  if [ "$HAS_MASSCAN" -eq 1 ]; then
    MASSCAN_VER="$(masscan --version 2>&1 | head -2 | tr '\n' ' ')"
    masscan --version 2>&1 | grep -qi 'PF_RING.*enabled\|pfring' && MASSCAN_PFRING="yes"
  fi
}

detect_network() {
  info "探测网卡与链路…"
  IFACE="$(ip -4 route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1);exit}}')"
  [ -z "$IFACE" ] && IFACE="$(ls /sys/class/net 2>/dev/null | grep -v '^lo$' | head -1)"
  if [ -z "$IFACE" ]; then
    warn "未找到可用网卡，网卡层调优将跳过"
    NO_NIC=1
    IF_SPEED="unknown"
    return
  fi
  IF_MAC="$(rd "/sys/class/net/$IFACE/address" "")"
  IF_MTU="$(rd "/sys/class/net/$IFACE/mtu" "1500")"
  IF_IP="$(ip -4 -o addr show dev "$IFACE" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1)"
  GW_IP="$(ip -4 route show default 2>/dev/null | awk '{print $3;exit}')"
  IF_DRIVER=""
  if [ -e "/sys/class/net/$IFACE/device/driver" ]; then
    IF_DRIVER="$(basename "$(readlink -f "/sys/class/net/$IFACE/device/driver")")"
  fi
  case "$IF_DRIVER" in
    virtio_net|vmxnet3|xen-netfront|hv_netvsc|veth|"") IF_VIRT="vm" ;;
    *) IF_VIRT="phy" ;;
  esac
  if [ "$HAS_ETHTOOL" -eq 1 ]; then
    IF_SPEED="$(ethtool "$IFACE" 2>/dev/null | awk -F: '/Speed/{gsub(/[^0-9]/,"",$2);print $2;exit}')"
    [ -z "$IF_SPEED" ] && IF_SPEED="unknown"
  else
    IF_SPEED="unknown"
  fi
  [ -z "$IF_SPEED" ] && IF_SPEED="unknown"

  # 网关 MAC：ARP 表为空时主动 ping 一次把它"打"出来（--router-mac 是最大提速项）
  if [ -n "$GW_IP" ]; then
    gw_mac_lookup() {
      local m
      m="$(ip neigh show "$GW_IP" dev "$IFACE" 2>/dev/null | awk '/lladdr/{print $5;exit}')"
      [ -z "$m" ] && m="$(arp -n "$GW_IP" 2>/dev/null | awk 'NR>1{print $3;exit}')"
      printf '%s' "$m"
    }
    GW_MAC="$(gw_mac_lookup)"
    if [ -z "$GW_MAC" ]; then
      ping -c 1 -W 1 "$GW_IP" >/dev/null 2>&1 || true
      sleep 0.3
      GW_MAC="$(gw_mac_lookup)"
    fi
  fi
}

# =============================================================================
#  阶段二：决策（按硬件推导目标值）
# =============================================================================
plan_sysctl() {
  info "推导内核参数…"

  # 缓冲区上限：内存的 1/8，夹在 16MB ~ 256MB
  local buf_mb=$(( MEM_TOTAL_MB / 8 ))
  local buf=$(( buf_mb * 1024 * 1024 ))
  buf=$(clamp "$buf" 16777216 268435456)
  # 默认值只给 1/4 且封顶 16MB —— 这是"每个 socket 初始缓冲"，
  # 在 2GB 小机器上给太大反而会触发 OOM
  local buf_def=$(( buf / 4 ))
  buf_def=$(clamp "$buf_def" 4194304 16777216)

  # 分片队列阈值：内存的 1/16，夹在 32MB ~ 256MB（真实占内存，按 RAM 缩放）
  local frag_hi=$(( MEM_TOTAL_MB * 1024 * 1024 / 16 ))
  frag_hi=$(clamp "$frag_hi" 33554432 268435456)
  local frag_lo=$(( frag_hi * 3 / 4 ))

  # 收包 backlog：按核数放大，单核 20 万，封顶 100 万
  local backlog=$(( CPU_LOGICAL * 200000 ))
  backlog=$(clamp "$backlog" 131072 1000000)

  # budget：每个软中断周期最多处理的包数
  local budget=$(( CPU_LOGICAL * 10000 ))
  budget=$(clamp "$budget" 30000 60000)

  # 邻接表：内存 >=8G 给满，否则按内存线性
  local neigh
  if   [ "$MEM_TOTAL_MB" -ge 8192 ]; then neigh=65536
  elif [ "$MEM_TOTAL_MB" -ge 4096 ]; then neigh=32768
  else neigh=16384
  fi

  # 端口范围
  local pmin=1024

  # conntrack：内存 1/16 的千条目，封顶 100 万
  local ct=$(( MEM_TOTAL_MB * 1024 / 16 / 1000 ))
  ct=$(clamp "$ct" 65536 1048576)

  SYSCTL_NEW["net.core.rmem_max"]="$buf"
  SYSCTL_NEW["net.core.wmem_max"]="$buf"
  SYSCTL_NEW["net.core.rmem_default"]="$buf_def"
  SYSCTL_NEW["net.core.wmem_default"]="$buf_def"
  SYSCTL_NEW["net.core.optmem_max"]="25165824"
  SYSCTL_NEW["net.core.netdev_max_backlog"]="$backlog"
  SYSCTL_NEW["net.core.netdev_budget"]="$budget"
  SYSCTL_NEW["net.core.netdev_budget_usecs"]="8000"
  SYSCTL_NEW["net.core.somaxconn"]="65535"
  SYSCTL_NEW["net.core.default_qdisc"]="fq"

  SYSCTL_NEW["net.ipv4.ip_local_port_range"]="${pmin} 65535"
  SYSCTL_NEW["net.ipv4.tcp_fin_timeout"]="10"
  SYSCTL_NEW["net.ipv4.tcp_tw_reuse"]="1"
  SYSCTL_NEW["net.ipv4.tcp_max_syn_backlog"]="65535"
  SYSCTL_NEW["net.ipv4.tcp_sack"]="1"
  SYSCTL_NEW["net.ipv4.tcp_timestamps"]="1"

  SYSCTL_NEW["net.ipv4.neigh.default.gc_thresh1"]="$(( neigh / 4 ))"
  SYSCTL_NEW["net.ipv4.neigh.default.gc_thresh2"]="$(( neigh / 2 ))"
  SYSCTL_NEW["net.ipv4.neigh.default.gc_thresh3"]="$neigh"
  SYSCTL_NEW["net.ipv6.neigh.default.gc_thresh1"]="$(( neigh / 4 ))"
  SYSCTL_NEW["net.ipv6.neigh.default.gc_thresh2"]="$(( neigh / 2 ))"
  SYSCTL_NEW["net.ipv6.neigh.default.gc_thresh3"]="$neigh"

  SYSCTL_NEW["net.ipv4.conf.all.rp_filter"]="2"
  SYSCTL_NEW["net.ipv4.conf.default.rp_filter"]="2"
  SYSCTL_NEW["net.ipv4.conf.all.arp_ignore"]="1"
  SYSCTL_NEW["net.ipv4.conf.all.arp_announce"]="2"
  SYSCTL_NEW["net.ipv4.conf.all.forwarding"]="0"

  SYSCTL_NEW["net.ipv4.ipfrag_high_thresh"]="$frag_hi"
  SYSCTL_NEW["net.ipv4.ipfrag_low_thresh"]="$frag_lo"
  SYSCTL_NEW["net.ipv4.ipfrag_time"]="30"

  if [ -d /proc/sys/net/netfilter ]; then
    SYSCTL_NEW["net.netfilter.nf_conntrack_max"]="$ct"
    SYSCTL_NEW["net.netfilter.nf_conntrack_tcp_timeout_time_wait"]="30"
    SYSCTL_NEW["net.netfilter.nf_conntrack_tcp_timeout_syn_sent"]="30"
  fi

  # 采集旧值
  local k
  for k in "${!SYSCTL_NEW[@]}"; do
    SYSCTL_OLD["$k"]="$(sysctl -n "$k" 2>/dev/null || echo "N/A")"
  done

  # 只升不降的参数：现有值已经 >= 目标值时保持原样，避免"优化成倒退"
  local -a INCREASE_ONLY=(
    net.core.rmem_max net.core.wmem_max net.core.rmem_default net.core.wmem_default
    net.core.optmem_max net.core.netdev_max_backlog net.core.netdev_budget
    net.core.somaxconn net.ipv4.tcp_max_syn_backlog
    net.ipv4.neigh.default.gc_thresh1 net.ipv4.neigh.default.gc_thresh2
    net.ipv4.neigh.default.gc_thresh3
    net.ipv6.neigh.default.gc_thresh1 net.ipv6.neigh.default.gc_thresh2
    net.ipv6.neigh.default.gc_thresh3
    net.ipv4.ipfrag_high_thresh net.ipv4.ipfrag_low_thresh
    net.ipv4.tcp_tw_reuse
    net.netfilter.nf_conntrack_max
  )
  local o n
  for k in "${INCREASE_ONLY[@]}"; do
    [ -z "${SYSCTL_NEW[$k]:-}" ] && continue
    o="${SYSCTL_OLD[$k]}"; n="${SYSCTL_NEW[$k]}"
    if [[ "$o" =~ ^[0-9]+$ ]] && [[ "$n" =~ ^[0-9]+$ ]] && [ "$o" -ge "$n" ]; then
      SYSCTL_NEW["$k"]="$o"
    fi
  done

  # 目标值与现值完全相同 → 标记为 no-op，报告里显示"已达标"
  for k in "${!SYSCTL_NEW[@]}"; do
    if [ "${SYSCTL_OLD[$k]}" = "${SYSCTL_NEW[$k]}" ]; then
      SYSCTL_KEEP["$k"]=1
    fi
  done
}

plan_nic() {
  [ "$NO_NIC" -eq 1 ] && return
  [ "$HAS_ETHTOOL" -eq 1 ] || { warn "缺少 ethtool，网卡调优跳过"; NO_NIC=1; return; }

  # 环形缓冲：取硬件最大值，但不超过 4096（再大只增延迟不增吞吐）
  local gmax_rx gmax_tx
  gmax_rx="$(ethtool -g "$IFACE" 2>/dev/null | awk -F: '/RX:|Pre-set maximums/{ } /^RX:/{gsub(/ /,"",$2);print $2;exit}')"
  gmax_tx="$(ethtool -g "$IFACE" 2>/dev/null | awk -F: '/^TX:/{gsub(/ /,"",$2);print $2;exit}')"
  NIC_MAX_RX="${gmax_rx:-0}"; NIC_MAX_TX="${gmax_tx:-0}"
  NIC_OLD_RX="$(ethtool -g "$IFACE" 2>/dev/null | awk -F: '/^RX:/{gsub(/ /,"",$2);print $2}' | sed -n '2p')"
  NIC_OLD_TX="$(ethtool -g "$IFACE" 2>/dev/null | awk -F: '/^TX:/{gsub(/ /,"",$2);print $2}' | sed -n '2p')"
  NIC_OLD_RX="${NIC_OLD_RX:-0}"; NIC_OLD_TX="${NIC_OLD_TX:-0}"

  NIC_NEW_RX=4096; NIC_NEW_TX=4096
  [ "$NIC_MAX_RX" -gt 0 ] 2>/dev/null && NIC_NEW_RX=$(clamp 4096 1 "$NIC_MAX_RX")
  [ "$NIC_MAX_TX" -gt 0 ] 2>/dev/null && NIC_NEW_TX=$(clamp 4096 1 "$NIC_MAX_TX")

  # 队列：不超过物理核
  local q
  q="$(ethtool -l "$IFACE" 2>/dev/null | awk -F: '/Pre-set maximums/{f=1;next} f&&/Combined/{gsub(/ /,"",$2);print $2;exit}')"
  NIC_MAX_Q="${q:-0}"
  NIC_OLD_Q="$(ethtool -l "$IFACE" 2>/dev/null | awk -F: '/Current hardware settings/{f=1;next} f&&/Combined/{gsub(/ /,"",$2);print $2;exit}')"
  NIC_OLD_Q="${NIC_OLD_Q:-0}"
  NIC_NEW_Q="$CPU_PHYS"
  [ "$NIC_MAX_Q" -gt 0 ] 2>/dev/null && NIC_NEW_Q=$(clamp "$CPU_PHYS" 1 "$NIC_MAX_Q")
  [ "$NIC_MAX_Q" -eq 0 ] && NIC_NEW_Q=0

  NIC_OLD_TXQ="$(rd "/sys/class/net/$IFACE/tx_queue_len" 1000)"
  NIC_NEW_TXQ=20000

  # offload 快照
  local feat
  for feat in gro lro gso tso sg tx; do
    OFFLOAD_OLD["$feat"]="$(ethtool -k "$IFACE" 2>/dev/null | awk -v f="$feat:" '$1==f{print $2;exit}')"
    OFFLOAD_NEW["$feat"]="off"
  done
}

plan_rate() {
  local r
  if [ "$HAS_PFRING" -eq 1 ] && [ "$MASSCAN_PFRING" = "yes" ]; then
    case "$IF_SPEED" in
      10000|25000|40000|100000) r=3000000 ;;
      1000)  r=800000 ;;
      *)     r=200000 ;;
    esac
  else
    case "$IF_SPEED" in
      10000|25000|40000|100000) r=1000000 ;;
      1000)  r=400000 ;;
      *)     r=100000 ;;
    esac
  fi
  [ "$IF_VIRT" = "vm" ] && r=$(( r / 4 ))
  [ "$CPU_LOGICAL" -le 2 ] && r=$(( r / 2 ))
  [ "$r" -lt 10000 ] && r=10000
  RECOMMEND_RATE=$r
  [ -z "$BENCH_RATE" ] && BENCH_RATE=$r
}

print_plan() {
  hr
  printf '%s检测结果%s\n' "$C_D" "$C_0"
  hr
  printf '  %-16s %s\n' "系统"      "$DISTRO"
  printf '  %-16s %s (%s)\n' "内核"  "$KERNEL" "$ARCH"
  printf '  %-16s %s\n' "CPU"       "$CPU_MODEL"
  printf '  %-16s %s 逻辑 / %s 物理  @ %s MHz   governor=%s  cstate=%s' \
         "核心" "$CPU_LOGICAL" "$CPU_PHYS" "${CPU_MHZ:-?}" "$GOVERNOR" "$CUR_CSTATE"
  printf '\n'
  printf '  %-16s %s MB (可用 %s MB)\n' "内存" "$MEM_TOTAL_MB" "$MEM_AVAIL_MB"
  if [ "$NO_NIC" -eq 0 ]; then
    local spd_disp="$IF_SPEED"
    [ "$spd_disp" = "unknown" ] && spd_disp="未知(虚拟网卡)"
    printf '  %-16s %s  driver=%s  speed=%s  mtu=%s  ip=%s\n' \
           "网卡" "$IFACE" "$IF_DRIVER" "$spd_disp" "$IF_MTU" "${IF_IP:-none}"
    printf '  %-16s %s\n' "网关" "${GW_IP:-none} / ${GW_MAC:-未知}"
  fi
  printf '  %-16s masscan=%s  PF_RING=%s  conntrack=%s\n' \
         "工具" "$([ "$HAS_MASSCAN" -eq 1 ] && echo installed || echo missing)" \
         "$([ "$HAS_PFRING" -eq 1 ] && echo yes || echo no)" \
         "$([ "$HAS_CONNTRACK" -eq 1 ] && echo yes || echo no)"

  hr
  printf '%s内核参数方案%s（%s 项）\n' "$C_D" "$C_0" "${#SYSCTL_NEW[@]}"
  hr
  printf '  %-46s %-22s %s\n' "参数" "当前" "目标"
  local k mark
  for k in $(printf '%s\n' "${!SYSCTL_NEW[@]}" | sort); do
    mark=""
    [ "${SYSCTL_KEEP[$k]:-}" = "1" ] && mark=" (已达标·不改)"
    printf '  %-46s %-22s %s%s\n' "$k" "${SYSCTL_OLD[$k]}" "${SYSCTL_NEW[$k]}" "$mark"
  done

  if [ "$NO_NIC" -eq 0 ]; then
    hr
    printf '%s网卡参数方案%s\n' "$C_D" "$C_0"
    hr
    printf '  %-28s %-14s %s\n' "项目" "当前" "目标"
    printf '  %-28s %-14s %s\n' "RX ring"        "$NIC_OLD_RX"  "$NIC_NEW_RX"
    printf '  %-28s %-14s %s\n' "TX ring"        "$NIC_OLD_TX"  "$NIC_NEW_TX"
    printf '  %-28s %-14s %s\n' "Combined 队列"  "$NIC_OLD_Q"   "$NIC_NEW_Q"
    printf '  %-28s %-14s %s\n' "txqueuelen"     "$NIC_OLD_TXQ" "$NIC_NEW_TXQ"
    printf '  %-28s %-14s %s\n' "GRO/LRO/GSO/TSO" "混合"        "全部 off"
  fi

  hr
  local spd="$IF_SPEED"; [ "$spd" = "unknown" ] || [ -z "$spd" ] && spd="未知"
  printf '  %-16s %s pps（按链路 %s / %s 核推导）\n' "推荐 rate" "$RECOMMEND_RATE" "$spd" "$CPU_LOGICAL"
  hr
}

# =============================================================================
#  阶段三：备份
# =============================================================================
snapshot() {
  local tag="$1"
  local dir="${BACKUP_DIR}/${tag}"
  mkdir -p "$dir" 2>/dev/null || return 0

  sysctl -a 2>/dev/null >"$dir/sysctl.all" || true
  cp -a "$SYSCTL_CONF"  "$dir/sysctl.conf.exist" 2>/dev/null || true
  cp -a "$LIMITS_CONF"  "$dir/limits.conf.exist" 2>/dev/null || true

  if [ "$NO_NIC" -eq 0 ] && [ "$HAS_ETHTOOL" -eq 1 ]; then
    ethtool "$IFACE"      >"$dir/ethtool.info"   2>/dev/null || true
    ethtool -g "$IFACE"   >"$dir/ethtool.ring"   2>/dev/null || true
    ethtool -k "$IFACE"   >"$dir/ethtool.k"      2>/dev/null || true
    ethtool -l "$IFACE"   >"$dir/ethtool.l"      2>/dev/null || true
    ethtool -S "$IFACE"   >"$dir/ethtool.S"      2>/dev/null || true
  fi
  [ -r /proc/net/softnet_stat ] && cp /proc/net/softnet_stat "$dir/softnet.stat" 2>/dev/null || true
  [ -r "/sys/class/net/${IFACE:-lo}/statistics/tx_packets" ] && \
    cat "/sys/class/net/${IFACE:-lo}/statistics/tx_packets" >"$dir/tx_packets" 2>/dev/null || true
  nft list ruleset >"$dir/nft.ruleset" 2>/dev/null || true
  ip -br addr >"$dir/ip.addr" 2>/dev/null || true

  log "备份已保存: $dir"
}

# =============================================================================
#  阶段四：下发
# =============================================================================
apply_sysctl() {
  local k v
  if [ "$DRY_RUN" -eq 1 ]; then
    ACTION_ROWS+=("sysctl|dry-run|跳过实际写入")
    return
  fi

  # 先逐项实时写（失败不影响其他）
  for k in $(printf '%s\n' "${!SYSCTL_NEW[@]}" | sort); do
    v="${SYSCTL_NEW[$k]}"
    if [ "${SYSCTL_KEEP[$k]:-}" = "1" ]; then
      SYSCTL_RESULT["$k"]="keep"
      continue
    fi
    if [ "${SYSCTL_OLD[$k]}" = "N/A" ] && [ ! -e "/proc/sys/$(printf '%s' "$k" | tr '.' '/')" ]; then
      SYSCTL_RESULT["$k"]="skip"
      continue
    fi
    if sysctl -w "$k=$v" >/dev/null 2>&1; then
      SYSCTL_RESULT["$k"]="ok"
    else
      SYSCTL_RESULT["$k"]="fail"
    fi
  done

  # 再落盘为持久配置
  {
    echo "# 由 masscan-tune.sh v${SCRIPT_VER} 于 ${TS} 生成"
    echo "# 硬件: ${CPU_LOGICAL}C / ${MEM_TOTAL_MB}MB / ${IFACE:-n/a} speed=${IF_SPEED}"
    for k in $(printf '%s\n' "${!SYSCTL_NEW[@]}" | sort); do
      [ "${SYSCTL_RESULT[$k]:-}" = "skip" ] && continue
      echo "$k = ${SYSCTL_NEW[$k]}"
    done
  } >"$SYSCTL_CONF"

  ACTION_ROWS+=("sysctl 持久化|ok|$SYSCTL_CONF")
  ok "内核参数已应用并写入 $SYSCTL_CONF"
}

apply_limits() {
  if [ "$DRY_RUN" -eq 1 ]; then ACTION_ROWS+=("ulimit|dry-run|跳过"); return; fi
  cat >"$LIMITS_CONF" <<'EOF'
# masscan-tune.sh
*    soft nofile 1048576
*    hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
*    soft memlock unlimited
*    hard memlock unlimited
EOF
  chmod 644 "$LIMITS_CONF"
  mkdir -p "$(dirname "$SYSTEMD_CONF")"
  cat >"$SYSTEMD_CONF" <<'EOF'
# masscan-tune.sh
[Manager]
DefaultLimitNOFILE=1048576
DefaultLimitMEMLOCK=infinity
EOF
  systemctl daemon-reexec >/dev/null 2>&1 || true
  ACTION_ROWS+=("nofile/memlock|ok|$LIMITS_CONF")
  ok "文件描述符与内存锁定限制已写入（新会话生效）"
}

apply_nic() {
  [ "$NO_NIC" -eq 1 ] && { ACTION_ROWS+=("网卡调优|skip|无网卡或缺少 ethtool"); return; }
  if [ "$DRY_RUN" -eq 1 ]; then ACTION_ROWS+=("网卡调优|dry-run|跳过"); return; fi
  local msg=""

  if [ "$NIC_NEW_RX" -ne "$NIC_OLD_RX" ] || [ "$NIC_NEW_TX" -ne "$NIC_OLD_TX" ]; then
    if ethtool -G "$IFACE" rx "$NIC_NEW_RX" tx "$NIC_NEW_TX" >/dev/null 2>&1; then
      msg="${msg}ring=${NIC_NEW_RX}/${NIC_NEW_TX} "
    else
      msg="${msg}ring=失败 "
    fi
  fi

  local feat
  for feat in gro lro gso tso; do
    ethtool -K "$IFACE" "$feat" off >/dev/null 2>&1 && msg="${msg}${feat}=off "
  done

  ethtool -C "$IFACE" rx-usecs 0 tx-usecs 0 adaptive-rx off adaptive-tx off >/dev/null 2>&1 \
    && msg="${msg}irq-coalesce=0 "

  if [ "$NIC_NEW_Q" -gt 0 ] && [ "$NIC_NEW_Q" -ne "$NIC_OLD_Q" ]; then
    ethtool -L "$IFACE" combined "$NIC_NEW_Q" >/dev/null 2>&1 && msg="${msg}queues=${NIC_NEW_Q} "
  fi

  ip link set "$IFACE" txqueuelen "$NIC_NEW_TXQ" >/dev/null 2>&1 && msg="${msg}txqueuelen=${NIC_NEW_TXQ}"

  ACTION_ROWS+=("网卡调优|ok|$msg")
  ok "网卡已调优: $msg"
}

apply_cpu() {
  if [ "$MODE" != "aggressive" ]; then
    ACTION_ROWS+=("CPU governor|skip|safe 模式，建议 --aggressive")
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then ACTION_ROWS+=("CPU governor|dry-run|跳过"); return; fi

  local msg=""
  if [ "$HAS_CPUPOWER" -eq 1 ]; then
    cpupower frequency-set -g performance >/dev/null 2>&1 && msg="governor=performance"
  else
    local f
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      [ -w "$f" ] && echo performance >"$f" 2>/dev/null
    done
    [ "$(rd /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor n/a)" = "performance" ] \
      && msg="governor=performance"
  fi

  # C-state：写入 GRUB，重启后生效
  if [ -f /etc/default/grub ] && ! grep -q 'intel_idle.max_cstate=1' /etc/default/grub; then
    cp -a /etc/default/grub "${BACKUP_DIR}/grub.exist" 2>/dev/null || true
    sed -i 's/^GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 intel_idle.max_cstate=1 processor.max_cstate=1"/' \
      /etc/default/grub 2>/dev/null
    update-grub >/dev/null 2>&1 && msg="${msg} cstate=1(重启生效)"
  fi

  ACTION_ROWS+=("CPU 调优|ok|${msg:-无变化}")
  ok "CPU 调优: ${msg:-无变化}"
}

apply_irq() {
  if [ "$MODE" != "aggressive" ]; then
    ACTION_ROWS+=("中断绑核|skip|safe 模式")
    return
  fi
  [ "$NO_NIC" -eq 1 ] && { ACTION_ROWS+=("中断绑核|skip|无网卡"); return; }
  if [ "$DRY_RUN" -eq 1 ]; then ACTION_ROWS+=("中断绑核|dry-run|跳过"); return; fi

  local cpu_mask="0-3"
  [ "$CPU_LOGICAL" -lt 4 ] && cpu_mask="0-$((CPU_LOGICAL-1))"

  if [ "$IRQBAL_ACTIVE" -eq 1 ]; then
    systemctl stop irqbalance >/dev/null 2>&1 && systemctl disable irqbalance >/dev/null 2>&1
  fi

  local n=0 irq
  for irq in $(grep -E "$IFACE" /proc/interrupts 2>/dev/null | awk -F: '{print $1}'); do
    if [ -w "/proc/irq/$irq/smp_affinity_list" ]; then
      echo "$cpu_mask" >"/proc/irq/$irq/smp_affinity_list" 2>/dev/null && n=$((n+1))
    fi
  done

  # 收包软中断已落到 0-3，masscan 建议独占最后一个核
  IRQ_BOUND=$n
  ACTION_ROWS+=("中断绑核|ok|${n} 个 IRQ → CPU ${cpu_mask}，irqbalance 已停")
  ok "中断绑定完成: ${n} 个 → CPU ${cpu_mask}"
  [ "$CPU_LOGICAL" -ge 4 ] && NOTES+=("建议用 taskset -c $((CPU_LOGICAL-1)) 独占最后一个核给 masscan")
}

apply_firewall() {
  local sp_lo=40000 sp_hi=40100
  if [ "$DRY_RUN" -eq 1 ]; then ACTION_ROWS+=("防火墙规则|dry-run|跳过"); return; fi

  if [ "$HAS_NFT" -eq 1 ]; then
    nft list table inet masscan >/dev/null 2>&1 || nft add table inet masscan 2>/dev/null
    nft list chain inet masscan out >/dev/null 2>&1 || \
      nft 'add chain inet masscan out { type filter hook output priority 0; policy accept; }' 2>/dev/null
    nft list chain inet masscan post >/dev/null 2>&1 || \
      nft 'add chain inet masscan post { type filter hook output priority raw; policy accept; }' 2>/dev/null

    # 屏蔽内核对本机伪造连接的 RST（只针对 masscan 源端口段，不影响系统其他 TCP）
    if ! nft list chain inet masscan out 2>/dev/null | grep -q 'masscan-kernel-rst'; then
      nft add rule inet masscan out tcp sport ${sp_lo}-${sp_hi} tcp flags \& rst == rst \
        drop comment "masscan-kernel-rst" 2>/dev/null
    fi
    # 扫描流量绕过 conntrack
    if [ -n "$IF_IP" ] && ! nft list chain inet masscan post 2>/dev/null | grep -q 'masscan-notrack'; then
      nft add rule inet masscan post ip saddr "$IF_IP" tcp sport ${sp_lo}-${sp_hi} \
        notrack comment "masscan-notrack" 2>/dev/null
    fi
    ACTION_ROWS+=("防火墙规则|ok|nft: RST drop + notrack (sport ${sp_lo}-${sp_hi})")
    ok "nftables 规则已就绪（RST 屏蔽 + notrack）"
  elif [ "$HAS_IPT" -eq 1 ]; then
    iptables -C OUTPUT -p tcp --tcp-flags RST RST --sport ${sp_lo}:${sp_hi} -j DROP 2>/dev/null || \
      iptables -I OUTPUT -p tcp --tcp-flags RST RST --sport ${sp_lo}:${sp_hi} -j DROP 2>/dev/null
    iptables -t raw -C OUTPUT -p tcp --sport ${sp_lo}:${sp_hi} -j CT --notrack 2>/dev/null || \
      iptables -t raw -I OUTPUT -p tcp --sport ${sp_lo}:${sp_hi} -j CT --notrack 2>/dev/null
    ACTION_ROWS+=("防火墙规则|ok|iptables: RST drop + NOTRACK")
    ok "iptables 规则已就绪"
  else
    ACTION_ROWS+=("防火墙规则|skip|无 nft / iptables")
  fi

  # 排除表模板
  if [ ! -f "$EXCLUDE_FILE" ]; then
    mkdir -p "$(dirname "$EXCLUDE_FILE")"
    cat >"$EXCLUDE_FILE" <<'EOF'
# masscan 排除段（按需删改）
0.0.0.0/8
10.0.0.0/8
100.64.0.0/10
127.0.0.0/8
169.254.0.0/16
172.16.0.0/12
192.0.0.0/24
192.0.2.0/24
192.168.0.0/16
198.18.0.0/15
198.51.100.0/24
203.0.113.0/24
224.0.0.0/4
240.0.0.0/4
EOF
    ACTION_ROWS+=("排除表|ok|$EXCLUDE_FILE")
  fi
}

apply_setcap() {
  [ "$DRY_RUN" -eq 1 ] && return
  local mp
  mp="$(command -v masscan 2>/dev/null)" || return 0
  setcap cap_net_raw,cap_net_admin+eip "$mp" 2>/dev/null && \
    ACTION_ROWS+=("masscan 权限|ok|setcap cap_net_raw,cap_net_admin+eip")
}

# =============================================================================
#  阶段五：效果测量
# =============================================================================
softnet_drop() {
  local sum=0 c1 c2
  while read -r c1 c2 _; do
    if [[ "${c2:-}" =~ ^[0-9a-fA-F]+$ ]]; then
      sum=$(( sum + 16#$c2 ))
    fi
  done </proc/net/softnet_stat
  printf '%s' "$sum"
}

nic_err() {
  [ "$NO_NIC" -eq 1 ] && { echo 0; return; }
  ethtool -S "$IFACE" 2>/dev/null | \
    awk -F: 'tolower($1) ~ /drop|err|discard|no_buffer|fifo|miss/ {gsub(/[^0-9]/,"",$2); s+=$2} END{print s+0}'
}

tx_packets() {
  local f="/sys/class/net/${IFACE:-lo}/statistics/tx_packets"
  [ -r "$f" ] && cat "$f" || echo 0
}

# bench_run <tag> → 写全局变量 BENCH_<TAG>_*
bench_run() {
  local tag="$1"
  local up
  up="$(printf '%s' "$tag" | tr '[:lower:]' '[:upper:]')"

  if [ "$HAS_MASSCAN" -ne 1 ]; then
    warn "未安装 masscan，跳过 ${tag} 基准测试"
    printf -v "BENCH_${up}_OK" '%s' 0
    return 0
  fi
  if [ "$NO_NIC" -eq 1 ]; then
    warn "无可用网卡，跳过 ${tag} 基准测试"
    printf -v "BENCH_${up}_OK" '%s' 0
    return 0
  fi

  # 计算包量，让运行时长接近 BENCH_SECS
  BENCH_RATE="${BENCH_RATE//[^0-9]/}"
  [ -z "$BENCH_RATE" ] && BENCH_RATE=100000
  BENCH_SECS="${BENCH_SECS//[^0-9]/}"
  [ -z "$BENCH_SECS" ] && BENCH_SECS=5

  local ports_n=2000
  local rate=$BENCH_RATE
  local hosts=256
  local total expect

  if [ "$BENCH_PORTS" = "auto" ]; then
    # 反推端口数：让"包量 / rate ≈ BENCH_SECS"，保证小机器不跑太久、大机器不致于太短
    ports_n=$(( rate * BENCH_SECS / hosts ))
    [ "$ports_n" -lt 1 ] && ports_n=1
    [ "$ports_n" -gt 65535 ] && ports_n=65535
    BENCH_PORTS_ACTUAL="1-${ports_n}"
  else
    case "$BENCH_PORTS" in
      *-*) ports_n=$(( ${BENCH_PORTS#*-} - ${BENCH_PORTS%-*} + 1 )) ;;
      *,*) ports_n=$(printf '%s' "$BENCH_PORTS" | awk -F, '{print NF}') ;;
      *)   ports_n=1 ;;
    esac
    if ! [[ "${ports_n:-}" =~ ^[0-9]+$ ]] || [ "$ports_n" -lt 1 ]; then ports_n=2000; fi
    BENCH_PORTS_ACTUAL="$BENCH_PORTS"
  fi

  total=$(( hosts * ports_n ))
  expect=$(( total / (rate>0?rate:1) ))
  [ "$expect" -lt 1 ] && expect=1
  [ "$expect" -gt 120 ] && expect=120

  info "基准测试(${tag}): rate=${rate}pps target=${BENCH_TARGET} ports=${BENCH_PORTS_ACTUAL} 预计 ${expect}s"

  local tx0 tx1 t0 t1 pps drop0 drop1 nic0 nic1
  tx0=$(tx_packets); drop0=$(softnet_drop); nic0=$(nic_err)
  t0=$(date +%s%N)

  timeout $(( expect + 30 )) \
    masscan --interface "$IFACE" \
            --rate "$rate" --retries 0 --wait 1 --nostatus \
            -p"${BENCH_PORTS_ACTUAL}" "$BENCH_TARGET" \
            -oG /dev/null >/dev/null 2>&1
  local rc=$?

  t1=$(date +%s%N)
  tx1=$(tx_packets); drop1=$(softnet_drop); nic1=$(nic_err)

  local dtx=$(( tx1 - tx0 ))
  local dns=$(( (t1 - t0) / 1000000 ))
  [ "$dns" -le 0 ] && dns=1
  pps=$(( dtx * 1000 / dns ))

  printf -v "BENCH_${up}_PPS"   '%s' "$pps"
  printf -v "BENCH_${up}_DROP"  '%s' "$(( drop1 - drop0 ))"
  printf -v "BENCH_${up}_NICERR" '%s' "$(( nic1 - nic0 ))"
  local ach=$(( rate > 0 ? pps * 100 / rate : 0 ))
  printf -v "BENCH_${up}_ACH"   '%s' "$ach"

  if [ "$rc" -eq 124 ]; then
    warn "基准测试超时（可能被防火墙/路由拦截）"
    printf -v "BENCH_${up}_OK" '%s' 0
  else
    printf -v "BENCH_${up}_OK" '%s' 1
  fi
  ok "基准(${tag}): 实测 ${pps} pps / 目标 ${rate} pps = 达成 ${ach}% | 内核丢包 +$((drop1-drop0)) | 网卡错误 +$((nic1-nic0))"
}

# =============================================================================
#  阶段六：报告
# =============================================================================
report() {
  local md="${REPORT_MD}"
  if [ -z "$md" ] && [ -d "$LOG_DIR" ]; then md="${LOG_DIR}/report-${TS}.md"; fi
  : >"$md" 2>/dev/null || md=""

  emit() {
    printf '%s\n' "$*"
    [ -n "$md" ] && printf '%s\n' "$*" >>"$md"
  }

  emit ""
  emit "# masscan 调优报告"
  emit ""
  emit "- 生成时间：$(date '+%Y-%m-%d %H:%M:%S %Z')"
  emit "- 脚本版本：v${SCRIPT_VER}   模式：${MODE}"
  emit "- 主机：${DISTRO} / ${KERNEL} / ${ARCH}"
  emit "- CPU：${CPU_MODEL}（${CPU_LOGICAL} 逻辑核 / ${CPU_PHYS} 物理核）"
  emit "- 内存：${MEM_TOTAL_MB} MB"
  if [ "$NO_NIC" -eq 0 ]; then
    emit "- 网卡：${IFACE}（${IF_DRIVER}，$([ "$IF_SPEED" = "unknown" ] && echo "速率未知" || echo "${IF_SPEED}M")，MTU ${IF_MTU}，IP ${IF_IP:-none}）"
  fi
  emit "- masscan：$([ "$HAS_MASSCAN" -eq 1 ] && echo "${MASSCAN_VER}" || echo "未安装")  PF_RING：$([ "$HAS_PFRING" -eq 1 ] && echo yes || echo no)"
  emit ""

  # ---- 1. 参数变更 ----
  emit "## 一、参数变更明细"
  emit ""
  emit "| 参数 | 优化前 | 优化后 | 状态 |"
  emit "|---|---|---|---|"
  local k st
  for k in $(printf '%s\n' "${!SYSCTL_NEW[@]}" | sort); do
    st="${SYSCTL_RESULT[$k]:-pending}"
    case "$st" in
      ok)   st="✅ 生效" ;;
      fail) st="⚠️ 写入失败" ;;
      skip) st="— 内核不支持" ;;
      keep) st="· 已达标" ;;
      *)    st="· 未执行" ;;
    esac
    emit "| \`$k\` | \`${SYSCTL_OLD[$k]}\` | \`${SYSCTL_NEW[$k]}\` | $st |"
  done
  emit ""

  if [ "$NO_NIC" -eq 0 ]; then
    emit "## 二、网卡层变更"
    emit ""
    emit "| 项目 | 优化前 | 优化后 |"
    emit "|---|---|---|"
    emit "| RX ring | ${NIC_OLD_RX} | ${NIC_NEW_RX} |"
    emit "| TX ring | ${NIC_OLD_TX} | ${NIC_NEW_TX} |"
    emit "| Combined 队列 | ${NIC_OLD_Q} | ${NIC_NEW_Q:-保持} |"
    emit "| txqueuelen | ${NIC_OLD_TXQ} | ${NIC_NEW_TXQ} |"
    emit "| GRO / LRO / GSO / TSO | ${OFFLOAD_OLD[gro]:-?} / ${OFFLOAD_OLD[lro]:-?} / ${OFFLOAD_OLD[gso]:-?} / ${OFFLOAD_OLD[tso]:-?} | off / off / off / off |"
    emit "| 中断合并 | 默认 | rx-usecs 0 / 自适应关闭 |"
    [ "$IRQ_BOUND" -gt 0 ] && emit "| 中断绑核 | irqbalance 托管 | ${IRQ_BOUND} 个 IRQ 手工绑定 |"
    emit ""
  fi

  emit "## 三、执行动作"
  emit ""
  local row a b c
  for row in "${ACTION_ROWS[@]}"; do
    IFS='|' read -r a b c <<<"$row"
    emit "- **${a}** → ${b}：${c}"
  done
  emit ""

  # ---- 2. 效果 ----
  emit "## 四、优化效果（实测）"
  emit ""
  if [ "$SKIP_BENCH" -eq 1 ]; then
    emit "> 已通过 --skip-bench 跳过发型基准，本节无数据。"
  elif [ "$HAS_MASSCAN" -ne 1 ]; then
    emit "> 未安装 masscan，无法测量实际发包能力。"
  elif [ "$BENCH_BEFORE_OK" -eq 0 ] || [ "$BENCH_AFTER_OK" -eq 0 ]; then
    emit "> 基准测试未能完成（目标不可达 / 无出网权限）。以下为过程数据："
    emit ""
    emit "| 阶段 | 实测 pps | 内核丢弃 | 网卡错误 |"
    emit "|---|---|---|---|"
    emit "| 优化前 | ${BENCH_BEFORE_PPS} | +${BENCH_BEFORE_DROP} | +${BENCH_BEFORE_NICERR} |"
    emit "| 优化后 | ${BENCH_AFTER_PPS} | +${BENCH_AFTER_DROP} | +${BENCH_AFTER_NICERR} |"
  else
    local delta=0 pct=0
    delta=$(( BENCH_AFTER_PPS - BENCH_BEFORE_PPS ))
    [ "$BENCH_BEFORE_PPS" -gt 0 ] && pct=$(( delta * 100 / BENCH_BEFORE_PPS ))

    emit "测试条件：目标 \`${BENCH_TARGET}\`，端口 \`${BENCH_PORTS_ACTUAL:-$BENCH_PORTS}\`，设定 rate \`${BENCH_RATE}\` pps，\`--retries 0\`，统计网卡 tx_packets 增量。"
    emit ""
    emit "| 指标 | 优化前 | 优化后 | 变化 |"
    emit "|---|---|---|---|"
    emit "| 实测发包速率 | **${BENCH_BEFORE_PPS} pps** | **${BENCH_AFTER_PPS} pps** | ${delta} pps（${pct}%） |"
    emit "| 达成率（实测/设定） | ${BENCH_BEFORE_ACH}% | ${BENCH_AFTER_ACH}% | $(( BENCH_AFTER_ACH - BENCH_BEFORE_ACH )) pt |"
    emit "| 内核 softnet 丢弃 | +${BENCH_BEFORE_DROP} | +${BENCH_AFTER_DROP} | $(( BENCH_AFTER_DROP - BENCH_BEFORE_DROP )) |"
    emit "| 网卡侧错误/丢弃 | +${BENCH_BEFORE_NICERR} | +${BENCH_AFTER_NICERR} | $(( BENCH_AFTER_NICERR - BENCH_BEFORE_NICERR )) |"
    emit ""
    if [ "$pct" -gt 0 ]; then
      emit "**结论：同等设定 rate 下，实际落地吞吐提升 ${pct}%。**"
    elif [ "$pct" -eq 0 ]; then
      emit "**结论：吞吐未变化 —— 说明瓶颈不在内核/网卡层，而在单线程发包或链路本身，需要 --shard 多实例。**"
    else
      emit "**结论：吞吐下降 —— 请检查是否 rate 设得过高导致回包路径拥塞，降低 rate 通常结果更多。**"
    fi
  fi
  emit ""

  # ---- 3. 注意事项 ----
  if [ "${#NOTES[@]}" -gt 0 ]; then
    emit "## 五、注意事项"
    emit ""
    local n
    for n in "${NOTES[@]}"; do emit "- $n"; done
    emit ""
  fi

  emit "---"
  emit "回滚：\`sudo $0 --restore\`（备份目录 ${BACKUP_DIR}）"
  emit ""

  [ -n "$md" ] && printf '%s报告已保存: %s%s\n' "$C_G" "$md" "$C_0"
}

# =============================================================================
#  回滚
# =============================================================================
do_restore() {
  local latest
  latest="$(ls -1dt "${BACKUP_ROOT}"/*/ 2>/dev/null | head -1)"
  [ -z "$latest" ] && { err "没有找到备份目录"; exit 1; }
  info "使用备份: $latest"

  if [ -f "${latest}sysctl.conf.exist" ]; then
    cp -a "${latest}sysctl.conf.exist" "$SYSCTL_CONF"
  else
    rm -f "$SYSCTL_CONF"
  fi
  if [ -f "${latest}limits.conf.exist" ]; then
    cp -a "${latest}limits.conf.exist" "$LIMITS_CONF"
  else
    rm -f "$LIMITS_CONF"
  fi
  sysctl --system >/dev/null 2>&1 || true
  ok "sysctl 已回滚"

  [ -f "${latest}grub.exist" ] && cp -a "${latest}grub.exist" /etc/default/grub && update-grub >/dev/null 2>&1

  local ring="${latest}ethtool.ring"
  if [ -f "$ring" ]; then
    local ifc rx tx
    ifc="$(awk -F': ' '/Settings for/{print $2;exit}' "$ring" | awk '{print $1}')"
    rx="$(awk -F: '/^RX:/{gsub(/ /,"",$2);print $2}' "$ring" | sed -n '2p')"
    tx="$(awk -F: '/^TX:/{gsub(/ /,"",$2);print $2}' "$ring" | sed -n '2p')"
    if [ -n "$ifc" ] && [ -n "$rx" ]; then
      ethtool -G "$ifc" rx "$rx" tx "$tx" 2>/dev/null && ok "网卡 ring 已回滚 ($ifc rx=$rx tx=$tx)"
    fi
    local k
    for k in gro lro gso tso; do
      [ -n "$ifc" ] && ethtool -K "$ifc" "$k" on >/dev/null 2>&1
    done
  fi

  if have nft; then
    nft delete table inet masscan 2>/dev/null && ok "nftables 规则已清除"
  fi
  if have iptables; then
    iptables -D OUTPUT -p tcp --tcp-flags RST RST --sport 40000:40100 -j DROP 2>/dev/null || true
    iptables -t raw -D OUTPUT -p tcp --sport 40000:40100 -j CT --notrack 2>/dev/null || true
  fi

  systemctl enable --now irqbalance >/dev/null 2>&1 || true
  ok "回滚完成。CPU/C-state 相关项需重启后完全生效。"
}

# =============================================================================
#  主流程
# =============================================================================
main() {
  parse_args "$@"
  require_root "$@"

  if [ "$RESTORE" -eq 1 ]; then
    do_restore
    exit 0
  fi

  printf '%s' "$C_D"
  cat <<'BANNER'
  ╔══════════════════════════════════════════════════════════════╗
  ║        masscan-tune.sh · Ubuntu 扫描性能自动调优              ║
  ║        detect → plan → apply → measure → report              ║
  ╚══════════════════════════════════════════════════════════════╝
BANNER
  printf '%s\n' "$C_0"

  detect_system
  detect_network
  plan_sysctl
  plan_nic
  plan_rate
  print_plan

  if [ "$DRY_RUN" -eq 1 ]; then
    info "dry-run 模式，仅展示方案，不做任何修改"
    report
    exit 0
  fi

  info "备份当前状态…"
  snapshot "before"

  # 调优前基准
  if [ "$SKIP_BENCH" -eq 0 ]; then
    [ -z "$BENCH_RATE" ] && BENCH_RATE=$RECOMMEND_RATE
    bench_run before
  fi

  hr
  info "开始下发调优（模式：$MODE）"
  hr
  apply_sysctl
  apply_limits
  apply_nic
  apply_cpu
  apply_irq
  apply_firewall
  apply_setcap

  snapshot "after"

  # 调优后基准
  if [ "$SKIP_BENCH" -eq 0 ]; then
    hr
    info "复测以验证效果…"
    bench_run after
  fi

  hr
  report

  printf '\n%s完成。日志: %s%s\n' "$C_G" "${LOG_FILE:-控制台}" "$C_0"
}

main "$@"
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
