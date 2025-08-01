#!/bin/bash
set -e

ORIGINAL="dist/github-contribution-grid-snake.svg"
TARGET="img/svg/snake/snake_updated.svg"

mkdir -p img/svg/snake

BORDER='<rect x="-16" y="-32" width="880" height="192" rx="20" ry="20" fill="none" stroke="#999" stroke-width="2"/>'

echo "$(cat "$ORIGINAL")" | sed "s|<svg[^>]*>|&\n$BORDER|" > "$TARGET"
