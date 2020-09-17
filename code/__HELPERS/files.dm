/client/proc/browse_files(root_type=BROWSE_ROOT_ALL_LOGS, max_iterations=10, list/valid_extensions=list("txt","log","htm", "html"))
	// wow why was this ever a parameter
	var/root = "data/logs/"
	switch(root_type)
		if(BROWSE_ROOT_ALL_LOGS)
			root = "data/logs/"
		if(BROWSE_ROOT_CURRENT_LOGS)
			root = "[GLOB.log_directory]/"
	var/path = root

	for(var/i=0, i<max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1,"/")

		var/choice = input(src,"Choose a file to access:","Download",null) as null|anything in sortList(choices)
		switch(choice)
			if(null)
				return
			if("/")
				path = root
				continue
		path += choice

		if(copytext_char(path, -1) != "/")		//didn't choose a directory, no need to iterate again
			break
	var/extensions
	for(var/i in valid_extensions)
		if(extensions)
			extensions += "|"
		extensions += "[i]"
	var/regex/valid_ext = new("\\.([extensions])$", "i")
	if( !fexists(path) || !(valid_ext.Find(path)) )
		to_chat(src, "<font color='red'>Error: browse_files(): File not found/Invalid file([path]).</font>")
		return

	return path

#define FTPDELAY 200	//200 tick delay to discourage spam
#define ADMIN_FTPDELAY_MODIFIER 0.5		//Admins get to spam files faster since we ~trust~ them!
/*	This proc is a failsafe to prevent spamming of file requests.
	It is just a timer that only permits a download every [FTPDELAY] ticks.
	This can be changed by modifying FTPDELAY's value above.

	PLEASE USE RESPONSIBLY, Some log files can reach sizes of 4MB!	*/
/client/proc/file_spam_check()
	var/time_to_wait = GLOB.fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: file_spam_check(): Spam. Please wait [DisplayTimeText(time_to_wait)].</font>")
		return TRUE
	var/delay = FTPDELAY
	if(holder)
		delay *= ADMIN_FTPDELAY_MODIFIER
	GLOB.fileaccess_timer = world.time + delay
	return FALSE
#undef FTPDELAY
#undef ADMIN_FTPDELAY_MODIFIER

/proc/pathwalk(path)
	var/list/jobs = list(path)
	var/list/filenames = list()

	while(jobs.len)
		var/current_dir = pop(jobs)
		var/list/new_filenames = flist(current_dir)
		for(var/new_filename in new_filenames)
			// if filename ends in / it is a directory, append to currdir
			if(findtext(new_filename, "/", -1))
				jobs += current_dir + new_filename
			else
				filenames += current_dir + new_filename
	return filenames

/proc/pathflatten(path)
	return replacetext(path, "/", "_")

/// Returns the md5 of a file at a given path.
/proc/md5filepath(path)
	. = md5(file(path))

/// Save file as an external file then md5 it.
/// Used because md5ing files stored in the rsc sometimes gives incorrect md5 results.
/proc/md5asfile(file)
	var/filename = file2filepath(file)
	var/istmp = FALSE
	if (!filename || length(filename) < 1)
		// its importaint this code can handle md5filepath sleeping instead of hard blocking, if it's converted to use rust_g.
		filename = generate_tmp_filepath("md5asfile")
		fcopy(file, filename)
		istmp = TRUE
	. = md5filepath(filename)
	if (istmp)
		fdel(filename)

/// Generate a unique filepath inside the tmp folder.
/// namespace - a optional string to prepend to the filename, useful for knowing what isn't cleaning up their things in the tmp folder
/proc/generate_tmp_filepath(namespace = "tmpfile")
	var/static/notch = 0
	. = "tmp/[namespace].[world.realtime].[world.timeofday].[world.time].[world.tick_usage].[notch]"
	notch = WRAP(notch+1, 0, 2^15)
	
/// Returns the filepath a given file reference can be found at.
/// returns null if the file exists only in the rsc (modified icons), in those cases just fcopy() the file to the tmp folder and clean it up when you are done
/// file_or_icon - A file, rsc cache reference, or /icon.
/proc/file2filepath(file_or_icon)
	if (istype(file_or_icon, /icon))
		var/icon/I = file_or_icon
		file_or_icon = I.icon //undocumented var, stores the actual file reference the icon is at, almost always a rsc cache entry
	if (!isfile(file_or_icon))
		CRASH("file2filepath: unknown input: [file_or_icon] (\ref[file_or_icon]) - [json_encode(file_or_icon)]")
	. = "[locate("\ref[file_or_icon]")]"
	if (length(.) < 1)
		return null
		




