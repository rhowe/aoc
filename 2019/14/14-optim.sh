#!/bin/bash -eu

declare -A batchsizes recipes

batchsizes[FUEL]=1
batchsizes[ORE]=1
recipefile=$(dirname "$0")/recipes.sh

parse() {
  local reaction
  local -a reactions
  mapfile -t reactions < "$1"

  for reaction in "${reactions[@]}"; do
    local sourcepart=${reaction% =>*}
    local -a sources
    IFS=' ' read -ra dests <<<"${reaction#* => }"
    batchsizes[${dests[1]}]=${dests[0]}
    recipes[${dests[1]}]=$sourcepart
  done
}

multiply() {
  local product=$1 mul=$2 source newsourcestr src qty
  local sourcepart=${recipes[$product]}
  local -a sources newsources=()

  IFS=, read -ra sources <<<"${sourcepart//, /,}"

  for source in "${sources[@]}"; do
    read -r qty src <<<"$source"
    newsources+=("$((qty*mul)) $src")
  done
  IFS=, newsourcestr="${newsources[*]}"
  echo "${newsourcestr//,/, }"
}

optimise() {
  local src qty oldsource newsourcepart product oldifs changesmade=1
  local -a reactions sources newsources

  mapfile -t reactions

  while [ "$changesmade" -ne 0 ]; do
    changesmade=0
    for product in "${!recipes[@]}"; do
      newsources=()
      sourcepart=${recipes[$product]}
      #[ "$product" != WDJKB ] || echo "Examining $product, made of $sourcepart"
      IFS=, read -ra sources <<<"${sourcepart//, /,}"
  
      for oldsource in "${sources[@]}"; do
        read -r qty src <<<"$oldsource"
        #[ "$product" != WDJKB ] || echo "'$oldsource': we need $qty of source $src (${recipes[$src]})"
        if [ "$src" != ORE ] && [ "$qty" -ge "${batchsizes[$src]}" ]; then
          #[ "$product" != WDJKB ] || echo "this is $((qty / ${batchsizes[$src]}))x more than the batch size with $((qty % ${batchsizes[$src]})) left over"
          newpart=$(multiply $src $((qty / ${batchsizes[$src]})))
          [ "$((qty % ${batchsizes[$src]}))" -eq 0 ] || newpart="$newpart, $((qty % ${batchsizes[$src]})) $src"
          #[ "$product" != WDJKB ] || echo "Replacing $qty $src with $newpart"
          newsources+=("$newpart")
          changesmade=1
        else
          newsources+=("$qty $src")
        fi
      done
      oldifs=$IFS
      IFS=, newsourcepart="${newsources[*]}"
      IFS=$oldifs
      newsourcepart="${newsourcepart//,/, }"
      newsourcepart="${newsourcepart//  / }"
      #[ "$product" != WDJKB ] || echo "$product is now made of $newsourcepart"
      recipes[$product]="${newsourcepart}"
    done
    if ! merge; then
      changesmade=1
    fi
  done
}

merge() {
  local src qty sourcestr newsourcepart product oldifs changesmade=0
  local -a reactions sources newsources
  local -A recipeqty

  for product in "${!recipes[@]}"; do
    newsources=()
    for prodsrc in "${!recipes[@]}"; do
      recipeqty[$prodsrc]=0
    done
    recipeqty[ORE]=0

    sourcepart=${recipes[$product]}
    IFS=, read -ra sources <<<"${sourcepart//, /,}"

    for sourcestr in "${sources[@]}"; do
      read -r qty src <<<"$sourcestr"
      if [ "${recipeqty[$src]}" -ne 0 ]; then
        changesmade=1
      fi
      recipeqty[$src]=$((${recipeqty[$src]}+qty))
    done

    for src in "${!recipeqty[@]}"; do
      [ "${recipeqty[$src]}" -ne 0 ] || continue
      newsources+=("${recipeqty[$src]} $src")
    done

    oldifs=$IFS
    IFS=, newsourcepart="${newsources[*]}"
    IFS=$oldifs
    newsourcepart="${newsourcepart//,/, }"
    newsourcepart="${newsourcepart//  / }"
    recipes[$product]="${newsourcepart}"
  done
  return $changesmade
}

generate() {
  for product in "${!recipes[@]}"; do
    echo "${recipes[$product]} => ${batchsizes[$product]} $product"
  done
}

parse "$1"
optimise < "$1"
generate | rev | sort -n -t= -k2 | rev
