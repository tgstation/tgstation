run_updatepaths()
{
	./bootstrap/python -m UpdatePaths "$1"
}

run_updatepaths_all()
{
	scripts=$(find ./scripts -maxdepth 1 -type f -regextype posix-egrep -regex '.*\/([0-9]+)_.*' | sort -n -t_ -k1.1 | sed 's#./##')
	for script in $scripts; do
		echo "Running UpdatePaths with ./scripts/$script"
		run_updatepaths "./scripts/$script"
	done
}

if [ -z "$1" ]; then
	run_updatepaths_all
else
	run_updatepaths "$1"
fi
