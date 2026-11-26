#!/usr/bin/env bash
# PreToolUse: bloquea git commit / git push (y variantes) ejecutados por Claude o sus subagentes.
# Los autores hacen todos los commits manualmente.
input=$(cat)
if printf '%s' "$input" | grep -qiE '\bgit\b[^|;&"]*\b(commit|push)\b|co-authored-by'; then
     echo "Bloqueado por el proyecto: Claude no puede hacer git commit/push ni añadir Co-Authored-By. Los autores hacen los commits manualmente." >&2
     exit 2
fi
exit 0
