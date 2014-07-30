java -jar maptools/MapPatcher.jar -merge $1 $2 $3 $2
if [ "$?" -gt 0 ]
then
    echo "Unable to automatically resolve map conflicts, please merge manually."
    exit 1
fi
java -jar maptools/MapPatcher.jar -clean $1 $2 $2

exit 0
