# laprassl

An API which aimes to be a full-featured public key infrastructure.
It's designed to be as simple as possible in packaging as well as in usage.
There are many use-cases for an application which provides certificates signed by a
ca which is under your control.

e.g.:
  - provisioning of many servers
  - provisioning of embedded devices

It's based on the [lapis webframework](http://leafo.net/lapis/) and the [luaossl](https://github.com/wahern/luaossl) openssl bindings.

## installation

Currently there is no way to add subjectKeyIdentifier and authorityKeyIdentifier via luaossl.
Unfortunatelly this X509v3 extensions are necessary for valid CA certificates therefore I'm shipping
a [customized binding](https://github.com/fnordpipe/luaossl). So you have to install this one instead of the official one.
I will skip back to the official bindings as soon as PR [#88](https://github.com/wahern/luaossl/pull/88) or [#89](https://github.com/wahern/luaossl/pull/89) is merged.

1. install lua
2. install lapis
3. install luaossl
4. clone this repo
5. change config in src/app.lua
6. start nginx (with lua module)

### install luaossl

    git clone https://github.com/fnordpipe/luaossl && cd luaossl
    make all5.1
    make DESTDIR="~/lua" install5.1

    export LUA_PATH='~/lua/usr/local/share/lua/5.1/?.so;${LUA_PATH}'
    export LUA_CPATH='~/lua/usr/local/lib/lua/5.1/?.so;${LUA_CPATH}'

# features

* create RSA/ECDSA keys
* create certificate signing requests
* create certificates
* supports multiple root CA's
* supports multiple sub CA's

# endpoints

## /v1/key

Generates a keypair

    curl -H "Content-type: application/json" \
      -d '{"keytype": "ec"}' \
      'http://127.0.0.1:8080/v1/x509/csr' && echo

## /v1/x509/csr

Generates a certificate signing request

    curl -H "Content-type: application/json" \
      -d '{"cn": "www.example.org", "o": ["example corporation", "example corp."], "key": "key-in-pem-format"}' \
      'http://127.0.0.1:8080/v1/x509/csr' && echo

## /v1/x509/crt

Generates a signed certificate. Key parameter is only required when the result should be a self-signed certificate

    curl -H "Content-type: application/json" \
      -d '{"authkey": "profile-specific-key", "profile": "server", "csr": "csr-in-pem-format", "key": "key-in-pem-format"}' \
      'http://127.0.0.1:8080/v1/x509/crt' && echo
