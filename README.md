# mkpw

## Description

Generates random secure passwords suitable for linux logins,
prints out the creatext password and the corresponding `sha-512` hash.  
The hash includes a random salt and `10000` rounds.  
All randomness is generated using `/dev/urandom`.

## Requirements

- `mkpasswd`

`mkpasswd` is provided by the package `whois`, on debian based distributions run the following command to install it:

```sh
# apt install whois
```

## Usage

```
Usage: ./mkpw.sh [length [amount]]

- length: password length (default=32)
- amount: amount of passwords generated (default=1)

Output: <cleartext-password>   <hashed-password>
```
