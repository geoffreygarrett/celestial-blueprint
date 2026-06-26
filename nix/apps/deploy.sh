#!/bin/sh -e
# Deploy flake nodes via deploy-rs (see flake.nix deploy.nodes).
exec nix run github:serokell/deploy-rs -- . "$@"
