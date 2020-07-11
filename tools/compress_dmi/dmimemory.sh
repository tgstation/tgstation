MEMCOUNTER=0
for f in $(find ../../ -name "*.dmi") ; do
	MEMCOUNTER=$(($MEMCOUNTER+$(stat -c %s $f)));
done;
echo $MEMCOUNTER;
