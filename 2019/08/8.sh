#!/bin/bash

set -eu
set -o pipefail

input=$(<"$1")
layers=()
width=$2
height=$3
area=$((width * height))
areapixels=($(seq 0 "$((area - 1))"))

image=($(yes 2 | head -n "$area"))

for offset in $(seq 0 "$area" "${#input}"); do
  layer="${input:$offset:$area}"
  for px in "${areapixels[@]}"; do
    layerpx=${layer:$px:1}
    if [ ${image[$px]} -eq 2 ]; then
      image[$px]=$layerpx
    fi
  done
done

for row in $(seq 0 "$((height - 1))"); do
  for col in $(seq 0 "$((width - 1))"); do
    idx=$((row * width + col))
    echo -n ${image[$idx]}
  done
  echo
done
echo
