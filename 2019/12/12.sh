#!/bin/bash

set -eu

posx=() posy=() posz=()
velx=() vely=() velz=()
t=0

mapfile -t input < "$1"

for (( idx=0; idx < ${#input[@]}; idx++ )); do
  IFS=, read -r -a parts <<<"${input[idx]}"
  x=${parts[0]} ; x=${x#<x=}
  y=${parts[1]} ; y=${y# y=}
  z=${parts[2]} ; z=${z# z=} ; z=${z%>}
  posx[idx]=$x posy[idx]=$y posz[idx]=$z
  velx[idx]=0 vely[idx]=0 velz[idx]=0
done

rm -rf steps && mkdir steps

for (( t=0; t < 1000; t++ )); do
  echo "After $t steps:"
  for (( idx=0; idx < ${#posx[@]}; idx++ )); do
    echo "$idx: pos=<x=${posx[idx]}, y=${posy[idx]}, z=${posz[idx]}>, vel=<x=${velx[idx]}, y=${vely[idx]}, z=${velz[idx]}>"
  done

  for (( m1=0; m1 < ${#posx[@]}; m1++ )); do
    for (( m2=m1+1; m2 < ${#posx[@]}; m2++ )); do
      dx=$(( posx[m1] < posx[m2] ? 1 : posx[m1] > posx[m2] ? -1 : 0 ))
      dy=$(( posy[m1] < posy[m2] ? 1 : posy[m1] > posy[m2] ? -1 : 0 ))
      dz=$(( posz[m1] < posz[m2] ? 1 : posz[m1] > posz[m2] ? -1 : 0 ))
      (( velx[m1]+=dx )) || :
      (( vely[m1]+=dy )) || :
      (( velz[m1]+=dz )) || :
      (( velx[m2]+=dx*-1 )) || :
      (( vely[m2]+=dy*-1 )) || :
      (( velz[m2]+=dz*-1 )) || :
    done
  done
  
  for (( idx=0; idx < ${#posx[@]}; idx++ )); do
    (( posx[idx]+=velx[idx] )) || :
    (( posy[idx]+=vely[idx] )) || :
    (( posz[idx]+=velz[idx] )) || :
  done
done

echo "After $t steps:"
for (( idx=0; idx < ${#posx[@]}; idx++ )); do
  echo "$idx: pos=<x=${posx[idx]}, y=${posy[idx]}, z=${posz[idx]}>, vel=<x=${velx[idx]}, y=${vely[idx]}, z=${velz[idx]}>"
done

nrg=0

for (( idx=0; idx < ${#posx[@]}; idx++ )); do
  apx=$(((posx[idx] < 0 ? -1 : 1) * posx[idx]))
  apy=$(((posy[idx] < 0 ? -1 : 1) * posy[idx]))
  apz=$(((posz[idx] < 0 ? -1 : 1) * posz[idx]))
  avx=$(((velx[idx] < 0 ? -1 : 1) * velx[idx]))
  avy=$(((vely[idx] < 0 ? -1 : 1) * vely[idx]))
  avz=$(((velz[idx] < 0 ? -1 : 1) * velz[idx]))
  pot=$((apy+apx+apz))
  kin=$((avy+avx+avz))
  echo "pot: $apx + $apy + $apz;   kin: $avx + $avy + $avz"
  nrg=$((nrg + pot * kin))
done

echo "nrg: $nrg"
