#!/bin/sh

set -e

echo "create profile"
curl \
  -H "Content-Type: application/json" \
  -H "X-Laprassl-Auth: 89137378-3b35-4a81-918d-8852cb4ce2d1" \
  -X POST \
  -d @./tests/data/mkrootca.json \
 'http://127.0.0.1:8080/v1/profile' && echo

echo "create rsa key"
curl \
  -H "Content-Type: application/json" \
  -X POST \
  -d @./tests/data/mkrsakey.json \
 'http://127.0.0.1:8080/v1/x509/key' && echo

echo "create ec key"
curl \
  -H "Content-Type: application/json" \
  -X POST \
  -d @./tests/data/mkeckey.json \
 'http://127.0.0.1:8080/v1/x509/key' && echo
