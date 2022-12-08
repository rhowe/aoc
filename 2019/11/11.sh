#!/bin/bash -eu

getloc() {
  case $1 in
    0) echo "$2" ;;
    1) echo "Can't get location of immediate value" >&2 && exit 1 ;;
    2) echo "$((rb + $2))" ;;
  esac
}

getval() {
  case $1 in
    0) echo "${ram[$2]}" ;;
    1) echo "$2" ;;
    2) echo "${ram[rb+$2]}" ;;
  esac
}

inb() {
  [ "${#inputs[@]}" -ne 0 ] || read -ra inputs
  ram[$(getloc "$1" "$2")]=${inputs[0]}
  inputs=("${inputs[@]:1}")
}

add()   { ram[$5 == 0 ? $6 : rb+$6]=$((($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]) + ($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4]))) ; }
mul()   { ram[$5 == 0 ? $6 : rb+$6]=$((($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]) * ($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4]))) ; }
cmpl()  { ram[$5 == 0 ? $6 : rb+$6]=$((($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]) < ($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4]) ? 1 : 0 )) ; }
cmpe()  { ram[$5 == 0 ? $6 : rb+$6]=$((($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]) == ($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4]) ? 1 : 0 )) ; }
jmpt()  { [ "$(($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]))" -eq 0 ] || pc=$(($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4])) ; }
jmpf()  { [ "$(($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]))" -ne 0 ] || pc=$(($3 == 1 ? $4 : $3 == 0 ? ram[$4] : ram[rb+$4])) ; }
addrb() { ((rb+=($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2]))) ; }
outb()  { echo $(($1 == 1 ? $2 : $1 == 0 ? ram[$2] : ram[rb+$2])) ; }

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

dirinsthist=
dirhist=
painthist=

painter() {
  local width=60 height=70 dir=0 dirs=('^' '>' 'v' '<') moves=(l r)
  local hull=($(yes 0 | head -n $((width * height)))) x=$((width/2)) y=$((height/2))
  hull[y*width+x]=1
  echo "${hull[y*width+x]}"
  while read -r paint; do
    hull[y*width+x]=$paint
    read -r move
    case $move in
      0) dir=$(((dir + 3) % 4));;
      1) dir=$(((dir + 1) % 4));;
    esac
    case $dir in
      0) y=$((y-1)) ;;
      1) x=$((x+1)) ;;
      2) y=$((y+1)) ;;
      3) x=$((x-1)) ;;
    esac
    painthist=${painthist}$paint
    dirinsthist=${dirinsthist}$move
    dirhist=${dirhist}${dirs[dir]}
    local grid=("${hull[@]}")
    local colour=${grid[y*width+x]}
    echo "$x,$y" >> painthistory
    grid[y*width+x]=${dirs[dir]}
    pic=$(
      tput cup 0 0
      for pos in $(seq 0 "$width" "${#grid[@]}"); do
         IFS= echo "${grid[*]:pos:width}" | tr '01' ' #'
      done
#      echo "$x,$y=$colour->$paint : ${dirs[dir]}($dir) -> ${moves[move]}($move)"
#      echo "$dirinsthist"
#      echo "$dirhist"
#      echo "$painthist"
    )
    echo "$pic" >&2
    echo "$colour"
    #sleep 5
  done
}

rm -f paintin
mkfifo paintin 
> painthistory

painter < paintin | run "$@" > paintin
