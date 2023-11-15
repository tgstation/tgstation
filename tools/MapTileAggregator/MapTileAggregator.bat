@call "%~dp0\..\bootstrap\python.bat" -m MapTileAggregator --posthoc %*
@echo Running the map merger automatically...
@call "%~dp0\..\bootstrap\python.bat" -m mapmerge2.precommit --use-workdir %*
@pause
