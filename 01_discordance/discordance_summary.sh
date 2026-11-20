#!/bin/bash
# Summarise PhyParts per-node results into a table of discordance proportions.
# Usage: bash discordance_summary.sh [phyparts_prefix]
# Run in the folder with the PhyParts output (*.concord.node.* and *.node.key files).

PREFIX=${1:-phyparts_Rodents2}

echo "node_number,clade,discordance_proportion" > discordance_summary.csv

for f in ${PREFIX}.concord.node.*; do
  node=$(basename "$f" | cut -d. -f3)
  c=$(grep 'Concordant:' "$f" | awk '{print $2}')
  alt=$(grep 'Dominant alternative:' "$f" | awk '{print $3}')
  conf=$(grep 'Conflicting:' "$f" | awk '{print $2}')
  total=$((c + alt + conf))
  if [ "$total" -ne 0 ]; then
    disc=$((alt + conf))
    prop=$(echo "scale=4; $disc / $total" | bc)
  else
    prop="NA"
  fi

  clade=$(grep "node$node:" ${PREFIX}.node.key | cut -d: -f2- | sed 's/^ *//')
  echo "$node,\"$clade\",$prop" >> discordance_summary.csv
done
