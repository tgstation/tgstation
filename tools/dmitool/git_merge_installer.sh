F="../../.git/config"

echo '' >> $F
echo '[merge "merge-dmi"]' >> $F
echo '	name = iconfile merge driver' >> $F
echo '	driver = ./tools/dmitool/dmimerge.sh %O %A %B' >> $F
