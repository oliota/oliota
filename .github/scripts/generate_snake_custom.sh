#!/bin/bash
set -e

ORIGINAL="dist/github-contribution-grid-snake.svg"
TARGET="img/svg/snake/snake_updated.svg"

mkdir -p img/svg/snake

BORDER='<rect x="-16" y="-32" width="880" height="192" rx="20" ry="20" fill="none" stroke="#999" stroke-width="2"/>'

# Configurações do SVG
WIDTH=880
PADDING=32
USABLE_WIDTH=$((WIDTH - 2 * PADDING))

# Mês atual
CURRENT_MONTH=$(date +%-m)
CURRENT_YEAR=$(date +%Y)

# Array de nomes de meses (abreviados em inglês)
MONTH_NAMES=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

# Construir os labels dinâmicos
LABELS=""
for ((i=0; i<12; i++)); do
  INDEX=$((CURRENT_MONTH - 11 + i))
  YEAR=$CURRENT_YEAR
  if (( INDEX <= 0 )); then
    INDEX=$((INDEX + 12))
    YEAR=$((YEAR - 1))
  fi

  NAME=${MONTH_NAMES[INDEX - 1]}
  PERCENT=$(awk "BEGIN { printf \"%.4f\", ($i + 0.5)/12 }")
  X=$(awk "BEGIN { printf \"%d\", $PADDING + ($USABLE_WIDTH * $PERCENT) }")
  LABELS="${LABELS}<text x=\"$X\" y=\"-12\" font-size=\"10\" fill=\"#666\" text-anchor=\"middle\">$NAME</text>\n"
done

# Inserir no SVG original
echo "$(cat "$ORIGINAL")" | sed "s|<svg[^>]*>|&\n$BORDER\n$LABELS|" > "$TARGET"
