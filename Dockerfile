FROM python:alpine

WORKDIR /usr/local/bin
RUN find . -maxdepth 1 -type f | cut -d/ -f2- >/tmp/bin-before.txt && \
	pip install csvkit && \
	find . -maxdepth 1 -type f | cut -d/ -f2- >/tmp/bin-after.txt && \
	diff /tmp/bin-before.txt /tmp/bin-after.txt | grep -E '^\+' | grep -v -E '^\+\+\+' | sed -E 's/^\+//' >/supported-commands.txt && \
	rm -f /tmp/bin-*.txt

RUN apk add --no-cache jq

WORKDIR /data

CMD [ "sh", "-c", "echo 'Supported Commands:'; cat /supported-commands.txt | sed 's/^/\t/'" ]
