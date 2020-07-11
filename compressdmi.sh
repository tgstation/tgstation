for f in $(find ../../ -name "*.dmi") ; do
	optipng $f;
done;
