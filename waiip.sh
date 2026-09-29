#!/data/data/com.termux/files/usr/bin/bash
# waiip — lightweight IP/network scanner for Termux
# For systems/networks you own or are authorized to assess.

set -u

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

banner() {
  clear
  printf "${GREEN}"
  cat <<'EOF'
 __        ___    ___ ___
 \ \      / / \  |_ _|_ _| _ __
  \ \ /\ / / _ \  | | | | | '_ \
   \ V  V / ___ \ | | | | | |_) |
    \_/\_/_/   \_\___|___| .__/
                         |_|

          W A I I P  •  TERMUX
       Lightweight IP / Port Scanner
EOF
  printf "${RESET}\n"
  echo -e "${YELLOW}Authorized targets only.${RESET}"
  echo
}

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo -e "${RED}[!] Missing: $1${RESET}"
    return 1
  }
}

install_deps() {
  echo "[*] Installing dependencies..."
  pkg update -y
  pkg install -y nmap iproute2
  echo -e "${GREEN}[+] waiip is ready.${RESET}"
}

scan_basic() {
  local target="$1"
  need nmap || return
  echo -e "${CYAN}[*] Basic scan: $target${RESET}"
  nmap -T3 --open "$target"
}

scan_services() {
  local target="$1"
  need nmap || return
  echo -e "${CYAN}[*] Service/version scan: $target${RESET}"
  nmap -T3 -sV --open "$target"
}

scan_common() {
  local target="$1"
  need nmap || return
  echo -e "${CYAN}[*] Common TCP ports: $target${RESET}"
  nmap -T3 --open -p 21,22,23,25,53,80,110,143,443,445,3306,3389,8080,8443 "$target"
}

scan_subnet() {
  local target="$1"
  need nmap || return
  echo -e "${CYAN}[*] Discovering live hosts: $target${RESET}"
  nmap -sn -T3 "$target"
}

main() {
  banner

  while true; do
    echo "1) Install dependencies"
    echo "2) Basic port scan"
    echo "3) Service/version scan"
    echo "4) Scan common ports"
    echo "5) Discover live hosts in a subnet"
    echo "0) Exit"
    echo
    read -rp "waiip > " choice

    case "$choice" in
      1)
        install_deps
        ;;
      2)
        read -rp "Target IP/hostname: " target
        scan_basic "$target"
        ;;
      3)
        read -rp "Target IP/hostname: " target
        scan_services "$target"
        ;;
      4)
        read -rp "Target IP/hostname: " target
        scan_common "$target"
        ;;
      5)
        read -rp "Subnet (example 192.168.1.0/24): " target
        scan_subnet "$target"
        ;;
      0)
        echo "waiip exiting."
        exit 0
        ;;
      *)
        echo -e "${RED}[!] Invalid option.${RESET}"
        ;;
    esac

    echo
    read -rp "Press Enter to continue..."
    banner
  done
}

main
