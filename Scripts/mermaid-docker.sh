#!/bin/bash
/usr/local/bin/docker run --rm -v "$(pwd)":/data minlag/mermaid-cli "$@"
