for f in $(find ../../ -name "*.dmi" -o "*.png") ; do
	optipng $f;
done;
