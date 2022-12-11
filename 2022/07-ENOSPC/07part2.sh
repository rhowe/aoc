#!/bin/bash

set -eu

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

freespace=70000000
for sz in $(find . -type f -print0|xargs -0 stat -c %s); do
		  freespace=$((freespace - sz))
done
needed=$((30000000 - freespace))
smallest=70000000
for dir in $(find . -type d); do
		  dirsize=0
		  for sz in $(find "$dir" -type f -print0|xargs -0 stat -c %s); do
					 dirsize=$((dirsize + sz))
		  done
		  if [[ $dirsize -ge $needed && $dirsize -lt $smallest ]]; then
					 smallest=$((dirsize))
		  fi
done
echo $smallest
