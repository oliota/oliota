#!/bin/bash
set -e

ORIGINAL="dist/github-contribution-grid-snake.svg"
TARGET="img/svg/snake/snake_updated.svg"

mkdir -p img/svg/snake

BORDER='<rect x="-16" y="-32" width="880" height="192" rx="20" ry="20" fill="none" stroke="#000" stroke-width="2"/>'

WIDTH=880
PADDING=16
USABLE_WIDTH=$((WIDTH - 2 * PADDING))

CURRENT_MONTH=$(date +%-m)
CURRENT_YEAR=$(date +%Y)

MONTH_NAMES=(January February March April May June July August September October November December)

declare -a MONTHS=()
declare -a YEARS=()
for ((i=0; i<12; i++)); do
  IDX=$((CURRENT_MONTH - 11 + i))
  YEAR=$CURRENT_YEAR
  if (( IDX <= 0 )); then
    IDX=$((IDX + 12))
    YEAR=$((YEAR - 1))
  elif (( IDX > 12 )); then
    IDX=$((IDX - 12))
    YEAR=$((YEAR + 1))
  fi
  MONTHS[$i]=${MONTH_NAMES[$((IDX - 1))]}
  YEARS[$i]=$YEAR
done

LABELS=""
declare -A YEAR_RANGES=()

for i in "${!MONTHS[@]}"; do
  NAME=${MONTHS[$i]}
  YEAR=${YEARS[$i]}
  PERCENT=$(awk "BEGIN { printf \"%.4f\", ($i + 0.5)/12 }")
  X=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * $PERCENT) }")
  LABELS="${LABELS}<text x=\"$X\" y=\"0\" font-size=\"12\" fill=\"#666\" text-anchor=\"middle\">$NAME</text>\n"

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

YEARS_SORTED=($(echo "${!YEAR_RANGES[@]}" | tr ' ' '\n' | sort))

for YEAR in "${YEARS_SORTED[@]}"; do
  IFS=':' read -r START END <<< "${YEAR_RANGES[$YEAR]}"

  if [[ $YEAR == "${YEARS_SORTED[0]}" ]]; then
    X1=0
    X2=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * (($END + 1) / 12)) }")
    X2=$((X2 + PADDING))
  else
    X1=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * $START / 12) }")
    X2=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * (($END + 1) / 12)) }")
  fi

  LABELS="${LABELS}<line x1=\"$X1\" y1=\"-15\" x2=\"$X2\" y2=\"-15\" stroke=\"#000\" stroke-width=\"2\" />\n"
  LABELS="${LABELS}<text x=\"$(( (X1 + X2) / 2 ))\" y=\"-20\" font-size=\"14\" fill=\"#000\" text-anchor=\"middle\">$YEAR</text>\n"
done

for ((i=0; i < ${#YEARS_SORTED[@]} - 1; i++)); do
  CUR_YEAR=${YEARS_SORTED[$i]}
  CUR_END=${YEAR_RANGES[$CUR_YEAR]##*:}
  XV=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * (($CUR_END + 1) / 12)) }")
  LABELS="${LABELS}<line x1=\"$XV\" y1=\"-15\" x2=\"$XV\" y2=\"0\" stroke=\"#000\" stroke-width=\"2\" />\n"
done

sed "s|<svg[^>]*>|&\n$BORDER\n$LABELS|" "$ORIGINAL" > "$TARGET"
