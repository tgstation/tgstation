SUBSYSTEM_DEF(cassette_storage)
	name = "Cassette Storage"
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_LOBBY|RUNLEVELS_DEFAULT
	var/list/cassette_datums = list()


/datum/controller/subsystem/cassette_storage/Initialize()
	if(!length(GLOB.approved_ids))
		GLOB.approved_ids = initialize_approved_ids()
	generate_cassette_datums()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/cassette_storage/proc/generate_cassette_datums()
	for(var/id in GLOB.approved_ids)
		var/datum/cassette_data/new_data = new
		if(!new_data.populate_data(id))
			qdel(new_data)
			continue
		cassette_datums += new_data
