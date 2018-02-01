# foo

docs:
	raml2html --theme raml2html-kaa-theme ./doc/v1.raml > ./doc/v1.html

test:
	sh ./tests/test.sh

clean:
	rm -rf src/nginx.conf.compiled \
		src/client_body_temp \
		src/fastcgi_temp \
		src/logs \
		src/proxy_temp \
		src/scgi_temp \
		src/uwsgi_temp
