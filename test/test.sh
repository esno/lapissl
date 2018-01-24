#!/bin/sh

echo "create profile"
curl \
  -H "Content-Type: application/json" \
  -H "X-Laprassl-Auth: 89137378-3b35-4a81-918d-8852cb4ce2d1" \
  -X POST  \
  -d @./test/data/mkrootca.json \
 'http://127.0.0.1:8080/v1/profile' && echo
