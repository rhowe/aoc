#!/bin/bash

set -u
set -o pipefail

inbounds() {
  local x=$1 y=$2
  return $((x < 0 || x >= cols || y < 0 || y >= rows ? 1 : 0))
}

abs() {
  num=$1

  echo $((num < 0 ? num * -1 : num))
}

coprime() {
  local num1=$(abs $1) num2=$(abs $2)
  local div
  [ $num1 -ne 0 ] || return $((num2 <= 1 ? 0 : 1))
  [ $num2 -ne 0 ] || return $((num1 <= 1 ? 0 : 1))
  for (( div=2; div <= num1; div++ )); do
    if [ "$((num1 % div))" -eq 0 -a "$((num2 % div))" -eq 0 ]; then return 1; fi
  done
  return 0
}

printgrid() {
  local map=$1 obsx=$2 obsy=$3 tstx=$4 tsty=$5
  local observer=$((obsy*cols+obsx)) target=$((tsty*cols+tstx))
  map=${map:0:observer}X${map:observer+1} 
  map=${map:0:target}'*'${map:target+1} 
  local display=$(tput cup 0 0)
  for idx in $(seq 0 $cols "$(("${#map}" - 1))"); do
    display="$display
${map:idx:cols}"
  done
  echo "$display"
}

readarray -t grid < "$1"

cols=${#grid[0]}
rows="${#grid[@]}"

oldifs=$IFS
IFS= allpos="${grid[*]}"
IFS=$oldifs

counts=($(yes 0 | head -n "${#allpos}")) || :

[ -z "${GUI:-}" ] || tput clear
max=0
maxcoords=
for (( y=0; y < rows; y++ )); do
  for (( x=0; x < cols; x++ )); do
    [ "${allpos:y*cols+x:1}" == "#" ] || continue
    seen=0
     for (( ty=0; ty < rows; ty++ )); do
       for (( tx=0 ; tx < cols ; tx++ )); do
        dx=$((tx - x)); dy=$((ty - y))
        coprime $dx $dy || continue
        for (( testx=x+dx, testy=y+dy ; testx < 0 || testx >= cols || testy < 0 || testy >= rows ? 0 : 1; testx+=dx, testy+=dy )) ; do
          [ -z "${GUI:-}" ] || printgrid $allpos $x $y $testx $testy
          if [ "${allpos:testy*rows+testx:1}" == "#" ]; then
            ((seen++))
            break
          fi
        done
      done
    done
    [ "$seen" -le "$max" ] || { max=$((seen -1)); maxcoords=$x,$y; }
  done
done

echo $maxcoords: $max
