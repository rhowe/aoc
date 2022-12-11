#!/bin/bash

set -e

input=$(<input)
input=${input//$ /}
workdir="$(mktemp -d)"
cd "$workdir"
cleanup() {
		  rm -rf "$workdir"
}
trap cleanup EXIT

(
while IFS= read -r line; do
		  case "$line" in
					 dir|'cd /')
								;;
					 'cd ..')
								echo "cd .."
								;;
					 'cd '*) d="${line:3}"
								echo "mkdir $d && cd $d"
								;;
					 [0-9]*) read -r size file <<<"$line"
					 echo "dd if=/dev/zero of=$file bs=$size count=1 &> /dev/null"
					 ;;
		  esac
done <<<"$input"
)|bash

cd "$workdir"

total=0
for dir in $(find . -type d); do
		  dirsize=0
		  for sz in $(find "$dir" -type f -print0|xargs -0 stat -c %s); do
					 dirsize=$((dirsize + sz))
		  done
		  if [[ "$dirsize" -le 100000 ]]; then
					 total=$((total + dirsize))
		  fi
done
echo $total
