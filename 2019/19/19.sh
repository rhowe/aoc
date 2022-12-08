#!/bin/bash

set -eu

declare -ai ram
declare -i addrmode1 addrmode2 arg1 arg2 pc=0 rb=0
IFS=, read -r -a program < input
shift
ops=(x '+' '*' x x '-eq' '-ne' '<' '==')

cpu() {
  ram=("${program[@]}")
  while : ; do
    printf -v opcode %05d "${ram[pc++]}"
    case "${opcode: -2:2}" in
      01|02|07|08) addrmode1=${opcode: -3:1} addrmode2=${opcode: -4:1} arg1=${ram[pc++]} arg2=${ram[pc++]} ram[(${opcode: -5:1} != 0)*rb+${ram[pc++]}]=$(((addrmode1 == 1 ? arg1 : ram[(addrmode1 != 0)*rb+arg1]) ${ops[${opcode: -1:1}]} (addrmode2 == 1 ? arg2 : ram[(addrmode2 != 0)*rb+arg2]))) ;;
      03)
        ram[(${opcode: -3:1} == 0 ? 0 : rb)+${ram[pc++]}]=$1
        shift
        ;;
      04)
        addrmode1=${opcode: -3:1} arg1=${ram[pc++]}
        echo $((addrmode1 == 1 ? arg1 : ram[(addrmode1 == 0 ? 0 : rb)+arg1]))
        ;;
      05|06)
        addrmode1=${opcode: -3:1} addrmode2=${opcode: -4:1} arg1=${ram[pc++]} arg2=${ram[pc++]}
        [ "$((addrmode1 == 1 ? arg1 : ram[(addrmode1 == 0 ? 0 : rb)+arg1]))" ${ops[${opcode: -1:1}]} 0 ] || pc=$((addrmode2 == 1 ? arg2 : ram[(addrmode2 == 0 ? 0 : rb)+arg2]))
        ;;
      09)
        addrmode1=${opcode: -3:1} arg1=${ram[pc++]}
        ((rb+=addrmode1 == 1 ? arg1 : ram[(addrmode1 == 0 ? 0 : rb)+arg1]))
        ;;
      99) break ;;
    esac
  done
}

declare -i cells=0 width=50 height=50 x=0 y=0

for ((y=0; y < height; y++)); do
  for ((x=0; x < width; x++)); do
    case "$(cpu "$x" "$y")" in
      1) cells+=1 ;;
    esac
  done
done

echo "cells: $cells"
