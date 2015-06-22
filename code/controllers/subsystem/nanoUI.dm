var/datum/subsystem/nano/SSnano

/datum/subsystem/nano
	name = "NanoUI"
	can_fire = 1
	wait = 10
	priority = 16

	var/list/open_uis = list()			//a list of current open /nanoui UIs, grouped by src_object and ui_key
	var/list/processing_uis = list()	//a list of current open /nanoui UIs, not grouped, for use in processing

	//List of asset filenames to be sent to the client on user login
	var/list/asset_files = list()


/datum/subsystem/nano/New()
	NEW_SS_GLOBAL(SSnano)

	//Generate list of files to send to client for nano UI's
	var/list/nano_asset_dirs = list(\
		"nano/css/",\
		"nano/images/",\
		"nano/js/",\
		"nano/templates/"\
	)
	var/list/filenames = null
	for (var/path in nano_asset_dirs)
		filenames = flist(path)
		for(var/filename in filenames)
			//Ignore directories
			if(copytext(filename, length(filename)) != "/")
				if(fexists(path + filename))
					asset_files.Add(fcopy_rsc(path + filename))


/datum/subsystem/nano/stat_entry()
	..("P:[processing_uis.len]")


/datum/subsystem/nano/fire()
	var/i=1
	for(var/thing in SSnano.processing_uis)
		if(thing)
			var/datum/nanoui/ui = thing
			if(ui.src_object && ui.user)
				ui.process()
				++i
				continue
		processing_uis.Cut(i, i+1)
