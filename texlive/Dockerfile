# syntax=docker/dockerfile:1
#
# Full TeX Live on top of the Overleaf Extended CE image.
#
# upstream's Dockerfile-base installs scheme-basic only (latexmk, texcount,
# synctex, etoolbox, xetex), so almost any real document fails to compile with
# "File `xxx.sty' not found". This layer installs scheme-full, the same thing
# Overleaf's own docs tell self-hosters to do. It is a separate layer so a
# TeX Live refresh never forces the application to be rebuilt.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG TEXLIVE_MIRROR=https://mirror.ox.ac.uk/sites/ctan.org/systems/texlive/tlnet

RUN tlmgr option repository ${TEXLIVE_MIRROR} \
 && tlmgr install scheme-full \
 && tlmgr path add
