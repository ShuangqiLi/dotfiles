#!/bin/bash
out=$(mo status --json 2>/dev/null | /usr/bin/jq -r '
  (.cpu.usage|floor) as $c
  | (.memory.used_percent|floor) as $m
  | (.gpu[0].usage // -1) as $g
  | "C:\($c)% M:\($m)%" + (if $g>=0 then " G:\($g)%" else "" end)
')
if [ -n "$out" ]; then
  printf '%s' "$out"
fi
