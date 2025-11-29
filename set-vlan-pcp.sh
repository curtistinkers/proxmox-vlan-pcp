#!/usr/bin/env sh

NO_FORMAT="\033[0m"
F_BOLD="\033[1m"
#_UNDERLINED="\033[4m"
C_RED="\033[38;5;9m"
C_BLUE="\033[38;5;12m"
C_ORANGERED1="\033[38;5;202m"
C_LIME="\033[38;5;10m"
C_YELLOW="\033[38;5;11m"
F_TAB="\t"
#F_NL="\n"

# Default options
OPT_HELP=0
OPT_VERBOSE=0
OPT_CONFIRM=0
BAD_IFACE=0
BAD_PCP=0

# Read command line options
while [ ${#} -gt 0 ]; do
  case ${1} in
    -i | --interface)
      if [ "${2}" != "" ]; then
        OPT_IFACE=${2}
        shift
      else
        BAD_IFACE=1
        print_error "--interface cannot be empty"
      fi
      ;;
    -p | --pcp)
      if [ "${2}" != "" ]; then
        OPT_PCP=${2}
        shift
      else
        BAD_PCP=1
        print_error "--pcp cannot be empty"
      fi
      ;;
    -h | --help | "-?" | "--?")
      # Display script help information# Display script help information
      OPT_HELP=1
      #help_info
      ;;
    -v | --verbose)
      # Enable verbose mode
      OPT_VERBOSE=1
      ;;
    -c | --confirm)
      # Enable confirmation mode
      OPT_CONFIRM=1
      ;;
  esac
  shift
done

get_help() {
  echo "\n${C_YELLOW}Easy VLAN priority shell script${NO_FORMAT}\n"

  echo "Usage:"
  echo "\t${C_LIME}-h | --help${NO_FORMAT}\t\tThis menu"
  echo "\t${C_LIME}-v | --verbose${NO_FORMAT}\t\tVerbose output"
  echo "\t${C_LIME}-i | --interface${NO_FORMAT}\tVLAN interface name (ex vmbr0.19)"
  echo "\t${C_LIME}-p | --pcp${NO_FORMAT}\t\tVLAN priority code point, must be 0-7"
  echo "\nPriority code points:\n"

  echo "${F_TAB}PCP #${F_TAB}Priority${F_TAB}Acronym${F_TAB}Traffic types"

  echo "${F_TAB}1${F_TAB}0 (lowest)${F_TAB}BK${F_TAB}Background"
  echo "${F_TAB}0${F_TAB}1 (default)${F_TAB}BE${F_TAB}Best effort"
  echo "${F_TAB}2${F_TAB}2${F_TAB}${F_TAB}EE${F_TAB}Excellent effort"
  echo "${F_TAB}3${F_TAB}3${F_TAB}${F_TAB}CA${F_TAB}Critical applications"
  echo "${F_TAB}4${F_TAB}4${F_TAB}${F_TAB}VI${F_TAB}Video, < 100 ms latency and jitter"
  echo "${F_TAB}5${F_TAB}5${F_TAB}${F_TAB}VO${F_TAB}Voice, < 10 ms latency and jitter"
  echo "${F_TAB}6${F_TAB}6${F_TAB}${F_TAB}IC${F_TAB}Internetwork control"
  echo "${F_TAB}7${F_TAB}7 (highest)${F_TAB}NC${F_TAB}Network control"

  echo "\n${C_ORANGERED1}This script may not work for all interfaces${NO_FORMAT}\n"

  exit 0
}

print_info() {
  echo "${F_BOLD}${C_YELLOW}INFO:${NO_FORMAT} ${1}"
}

print_error() {
  echo "${F_BOLD}${C_RED}ERROR:${NO_FORMAT} ${1}"
}

print_verbose() {
  if [ ! ${OPT_VERBOSE} -eq 0 ]; then
    echo "${1}"
  fi
}

print_yellow() {
  echo "${F_BOLD}${C_YELLOW}${1}${NO_FORMAT}" 
}

print_green() {
  echo "${F_BOLD}${C_LIME}${1}${NO_FORMAT}" 
}

print_acronym_notice() {
  if [ ! ${OPT_VERBOSE} -eq 0 ]; then
    echo "${F_BOLD}${C_YELLOW}NOTICE:${NO_FORMAT} ${F_BOLD}${C_BLUE}${1}${NO_FORMAT} has a PCP value of ${F_BOLD}${C_LIME}${2}${NO_FORMAT}."
  fi
}

pcp_to_string() {
  case ${1} in
    0) echo "Best Effort";;
    1) echo "Background";;
    2) echo "Excellent Effort";;
    3) echo "Critical Applications";;
    4) echo "Video";;
    5) echo "Voice";;
    6) echo "Internetwork Control";;
    7) echo "Network Control";;
  esac
}

set_interface() {
  if [ "${1}" = "" ]; then
    print_error "--interface cannot be empty"
    BAD_IFACE=1
  elif [ -d "/sys/class/net/${1}" ]; then
    IFACE=${1}
    print_verbose "${F_BOLD}${C_YELLOW}NOTICE:${NO_FORMAT} ${F_BOLD}${C_BLUE}${1}${NO_FORMAT} is a valid interface."
  else
    #echo "${F_BOLD}${C_RED}ERROR:${NO_FORMAT} Interface ${F_BOLD}${C_ORANGERED1}${1}${NO_FORMAT} does not exist."
    print_error "Interface ${F_BOLD}${C_ORANGERED1}${1}${NO_FORMAT} does not exist."
    BAD_IFACE=1
  fi
}

set_pcp() {
  case ${1} in
    "")
      # ${1} is empty
      print_error "--pcp cannot be empty"
      BAD_PCP=1
      ;;
    *[!0-9]*)
      # ${1} is a string
      case ${1} in
        bk|BK)
          PCP=1
          print_acronym_notice "${1}" "${PCP}"
          ;;
        be|BE)
          PCP=0
          print_acronym_notice "${1}" "${PCP}"
          ;;
        ee|EE)
          PCP=2
          print_acronym_notice "${1}" "${PCP}"
          ;;
        ca|CA)
          PCP=3
          print_acronym_notice "${1}" "${PCP}"
          ;;
        vi|VI)
          PCP=4
          print_acronym_notice "${1}" "${PCP}"
          ;;
        vo|VO)
          PCP=5
          print_acronym_notice "${1}" "${PCP}"
          ;;
        ic|IC)
          PCP=6
          print_acronym_notice "${1}" "${PCP}"
          ;;
        nc|NC)
          PCP=7
          print_acronym_notice "${1}" "${PCP}"
          ;;
        *)
          BAD_PCP=1
          #echo "${F_BOLD}${C_RED}ERROR:${NO_FORMAT} ${F_BOLD}${C_ORANGERED1}${1}${NO_FORMAT} is not a valid PCP acronym."
          print_error "${F_BOLD}${C_ORANGERED1}${1}${NO_FORMAT} is not a valid PCP acronym."
          ;;
      esac
      ;;
    *)
      # ${1} is a number
      if [ "${1}" -ge 0 ] && [ "${1}" -le 7 ]; then
        PCP=${1}
        print_verbose "${F_BOLD}${C_YELLOW}NOTICE:${NO_FORMAT} ${F_BOLD}${C_LIME}${1}${NO_FORMAT} is a valid PCP value."
      else
        #echo "${F_BOLD}${C_RED}ERROR:${NO_FORMAT} Priority must be between 0-7, you entered ${F_BOLD}${C_ORANGERED1}${1}${NO_FORMAT}."
        print_error "Priority must be between 0-7, you entered ${F_BOLD}${C_ORANGERED1}${1}${NO_FORMAT}."
        BAD_PCP=1
      fi
      ;;
  esac
}

check_exit() {
  if [ ! ${BAD_IFACE} -eq 0 ] && [ ! ${BAD_PCP} -eq 0 ]; then
    print_verbose "Exiting (code 3)"
    exit 3
  elif [ ! ${BAD_IFACE} -eq 0 ]; then
    print_verbose "Exiting (code 1)"
    exit 1
  elif [ ! ${BAD_PCP} -eq 0 ]; then
    print_verbose "Exiting (code 2)"
    exit 2
  fi
}

if [ ${OPT_HELP} -eq 1 ]; then get_help; fi


set_interface "${OPT_IFACE}"
set_pcp "${OPT_PCP}"

check_exit

PCP_STR=$(pcp_to_string "${PCP}")

echo "Setting ${F_BOLD}${C_BLUE}${IFACE}${NO_FORMAT} interface egress QoS priority to ${F_BOLD}${C_LIME}${PCP_STR}${NO_FORMAT}"

/usr/bin/ip link set "${IFACE}" type vlan \
	ingress 0:1 1:0 2:2 3:3 4:4 5:5 6:6 7:7 \
	egress 0:"${PCP}" 1:"${PCP}" 2:"${PCP}" 3:"${PCP}" 4:"${PCP}" 5:"${PCP}" 6:"${PCP}" 7:"${PCP}"

if [ ${OPT_CONFIRM} -eq 1 ]; then
  INGRESS=$(/usr/bin/ip -d link show "${IFACE}" | /usr/bin/grep "ingress" | sed 's/[[:space:]]*ingress-qos-map //g')
  EGRESS=$(/usr/bin/ip -d link show "${IFACE}" | /usr/bin/grep "egress" | sed 's/[[:space:]]*egress-qos-map //g')

  printf "\nVLAN QoS priority for ${F_BOLD}${C_BLUE}%s${NO_FORMAT}:\n" "${IFACE}"
  # echo "QoS priority for ${F_BOLD}${C_BLUE}${IFACE}${NO_FORMAT}:"
  printf "\t${F_BOLD}${C_YELLOW}Ingress QoS map${NO_FORMAT}: %s\n" "${INGRESS}"
  printf "\t${F_BOLD}${C_LIME}Egress QoS map${NO_FORMAT}: %s\n" "${EGRESS}"
fi