java -jar MapPatcher.jar -unpack $1 $1 > /dev/null
java -jar MapPatcher.jar -unpack $2 $2 > /dev/null
java -jar MapPatcher.jar -unpack $3 $3 > /dev/null

cp $2 original.dmm

echo "Map merge conflict, make sure to repack the map with MapPatcher -pack and clean it with MapPatcher -clean original.dmm"
exit 0
