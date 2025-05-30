FROM ubuntu:latest

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update && apt-get install -y make pandoc lmodern texlive-fonts-recommended texlive-latex-extra wkhtmltopdf inotify-tools

ENV WORKDIR=/mdr
ENV XDG_RUNTIME_DIR=/tmp/runtime-root

WORKDIR ${WORKDIR}
COPY . ./

VOLUME ${WORKDIR}/output
VOLUME ${WORKDIR}/src

ENTRYPOINT make watch
