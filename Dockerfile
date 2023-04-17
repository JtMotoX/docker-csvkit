FROM python:alpine

ARG TARGETPLATFORM

RUN cd /usr/local/bin && \
	if [ "${TARGETPLATFORM}" == "linux/386" ] || [ "${TARGETPLATFORM}" = "linux/ppc64le" ]; then \
		export INSTALL_BUILD_BASE="true"; \
	fi && \
	if [ "${INSTALL_BUILD_BASE}" = "true" ]; then \
		apk add --no-cache build-base; \
	fi && \
	find . -maxdepth 1 -type f | cut -d/ -f2- >/tmp/bin-before.txt && \
	pip install csvkit && \
	find . -maxdepth 1 -type f | cut -d/ -f2- >/tmp/bin-after.txt && \
	if [ "${INSTALL_BUILD_BASE}" = "true" ]; then \
		apk del --no-cache build-base; \
	fi && \
	diff /tmp/bin-before.txt /tmp/bin-after.txt | grep -E '^\+' | grep -v -E '^\+\+\+' | sed -E 's/^\+//' >/supported-commands.txt && \
	rm -f /tmp/bin-*.txt

RUN apk add --no-cache jq

WORKDIR /data

CMD [ "sh", "-c", "echo 'Supported Commands:'; cat /supported-commands.txt | sed 's/^/\t/'" ]
