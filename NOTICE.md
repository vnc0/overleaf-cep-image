# Notices

These images bundle third-party software. This file lists the main
components; it is not a complete bill of materials.

| Component | Licence | Source |
|---|---|---|
| Overleaf Community Edition and the Extended CE modules (yu-i-i/overleaf-cep) | GNU AGPL-3.0 | https://github.com/yu-i-i/overleaf-cep (commit pinned in `upstream.env`) |
| Overleaf git-bridge | GNU AGPL-3.0 (built from the same commit) | `services/git-bridge` in the repository above |
| TeX Live (`scheme-full`) | A collection of free-software licences, per package | https://tug.org/texlive/ |
| Ubuntu / phusion baseimage, Node.js, nginx, git and other distribution packages | Their respective licences | Distribution archives |
| Eclipse Temurin JRE (git-bridge image) | GPLv2 with Classpath Exception | https://adoptium.net/ |
| envsubst (a8m/envsubst, in the git-bridge image) | MIT | https://github.com/a8m/envsubst |

## AGPL-3.0 source offer

The images contain Overleaf unmodified. The source of the running software is
the upstream commit recorded in the image label `com.overleaf.ce.revision`,
available from https://github.com/yu-i-i/overleaf-cep. The build recipe is
this repository at the revision in the image tag. If a patch is ever applied
it will be committed here.

## Trademarks

"Overleaf" and the Overleaf logo are trademarks of their owner. This project
is unofficial and is not affiliated with, sponsored by, or endorsed by
Overleaf or Digital Science.
