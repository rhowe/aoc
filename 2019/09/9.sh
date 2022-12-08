#!/bin/bash

set -eu

getloc() {
  src=$2
  case $1 in
    0) echo "$src" ;;
    1) echo "Can't get location of immediate value" >&2 && exit 1 ;;
    2) echo "$((rb + src))" ;;
  esac
}

getval() {
  mode=$1
  src=$2
  case $mode in
    1) # immediate
      echo "$src"
      ;;
    0|2) # indirect
      addr=$(getloc "$mode" "$src")
      echo "${ram[addr]}"
      ;;
  esac
}

printinstr() {
  instr=$1
  addrmode=$2
  shift 2

  argidx=0
  for arg in "$@"; do
    case ${addrmode:argidx++:1} in
      0) instr="$instr [$arg]" ;;
      1) instr="$instr $arg" ;;
      2) instr="$instr [$arg + rb($rb)]" ;;
    esac
  done
  echo "$0($pc) $instr"
}

jmpt() {
  [ -z "${DEBUG:-}" ] || printinstr "${FUNCNAME}" "$@" >&2
  local addrmode; addrmode=$1
  local arg; arg=$(getval "${addrmode:0:1}" "$2")
  local dest; dest=$(getval "${addrmode:1:1}" "$3")
  ((pc = arg == 0 ? pc+2 : dest))
}

jmpf() {
  [ -z "${DEBUG:-}" ] || printinstr "${FUNCNAME}" "$@" >&2
  local addrmode; addrmode=$1
  local arg; arg=$(getval "${addrmode:0:1}" "$2")
  local dest; dest=$(getval "${addrmode:1:1}" "$3")
  ((pc = arg == 0 ? dest : pc+2))
}

add() {
  [ -z "${DEBUG:-}" ] || printinstr "${FUNCNAME}" "$@" >&2
  local addrmode; addrmode=$1
  local src1; src1=$(getval "${addrmode:0:1}" "$2")
  local src2; src2=$(getval "${addrmode:1:1}" "$3")
  local dest; dest=$(getloc "${addrmode:2:1}" "$4")
  ram[dest]=$((src1 + src2))
  ((pc += 3))
}

mul() {
  [ -z "${DEBUG:-}" ] || printinstr "${FUNCNAME}" "$@" >&2
  local addrmode; addrmode=$1
  local src1; src1=$(getval "${addrmode:0:1}" "$2")
  local src2; src2=$(getval "${addrmode:1:1}" "$3")
  local dest; dest=$(getloc "${addrmode:2:1}" "$4")
  ram[dest]=$((src1 * src2))
  ((pc += 3))
}

cmpl() {
  [ -z "${DEBUG:-}" ] || printinstr "${FUNCNAME}" "$@" >&2
  local addrmode; addrmode=$1
  local src1; src1=$(getval "${addrmode:0:1}" "$2")
  local src2; src2=$(getval "${addrmode:1:1}" "$3")
  local dest; dest=$(getloc "${addrmode:2:1}" "$4")
  ram[dest]=$((src1 < src2 ? 1 : 0))
  ((pc += 3))
}

cmpe() {
  [ -z "${DEBUG:-}" ] || printinstr "${FUNCNAME}" "$@" >&2
  local addrmode; addrmode=$1
  local src1; src1=$(getval "${addrmode:0:1}" "$2")
  local src2; src2=$(getval "${addrmode:1:1}" "$3")
  local dest; dest=$(getloc "${addrmode:2:1}" "$4")
  ram[dest]=$((src1 == src2 ? 1 : 0))
  ((pc += 3))
}

inb() {
  [ -z "${DEBUG:-}" ] || printinstr "${FUNCNAME}" "$@" >&2
  local addrmode; addrmode=$1
  local dest; dest=$(getloc "${addrmode:0:1}" "$2")
  if [ -z "${inputs:-}" ]; then
    read -r input
    ram[dest]=$input
  else
    ram[dest]=${inputs[0]}
    inputs=("${inputs[@]:1}")
  fi
  ((pc++))
}

outb() {
  [ -z "${DEBUG:-}" ] || printinstr "${FUNCNAME}" "$@" >&2
  local addrmode; addrmode=$1
  echo $(getval "${addrmode:0:1}" "$2")
  ((pc++))
}

addrb() {
  [ -z "${DEBUG:-}" ] || printinstr "${FUNCNAME}" "$@" >&2
  local addrmode; addrmode=$1
  local src; src=$(getval "${addrmode:0:1}" "$2")
  ((rb += src))
  ((pc++))
}

gdb() {
  ramcopy=("${ram[@]}")
  ramcopy[pc]="${ramcopy[pc]}*"
  gdbout=$(
  echo -e "$0\t$pc/$rb\t$(seq 0 15 | xargs | tr \  \\t)"
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
    local opcode; printf -v opcode %05d "${ram[pc++]}"
    local addrmode; addrmode=${opcode: -3:1}${opcode: -4:1}${opcode: -5:1}
    [ "${DEBUG:-}" != 2 ] || gdb
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

export -f add mul inb outb jmpt jmpf cmpl cmpe addrb run gdb getval getloc
export DEBUG

run "$@"

