#!/bin/bash

## hash algorithm variables

# character set to use for passwords
passwd_charset='_-`~!@#$%^&*()+={}[]|\;:'\''"<>,.?/a-zA-Z0-9'
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
  echo "Generates strong passwords suitable for linux logins."
  echo -e "\nUsage: ${0} [length [amount]]\n" 
  echo "- length: password length (default=32)"
  echo "- amount: amount of passwords generated (default=1)"
  echo -e "\nOutput: <cleartext-password>   <hashed-password>\n"
}

print_requirement() {
  echo "Error: mkpasswd is not installed. To install run:"
  echo -e "\n  apt install whois\n"
}

print_passwd_insecure() {
  echo "Warning: Using a too short password is insecure (recommended length: >= 16)"
}

print_passwd_too_long() {
  echo "Error: Password is too long (maximum length = 86)"
}

if [ "$(which mkpasswd)" != "/usr/bin/mkpasswd" ]; then
  print_requirement
  exit 1
fi

if [ "$#" -lt 0 ] || [ "$#" -gt 2 ]; then
  print_usage
  exit 1
fi

if [ "$#" -ge 1 ]; then
  if [ "${1}" -lt "${passwd_min}" ]; then
    print_passwd_insecure
  elif [ "${1}" -gt "${passwd_max}" ]; then
    print_passwd_too_long
    exit 1
  fi
  passwd_len="${1}"
fi

if [ "$#" -eq 2 ]; then
  amount="${2}"
fi

while [ $counter -lt $amount ]; do
  password=$(< /dev/urandom tr -dc ${passwd_charset} | head -c"${passwd_len}"; echo)
  salt=$(< /dev/urandom tr -dc ${salt_charset} | head -c"${salt_len}")
  echo -n ${password}
  echo -n '   '
  /usr/bin/mkpasswd -m ${hash_algorithm} -R "${rounds}" ${password} ${salt}
  let counter+=1
done
