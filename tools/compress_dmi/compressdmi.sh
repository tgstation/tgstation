for f in $(find ../../ -name "*.dmi" -o -name "*.png") ; do
	optipng $f;
done;
