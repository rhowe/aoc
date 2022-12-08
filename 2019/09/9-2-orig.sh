#!/bin/bash -eu

add()   { ram[$5 == 0 ? $6 : rb+$6]=$((($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]) + ($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4]))) ; }
mul()   { ram[$5 == 0 ? $6 : rb+$6]=$((($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]) * ($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4]))) ; }
cmpl()  { ram[$5 == 0 ? $6 : rb+$6]=$((($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]) < ($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4]) ? 1 : 0 )) ; }
cmpe()  { ram[$5 == 0 ? $6 : rb+$6]=$((($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]) == ($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4]) ? 1 : 0 )) ; }
jmpt()  { [ "$(($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]))" -eq 0 ] || pc=$(($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4])) ; }
jmpf()  { [ "$(($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]))" -ne 0 ] || pc=$(($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4])) ; }
addrb() { ((rb+=($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]))) ; }
outb()  { echo $(($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2])) ; }
inb()   { ram[$1 == 0 ? $2 : rb+$2]=${inputs[0]} ; inputs=("${inputs[@]:1}") ; }

run() {
  local -ai program ram
  IFS=, read -r -a program < "$1"
  shift
  inputs=("$@")
  ram=("${program[@]}" $(yes 0|head -n 128))
  declare -i pc=0 rb=0
  while : ; do
    local opcode opfunc
    local -i argc args=()
    printf -v opcode %05d "${ram[pc++]}"
    case "${opcode: -2:2}" in
      01) opfunc=add   argc=3 ;;
      02) opfunc=mul   argc=3 ;;
      03) opfunc=inb   argc=1 ;;
      04) opfunc=outb  argc=1 ;;
      05) opfunc=jmpt  argc=2 ;;
      06) opfunc=jmpf  argc=2 ;;
      07) opfunc=cmpl  argc=3 ;;
      08) opfunc=cmpe  argc=3 ;;
      09) opfunc=addrb argc=1 ;;
      99) break ;;
      *)
        echo "Unknown opcode $opcode at $((pc-1))" >&2
        return 1
      ;;
    esac
    for ((arg=0; arg < argc; arg++)); do
      args+=("${opcode: -3-arg:1}" "${ram[@]:pc++:1}")
    done
    "$opfunc" "${args[@]}"
  done
}

readonly -f add mul inb outb jmpt jmpf cmpl cmpe addrb run
export -f add mul inb outb jmpt jmpf cmpl cmpe addrb run

run "$@"
