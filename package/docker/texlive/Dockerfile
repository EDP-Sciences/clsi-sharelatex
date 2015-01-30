FROM debian:jessie
MAINTAINER Xavier Trochu <xavier.trochu@edpsciences.org>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -q -y
RUN apt-get dist-upgrade --no-install-recommends -q -y
RUN apt-get install --no-install-recommends -q -y texlive-base texlive-latex-base texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended texlive-science texlive-lang-cyrillic texlive-lang-french texlive-lang-greek latexmk

ADD texmf /usr/local/share/texmf
RUN mktexlsr /usr/local/share/texmf

RUN useradd -m texlive -u 500

USER texlive
VOLUME /source
WORKDIR /source

ENTRYPOINT ["/usr/bin/latexmk"]

CMD ["-pdf","output.tex"]
