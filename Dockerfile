FROM docker.pkg.github.com/jeff-tian/latex-docker/texlive-full:latest

COPY \
  LICENSE \
  README.md \
  entrypoint.sh \
  /root/

ENTRYPOINT ["/root/entrypoint.sh"]

expose 3000
