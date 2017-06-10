//This is the hippie init file, here we will initialize everything hippie where possible.
//Create a proc to load something in the appropriate module file and call the proc here.

/proc/hippie_initialize()
	load_hippie_config("hippiestation/config/config.txt")
	LAZYCLEARLIST(mentor_datums)