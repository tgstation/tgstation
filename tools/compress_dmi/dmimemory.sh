MEMCOUNTER=0
for f in $(find ../../ -name "*.dmi" -o -name "*.png") ; do
	MEMCOUNTER=$(($MEMCOUNTER+$(stat -c %s $f)));
done;
echo $MEMCOUNTER;
