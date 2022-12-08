#!/bin/bash

set -eu

declare -A cache

read -r inputstr < "${1:?}"

generate_coefficients() {
  local -ai coeff basepattern=(0 1 0 -1)
  local -i i j size=$1
  for ((i=0; i < size; i++)); do
    for ((j=0; j < size; j++)); do
      local -n coeffvar=coeff_${i}_${j}
      coeffvar=${basepattern[((j+1) / (i+1)) % 4]}
    done
  done
}

prime_cache() {
  local input="$inputstr"
  local -i i
  for ((i=0; i < ${#input}; i++)); do
    cache[0_$i]=${input:$i:1}
  done
}

generate_coefficients "${#inputstr}"

prime_cache "$inputstr"

fft() {
  local -i phase=$1 idx=$2 i
  local -i prevphase=$((phase-1))
  local coeffvar
  local result=0
  for ((i=0; i < ${#inputstr}; i++)); do
    cachekey=${prevphase}_$i
    coeffvar=coeff_${idx}_${i}
    coefficient=${!coeffvar}
    if ((coefficient != 0)); then
      previous=${cache[${prevphase}_${i}]:=$(fft "$prevphase" "$i")}
      result=$((result + coefficient * previous))
    fi
  done
  echo "${result: -1:1}"
}

p=8
echo \
  "${cache[${p}_0]:=$(fft "$p" 0)}" \
  "${cache[${p}_1]:=$(fft "$p" 1)}" \
  "${cache[${p}_2]:=$(fft "$p" 2)}" \
  "${cache[${p}_3]:=$(fft "$p" 3)}" \
  "${cache[${p}_4]:=$(fft "$p" 4)}" \
  "${cache[${p}_5]:=$(fft "$p" 5)}" \
  "${cache[${p}_6]:=$(fft "$p" 6)}" \
  "${cache[${p}_7]:=$(fft "$p" 7)}"
