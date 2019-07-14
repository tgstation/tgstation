PROCESSING_SUBSYSTEM_DEF(dcs)
	name = "Datum Component System"
	flags = SS_NO_INIT

	var/list/elements_by_type = list()

/datum/controller/subsystem/processing/dcs/Recover()
	comp_lookup = SSdcs.comp_lookup

/datum/controller/subsystem/processing/dcs/proc/GetElement(eletype)
	. = elements_by_type[eletype]
	if(.)
		return
	if(!ispath(eletype, /datum/element))
		CRASH("Attempted to instantiate [eletype] as a /datum/element")
	. = elements_by_type[eletype] = new eletype
