#!/usr/bin/env bash

pdf="$1"
width="${w:-80}"
height="${h:-24}"

tmp="$(mktemp --suffix=.png)"

trap 'rm -f "$tmp"' EXIT

pdftoppm \
    -png \
    -singlefile \
    -f 1 \
    -l 1 \
    "$pdf" \
    "${tmp%.png}"

TERM=xterm-256color chafa \
    --probe=off \
    --passthrough=none \
    -f symbols \
    -c full \
    --animate=off \
    --relative=off \
    --optimize=0 \
    --size="${width}x${height}" \
    "$tmp"
