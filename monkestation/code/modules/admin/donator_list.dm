#define DONATORLISTFILE "[global.config.directory]/monkestation/donators.txt"

GLOBAL_LIST(donator_list)

/proc/load_donators()
	GLOB.donator_list = list()
	for(var/line in world.file2list(DONATORLISTFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.donator_list[ckey(line)] = TRUE //Associative so we can check it much faster

/proc/save_donators()
	/// Yes, this is incredibly long, deal with it. It's to keep that cute little comment at the top.
	var/donators = "###############################################################################################\n# List for people who support us! They get cool loadout items                                 #\n# Case is not important for ckey.                                                             #\n###############################################################################################\n"
	for(var/donator in GLOB.donator_list)
		donators += donator + "\n"
	rustg_file_write(donators, DONATORLISTFILE)

#undef DONATORLISTFILE
