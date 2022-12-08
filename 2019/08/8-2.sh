#!/bin/bash

set -eu
set -o pipefail

input=$1
width=$2
height=$3

cd "$(dirname "$0")"

rm -rf tmp
mkdir tmp

cd tmp

split -b "$((width * height))" "../$1"
sed -i 's/./&\n/g' *
paste -d '' *|sed -e 's/^2*\(.\).*/\1/' |xargs -n "$width" |tr -d \  | tr '[01]' '[ #]'
