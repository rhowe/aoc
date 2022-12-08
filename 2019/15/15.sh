#!/bin/bash -eu

declare -i width=80 height=50 x=40 y=20 nextx=40 nexty=19 input=1 dir=0 measuredist=0 maxdist=0
declare -a world distances

for ((i=0; i < width * height; i++)); do
  world[i]=' '
  distances[i]='.'
done

declare -ai program ram
declare -i addrmode1 addrmode2 arg1 arg2 pc=0 rb=0
IFS=, read -r -a program < "$1"
shift
ram=("${program[@]}")
ops=(x '+' '*' x x '-eq' '-ne' '<' '==')

#           n s w e
dirdeltax=(0 0 -1 1)
dirdeltay=(-1 1 0 0)


cpu() {
  while : ; do
    printf -v opcode %05d "${ram[pc++]}"
    case "${opcode: -2:2}" in
      01|02|07|08) addrmode1=${opcode: -3:1} addrmode2=${opcode: -4:1} arg1=${ram[pc++]} arg2=${ram[pc++]} ram[(${opcode: -5:1} != 0)*rb+${ram[pc++]}]=$(((addrmode1 == 1 ? arg1 : ram[(addrmode1 != 0)*rb+arg1]) ${ops[${opcode: -1:1}]} (addrmode2 == 1 ? arg2 : ram[(addrmode2 != 0)*rb+arg2]))) ;;
      03) ram[(${opcode: -3:1} == 0 ? 0 : rb)+${ram[pc++]}]=$input ;;
      04)
        addrmode1=${opcode: -3:1} arg1=${ram[pc++]}
        readans $((addrmode1 == 1 ? arg1 : ram[(addrmode1 == 0 ? 0 : rb)+arg1]))
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

draw() {
  screen=("${world[@]}")
  screen[y*width+x]=$input
  out=$(
    clear
    oldifs=$IFS
    IFS=
    for ((row=0; row < height; row++)); do
      echo "${screen[*]:row*width:width}"
    done
    IFS=$oldifs
  )
  echo "$out"
}

readans() {
  case $1 in
    0) world[nexty*width+nextx]=+ ;;
    1)
      world[y*width+x]=. dir=$input
      currdist=${distances[y*width+x]}
      if [ "$measuredist" -eq 1 ] && [ "${distances[nexty*width+nextx]}" == '.' ]; then
        distances[nexty*width+nextx]=$((distances[y*width+x]+1))
        if [ "${distances[nexty*width+nextx]}" -gt $maxdist ]; then
          maxdist=${distances[nexty*width+nextx]}
        fi
      fi
      world[y*width+x]=${currdist: -1:1}
      x=$nextx y=$nexty dir=$input
      ;;
    2)
      if (( measuredist )); then
        echo "Furthest point is at $maxdist"
        exit
      fi
      world[nexty*width+nextx]=O distances[nexty*width+nextx]=0 x=$nextx y=$nexty dir=$input measuredist=1
      ;;
  esac
  draw
  nextmove
}

nextmove() {
  oldinput=$input
  case $dir in
    1) testdirs=(4 1 3 2) ;;
    2) testdirs=(3 2 4 1) ;;
    3) testdirs=(1 3 2 4) ;;
    4) testdirs=(2 4 1 3) ;;
  esac

  for move in "${testdirs[@]}"; do
    nextx=$((x + dirdeltax[move-1])) nexty=$((y + dirdeltay[move-1]))
    case "${world[nexty*width+nextx]}" in
      +) ;;
      *)
        input=$move
        break
        ;;
    esac
  done
  if [ $input -eq ${testdirs[3]} ]; then
    world[y*width+x]=x
  fi
}

cpu
