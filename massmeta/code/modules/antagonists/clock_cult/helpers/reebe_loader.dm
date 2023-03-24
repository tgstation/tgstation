/proc/LoadReebe()
	//Don't load reebe twice in case something happens
	var/static/reebe_loaded = FALSE
	if(reebe_loaded)
		return
	var/datum/map_template/template = new("_maps/templates/clockwork_cityofcogs.dmm", "Reebe")
	template.load_new_z(FALSE, ZTRAITS_REEBE)
	reebe_loaded = TRUE
