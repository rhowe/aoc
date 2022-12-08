#!/bin/bash -eu

set -eu

declare -i width=0 height=0 x=0 y=0 nextx=0 nexty=0 dir=1 measuredist=0 maxdist=0
declare -a world distances

while read -r line; do
  width=${#line}
  for ((i=0; i < width; i++)); do
    if [ "${line:i:1}" = "@" ]; then
      x=$i y=$height
      world[height*width+i]=.
    else
      world[height*width+i]=${line:i:1}
    fi
  done
  : $((height++))
done


for ((i=0; i < width * height; i++)); do
  distances[i]='.'
done

declare -ai dirdeltax dirdeltay
#           n s w e
dirdeltax=(0 0 -1 1)
dirdeltay=(-1 1 0 0)

y=$((y+1))
while : ; do
  screen=("${world[@]}")
  screen[y*height+x]=\@
  echo "$(
    clear
    oldifs=$IFS
    IFS=
    for ((row=0; row < height; row++)); do
      echo "${screen[*]:row*width:width}"
    done
    IFS=$oldifs
  )"

#  currdist=${distances[y*width+x]}
#  if [ "$measuredist" -eq 1 ] && [ "${distances[nexty*width+nextx]}" == '.' ]; then
#    distances[nexty*width+nextx]=$((distances[y*width+x]+1))
#    if [ "${distances[nexty*width+nextx]}" -gt $maxdist ]; then
#      maxdist=${distances[nexty*width+nextx]}
#    fi
#  fi

  case $dir in
    1) testdirs=(4 1 3 2) ;;
    2) testdirs=(3 2 4 1) ;;
    3) testdirs=(1 3 2 4) ;;
    4) testdirs=(2 4 1 3) ;;
  esac

  for move in "${testdirs[@]}"; do
    nextx=$((x + dirdeltax[move-1])) nexty=$((y + dirdeltay[move-1]))
    case "${world[nexty*width+nextx]}" in
      '#') ;;
      [A-Z]) ;;
      *)
        dir=$move
        break
        ;;
    esac
  done
  x=$nextx y=$nexty
done
