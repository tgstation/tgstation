MEMCOUNTER=0
for f in $(find ../../ -name "*.dmi" -o "*.png") ; do
	MEMCOUNTER=$(($MEMCOUNTER+$(stat -c %s $f)));
done;
echo $MEMCOUNTER;
