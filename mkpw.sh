#!/bin/bash

# Author: Sven Mäder
# Github: https://github.com/rda0/mkpw/blob/master/mkpw.sh

## hash algorithm variables

# character sets to use for passwords
# escaping: '\\' --> '\', '\-' --> '-'
charset_g='[:graph:]'
charset_a='[:alnum:]'
charset_p='[:print:]'
charset_c='\-#,./:=?@[]^{}~a-zA-Z0-9'
charset_d='\\\-`_~!@#$%^&*()+={}[]|;:"<>,.?/a-zA-Z0-9'\'
passwd_charset=${charset_g}
# character set to use for salts (allowed charset = ./a-zA-Z0-9 )
salt_charset='./a-zA-Z0-9'
# hashing algorithm used (use: sha-256 | sha-512)
hash_algorithm='sha-512'
# maximum password length (sha-256_max=43, sha-512_max=86)
passwd_max=86
# minimum password length not showing insecure warning
passwd_min=12
# salt length (min=8, max=16)
salt_len=16
# number of rounds the password is hashed (min=1'000, max=999'999'999)
rounds=10000

## loop variables

counter=0
amount=1
passwd_len=32

print_usage() { 
  echo -e "Usage: ${0} [option] [length [amount]]" 
  echo -e "\n    Generates strong passwords suitable for linux logins."
  echo -e "\nOutput: <cleartext-password>   <hashed-password>"
  echo -e "\nOptions:\n"
  echo "    length"
  echo "        password length (default=32)"
  echo "    amount"
  echo "        amount of passwords generated (default=1)"
  echo "    -g, --graph"
  echo "        use printable characters only (default)"
  echo "    -a, --alnum"
  echo "        use alphanumeric characters only"
  echo "    -p, --print"
  echo "        use printable characters including space"
  echo "    -c, --custom"
  echo "        use custom character set (ETH Zurich): $(echo -n ${charset_c} | sed 's/\\-/-/' | sed 's/\\\\/\\/')"
  echo "    -d, --default"
  echo "        use default character set: $(echo -n ${charset_d} | sed 's/\\-/-/' | sed 's/\\\\/\\/')"
  echo "    -h, --help"
  echo "        print this help message"
}

check_opt() {
    if [ "${opt}" -eq 1 ]; then
        echo -e "error: Invalid combination of options\n" >&2
        print_usage
        exit 1
    fi
}

check_num() {
    re='^[0-9]+$'
    if ! [[ ${1} =~ $re ]] ; then
        echo -e "error: Wrong option or not a number\n" >&2
        print_usage
        exit 1
    fi
}

print_requirement() {
  echo -e "error: mkpasswd is not installed. To install run:"
  echo -e "\n    apt install whois\n"
}

print_passwd_insecure() {
  echo -e "warning: Using a too short password is insecure (recommended length: >= 16)\n"
}

print_passwd_too_long() {
  echo -e "error: Password is too long (maximum length = 86)"
}

if [ "$(which mkpasswd)" != "/usr/bin/mkpasswd" ]; then
  print_requirement
  exit 1
fi

if [ "$#" -lt 0 ] || [ "$#" -gt 3 ]; then
  print_usage
  exit 1
fi

opt=0
num=0

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
        print_usage
        exit 1
        ;;
    -g|--graph)
        check_opt
        passwd_charset=${charset_g}
        opt=1
        ;;
    -a|--alnum)
        check_opt
        passwd_charset=${charset_a}
        opt=1
        ;;
    -p|--print)
        check_opt
        passwd_charset=${charset_p}
        opt=1
        ;;
    -c|--custom)
        check_opt
        passwd_charset=${charset_c}
        opt=1
        ;;
    -d|--default)
        check_opt
        passwd_charset=${charset_d}
        opt=1
        ;;
    *)
        if [ ${num} -ge 2 ]; then
            echo "Error: too many arguments" >&2
            print_usage
            exit 1
        fi
        check_num ${1}
        if [ ${num} -eq 0 ]; then
            passwd_len="${1}"
        fi
        if [ ${num} -eq 1 ]; then
            amount="${1}"
        fi
        ((num++))
        ;;
esac
shift # past argument or value
done

if [ "${passwd_len}" -lt "${passwd_min}" ]; then
  print_passwd_insecure
elif [ "${passwd_len}" -gt "${passwd_max}" ]; then
  print_passwd_too_long
  exit 1
fi

while [ $counter -lt $amount ]; do
  passwd=$(< /dev/urandom tr -dc "${passwd_charset}" | head -c"${passwd_len}")
  salt=$(< /dev/urandom tr -dc "${salt_charset}" | head -c"${salt_len}")
  echo -n "${passwd}"
  echo -n '   '
  echo -n "${passwd}" | /usr/bin/mkpasswd -s -m "${hash_algorithm}" -R "${rounds}" -S "${salt}"
  let counter+=1
done
