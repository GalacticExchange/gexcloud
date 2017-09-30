#!/usr/bin/env bash

cp /vagrant/files/nginx-jwt/nginx-jwt.lua /home/vagrant/nginx-jwt/

sudo /etc/init.d/nginx restart

#curl -i http://devwebproxy.gex:9000 -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6ImdleCIsInVzZXJfaWQiOiIxIiwiY2x1c3Rlcl9pZCI6IjEwNyIsImlhdCI6MTQ1MDExOTQ3NH0.srp0W0YsjvQMmfIQl0-Lu8mXd280AfzMtQEJxJS0VAM'
curl -i http://devwebproxy.gex:5082 -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6ImRldjMwIiwidXNlcl9pZCI6MTMwLCJleHAiOjE0NTI3MTc4MTJ9.v8KTWUpqhqhbx_8CE_Dw4ieAu-bBcua8-58zrcZHoAI'
