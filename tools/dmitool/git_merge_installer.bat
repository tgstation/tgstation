@echo off
set tab=	
echo. >> ../../.git/config
echo [merge "merge-dmi"] >> ../../.git/config
echo %tab%name = iconfile merge driver >> ../../.git/config
echo %tab%driver = ./tools/dmitool/dmimerge.sh %%O %%A %%B >> ../../.git/config
