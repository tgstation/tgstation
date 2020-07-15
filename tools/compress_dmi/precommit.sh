 for f in $($(git diff --name-only) & $(find ../../ -name "*.dmi" -o -name "*.png")) ; do
	echo $f;
done;
