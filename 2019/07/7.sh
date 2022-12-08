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

printinstr() {
  local instr=$1 ; shift

  while [ $# -gt 0 ]; do
    case "$1" in
      0) instr="$instr [$2]" ;;
      1) instr="$instr $2" ;;
      2) instr="$instr [$2 + rb($rb)]" ;;
    esac
    shift 2
  done
  echo "$0 $instr"
}

add()   { ram[$(getloc "$5" "$6")]=$(($(getval "$1" "$2") + $(getval "$3" "$4"))) ; }
mul()   { ram[$(getloc "$5" "$6")]=$(($(getval "$1" "$2") * $(getval "$3" "$4"))) ; }
cmpl()  { ram[$(getloc "$5" "$6")]=$(($(getval "$1" "$2") < $(getval "$3" "$4") ? 1 : 0 )) ; }
cmpe()  { ram[$(getloc "$5" "$6")]=$(($(getval "$1" "$2") == $(getval "$3" "$4") ? 1 : 0 )) ; }
jmpt()  { [ "$(getval "$1" "$2")" -eq 0 ] || pc=$(getval "$3" "$4") ; }
jmpf()  { [ "$(getval "$1" "$2")" -ne 0 ] || pc=$(getval "$3" "$4") ; }
addrb() { ((rb+=$(getval "$1" "$2"))) ; }
outb()  { getval "$1" "$2" ; }

inb() {
  [ "${#inputs[@]}" -ne 0 ] || read -ra inputs
  ram[$(getloc "$1" "$2")]=${inputs[0]}
  inputs=("${inputs[@]:1}")
}

bdb() {
  local ramcopy=("${ram[@]}")
  ramcopy[pc]="$(tput setaf 10)${ramcopy[pc]}$(tput setaf 15)<"
  bdbout=$(
    echo -e "$0\t$pc/$rb\t$(seq 0 15 | xargs | tr \  \\t)"
    for addr in $(seq 0 16 "${#ramcopy[@]}"); do
       echo "$0 $addr: ${ramcopy[*]:addr:16}" | tr \  \\t
    done)
  echo "$bdbout" >&2
}

run() {
  local -ai program ram
  IFS=, read -r -a program < "$1"
  shift
  inputs=("$@")
  [ -z "${DEBUG:-}" ] || echo "$0: program start: ${inputs[*]}" >&2
  ram=("${program[@]}" $(yes 0|head -n 128))
  declare -i pc=0 rb=0
  while : ; do
    [ "${DEBUG:-}" != 2 ] || bdb
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
    [ -z "${DEBUG:-}" ] || printinstr "$opfunc" "${args[@]}" >&2
    "$opfunc" "${args[@]}"
  done
}

readonly -f add mul inb outb jmpt jmpf cmpl cmpe addrb run bdb getval getloc printinstr
export -f add mul inb outb jmpt jmpf cmpl cmpe addrb run bdb getval getloc printinstr
export DEBUG

highestoutput=0

if [ ! -f phases ]; then
  for phases in {5,6,7,8,9},{5,6,7,8,9},{5,6,7,8,9},{5,6,7,8,9},{5,6,7,8,9}; do
    IFS=, read -r -a phasearray <<<"$phases"
    if [ "$(xargs -n1 echo <<<"${phasearray[@]}" | sort -u)" != "$(xargs -n1 echo <<<"${phasearray[@]}" | sort)" ]; then
      continue
    fi
    echo $phases >> phases
  done
fi

for phases in $(<phases); do
  rm -rf io
  mkdir io

  for amp in A B C D E F; do
    mkfifo io/$amp.in
  done

  IFS=, read -r -a phasearray <<<"$phases"
  bash -c "run \"$1\" \"${phasearray[4]}\"" E <io/E.in >io/F.in &
  E_PID=$!
  echo "E started, pid $E_PID" >&2

  bash -c "run \"$1\" \"${phasearray[3]}\"" D <io/D.in >io/E.in &
  D_PID=$!
  echo "D started, pid $D_PID" >&2

  bash -c "run \"$1\" \"${phasearray[2]}\"" C <io/C.in >io/D.in &
  C_PID=$!
  echo "C started, pid $C_PID" >&2

  bash -c "run \"$1\" \"${phasearray[1]}\"" B <io/B.in >io/C.in &
  B_PID=$!
  echo "B started, pid $B_PID" >&2

  bash -c "run \"$1\" \"${phasearray[0]}\"" A <io/A.in >io/B.in &
  A_PID=$!
  echo "A started, pid $A_PID" >&2

  bash -c "tee io/F.tap" F <io/F.in >io/A.in &
  F_PID=$!
  echo 0 > io/F.in
  set +e
  jobs
  echo pids: $A_PID $B_PID $C_PID $D_PID $E_PID $F_PID
  wait $A_PID $B_PID $C_PID $D_PID $E_PID $F_PID || :
  acc=$(tail -n1 io/F.tap)
  echo "$phases,$acc" >> results
  echo "$phases got $acc (max $highestoutput)"
  if [ "$acc" -gt "$highestoutput" ]; then
    highestoutput=$acc
  fi
done
sort -n -t , -k 6 results | tail -n1 | cut -d , -f 6
