//checks if a file exists and contains text
//returns text as a string if these conditions are met
/proc/return_file_text(filename)
	if(fexists(filename) == 0)
		error("File not found ([filename])")
		return

	var/text = file2text(filename)
	if(!text)
		error("File empty ([filename])")
		return

	return text

/proc/get_maps(root="maps/voting/")
	var/list/maps = list()
	var/recursion_limit = 20 //lots of maps waiting to be played, feels like TF2
	//Get our potential maps
	//testing("starting in [root]")
	for(var/potential in flist(root))
		if(copytext(potential,-1,0 != "/")) continue // Not a directory, ignore it.
		//testing("Inside [root + potential]")
		if(!recursion_limit) break
		//our current working directory
		var/path = root + potential
		//The DMB that has the map we want.
		var/binary
		//Looking for a binary
		for(var/binaries in flist(path))
			//testing("Checking file [binaries]")
			if(copytext(binaries,-4,0) == ".dmb")
				binary = binaries
				break
		if(!binary)
			warning("Map folder [path] does not contain a valid byond binary, skipping.")
		else
			maps[potential] = path + binary
		recursion_limit--
	return maps

//Sends resource files to client cache
/client/proc/getFiles()
	for(var/file in args)
		src << browse_rsc(file)

/client/proc/browse_files(root="data/logs/", max_iterations=10, list/valid_extensions=list(".txt",".log",".htm"))
	var/path = root

	for(var/i=0, i<max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1,"/")

		var/choice = input(src,"Choose a file to access:","Download",null) as null|anything in choices
		switch(choice)
			if(null)
				return
			if("/")
				path = root
				continue
		path += choice

		if(copytext(path,-1,0) != "/")		//didn't choose a directory, no need to iterate again
			break

	var/extension = copytext(path,-4,0)
	if( !fexists(path) || !(extension in valid_extensions) )
		src << "<font color='red'>Error: browse_files(): File not found/Invalid file([path]).</font>"
		return

	return path

#define FTPDELAY 200	//200 tick delay to discourage spam
/*	This proc is a failsafe to prevent spamming of file requests.
	It is just a timer that only permits a download every [FTPDELAY] ticks.
	This can be changed by modifying FTPDELAY's value above.

	PLEASE USE RESPONSIBLY, Some log files canr each sizes of 4MB!	*/
/client/proc/file_spam_check()
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		src << "<font color='red'>Error: file_spam_check(): Spam. Please wait [round(time_to_wait/10)] seconds.</font>"
		return 1
	fileaccess_timer = world.time + FTPDELAY
	return 0
#undef FTPDELAY