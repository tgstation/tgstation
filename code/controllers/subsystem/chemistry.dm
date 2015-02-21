var/datum/subsystem/chemistry/SSchemistry

/datum/subsystem/chemistry
	name = "Chemistry"
	priority = 30
	var/list/reagent_datums = list()

/datum/subsystem/chemistry/New()
	NEW_SS_GLOBAL(SSchemistry)

/datum/subsystem/chemistry/proc/add_reagent_datum_to_list(var/datum_dongalongs)
	reagent_datums |= datum_dongalongs

/datum/subsystem/chemistry/stat_entry()
	stat(name, "[round(cost,0.001)]ds (CPU:[round(cpu,1)]%)")


/datum/subsystem/chemistry/fire()
	for(var/datum/reagents/R in reagent_datums)
		R.reagents_on_tick()