#!/bin/bash

set -e

declare -ai input basepattern

read -r inputstr < "${1:?}"

echo "Duplicating input 10,000 times"
for ((j=0; j < 10000; j++)); do
  for ((i=0; i < ${#inputstr}; i++)); do
    input+=("${inputstr:$i:1}")
  done
done

basepattern=(0 1 0 -1)

declare -n posvar negvar

echo "Calculating ${#input[@]} sets of coefficients"

for ((i=0; i < ${#input[@]}; i++)); do
  declare -i i1=$((i+1))
  posidxs= negidxs=
  for ((j=0; j < ${#input[@]}; j++)); do
    case "${basepattern[((j+1) / i1) % 4]}" in
      1) posidxs+=" $j" ;;
      -1) negidxs+=" $j" ;;
    esac
  done
  declare -n posvar=posidx$i negvar=negidx$i
  posvar=$posidxs negvar=$negidxs
  if (( i % 10 == 0 )); then
    echo "done $i"
  fi
done

results=()
declare -i ans=0

for phase in {1..100}; do
  for ((i=0; i < "${#input[@]}"; i++)); do
    declare -n posvar=posidx$i negvar=negidx$i
    ans=0
    for idx in $posvar; do
      ans+=input[idx]
    done
    for idx in $negvar; do
      ans+=input[idx]*-1
    done
    results[i]=${ans: -1:1}
  done

  echo "After $phase phases: ${results[@]}"
  input=("${results[@]}")
done
