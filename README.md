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

### test/development environment

    luarocks install luna
    cd src
    lapis server

> webserver user needs write access to `path/to/db.sqlite` directory! sqlite has to create a lock-file.

## usage

> **you have to change the admin-key and secret in your configuration**

see `./tests/test.sh`

# features

* create RSA/EC keys
* create certificate signing requests
* create certificates
* supports multiple root CA's
* supports multiple sub CA's
* provide certificate chain

# clients

Currently there is only an [ansible client](https://github.com/fnordpipe/ansible-playbook/blob/master/library/ssl/laprassl.py).
