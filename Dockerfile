FROM python:alpine as base_image

ARG TARGETPLATFORM

ENV VENV_DIR="/venv"
ENV PATH="${VENV_DIR}/bin:$PATH"

###

FROM base_image as builder_image

RUN if [ "${TARGETPLATFORM}" == "linux/386" ] || [ "${TARGETPLATFORM}" = "linux/ppc64le" ]; then apk add --no-cache build-base; fi
RUN python3 -m venv "${VENV_DIR}"
RUN find "${VENV_DIR}/bin" -maxdepth 1 -type f -exec basename {} \; | cut -d/ -f2- >/tmp/bin-before.txt
RUN pip install csvkit
RUN find "${VENV_DIR}/bin" -maxdepth 1 -type f -exec basename {} \; | cut -d/ -f2- >/tmp/bin-after.txt
RUN apk del --no-cache build-base
RUN pip uninstall -y pip setuptools
RUN find "${VENV_DIR}/bin" -name '*ctivate*' -type f -maxdepth 1 -exec rm -f {} \;
RUN diff /tmp/bin-before.txt /tmp/bin-after.txt | grep -E '^\+' | grep -v -E '^\+\+\+' | sed -E 's/^\+//' | grep 'csv' | sort >/supported-commands.txt
RUN rm -f /tmp/bin-*.txt

###

FROM base_image as final_image
RUN apk add --no-cache jq
COPY --from=builder_image "${VENV_DIR}" "${VENV_DIR}"
COPY --from=builder_image /supported-commands.txt /supported-commands.txt
RUN in2csv --version
WORKDIR /data
CMD [ "sh", "-c", "echo 'Supported Commands:'; { cat /supported-commands.txt && echo 'jq'; } | sed 's/^/\t/'" ]
