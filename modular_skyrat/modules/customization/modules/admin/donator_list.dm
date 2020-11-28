#define DONATORLISTFILE "[global.config.directory]/skyrat/donators.txt"

GLOBAL_LIST(donator_list)

/proc/load_donators()
	GLOB.donator_list = list()
	for(var/line in world.file2list(DONATORLISTFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.donator_list[ckey(line)] = TRUE //Associative so we can check it much faster

#undef DONATORLISTFILE
