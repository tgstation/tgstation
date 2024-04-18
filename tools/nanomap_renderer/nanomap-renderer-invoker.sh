#!/bin/bash
set -e
# Generate maps
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/Birdshot/birdshot.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/Deltastation/DeltaStation2.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/IceBoxStation/IceBoxStation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/MetaStation/MetaStation.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/Northstar/north_star.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 "./_maps/map_files/tramstation/tramstation.dmm"
# Move and rename files so the game understands them
cd "data/nanomaps"
mv "birdshot_nanomap_z1.png" "Birdshot Station_nanomap_z1.png"
mv "DeltaStation2_nanomap_z1.png" "Delta Station_nanomap_z1.png"
mv "IceBoxStation_nanomap_z1.png" "Ice Box Station_nanomap_z1.png"
mv "MetaStation_nanomap_z1.png" "MetaStation_nanomap_z1.png"
mv "north_star_nanomap_z1.png" "NorthStar_nanomap_z1.png"
mv "tramstation_nanomap_z1.png" "Tramstation_nanomap_z1.png"
cd "../../"
cp "data/nanomaps/Birdshot Station_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Delta Station_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Ice Box Station_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/MetaStation_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/NorthStar_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Tramstation_nanomap_z1.png" "icons/_nanomaps"
