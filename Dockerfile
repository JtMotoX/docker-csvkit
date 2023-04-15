FROM python:alpine as base_image

FROM base_image as trimmed_image
WORKDIR /usr/local/bin
RUN find . -maxdepth 1 -type f | cut -d/ -f2- >/tmp/bin-before.txt && \
	pip install csvkit && \
	find . -maxdepth 1 -type f | cut -d/ -f2- >/tmp/bin-after.txt && \
	diff /tmp/bin-before.txt /tmp/bin-after.txt | grep -E '^\+' | grep -v -E '^\+\+\+' | sed -E 's/^\+//' >/supported-commands.txt && \
	rm -f /tmp/bin-*.txt
RUN rm -rf \
		/usr/local/lib/python3.11/site-packages/pip \
		/usr/local/lib/python3.11/ensurepip \
		/usr/local/lib/python3.11/pydoc_data \
		&& \
	echo "Finished trimming base image"

FROM scratch as final_image
COPY --from=trimmed_image / /
RUN apk add --no-cache jq
WORKDIR /data
CMD [ "sh", "-c", "echo 'Supported Commands:'; cat /supported-commands.txt | sed 's/^/\t/'" ]
