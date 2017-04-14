java -jar tools/dmitool/dmitool.jar merge $1 $2 $3 $2
if [ "$?" -gt 0 ]
then
    echo "Unable to automatically resolve all icon_state conflicts, please merge manually."
    exit 1
fi

exit 0
