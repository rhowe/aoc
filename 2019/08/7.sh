#!/bin/bash

set -eu

getval() {
  src=$2
  case $1 in
    0) echo "${ram[$src]}" ;;
    1) echo "$src" ;;
    2) echo "${ram[$((rb + src))]}" ;;
  esac
}

jmpt() {
  local addrmode; addrmode=$1
  local arg; arg=$(getval "${addrmode:0:1}" "$2")
  local dest; dest=$(getval "${addrmode:1:1}" "$3")
  [ -z "${DEBUG:-}" ] || echo "$0($pc) jmpt $arg $dest" >&2
  if [ "$arg" -ne 0 ]; then
    pc=$dest
  else
    pc=$((pc+2))
  fi
}

jmpf() {
  local addrmode; addrmode=$1
  local arg; arg=$(getval "${addrmode:0:1}" "$2")
  local dest;dest=$(getval "${addrmode:1:1}" "$3")
  [ -z "${DEBUG:-}" ] || echo "$0($pc) jmpf $arg $dest" >&2
  if [ "$arg" -eq 0 ]; then
    pc=$dest
  else
    pc=$((pc+2))
  fi
}

add() {
  local addrmode; addrmode=$1
  local src1; src1=$(getval "${addrmode:0:1}" "$2")
  local src2; src2=$(getval "${addrmode:1:1}" "$3")
  local dest; dest=$4
  [ -z "${DEBUG:-}" ] || echo "$0($pc) add $src1 $src2 $dest" >&2
  ram[$dest]=$((src1 + src2))
  pc=$((pc+3))
}

mul() {
  local addrmode; addrmode=$1
  local src1; src1=$(getval "${addrmode:0:1}" "$2")
  local src2; src2=$(getval "${addrmode:1:1}" "$3")
  local dest; dest=$4
  [ -z "${DEBUG:-}" ] || echo "$0($pc) mul $src1 $src2 $dest" >&2
  ram[$dest]=$((src1 * src2))
  pc=$((pc+3))
}

cmpl() {
  local addrmode; addrmode=$1
  local src1; src1=$(getval "${addrmode:0:1}" "$2")
  local src2; src2=$(getval "${addrmode:1:1}" "$3")
  local dest; dest=$4
  [ -z "${DEBUG:-}" ] || echo "$0($pc) cmpl $src1 $src2 $dest" >&2
  if [ "$src1" -lt "$src2" ]; then
    ans=1
  else
    ans=0
  fi
  ram[$dest]=$ans
  pc=$((pc+3))
}

cmpe() {
  local addrmode; addrmode=$1
  local src1; src1=$(getval "${addrmode:0:1}" "$2")
  local src2; src2=$(getval "${addrmode:1:1}" "$3")
  local dest; dest=$4
  [ -z "${DEBUG:-}" ] || echo "$0($pc) cmpe $src1 $src2 $dest" >&2
  if [ "$src1" -eq "$src2" ]; then
    local ans=1
  else
    local ans=0
  fi
  ram[$dest]=$ans
  pc=$((pc+3))
}

inb() {
  local addrmode; addrmode=$1
  local dest; dest=$2
  if [ -z "${inputs:-}" ]; then
    read -r input
    [ -z "${DEBUG:-}" ] || echo "$0($pc) inb $dest (ext: $input)" >&2
    ram[$dest]=$input
  else
    ram[$dest]=${inputs[0]}
    inputs=("${inputs[@]:1}")
  fi
  pc=$((pc+1))
}

outb() {
  local addrmode; addrmode=$1
  local src; src=$(getval "${addrmode:0:1}" "$2")
  [ -z "${DEBUG:-}" ] || echo "$0($pc) outb $src" >&2
  echo "$src"
  pc=$((pc+1))
}

addrb() {
  local addrmode; addrmode=$1
  local src; src=$(getval "${addrmode:0:1}" "$2")
  [ -z "${DEBUG:-}" ] || echo "$0($pc) addrb $src" >&2
  rb=$((rb+src))
  pc=$((pc+1))
}

gdb() {
  ramcopy=("${ram[@]}")
  ramcopy[$pc]="${ramcopy[$pc]}*"
  gdbout=$(
  echo -e "$0\t$pc\t$(seq 0 15 | xargs | tr \  \\t)"
  for addr in $(seq 0 16 "${#ramcopy[@]}"); do
     echo "$0 $addr: ${ramcopy[@]:$addr:16}" | tr \  \\t
  done)
  echo "$gdbout" >&2
}

run() {
  IFS=, read -r -a program < "$1"
  shift
  inputs=("$@")
  [ -z "${DEBUG:-}" ] || echo "$0: program start: ${inputs[@]}" >&2
  pc=0
  rb=0
  ram=("${program[@]}" $(yes 0|head -n 128))
  while true; do
    local opcode; opcode=$(printf %05d "${ram[$pc]}")
    local addrmode; addrmode=${opcode: -3:1}${opcode: -4:1}
    [ "${DEBUG:-}" != 2 ] || gdb
    pc=$((pc+1))
    case "${opcode: -2}" in
      01) add   "$addrmode" "${ram[@]:$pc:3}" ;;
      02) mul   "$addrmode" "${ram[@]:$pc:3}" ;;
      03) inb   "$addrmode" "${ram[@]:$pc:1}" ;;
      04) outb  "$addrmode" "${ram[@]:$pc:1}" ;;
      05) jmpt  "$addrmode" "${ram[@]:$pc:2}" ;;
      06) jmpf  "$addrmode" "${ram[@]:$pc:2}" ;;
      07) cmpl  "$addrmode" "${ram[@]:$pc:3}" ;;
      08) cmpe  "$addrmode" "${ram[@]:$pc:3}" ;;
      09) addrb "$addrmode" "${ram[@]:$pc:1}" ;;
      99) break ;;
      *)
        echo "Unknown opcode $opcode at $pc" >&2
        return 1
      ;;
    esac
  done
}

cd "$(dirname "$0")"

export -f add mul inb outb jmpt jmpf cmpl cmpe addrb run gdb getval
export DEBUG

run "$@"
