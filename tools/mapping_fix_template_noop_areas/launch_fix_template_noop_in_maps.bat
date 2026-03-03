@echo off
setlocal

set PY_SCRIPT=fix_template_noop_in_maps.py

REM Example: search the SpaceRuins folder relative to git root
python "%PY_SCRIPT%" "_maps\RandomRuins\SpaceRuins"

endlocal
