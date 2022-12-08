#!/bin/bash

set -eu

posx=() posy=() posz=()
velx=() vely=() velz=()

declare -i periodx periody periodz idx t=0
declare -a input
declare -A xhist yhist zhist

mapfile -t input < "$1"

for (( idx=0; idx < ${#input[@]}; idx++ )); do
  IFS=, read -r -a parts <<<"${input[idx]}"
  x=${parts[0]} ; x=${x#<x=}
  y=${parts[1]} ; y=${y# y=}
  z=${parts[2]} ; z=${z# z=} ; z=${z%>}
  posx[idx]=$x posy[idx]=$y posz[idx]=$z
  velx[idx]=0 vely[idx]=0 velz[idx]=0
done

while :; do
  idx="${posx[0]},${posx[1]},${posx[2]},${posx[3]},${velx[0]},${velx[1]},${velx[2]},${velx[3]}"
  set +u
  if [ -n "${xhist[$idx]}" ]; then
    set -u
    periods[0]=$((t-xhist[idx]))
    break
  else
    set -u
    xhist[$idx]=$t
  fi

  for (( m1=0; m1 < ${#posx[@]}; m1++ )); do
    for (( m2=m1+1; m2 < ${#posx[@]}; m2++ )); do
      dx=$(( posx[m1] < posx[m2] ? 1 : posx[m1] > posx[m2] ? -1 : 0 ))
      (( velx[m1]+=dx )) || :
      (( velx[m2]+=dx*-1 )) || :
    done
  done
  
  (( posx[0]+=velx[0] )) || :
  (( posx[1]+=velx[1] )) || :
  (( posx[2]+=velx[2] )) || :
  (( posx[3]+=velx[3] )) || :
  t=$((t+1))
done

t=0
while :; do
  idx="${posy[0]},${posy[1]},${posy[2]},${posy[3]},${vely[0]},${vely[1]},${vely[2]},${vely[3]}"
  set +u
  if [ -n "${yhist[$idx]}" ]; then
    set -u
    periods[1]=$((t-yhist[idx]))
    break
  else
    set -u
    yhist[$idx]=$t
  fi

  for (( m1=0; m1 < ${#posy[@]}; m1++ )); do
    for (( m2=m1+1; m2 < ${#posy[@]}; m2++ )); do
      dx=$(( posy[m1] < posy[m2] ? 1 : posy[m1] > posy[m2] ? -1 : 0 ))
      (( vely[m1]+=dx )) || :
      (( vely[m2]+=dx*-1 )) || :
    done
  done
  
  (( posy[0]+=vely[0] )) || :
  (( posy[1]+=vely[1] )) || :
  (( posy[2]+=vely[2] )) || :
  (( posy[3]+=vely[3] )) || :
  t=$((t+1))
done

t=0
while :; do
  idx="${posz[0]},${posz[1]},${posz[2]},${posz[3]},${velz[0]},${velz[1]},${velz[2]},${velz[3]}"
  set +u
  if [ -n "${zhist[$idx]}" ]; then
    set -u
    periods[2]=$((t-zhist[idx]))
    break
  else
    set -u
    zhist[$idx]=$t
  fi

  for (( m1=0; m1 < ${#posz[@]}; m1++ )); do
    for (( m2=m1+1; m2 < ${#posz[@]}; m2++ )); do
      dx=$(( posz[m1] < posz[m2] ? 1 : posz[m1] > posz[m2] ? -1 : 0 ))
      (( velz[m1]+=dx )) || :
      (( velz[m2]+=dx*-1 )) || :
    done
  done
  
  (( posz[0]+=velz[0] )) || :
  (( posz[1]+=velz[1] )) || :
  (( posz[2]+=velz[2] )) || :
  (( posz[3]+=velz[3] )) || :
  t=$((t+1))
done

echo "gcm of ${periods[@]}"
