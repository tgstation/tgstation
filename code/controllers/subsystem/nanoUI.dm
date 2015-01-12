var/datum/subsystem/nano/SSnano

/datum/subsystem/nano
	name = "NanoUI"
	can_fire = 1
	wait = 5
	priority = 16

	var/list/open_uis = list()			//a list of current open /nanoui UIs, grouped by src_object and ui_key
	var/list/processing_uis = list()	//a list of current open /nanoui UIs, not grouped, for use in processing


/datum/subsystem/nano/New()
	NEW_SS_GLOBAL(SSnano)


/datum/subsystem/nano/stat_entry()
	stat(name, "[round(cost,0.001)]ds (CPU:[round(cpu,1)]%) [processing_uis.len]")


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