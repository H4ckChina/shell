#!/bin/bash
sh_v="1.2.0"
# 定义一个暂停函数，用于在操作完成后等待用户按键
function pause(){
  read -p "按任意键继续..." -n1 -s
  echo ""
}

# 系统命令菜单：包含系统更新、组件安装、安装Masscan、安装Node、修改名称、修改密码、重启系统
# 架设 FTP：一键部署 vsftpd，目录 /root/Data，账号 adm1n / 密码 adm1n
function install_ftp() {
  local FTP_USER="adm1n" FTP_PASS="adm1n" FTP_DIR="/root/Data"
  local PASV_MIN=40000 PASV_MAX=40100

  [ "$(id -u)" -eq 0 ] || { echo "请用 root 运行"; return 1; }

  echo "正在安装 vsftpd..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y || { echo "apt update 失败"; return 1; }
  apt-get install -y vsftpd || { echo "vsftpd 安装失败"; return 1; }

  mkdir -p "$FTP_DIR"
  if id "$FTP_USER" >/dev/null 2>&1; then
    usermod -d "$FTP_DIR" -s /usr/sbin/nologin "$FTP_USER"
  else
    useradd -d "$FTP_DIR" -s /usr/sbin/nologin "$FTP_USER"
  fi
  echo "$FTP_USER:$FTP_PASS" | chpasswd
  grep -qxF /usr/sbin/nologin /etc/shells || echo /usr/sbin/nologin >> /etc/shells

  chown -R "$FTP_USER:$FTP_USER" "$FTP_DIR"
  chmod 755 /root "$FTP_DIR"

  [ -f /etc/vsftpd.conf.orig ] || cp /etc/vsftpd.conf /etc/vsftpd.conf.orig 2>/dev/null || true

  cat > /etc/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
local_root=${FTP_DIR}
pasv_enable=YES
pasv_min_port=${PASV_MIN}
pasv_max_port=${PASV_MAX}
pam_service_name=vsftpd
secure_chroot_dir=/var/run/vsftpd/empty
utf8_filesystem=YES
EOF

  systemctl enable vsftpd >/dev/null 2>&1 || true
  systemctl restart vsftpd || { echo "vsftpd 启动失败"; return 1; }

  if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q "Status: active"; then
    ufw allow 20,21/tcp >/dev/null
    ufw allow "${PASV_MIN}:${PASV_MAX}/tcp" >/dev/null
  fi

  echo "FTP 已就绪：${FTP_USER} / ${FTP_PASS} -> ${FTP_DIR}"
  systemctl is-active vsftpd >/dev/null 2>&1 && echo "服务状态：运行中"
}

function system_commands_menu() {
  clear
    printf "+------------------------------------------------------+\n"
    printf "|         1. 系统更新        |        2. 组件安装      |\n"
    printf "+------------------------------------------------------+\n"
    printf "|         3. 安装 Massca     |        4. 架设 FTP      |\n"
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
      install_ftp
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
# =============================================================================
#  masscan-tune.sh   v2.2  (2026-10-31)
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
#  版本：
#    v2.0  veth 隔离基准，零外泄；速率改取 masscan 自报最大值
#    v2.1  粗扫 + 二分收敛，推荐值 = 实测上限（不再打折）
#    v2.2  新增 --bench-wan 真实外网标定（指标=网卡实发，3 次取中位数）
#
#  用法：
#    sudo ./masscan-tune.sh                 # 默认 safe 级别，自动测效
#    sudo ./masscan-tune.sh --aggressive    # 追加 CPU/IRQ 激进调优
#    sudo ./masscan-tune.sh --dry-run       # 只检测+出方案，不落盘
#    sudo ./masscan-tune.sh --skip-bench    # 不做发包基准
#    sudo ./masscan-tune.sh --restore       # 回滚到最近一次备份
#
#  注意：默认基准目标 = 脚本顶部 DEFAULT_BENCH_TARGET（真实网卡、真实发包）。
#        想零外发请加 --bench-local。
# =============================================================================
# shellcheck disable=SC2016,SC2086,SC2129,SC1091

# set -uo pipefail   # 作为 H4ck.sh 的子功能运行，不能改宿主 shell 选项

SCRIPT_VER="2.2"
TS="$(date +%Y%m%d-%H%M%S)"
LOG_DIR=""                                    # 不写日志文件
BACKUP_ROOT="/tmp/.masscan-tune-backup"       # 备份放 tmp，重启自动清
LOG_FILE=""
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
# ★ 默认基准目标：直接 sudo ./masscan-tune.sh 就用这里
#   改成你自己的授权网段即可；留空字符串则回退到 veth 隔离模式
DEFAULT_BENCH_TARGET="220.128.0.0/12 220.160.0.0/11"
BENCH_TARGET="${DEFAULT_BENCH_TARGET}"   # auto | 显式 CIDR/IP，可空格分隔多个
BENCH_TARGETS=()        # 解析后的目标段数组
BENCH_MODE="auto"       # auto | local | external
BENCH_RATE=""
BENCH_SECS=3
BENCH_PORTS="auto"
BENCH_PORTS_ACTUAL=""
BENCH_HOSTS=1
BENCH_TARGET_SRC=""
BENCH_IFACE="" BENCH_SRC_IP="" BENCH_SRC_MAC="" BENCH_ROUTER_MAC=""
BENCH_ISOLATED=0 NETNS_NAME="mstune" NS_LINK="msp"
BENCH_WAN="" WAN_PORTS="80,443,22" WAN_DUR=5
WAN_REAL_PPS=0 WAN_SELF_PPS=0 WAN_MBPS=0 WAN_FOUND=0
BENCH_MAX_PKTS=30000
BENCH_MAX_PKTS_ISO=300000
CALIBRATE=1
RATE_FORMULA=0
RATE_MEASURED=0
declare -a CAL_ROWS=()   # "档位|实测pps|达成率|判定"
REPORT_MD=""
SCAN_DIR="/root/Scan" SCAN_SYNC=1

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
BENCH_INVALID=0
PROBE_TX_PPS=0 PROBE_M_PPS=0 PROBE_DROP=0 PROBE_NICERR=0 PROBE_MS=0 PROBE_SENT=0
PROBE_RAW="" PROBE_TX0=0 PROBE_TX1=0 PROBE_WALL=0 PROBE_FOUND=0 PROBE_REAL_PPS=0
PROBE_LOG="" PROBE_RAWFILE=""

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
  --skip-bench         跳过基准测试与 rate 校准
  --no-calibrate       只做前后对比，不做阶梯 rate 校准
  --bench-target ARG   覆盖默认基准目标（IP / CIDR，可空格分隔多个）
  --bench-wan "CIDR"   真实外网标定：用你授权的目标段测出口上限（判据=网卡实发包数）
  --wan-ports P        外网标定用的端口，默认 80,443,22
  --bench-local        用本地保留段 192.0.2.0/24 + router-mac（默认，零外部流量）
  --bench-rate PPS     前后对比用的固定速率，默认 min(公式值, 50000)
  --bench-secs N       每档跑满的秒数，默认 3（发包量 = rate × N）
  --no-nic             跳过网卡层调优（虚拟机/容器环境）
  --report-md PATH     额外输出 Markdown 报告
  --restore            用最近一次备份回滚
  -h, --help           显示帮助

基准说明:
  默认直接对你的授权网段做真实标定（见脚本顶部 DEFAULT_BENCH_TARGET）。
  想完全不发外部包，加 --bench-local 走 veth 隔离。
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
      --bench-target) BENCH_TARGET="${2:-auto}"; shift ;;
      --bench-local)  BENCH_MODE="local" ;;
      --bench-wan)    BENCH_WAN="${2:-}"; shift ;;
      --wan-ports)    WAN_PORTS="${2:-80,443,22}"; shift ;;
      --no-calibrate) CALIBRATE=0 ;;
      --no-scan-sync) SCAN_SYNC=0 ;;
      --scan-dir)     SCAN_DIR="${2:-/root/Scan}"; shift ;;
      --bench-rate)   BENCH_RATE="${2:-}"; shift ;;
      --bench-secs)   BENCH_SECS="${2:-3}"; shift ;;
      --bench-ports)  BENCH_PORTS="${2:-auto}"; shift ;;
      --report-md)    REPORT_MD="${2:-}"; shift ;;
      -h|--help) usage; return 0 ;;
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
    return 1
  fi
  mkdir -p "$BACKUP_ROOT" 2>/dev/null || true
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

  # 依赖自检：缺什么就降级什么，并提示安装命令
  local missing=""
  have ethtool   || missing="$missing ethtool"
  have nft       || { have iptables || missing="$missing nftables"; }
  have conntrack || missing="$missing conntrack"
  have lscpu     || missing="$missing util-linux"
  [ -n "$missing" ] && NOTES+=("缺失工具:$missing（apt install$missing）")

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
  # 网卡探测三路兜底：ip route → /proc/net/route → /sys/class/net
  IFACE="$(ip -4 route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1);exit}}')"
  [ -z "$IFACE" ] && IFACE="$(awk '$2=="00000000"{print $1;exit}' /proc/net/route 2>/dev/null)"
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

  # 网关 MAC：拿不到 --router-mac 时 masscan 要自己 ARP，会拖慢 10 倍以上
  if [ -n "$GW_IP" ]; then
    GW_MAC="$(gw_mac_lookup)"
    if [ -z "$GW_MAC" ]; then
      warn "网关 MAC 未解析，尝试主动触发 ARP…"
      ping -c 1 -W 1 "$GW_IP" >/dev/null 2>&1 || true
      have arping && arping -c 1 -w 2 -I "$IFACE" "$GW_IP" >/dev/null 2>&1 || true
      sleep 0.5
      GW_MAC="$(gw_mac_lookup)"
    fi
    if [ -n "$GW_MAC" ]; then
      ok "网关 MAC: $GW_MAC"
    else
      warn "网关 MAC 仍然取不到 —— 基准测试会因 masscan 自己 ARP 而严重偏慢，请手动指定 --router-mac"
    fi
  fi

}

# 网关 MAC 多路探测
gw_mac_lookup() {
  local m=""
  local bad="00:00:00:00:00:00"
  m="$(ip neigh show "$GW_IP" dev "$IFACE" 2>/dev/null | awk '/lladdr/{print $5;exit}')"
  [ -n "$m" ] && [ "$m" != "$bad" ] && { printf '%s' "$m"; return; }
  m="$(awk -v ip="$GW_IP" '$1==ip{print $4;exit}' /proc/net/arp 2>/dev/null)"
  [ -n "$m" ] && [ "$m" != "$bad" ] && { printf '%s' "$m"; return; }
  m="$(arp -n "$GW_IP" 2>/dev/null | awk -v ip="$GW_IP" '$1==ip{print $3;exit}')"
  [ -n "$m" ] && [ "$m" != "$bad" ] && { printf '%s' "$m"; return; }
  printf ''
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
  gmax_rx="$(ethtool -g "$IFACE" 2>/dev/null | awk -F: '/^RX:/{gsub(/[^0-9]/,"",$2);print $2;exit}')"
  gmax_tx="$(ethtool -g "$IFACE" 2>/dev/null | awk -F: '/^TX:/{gsub(/[^0-9]/,"",$2);print $2;exit}')"
  NIC_MAX_RX="${gmax_rx:-0}"; NIC_MAX_TX="${gmax_tx:-0}"
  NIC_OLD_RX="$(ethtool -g "$IFACE" 2>/dev/null | awk -F: '/^RX:/{gsub(/[^0-9]/,"",$2);print $2}' | sed -n '2p')"
  NIC_OLD_TX="$(ethtool -g "$IFACE" 2>/dev/null | awk -F: '/^TX:/{gsub(/[^0-9]/,"",$2);print $2}' | sed -n '2p')"
  NIC_OLD_RX="${NIC_OLD_RX:-0}"; NIC_OLD_TX="${NIC_OLD_TX:-0}"

  NIC_NEW_RX=4096; NIC_NEW_TX=4096
  [ "$NIC_MAX_RX" -gt 0 ] 2>/dev/null && NIC_NEW_RX=$(clamp 4096 1 "$NIC_MAX_RX")
  [ "$NIC_MAX_TX" -gt 0 ] 2>/dev/null && NIC_NEW_TX=$(clamp 4096 1 "$NIC_MAX_TX")

  # 队列：不超过物理核
  local q
  q="$(ethtool -l "$IFACE" 2>/dev/null | awk -F: '/Pre-set maximums/{f=1;next} f&&/Combined/{gsub(/[^0-9]/,"",$2);print $2;exit}')"
  NIC_MAX_Q="${q:-0}"
  NIC_OLD_Q="$(ethtool -l "$IFACE" 2>/dev/null | awk -F: '/Current hardware settings/{f=1;next} f&&/Combined/{gsub(/[^0-9]/,"",$2);print $2;exit}')"
  NIC_OLD_Q="${NIC_OLD_Q:-0}"
  NIC_NEW_Q="$CPU_PHYS"
  [ "$NIC_MAX_Q" -gt 0 ] 2>/dev/null && NIC_NEW_Q=$(clamp "$CPU_PHYS" 1 "$NIC_MAX_Q")
  [ "$NIC_MAX_Q" -eq 0 ] && NIC_NEW_Q=0

  NIC_OLD_TXQ="$(rd "/sys/class/net/$IFACE/tx_queue_len" 1000)"
  NIC_NEW_TXQ=20000

  # offload 快照
  local feat pat
  for feat in gro lro gso tso; do
    case "$feat" in
      gro) pat="generic-receive-offload|rx-gro" ;;
      lro) pat="large-receive-offload" ;;
      gso) pat="generic-segmentation-offload" ;;
      tso) pat="tcp-segmentation-offload" ;;
    esac
    OFFLOAD_OLD["$feat"]="$(ethtool -k "$IFACE" 2>/dev/null | awk -v p="$pat" -F: '(tolower($1) ~ p) {v=$2; gsub(/[^a-z]/,"",v); print v; exit}')"
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

  # 公式值仅作为"初值/上限保护"，真实值由 calibrate_rate 实测得出
  RATE_FORMULA=$r
  RECOMMEND_RATE=$r

  # 对比基准用固定中等速率，保证前后两次条件一致且包量可控
  if [ -z "$BENCH_RATE" ]; then
    BENCH_RATE=$r
    [ "$BENCH_RATE" -gt 50000 ] && BENCH_RATE=50000
    [ "$BENCH_RATE" -lt 1000 ]  && BENCH_RATE=1000
  fi
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
  printf '  %-16s %s pps（公式初值，按链路 %s / %s 核推导；最终值由实测校准决定）\n' "推荐 rate" "$RATE_FORMULA" "$spd" "$CPU_LOGICAL"
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
  local dev="${BENCH_IFACE:-$IFACE}"
  [ -z "$dev" ] && dev="lo"
  local f="/sys/class/net/${dev}/statistics/tx_packets"
  [ -r "$f" ] && cat "$f" || echo 0
}

# bench_run <tag> → 写全局变量 BENCH_<TAG>_*
# ---- 隔离测试网络：veth 一对，包只在内核内走，绝不出本机 ----
setup_bench_isolation() {
  have ip || return 1
  teardown_bench_isolation
  ip netns add "$NETNS_NAME" 2>/dev/null || return 1
  ip link add "${NS_LINK}0" type veth peer name "${NS_LINK}1" 2>/dev/null || {
    ip netns del "$NETNS_NAME" 2>/dev/null; return 1; }
  ip link set "${NS_LINK}1" netns "$NETNS_NAME" 2>/dev/null || return 1
  ip addr add 198.18.0.1/24 dev "${NS_LINK}0" 2>/dev/null
  ip link set "${NS_LINK}0" up 2>/dev/null
  ip link set "${NS_LINK}0" txqueuelen 10000 2>/dev/null
  ip netns exec "$NETNS_NAME" ip link set lo up 2>/dev/null
  ip netns exec "$NETNS_NAME" ip link set "${NS_LINK}1" up 2>/dev/null
  ip netns exec "$NETNS_NAME" ip link set "${NS_LINK}1" txqueuelen 10000 2>/dev/null
  BENCH_IFACE="${NS_LINK}0"
  BENCH_SRC_IP="198.18.0.1"
  BENCH_SRC_MAC="$(cat "/sys/class/net/${NS_LINK}0/address" 2>/dev/null)"
  BENCH_ROUTER_MAC="$(ip netns exec "$NETNS_NAME" cat "/sys/class/net/${NS_LINK}1/address" 2>/dev/null)"
  [ -n "$BENCH_SRC_MAC" ] && [ -n "$BENCH_ROUTER_MAC" ] || { teardown_bench_isolation; return 1; }
  return 0
}

teardown_bench_isolation() {
  ip link del "${NS_LINK}0" 2>/dev/null
  ip netns del "$NETNS_NAME" 2>/dev/null
  return 0
}

# 解析 --bench-target："220.128.0.0/12 220.160.0.0/11" → 数组
parse_bench_targets() {
  local raw="$1" t
  BENCH_TARGETS=()
  for t in $raw; do
    case "$t" in
      *[!0-9./:]*) warn "忽略非法目标：$t"; continue ;;
    esac
    BENCH_TARGETS+=("$t")
  done
  [ "${#BENCH_TARGETS[@]}" -gt 0 ]
}

# ---- 基准目标：默认隔离，绝不碰真实网络 ----
probe_bench_target() {
  BENCH_IFACE="$IFACE"
  # --bench-local 显式要求隔离时，忽略默认目标
  [ "$BENCH_MODE" = "local" ] && BENCH_TARGET="auto"
  BENCH_SRC_IP="$IF_IP"
  BENCH_SRC_MAC="$IF_MAC"
  BENCH_ROUTER_MAC="$GW_MAC"

  if [ -n "$BENCH_TARGET" ] && [ "$BENCH_TARGET" != "auto" ]; then
    BENCH_ISOLATED=0
    BENCH_TARGET_SRC="用户指定(真实网卡)"
    if ! parse_bench_targets "$BENCH_TARGET"; then
      warn "目标段解析失败：${BENCH_TARGET}"
      SKIP_BENCH=1
      return 1
    fi
    BENCH_HOSTS=0
    local t pp n
    for t in "${BENCH_TARGETS[@]}"; do
      case "$t" in
        */*) pp="${t#*/}"; n=$(( 1 << (32 - pp) )) ;;
        *)   n=1 ;;
      esac
      [ "$n" -gt "$BENCH_HOSTS" ] && BENCH_HOSTS=$n
    done
    [ "$BENCH_HOSTS" -lt 1 ] && BENCH_HOSTS=1
    # 真实网段窗口放长：3 秒里 masscan 启动要占掉 0.5~1 秒，误差太大
    [ "$BENCH_SECS" -eq 3 ] && BENCH_SECS=5
    warn "将向 ${#BENCH_TARGETS[@]} 个目标段发送真实数据包：${BENCH_TARGETS[*]}"
    warn "每档最多 ${BENCH_SECS} 秒（约 rate×${BENCH_SECS} 个包），确认是你的授权资产"
    ok "基准目标：${BENCH_TARGETS[*]}（真实网卡 ${BENCH_IFACE}）"
    return 0
  fi

  if setup_bench_isolation; then
    BENCH_ISOLATED=1
    BENCH_TARGET="198.18.0.0/24"
    BENCH_TARGETS=("198.18.0.0/24")
    BENCH_HOSTS=256
    BENCH_TARGET_SRC="隔离 veth（包不出本机）"
    ok "基准目标：${BENCH_TARGET}（隔离 veth ${BENCH_IFACE}，零外泄）"
    return 0
  fi

  warn "无法创建隔离 veth（需要 root + netns 支持），跳过基准测试"
  warn "如需实测，请显式指定：--bench-target 你自己的网段"
  SKIP_BENCH=1
}

# ---- 单档探测：设定 rate 跑满 BENCH_SECS 秒，回填 PROBE_* ----
# 原始探测数据写盘，便于事后逐条核对
probe_log() {
  local line="$*"
  printf '%s\n' "$line" >>"${PROBE_LOG:-/dev/null}" 2>/dev/null || true
}

# ---- 单档探测：设定 rate 跑满 BENCH_SECS 秒，回填 PROBE_* ----
# 全部原始计数都会写进 ${PROBE_LOG}，任何人都能拿笔算一遍验证
bench_probe() {
  local rate="$1"
  PROBE_TX_PPS=0; PROBE_M_PPS=0; PROBE_DROP=0; PROBE_NICERR=0
  PROBE_MS=0; PROBE_SENT=0; PROBE_RAW=""; PROBE_TX0=0; PROBE_TX1=0; PROBE_WALL=0

  [ "$HAS_MASSCAN" -eq 1 ] || return 1
  [ "$NO_NIC" -eq 0 ]      || return 1

  local cap=$BENCH_MAX_PKTS
  [ "${BENCH_ISOLATED:-0}" -eq 1 ] && cap=$BENCH_MAX_PKTS_ISO
  local want=$(( rate * BENCH_SECS ))
  [ "$want" -lt 6000 ] && want=6000
  [ "$want" -gt "$cap" ] && want=$cap

  local hosts=$BENCH_HOSTS
  [ "$hosts" -lt 1 ] && hosts=1

  local ports
  if [ "$BENCH_PORTS" != "auto" ]; then
    BENCH_PORTS_ACTUAL="$BENCH_PORTS"
    case "$BENCH_PORTS" in
      *-*) ports=$(( ${BENCH_PORTS#*-} - ${BENCH_PORTS%-*} + 1 )) ;;
      *)   ports=1 ;;
    esac
  elif [ "${BENCH_ISOLATED:-0}" -eq 1 ]; then
    # 隔离 veth：按包量反推端口，扫完自然结束
    ports=$(( want / hosts ))
    [ "$ports" -lt 1 ] && ports=1
    [ "$ports" -gt 65535 ] && ports=65535
    BENCH_PORTS_ACTUAL="1-${ports}"
  else
    # 真实网段：IP 数已经上百万，端口必须少，否则 masscan 调度开销会压垮发送速率
    ports=10
    BENCH_PORTS_ACTUAL="1-10"
  fi
  PROBE_SENT=$(( hosts * ports ))
  [ "${BENCH_ISOLATED:-0}" -eq 0 ] && PROBE_SENT=$(( rate * BENCH_SECS ))

  # --source-port 固定：避免内核 conntrack 建表，并与 nft notrack 规则对齐
  local dev="${BENCH_IFACE:-$IFACE}"
  local -a CMD=(masscan --interface "$dev")
  [ -n "$BENCH_SRC_IP" ]     && CMD+=(--adapter-ip  "$BENCH_SRC_IP")
  [ -n "$BENCH_SRC_MAC" ]    && CMD+=(--adapter-mac "$BENCH_SRC_MAC")
  [ -n "$BENCH_ROUTER_MAC" ] && CMD+=(--router-mac  "$BENCH_ROUTER_MAC")
  CMD+=(--source-port 40000 --rate "$rate" --retries 0 --wait 1
        -p"$BENCH_PORTS_ACTUAL" "${BENCH_TARGETS[@]}" -oG /dev/null)

  local cmd_str="" x
  for x in "${CMD[@]}"; do cmd_str+="$(printf '%q' "$x") "; done

  local tx0 tx1 drop0 drop1 nic0 nic1 t0 t1
  tx0=$(tx_packets); drop0=$(softnet_drop); nic0=$(nic_err)
  t0=$(date +%s%N)
  timeout $(( BENCH_SECS + 8 )) bash -c "$cmd_str" >"${PROBE_RAWFILE:-/dev/null}" 2>&1 || true
  t1=$(date +%s%N)
  tx1=$(tx_packets); drop1=$(softnet_drop); nic1=$(nic_err)

  local dtx=$(( tx1 - tx0 ))
  local dms=$(( (t1 - t0) / 1000000 )); [ "$dms" -le 0 ] && dms=1
  local send_ms=$dms
  # 隔离模式 masscan 正常退出，末尾有 --wait 1 秒要扣掉；
  # 真实网段模式靠 timeout 截断，根本没走到 wait，不能扣
  [ "${BENCH_ISOLATED:-0}" -eq 1 ] && send_ms=$(( dms - 1000 ))
  [ "$send_ms" -lt 500 ] && send_ms=$dms
  PROBE_TX0=$tx0; PROBE_TX1=$tx1; PROBE_WALL=$dms; PROBE_MS=$send_ms
  PROBE_DROP=$(( drop1 - drop0 ))
  PROBE_NICERR=$(( nic1 - nic0 ))
  PROBE_REAL_PPS=$(( dtx * 1000 / send_ms ))   # 网卡实发：真实网卡上唯一可信的指标
  PROBE_TX_PPS=$PROBE_REAL_PPS

  # masscan 用回车符刷新同一行，且 --wait 阶段全是 0.00-kpps。
  # 必须 tr 转换 + grep -a（输出含二进制字节）+ 取全序列最大值，绝不能取最后一行。
  if [ -n "${PROBE_RAWFILE:-}" ] && [ -r "$PROBE_RAWFILE" ]; then
    PROBE_RAW="$(tr '\r' '\n' <"$PROBE_RAWFILE" | grep -a 'rate:' | tail -1)"
    local maxk
    maxk="$(tr '\r' '\n' <"$PROBE_RAWFILE" | grep -a -oE 'rate:[ ]*[0-9]+\.[0-9]+-kpps' | grep -a -oE '[0-9]+\.[0-9]+' | sort -rn | head -1)"
    [ -n "$maxk" ] && PROBE_M_PPS=$(awk -v r="$maxk" 'BEGIN{printf "%d", r*1000}')
    PROBE_FOUND="$(tr '\r' '\n' <"$PROBE_RAWFILE" | grep -a -oE 'found=[0-9]+' | tail -1 | cut -d= -f2)"
  fi

  probe_log "$(printf 'rate=%-8s sent=%-8s tx0=%-12s tx1=%-12s dtx=%-8s wall_ms=%-7s self_pps=%-8s found=%s'       "$rate" "$PROBE_SENT" "$tx0" "$tx1" "$dtx" "$dms" "$PROBE_M_PPS" "${PROBE_FOUND:-?}")"
  probe_log "  cmd: ${cmd_str}"
  return 0
}

# ---- 阶梯实测：找这台机器真实能跑多少 pps ----
calibrate_rate() {
  if [ "$HAS_MASSCAN" -ne 1 ] || [ "$NO_NIC" -eq 1 ]; then
    warn "缺少 masscan 或无网卡，跳过 rate 校准"
    return 0
  fi
  hr
  info "阶梯实测校准 rate（目标 ${BENCH_TARGET}，${BENCH_TARGET_SRC}）"
  [ -n "$GW_MAC" ] || warn "网关 MAC 缺失"
  info "原始数据: ${PROBE_LOG}"
  hr

  local lv got lo hi mid i gain=0 prev_got=0
  local levels="4000 8000 16000 32000 64000 128000 256000 512000 1000000"
  # 真实网段：段太大扫不完，靠 timeout 截断，档位精简避免流量过大
  [ "${BENCH_ISOLATED:-0}" -eq 0 ] && levels="4000 8000 16000 32000 64000 128000"

  local last_good=0 fail_at=0 ceiling=0
  # veth 对端没有消费者，前一轮大批量会在队列里积压，先等它排空
  [ "${BENCH_ISOLATED:-0}" -eq 1 ] && sleep 2
  for lv in $levels; do
    bench_probe "$lv"
    # 隔离 veth：对端无消费者，墙钟会被积压拖长，用 masscan 自报值更准
    # 真实网卡：自报虚高 30%，必须用网卡实发
    if [ "${BENCH_ISOLATED:-0}" -eq 1 ]; then
      got=$PROBE_M_PPS
      [ "$got" -lt 1 ] && got=$PROBE_REAL_PPS
    else
      if [ "${BENCH_ISOLATED:-0}" -eq 1 ]; then
        got=$PROBE_M_PPS
        [ "$got" -lt 1 ] && got=$PROBE_REAL_PPS
      else
        got=$PROBE_REAL_PPS
        [ "$got" -lt 1 ] && got=$PROBE_M_PPS
      fi
    fi
    if [ "$got" -lt 1 ]; then
      CAL_ROWS+=("${lv}|0|0%|❌ 无出包")
      warn "档位 ${lv} 完全无出包，校准中止"
      break
    fi
    local ach=$(( got * 100 / lv ))
    [ "$got" -gt "$ceiling" ] && ceiling=$got

    if [ "${BENCH_ISOLATED:-0}" -eq 0 ]; then
      # 真实网段：达成率天然到不了 95%，看"加大设定值后实发还涨不涨"
      if [ "$prev_got" -gt 0 ]; then
        gain=$(( (got - prev_got) * 100 / prev_got ))
      else
        gain=999
      fi
      if [ "$prev_got" -gt 0 ] && [ "$gain" -lt 10 ]; then
        CAL_ROWS+=("${lv}|${got}|${ach}%|⚠️ 饱和 ${gain}%")
        printf '    粗扫 %-8s pps  →  实发 %-8s (%s%%)  较上档 %s%%  ← 饱和\n' "$lv" "$got" "$ach" "$gain"
        fail_at=$lv
        break
      fi
      CAL_ROWS+=("${lv}|${got}|${ach}%|✅ 增长 ${gain}%")
      printf '    粗扫 %-8s pps  →  实发 %-8s (%s%%)  较上档 +%s%%\n' "$lv" "$got" "$ach" "$gain"
      prev_got=$got
      last_good=$lv
    elif [ "$ach" -ge 95 ]; then
      CAL_ROWS+=("${lv}|${got}|${ach}%|✅ 达成")
      printf '    粗扫 %-8s pps  →  实测 %-8s (%s%%)\n' "$lv" "$got" "$ach"
      last_good=$lv
    else
      CAL_ROWS+=("${lv}|${got}|${ach}%|⚠️ 饱和")
      printf '    粗扫 %-8s pps  →  实测 %-8s (%s%%)  ← 已饱和\n' "$lv" "$got" "$ach"
      fail_at=$lv
      break
    fi
    sleep 1
  done

  # 真实网段：推荐值 = 实发峰值 × 80%，向下取整到千位
  # 绝不能把"设定值"当推荐值 —— 那会高于机器实际能跑的吞吐
  if [ "${BENCH_ISOLATED:-0}" -eq 0 ]; then
    RATE_MEASURED=$ceiling
    if [ "$ceiling" -gt 0 ]; then
      RECOMMEND_RATE=$(( ceiling * 80 / 100 ))
      # 取整规则：>=5000 按 5000 步进向下取整（92000→90000，97000→95000），
      # 1000~5000 按 1000 步进，低于 1000 兜底 1000
      if [ "$RECOMMEND_RATE" -ge 5000 ]; then
        RECOMMEND_RATE=$(( RECOMMEND_RATE / 5000 * 5000 ))
      elif [ "$RECOMMEND_RATE" -ge 1000 ]; then
        RECOMMEND_RATE=$(( RECOMMEND_RATE / 1000 * 1000 ))
      else
        RECOMMEND_RATE=1000
      fi
      ok "实发峰值 ${ceiling} pps → 推荐 rate = ${RECOMMEND_RATE} pps（峰值 -20%，向下取整到 5000）"
    else
      warn "无有效实发数据，保留公式初值 ${RATE_FORMULA} pps"
      RECOMMEND_RATE=$RATE_FORMULA
    fi
    return 0
  fi

  # 隔离 veth：继续二分，把推荐值逼到 masscan 发送能力上限
  if [ "$last_good" -gt 0 ] && [ "$fail_at" -gt 0 ] && [ "$fail_at" -gt "$last_good" ]; then
    lo=$last_good
    hi=$fail_at
    for i in 1 2 3 4 5; do
      [ $(( hi - lo )) -le 300 ] && break
      mid=$(( (lo + hi) / 2 ))
      bench_probe "$mid"
      if [ "${BENCH_ISOLATED:-0}" -eq 1 ]; then
        got=$PROBE_M_PPS
        [ "$got" -lt 1 ] && got=$PROBE_REAL_PPS
      else
        got=$PROBE_REAL_PPS
        [ "$got" -lt 1 ] && got=$PROBE_M_PPS
      fi
      local m_ach=$(( got * 100 / mid ))
      if [ "$m_ach" -ge 95 ]; then
        CAL_ROWS+=("${mid}|${got}|${m_ach}%|🔍 细调·达成")
        printf '    细调 %-8s pps  →  实测 %-8s (%s%%)  收窄到 (%s, %s]\n' "$mid" "$got" "$m_ach" "$mid" "$hi"
        lo=$mid
      else
        CAL_ROWS+=("${mid}|${got}|${m_ach}%|🔍 细调·未达")
        printf '    细调 %-8s pps  →  实测 %-8s (%s%%)  收窄到 (%s, %s]\n' "$mid" "$got" "$m_ach" "$lo" "$mid"
        hi=$mid
      fi
      sleep 0.2
    done
  elif [ "$last_good" -gt 0 ] && [ "$fail_at" -eq 0 ]; then
    lo=$last_good
    warn "粗扫已达 1000000 pps 仍全程达成，masscan 单线程基本到此为止"
  else
    lo=0
  fi

  RATE_MEASURED=$lo
  if [ "$RATE_MEASURED" -gt 0 ]; then
    RECOMMEND_RATE=$RATE_MEASURED
    ok "实测上限 ${RATE_MEASURED} pps → 推荐 rate = ${RECOMMEND_RATE} pps（这就是本机 masscan 的实测天花板）"
  else
    warn "无法测出有效吞吐，保留公式初值 ${RATE_FORMULA} pps"
    RECOMMEND_RATE=$RATE_FORMULA
  fi
}

# ---- 真实外网扫描能力标定（用你授权的目标段，指标取网卡实际发出的包）----
wan_probe() {
  local rate="$1" target="$2"
  WAN_REAL_PPS=0; WAN_SELF_PPS=0; WAN_MBPS=0; WAN_FOUND=0

  local tx0 t0 tx1 t1 by0 by1
  tx0=$(tx_packets); by0=$(cat "/sys/class/net/${BENCH_IFACE}/statistics/tx_bytes" 2>/dev/null || echo 0)
  t0=$(date +%s%N)
  timeout "$WAN_DUR" masscan --interface "$BENCH_IFACE" \
      --rate "$rate" --retries 0 --wait 1 --randomize-hosts \
      -p"$WAN_PORTS" $target -oG /dev/null >"${PROBE_RAWFILE:-/dev/null}" 2>&1 || true
  t1=$(date +%s%N)
  tx1=$(tx_packets); by1=$(cat "/sys/class/net/${BENCH_IFACE}/statistics/tx_bytes" 2>/dev/null || echo 0)

  local dp=$(( tx1 - tx0 )) db=$(( by1 - by0 ))
  local ms=$(( (t1 - t0) / 1000000 )); [ "$ms" -lt 1 ] && ms=1
  local send=$(( ms - 1000 )); [ "$send" -lt 1000 ] && send=$ms

  WAN_REAL_PPS=$(( dp * 1000 / send ))
  WAN_MBPS=$(awk -v b="$db" -v s="$send" 'BEGIN{printf "%.1f", b*8/1000000/(s/1000)}')

  local s
  s=$(tr '\r' '\n' <"${PROBE_RAWFILE:-/dev/null}" 2>/dev/null \
      | grep -a -oE 'rate:[ ]*[0-9]+\.[0-9]+-kpps' | grep -a -oE '[0-9]+\.[0-9]+' | sort -rn | head -1)
  [ -n "$s" ] && WAN_SELF_PPS=$(awk -v r="$s" 'BEGIN{printf "%d", r*1000}')
  WAN_FOUND=$(tr '\r' '\n' <"${PROBE_RAWFILE:-/dev/null}" 2>/dev/null | grep -a -oE 'found=[0-9]+' | tail -1 | cut -d= -f2)

  probe_log "WAN rate=$rate real=$WAN_REAL_PPS self=$WAN_SELF_PPS mbps=$WAN_MBPS found=${WAN_FOUND:-0}"
  return 0
}

calibrate_wan() {
  local targets="$1"
  hr
  info "外网扫描能力标定（目标段：${targets}，端口 ${WAN_PORTS}，每档 ${WAN_DUR}s × 3 次取中位数）"
  warn "真实外发流量，确认目标段是你的授权资产"
  hr

  local levels="10000 15000 20000 25000 30000 40000 50000 60000 80000 100000"
  local lv r best max_real=0 argmax_rate=0
  local -a RATES=() REALS=()

  for lv in $levels; do
    # 每档跑 3 次取中位数：单次方差可达 ±20%，最大值会系统性高估
    local -a v=()
    for r in 1 2 3; do
      wan_probe "$lv" "$targets"
      v+=("$WAN_REAL_PPS")
      [ "$r" -lt 3 ] && sleep 1
    done
    best=$(printf '%s
' "${v[@]}" | sort -n | sed -n '2p')
    [ -z "$best" ] && best=0
    RATES+=("$lv"); REALS+=("$best")
    printf '    %-8s pps → 实发 %-8s pps (%.1f Mbps)
' "$lv" "$best" "$WAN_MBPS"
    CAL_ROWS+=("${lv}|${best}|-|实发")
    [ "$best" -gt "$max_real" ] && { max_real=$best; argmax_rate=$lv; }
    sleep 1
  done

  # 平台期判定：实发达到峰值 95% 的最小设定值，才是可用的 rate
  local thr=$(( max_real * 95 / 100 )) rec=0 i
  for i in "${!RATES[@]}"; do
    if [ "${REALS[$i]}" -ge "$thr" ]; then rec="${RATES[$i]}"; break; fi
  done

  hr
  printf '  峰值实发 %s pps（出现在设定 %s 档）
' "$max_real" "$argmax_rate"
  if [ "$rec" -gt 0 ]; then
    RATE_MEASURED=$max_real
    RECOMMEND_RATE=$rec
    ok "外网扫描上限 ${max_real} pps ｜ 达到该上限 95% 的最小设定值 = ${rec} pps"
    ok "推荐 rate = ${RECOMMEND_RATE} pps（再往上加设定值，实发不再增长）"
  else
    warn "标定失败，保留公式初值 ${RATE_FORMULA} pps"
    RECOMMEND_RATE=$RATE_FORMULA
  fi
}

# ---- 调优前后对比（同 rate、同目标、同端口） ----
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

  BENCH_RATE="${BENCH_RATE//[^0-9]/}"
  [ -z "$BENCH_RATE" ] && BENCH_RATE=10000
  BENCH_SECS="${BENCH_SECS//[^0-9]/}"
  [ -z "$BENCH_SECS" ] && BENCH_SECS=3

  info "基准测试(${tag}): rate=${BENCH_RATE}pps target=${BENCH_TARGET} 预算 ${BENCH_SECS}s"

  # 只用 masscan 自报速率：tx_packets 在 veth/NAT 上会被 ARP、阻塞、其他流量污染
  # 跑两次取大值，压掉单次抖动（veth 尤其明显）
  local got=0 r
  for r in 1 2; do
    bench_probe "$BENCH_RATE"
    local one=$PROBE_REAL_PPS
    if [ "${BENCH_ISOLATED:-0}" -eq 1 ]; then
      one=$PROBE_M_PPS
      [ "$one" -lt 1 ] && one=$PROBE_REAL_PPS
    fi
    [ "$one" -lt 1 ] && one=$PROBE_TX_PPS
    [ "$one" -gt "$got" ] && got=$one
    [ "$got" -gt 0 ] && [ "$r" -eq 1 ] && sleep 0.3
  done
  printf -v "BENCH_${up}_PPS"    '%s' "$got"
  printf -v "BENCH_${up}_DROP"   '%s' "$PROBE_DROP"
  printf -v "BENCH_${up}_NICERR" '%s' "$PROBE_NICERR"

  local ach=$(( BENCH_RATE > 0 ? got * 100 / BENCH_RATE : 0 ))
  printf -v "BENCH_${up}_ACH" '%s' "$ach"

  if [ "$got" -lt 1 ]; then
    warn "基准(${tag}): 网卡零出包 —— 目标不可达或网关 MAC 未解析，本次数据无效"
    printf -v "BENCH_${up}_OK" '%s' 0
    BENCH_INVALID=1
  else
    printf -v "BENCH_${up}_OK" '%s' 1
  fi
  ok "基准(${tag}): masscan 自报 ${got} pps / 设定 ${BENCH_RATE} pps = 达成 ${ach}% | 发包 ${PROBE_SENT} 个 | tx增量 +$(( PROBE_TX1 - PROBE_TX0 )) | 内核丢包 +${PROBE_DROP}"
}

# =============================================================================
#  阶段六：报告
# =============================================================================
report() {
  # 控制台只打结论摘要；完整 Markdown 报告仅在你显式 --report-md 时才生成
  local md="${REPORT_MD}"
  local quiet=1
  if [ -n "$md" ]; then
    : >"$md" 2>/dev/null || md=""
    [ -n "$md" ] && quiet=0
  fi

  emit() {
    [ "$quiet" -eq 0 ] && printf '%s\n' "$*" >>"$md"
    return 0
  }

  if [ "$quiet" -eq 0 ]; then
    emit "# masscan 调优报告"
    emit ""
    emit "- 生成时间：$(date '+%Y-%m-%d %H:%M:%S %Z')"
    emit "- 主机：${DISTRO} / ${KERNEL} / ${ARCH}"
    emit "- CPU：${CPU_MODEL}（${CPU_LOGICAL} 逻辑核 / ${CPU_PHYS} 物理核），内存 ${MEM_TOTAL_MB} MB"
    [ "$NO_NIC" -eq 0 ] && emit "- 网卡：${IFACE}（${IF_DRIVER}，IP ${IF_IP:-none}）"
    emit ""

    emit "## 一、参数变更"
    emit ""
    emit "| 参数 | 优化前 | 优化后 | 状态 |"
    emit "|---|---|---|---|"
    local k st
    for k in $(printf '%s\n' "${!SYSCTL_NEW[@]}" | sort); do
      st="${SYSCTL_RESULT[$k]:-pending}"
      case "$st" in
        ok) st="生效" ;; fail) st="写入失败" ;; skip) st="内核不支持" ;;
        keep) st="已达标" ;; *) st="未执行" ;;
      esac
      emit "| \`$k\` | \`${SYSCTL_OLD[$k]}\` | \`${SYSCTL_NEW[$k]}\` | $st |"
    done
    emit ""

    emit "## 二、实测"
    emit ""
    if [ "${#CAL_ROWS[@]}" -gt 0 ]; then
      emit "| 设定 rate | 实发 pps | 达成率 | 判定 |"
      emit "|---|---|---|---|"
      local row a b c d
      for row in "${CAL_ROWS[@]}"; do
        IFS='|' read -r a b c d <<<"$row"
        emit "| ${a} | ${b} | ${c} | ${d} |"
      done
      emit ""
    fi
    emit "推荐 rate：\`${RECOMMEND_RATE}\` pps"
    emit ""
  fi

  # 控制台摘要
  return 0
}

# 按实测速率推导 --wait：速率越低给越长的收包窗口，下限 3 秒、上限 10 秒
calc_wait() {
  local r="$1" w
  [ "$r" -lt 1 ] && r=1
  w=$(( 150000 / r ))
  [ "$w" -lt 3 ]  && w=3
  [ "$w" -gt 10 ] && w=10
  printf '%s' "$w"
}

# ---- 把实测推荐值写回 Scan.sh 的 --max-rate ----
sync_scan_script() {
  [ "$SCAN_SYNC" -eq 1 ] || return 0
  # 只有校准真正测出结果才写回，公式兜底值不写
  [ "${RATE_MEASURED:-0}" -gt 0 ] || { info "未测出有效上限，跳过 Scan.sh 同步"; return 0; }

  local dir="${SCAN_DIR}" sh cur now wait_cur wait_new
  sh="${dir}/Scan.sh"
  [ -d "$dir" ] || return 0
  [ -f "$sh" ]  || { info "未找到 ${sh}，跳过同步"; return 0; }

  cur=$(grep -aoE -- '--max-rate[[:space:]]+[0-9]+' "$sh" 2>/dev/null | head -1 | grep -oE '[0-9]+$')
  if [ -z "$cur" ]; then
    warn "${sh} 里没有 --max-rate 参数，跳过"
    return 0
  fi
  wait_cur=$(grep -aoE -- '--wait[[:space:]]+[0-9]+' "$sh" 2>/dev/null | head -1 | grep -oE '[0-9]+$')
  wait_new=$(calc_wait "$RECOMMEND_RATE")

  # 两个参数都已经是目标值才跳过；只对上其中一个不能算完成
  if [ "$cur" = "$RECOMMEND_RATE" ] && { [ -z "$wait_cur" ] || [ "$wait_cur" = "$wait_new" ]; }; then
    ok "${sh} 已是目标值（--max-rate ${cur}$([ -n "$wait_cur" ] && echo "，--wait $wait_cur")），无需修改"
    return 0
  fi

  # 变化过大时提示：多半是链路状态波动，不是机器变了
  local hi=$cur lo=$cur
  [ "$RECOMMEND_RATE" -gt "$cur" ] && hi=$RECOMMEND_RATE || lo=$RECOMMEND_RATE
  if [ "$lo" -gt 0 ] && [ $(( hi / lo )) -ge 5 ]; then
    warn "新值 ${RECOMMEND_RATE} 与原值 ${cur} 相差 ${hi}:${lo}，可能是链路波动，建议复核"
  fi

  cp -a "$sh" "/tmp/Scan.sh.bak.${TS}" 2>/dev/null || true
  [ "$cur" != "$RECOMMEND_RATE" ] && \
    sed -i -E "s/--max-rate[[:space:]]+[0-9]+/--max-rate ${RECOMMEND_RATE}/g" "$sh" 2>/dev/null
  if [ -n "$wait_cur" ] && [ "$wait_cur" != "$wait_new" ]; then
    sed -i -E "s/--wait[[:space:]]+[0-9]+/--wait ${wait_new}/g" "$sh" 2>/dev/null
  fi

  now=$(grep -aoE -- '--max-rate[[:space:]]+[0-9]+' "$sh" 2>/dev/null | head -1 | grep -oE '[0-9]+$')
  if [ "$now" = "$RECOMMEND_RATE" ]; then
    local msg=""
    [ "$cur" != "$RECOMMEND_RATE" ] && msg="--max-rate ${cur} → ${RECOMMEND_RATE}"
    if [ -n "$wait_cur" ] && [ "$wait_cur" != "$wait_new" ]; then
      [ -n "$msg" ] && msg="${msg}，"
      msg="${msg}--wait ${wait_cur} → ${wait_new}"
    fi
    ok "已更新 ${sh}：${msg}"
  else
    warn "写入 ${sh} 失败（当前 ${now:-未知}）"
  fi
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
    return 0
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
    return 0
  fi

  PROBE_LOG="/tmp/.masscan-tune-probe-${TS}.log"
  : >"$PROBE_LOG" 2>/dev/null || PROBE_LOG=""
  PROBE_RAWFILE="$(mktemp /tmp/masscan-probe.XXXXXX 2>/dev/null)" || PROBE_RAWFILE=""

  info "备份当前状态…"
  snapshot "before"

  # 基准目标：--bench-wan 优先，其次 --bench-target / 默认值，最后才是 veth 隔离
  if [ -n "$BENCH_WAN" ]; then
    BENCH_IFACE="$IFACE"
    BENCH_SRC_IP="$IF_IP"
    BENCH_SRC_MAC="$IF_MAC"
    BENCH_ROUTER_MAC="$GW_MAC"
    BENCH_ISOLATED=0
    BENCH_TARGET="$BENCH_WAN"
    BENCH_TARGET_SRC="真实外网目标段(授权)"
    parse_bench_targets "$BENCH_WAN" || SKIP_BENCH=1
    [ "$BENCH_SECS" -eq 3 ] && BENCH_SECS=5
  elif [ "$SKIP_BENCH" -eq 0 ]; then
    probe_bench_target
  fi

  # 调优前基准（--bench-wan 走独立标定，不参与前后对比）
  if [ "$SKIP_BENCH" -eq 0 ] && [ -z "$BENCH_WAN" ]; then
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
  if [ "$SKIP_BENCH" -eq 0 ] && [ -z "$BENCH_WAN" ]; then
    hr
    info "复测以验证效果…"
    bench_run after
  fi

  # 实测校准：用真实吞吐反推推荐 rate
  if [ "$CALIBRATE" -eq 1 ]; then
    if [ -n "$BENCH_WAN" ]; then
      calibrate_wan "$BENCH_WAN"
    elif [ "$SKIP_BENCH" -eq 0 ]; then
      calibrate_rate
    fi
  fi

  # 拆掉隔离测试网络
  if [ "$BENCH_ISOLATED" -eq 1 ]; then
    teardown_bench_isolation
    info "隔离测试网络已拆除"
  fi

  sync_scan_script

  report

  hr
  printf '  %-14s %s%s%s pps\n' "推荐 rate" "$C_D" "$RECOMMEND_RATE" "$C_0"
  printf '  %-14s %s pps\n' "实测峰值" "${RATE_MEASURED:-0}"
  [ -n "$REPORT_MD" ] && printf '  %-14s %s\n' "报告文件" "$REPORT_MD"
  hr
  printf '\n%s完成。%s\n' "$C_G" "$C_0"
}

      main
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
    printf "|   1. 系统命令    |    2. Proxy    |    3. Scan       |\n"
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
