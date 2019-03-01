#!/bin/bash

# File:        mkpw.sh
# Author:      Sven Mäder <maeder@phys.ethz.ch>, ETH Zurich, ISG D-PHYS
# Date:        2019-03-01
# Github:      https://github.com/rda0/mkpw/blob/master/mkpw.sh
#
# Description: Generates random secure passwords suitable for linux logins,
#              prints out the creatext password and the corresponding
#              `sha-512` hash. The hash includes a random salt and 10000
#              rounds. All randomness is generated using `/dev/urandom`.
#              Example: tty=/dev/ttyS will match all logins via a serial
#                       console like /dev/ttyS0, /dev/ttyS1, etc.
#
# Requirement: `mkpasswd`, provided by the package whois, on debian based
#              distributions run the following command to install it:
#
#              apt install whois
#
# Copyright 2017 Sven Mäder
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

## hash algorithm variables

# character sets to use for passwords
# escaping: '\\' --> '\', '\-' --> '-'
charset_g='[:graph:]'
charset_a='[:alnum:]'
charset_p='[:print:]'
charset_c='\-#,./:=?@[]^{}~a-zA-Z0-9'
charset_d='\\\-`_~!@#$%^&*()+={}[]|;:"<>,.?/a-zA-Z0-9'\'
charset_q='\\\-_~!@#$%^&*()+={}[]|;:<>,.?/a-zA-Z0-9'
# default charset
passwd_charset=${charset_g}
# character set to use for salts (allowed charset = ./a-zA-Z0-9 )
salt_charset='./a-zA-Z0-9'
# hashing algorithm used (use: sha-256 | sha-512)
hash_algorithm='sha-512'
# maximum password length
passwd_max_des=8
# minimum password length not showing insecure warning
passwd_min=12
# salt length (sha: min=8, max=16,  md5: 8)
salt_len_sha=16
salt_len_md5=8
salt_len_des=2
# default salt len
salt_len=${salt_len_sha}
# number of rounds the password is hashed (min=1'000, max=999'999'999)
rounds=10000
# possible hashing algorithms
methods='sha-512 sha-256 md5 des'
# default method
method='sha-512'

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
  echo "        Password length (default=32)"
  echo "    amount"
  echo "        Amount of passwords generated (default=1)"
  echo "    -g, --graph"
  echo "        Use printable characters only (default)"
  echo "    -a, --alnum"
  echo "        Use alphanumeric characters only"
  echo "    -p, --print"
  echo "        Use printable characters including space"
  echo "    -c, --custom"
  echo "        Use custom character set (ETH Zurich): $(echo -n ${charset_c} | sed 's/\\-/-/' | sed 's/\\\\/\\/')"
  echo "    -d, --default"
  echo "        Use default character set: $(echo -n ${charset_d} | sed 's/\\-/-/' | sed 's/\\\\/\\/')"
  echo "    -q, --no-quotes"
  echo "        Use default character set: $(echo -n ${charset_q} | sed 's/\\-/-/' | sed 's/\\\\/\\/')"
  echo "    -h, --help"
  echo "        Print this help message"
  echo "    -m, --method TYPE"
  echo "        Compute the password using the TYPE method."
  echo "        Possible values for TYPE:"
  echo "        sha-512  SHA-512  (default)"
  echo "        sha-256  SHA-256"
  echo "        md5      MD5"
  echo "        des      standard 56 bit DES-based crypt(3)"
  echo "    -r, --rounds ROUNDS"
  echo "        Compute the password using ROUNDS number of rounds (default=10000)."
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
  echo -e "error: Password is too long (maximum length = ${passwd_max})"
}

if [ "$(which mkpasswd)" != "/usr/bin/mkpasswd" ]; then
  print_requirement
  exit 1
fi

if [ "$#" -lt 0 ] || [ "$#" -gt 7 ]; then
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
    -q|--no-quotes)
        check_opt
        passwd_charset=${charset_q}
        opt=1
        ;;
    -m|--method)
        valid_method=0
        for i in ${methods};
        do
            if [ "${i}" == "${2}" ]; then
                valid_method=1
            fi
        done
        if [ "${valid_method}" -eq 1 ]; then
            method=${2}
            shift
        else
            echo -e "Error: Invalid method\n" >&2
            print_usage
            exit 1
        fi
        ;;
    -r|--rounds)
        valid_rounds='[0-9]'
        if [[ ${2} =~ ${valid_rounds} ]] && [ ${2} -ge 1000 ] && [ ${2} -le 999999999 ]; then
            rounds=${2}
            shift
        else
            echo -e "Error: Invalid value for rounds\n" >&2
            echo -e "Provide a numeric value between 1000 and 999999999\n" >&2
            print_usage
            exit 1
        fi
        ;;
    *)
        if [ ${num} -ge 2 ]; then
            echo -e "Error: Too many arguments\n" >&2
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

case ${method} in
    sha-512)
        salt_len=${salt_len_sha}
        ;;
    sha-256)
        salt_len=${salt_len_sha}
        ;;
    md5)
        salt_len=${salt_len_md5}
        ;;
    des)
        salt_len=${salt_len_des}
        passwd_max=${passwd_max_des}
        ;;
esac

if [ "${passwd_len}" -lt "${passwd_min}" ]; then
  print_passwd_insecure
fi
if [ ! -z "${passwd_max}" ] && [ "${passwd_len}" -gt "${passwd_max}" ]; then
  print_passwd_too_long
  exit 1
fi

hash_algorithm=${method}

while [ $counter -lt $amount ]; do
  passwd=$(head -c"${passwd_len}" < <(LC_CTYPE=C tr -dc "${passwd_charset}" < /dev/urandom))
  salt=$(head -c"${salt_len}" < <(LC_CTYPE=C tr -dc "${salt_charset}" < /dev/urandom))
  echo -n "${passwd}"
  echo -n '   '
  echo -n "${passwd}" | /usr/bin/mkpasswd -s -m "${hash_algorithm}" -R "${rounds}" -S "${salt}"
  let counter+=1
done
