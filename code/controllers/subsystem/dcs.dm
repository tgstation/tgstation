SUBSYSTEM_DEF(dcs)
	name = "Datum Component System"
	flags = SS_NO_INIT | SS_NO_FIRE

/datum/controller/subsystem/dcs/Recover()
	comp_lookup = SSdcs.comp_lookup
