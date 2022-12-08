#!/bin/bash

set -eu

deal_with() {
  shift 2
  echo "Dealing with inc $1"
}

deal_into() {
  local -ai stack=()
  
  echo "Before ${FUNCNAME[0]}: ${deck[@]}" >&2
  for ((i=0; i < ${#deck[@]}; i++)); do
    stack[i]=${deck[-1-$i]}
  done

  deck=("${stack[@]}")
  echo "After ${FUNCNAME[0]}: ${deck[@]}" >&2
}

deal() {
  case "$1" in
    with) deal_with "$@" ;;
    into) deal_into "$@" ;;
  esac
}

cut() {
  echo "Cutting $1"
}

declare -ia deck=()

seq 0 10006 | mapfile -t deck

deck=(0 1 2 3 4 5 6)

echo "Cards in deck: ${#deck[@]}"
echo "Card 5 = ${deck[5]}"

. "$1"
