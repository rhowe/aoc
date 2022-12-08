#!/bin/bash

declare -ai program ram
declare -i addrmode1 addrmode2 arg1 arg2 pc=0 rb=0
IFS=, read -r -a program < "$1"
shift
inputs=("$@")
ram=("${program[@]}")
ram[0]=2
ops=(x '+' '*' x x '-eq' '-ne' '<' '==')


cols=38
rows=20
screensize=$((cols*rows))
score=0
screen=$(yes '·' | head -n "$screensize" | xargs | tr -d ' ')

draw() {
  local go=0
  local -a paddle=(0 0) ball=(0 0)
  > log
  tput clear

  while : ; do
    read -r x
    read -r y
    read -r thing

    echo "$thing $x $y" >> log
    local -i offset=$((y*cols+x))

    if [ "$x" -eq -1 ] && [ "$y" -eq 0 ]; then
      score=$thing
    else
      case $thing in
        0) screen="${screen:0:offset}·${screen:offset+1}" ;;
        1) screen="${screen:0:offset}+${screen:offset+1}" ;;
        2) screen="${screen:0:offset}#${screen:offset+1}" ;;
        3) paddle=("$x" "$y") ;;
        4) ball=("$x" "$y") ;;
      esac
    fi

    echo -n "$((${ball[0]} < ${paddle[0]} ? -1 : ${ball[0]} > ${paddle[0]} ? 1 : 0))" > joystick
  
    output=$(
      tput cup 0 0
      echo "Score: $score, ball=${ball[0]}, paddle=${paddle[0]}, joy=$(<joystick)          "
      for ((idx=0; idx < screensize; idx+=cols)); do
        echo "${screen:idx:cols}"
      done
      tput cup "$((${paddle[1]}+1))" "${paddle[0]}"
      echo -n '='
      tput cup "$((${ball[1]}+1))" "${ball[0]}"
      echo -n '*'
    )
    echo "$output"
  done
}

echo -n 0 > joystick

cpu() {
while : ; do
  printf -v opcode %05d "${ram[pc++]}"
  case "${opcode: -2:2}" in
    01|02|07|08) addrmode1=${opcode: -3:1} addrmode2=${opcode: -4:1} arg1=${ram[pc++]} arg2=${ram[pc++]} ram[(${opcode: -5:1} != 0)*rb+${ram[pc++]}]=$(((addrmode1 == 1 ? arg1 : ram[(addrmode1 != 0)*rb+arg1]) ${ops[${opcode: -1:1}]} (addrmode2 == 1 ? arg2 : ram[(addrmode2 != 0)*rb+arg2]))) ;;
    03)
      echo "Reading joystick: $(<joystick)" >&2
      ram[(${opcode: -3:1} == 0 ? 0 : rb)+${ram[pc++]}]=$(<joystick) ;;
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
cpu | draw 

echo "Final score: $score"
