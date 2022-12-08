#!/bin/bash -eu

declare -A stockpile batchsizes

startingore=1000000000000
stockpile[ORE]=$startingore
stockpile[FUEL]=0
batchsizes[ORE]=1
recipefile=$(dirname "$0")/recipes.sh

stock() {
  local thing
  for thing in "${!stockpile[@]}"; do
    echo "$thing: ${stockpile[$thing]}                                                      "
  done
}

mine() {
  case "$1" in
    ORE)
      stockpile[ORE]=$((${stockpile[ORE]} - $2))
      if [ "${stockpile[ORE]}" -lt 0 ]; then
        echo "Ran out of ORE! Mined ${stockpile[FUEL]} fuel" >&2
        exit
      fi
      ;;
    *)
    while [ "${stockpile[$1]}" -lt $2 ]; do
      "mine_$1"
    done
    stockpile[$1]=$((${stockpile[$1]}-$2))
      ;;
  esac
}

generate_recipes() {
  local -a reactions
  mapfile -t reactions < "$1"

  > "$recipefile"

  for reaction in "${reactions[@]}"; do
    local src=${reaction% =>*}
    local -a sources
    IFS=' ' read -ra dests <<<"${reaction#* => }"
    IFS=, read -ra sources <<<"${src//, /,}"
    echo "stockpile[${dests[1]}]=0" >> "$recipefile"
    echo "batchsizes[${dests[1]}]=${dests[0]}" >> "$recipefile"
    echo "mine_${dests[1]}() {" >> "$recipefile"
    for source in "${sources[@]}"; do
      amount=${source% *}
      ingredient=${source#* }
      echo "  mine $ingredient $amount" >> "$recipefile"
    done
    echo "  stockpile[${dests[1]}]=\$((\${stockpile[${dests[1]}]}+${dests[0]}))" >> "$recipefile"
    echo "}" >> "$recipefile"
  done
}

generate_recipes "$1"
. "$recipefile"

[ -z "${DEBUG:-}" ] || clear

mine_FUEL
ore_used=$((startingore - ${stockpile[ORE]}))
echo "Used $((ore_used)) ORE for 1 FUEL"

echo "Mining continues"
t0=$((SECONDS-1))
f0=1
o0=${stockpile[ORE]}
fuelrate=-
orerate=-1
while true; do
  mine_FUEL
  if (( ${stockpile[FUEL]} % 100 == 0)); then
    fuelrate=$((((${stockpile[FUEL]}-f0) / (SECONDS-t0))))
    orerate=$((((${stockpile[ORE]}-o0) / (SECONDS-t0))))
  if [ -z "${DEBUG:-}" ]; then
    echo "Making $fuelrate fuel/s using $((-1 * orerate)) ore/s ETA $(date -d "now + $((${stockpile[ORE]} / (-1 * orerate))) seconds")                "
  else
    out=$(
      tput cup 0 0
      stock|sort
      echo "Making $fuelrate fuel/s using $((-1 * orerate)) ore/s ETA $(date -d "now + $((${stockpile[ORE]} / (-1 * orerate))) seconds")                "
    )
    echo "$out"
  fi
  fi
done
