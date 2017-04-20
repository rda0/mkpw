# mkpw

## Description

Generates random secure passwords suitable for linux logins,
prints out the creatext password and the corresponding `sha-512` hash. 
The hash includes a random salt and `10000` rounds.
All randomness is generated using `/dev/urandom`.

## Requirements

- `mkpasswd`

`mkpasswd` is provided by the package `whois`,
on debian based distributions run the following command to install it:

```sh
apt install whois
```

## Usage

```
Usage: mkpw [option] [length [amount]]

    Generates strong passwords suitable for linux logins.

Output: <cleartext-password>   <hashed-password>

Options:

    length
        Password length (default=32)
    amount
        Amount of passwords generated (default=1)
    -g, --graph
        Use printable characters only (default)
    -a, --alnum
        Use alphanumeric characters only
    -p, --print
        Use printable characters including space
    -c, --custom
        Use custom character set (ETH Zurich): -#,./:=?@[]^{}~a-zA-Z0-9
    -d, --default
        Use default character set: \-`_~!@#$%^&*()+={}[]|;:"<>,.?/a-zA-Z0-9'
    -h, --help
        Print this help message
    -m, --method TYPE
        Compute the password using the TYPE method.
        Possible values for TYPE:
        des      standard 56 bit DES-based crypt(3)
        md5      MD5
        sha-256  SHA-256
        sha-512  SHA-512
```
