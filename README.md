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

    luarocks install luna
    cd src
    lapis server

### bootstrap

For initial installation use `bootstrap.lua` to create rootca, subca and server certificate then start nginx.

# features

* create RSA/ECDSA keys
* create certificate signing requests
* create certificates
* supports multiple root CA's
* supports multiple sub CA's
* provide certificate chain

# endpoints

## /v1/key

Generates a keypair

    curl -H "Content-type: application/json" \
      -d '{"keytype": "ec"}' \
      'http://127.0.0.1:8080/v1/key' && echo

## /v1/x509/ca

Generates ca chain

    curl -H "Content-type: application/json" \
      -d '{"crt": "crt-in-pem-format"}' \
      'http://127.0.0.1:8080/v1/x509/ca' && echo

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

# clients

Currently there is only an [ansible client](https://github.com/fnordpipe/ansible-playbook/blob/master/library/ssl/laprassl.py).
