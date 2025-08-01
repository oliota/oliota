#!/bin/bash
set -e

ORIGINAL="dist/github-contribution-grid-snake.svg"
TARGET="img/svg/snake/snake_updated.svg"

mkdir -p img/svg/snake

BORDER='<rect x="-16" y="-32" width="880" height="192" rx="20" ry="20" fill="none" stroke="#999" stroke-width="2"/>'

MONTHS=$(date +%-m)
LABELS=""
WIDTH=880
PADDING=32
USABLE_WIDTH=$((WIDTH - 2 * PADDING))

for ((i = 1; i <= MONTHS; i++)); do
  case $i in
    1) name="Jan" ;;
    2) name="Feb" ;;
    3) name="Mar" ;;
    4) name="Apr" ;;
    5) name="May" ;;
    6) name="Jun" ;;
    7) name="Jul" ;;
    8) name="Aug" ;;
    9) name="Sep" ;;
    10) name="Oct" ;;
    11) name="Nov" ;;
    12) name="Dec" ;;
  esac

  percent=$(awk "BEGIN { printf \"%.4f\", ($i - 0.5) / $MONTHS }")
  x=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * $percent) }")
  LABELS="${LABELS}<text x=\"$x\" y=\"-12\" font-size=\"10\" fill=\"#666\" text-anchor=\"middle\">$name</text>\n"
done

echo "$(cat "$ORIGINAL")" | sed "s|<svg[^>]*>|&\n$BORDER\n$LABELS|" > "$TARGET"
