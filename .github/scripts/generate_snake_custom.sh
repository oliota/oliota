#!/bin/bash
set -e

ORIGINAL="dist/github-contribution-grid-snake.svg"
TARGET="img/svg/snake/snake_updated.svg"

mkdir -p img/svg/snake

BORDER='<rect x="-16" y="-32" width="880" height="192" rx="20" ry="20" fill="none" stroke="#999" stroke-width="2"/>'

WIDTH=880
PADDING=16
USABLE_WIDTH=$((WIDTH - 2 * PADDING))

CURRENT_MONTH=$(date +%-m)
CURRENT_YEAR=$(date +%Y)

MONTH_NAMES=(January February March April May June July August September October November December)

# Montar array dos últimos 12 meses (nome, ano)
declare -a MONTHS=()
declare -a YEARS=()
for ((i=0; i<12; i++)); do
  IDX=$((CURRENT_MONTH - 11 + i))
  YEAR=$CURRENT_YEAR
  if (( IDX <= 0 )); then
    IDX=$((IDX + 12))
    YEAR=$((YEAR - 1))
  fi
  MONTHS[$i]=${MONTH_NAMES[$((IDX - 1))]}
  YEARS[$i]=$YEAR
done

# Montar labels dos meses e detectar as faixas de ano
LABELS=""
declare -A YEAR_RANGES=()

for i in "${!MONTHS[@]}"; do
  NAME=${MONTHS[$i]}
  YEAR=${YEARS[$i]}
  PERCENT=$(awk "BEGIN { printf \"%.4f\", ($i + 0.5)/12 }")
  X=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * $PERCENT) }")
  LABELS="${LABELS}<text x=\"$X\" y=\"-12\" font-size=\"10\" fill=\"#666\" text-anchor=\"middle\">$NAME</text>\n"

  # Guardar início e fim da faixa do ano
  if [[ -z "${YEAR_RANGES[$YEAR]}" ]]; then
    YEAR_RANGES[$YEAR]="$i:$i"
  else
    RANGE=${YEAR_RANGES[$YEAR]}
    START=${RANGE%%:*}
    END=${RANGE##*:}
    if (( i < START )); then START=$i; fi
    if (( i > END )); then END=$i; fi
    YEAR_RANGES[$YEAR]="$START:$END"
  fi
done

# Montar labels dos anos + linhas horizontais
for YEAR in "${!YEAR_RANGES[@]}"; do
  IFS=':' read -r START END <<< "${YEAR_RANGES[$YEAR]}"
  X1=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * $START / 12) }")
  X2=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * (($END + 1) / 12)) }")
  XMID=$(((X1 + X2) / 2))

  LABELS="${LABELS}<text x=\"$XMID\" y=\"-32\" font-size=\"11\" fill=\"#333\" text-anchor=\"middle\">$YEAR</text>\n"
  LABELS="${LABELS}<line x1=\"$X1\" y1=\"-28\" x2=\"$X2\" y2=\"-28\" stroke=\"#aaa\" stroke-width=\"1\" />\n"
done

# Inserir no SVG
echo "$(cat "$ORIGINAL")" | sed "s|<svg[^>]*>|&\n$BORDER\n$LABELS|" > "$TARGET"
