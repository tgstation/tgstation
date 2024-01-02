/**
 * We are modularly making stuff we don't want, early return.
 * We can manually re-add whatever we need here as well.
 */
/datum/controller/subsystem/mapping
	///List of all ships that can be purchased.
	var/list/datum/map_template/shuttle/voidcrew/ship_purchase_list = list()
	///List of all Nanotrasen ships, one is randomly selected to spawn at start.
	var/list/datum/map_template/shuttle/voidcrew/nt_ship_list = list()
	///List of all Syndicate ships, one is randomly selected to spawn at start.
	var/list/datum/map_template/shuttle/voidcrew/syn_ship_list = list()

	/**
	 * RUIN TEMPLATES
	 */
	var/list/space_ruins_templates = list()
	var/list/lava_ruins_templates = list()
	var/list/ice_ruins_templates = list()
	var/list/jungle_ruins_templates = list()
	var/list/beach_ruins_templates = list()
	var/list/wasteland_ruins_templates = list()
	var/list/yellow_ruins_templates = list()

/datum/controller/subsystem/mapping/Initialize(timeofday)
	load_ship_templates()
	return ..()

/datum/controller/subsystem/mapping/loadWorld()
	InitializeDefaultZLevels()

/datum/controller/subsystem/mapping/preloadRuinTemplates()
	. = ..()
/* This is all taken from parent */
	// Still supporting bans by filename
	var/list/banned = generateMapList("spaceruinblacklist.txt")
	if(config.minetype == "lavaland")
		banned += generateMapList("lavaruinblacklist.txt")
	else if(config.blacklist_file)
		banned += generateMapList(config.blacklist_file)

	for(var/item in sort_list(subtypesof(/datum/map_template/ruin), GLOBAL_PROC_REF(cmp_ruincost_priority)))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()
		if(banned.Find(R.mappath))
			continue
/* Custom code below. */
		if(istype(R, /datum/map_template/ruin/lavaland))
			lava_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/jungle))
			jungle_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/beach))
			beach_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/wasteland))
			wasteland_ruins_templates[R.name] = R

		else if(istype(R, /datum/map_template/ruin/icemoon))
			ice_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/space))
			space_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/reebe))
			yellow_ruins_templates[R.name] = R

/datum/controller/subsystem/mapping/generate_linkages_for_z_level(z_level)
	if(!isnum(z_level) || z_level <= 0)
		return FALSE

	if(multiz_levels.len < z_level)
		multiz_levels.len = z_level

	// TODO - MULTI-Z
	multiz_levels[z_level] = list()

/datum/controller/subsystem/mapping/setup_map_transitions()
	return

///generates the list of GLOB.the_station_areas - We don't have a station, maybe we can make use of this one day for ships.
/datum/controller/subsystem/mapping/generate_station_area_list()
	return

/// Only thing we want to do here is setup planetary atmos as needed
/datum/controller/subsystem/mapping/setup_ruins()
	var/datum/gas_mixture/immutable/planetary/lavaland_air = new
	lavaland_air.parse_string_immutable(LAVALAND_DEFAULT_ATMOS)
	SSair.planetary[LAVALAND_DEFAULT_ATMOS] = lavaland_air

/datum/controller/subsystem/mapping/proc/load_ship_templates()
	SHOULD_CALL_PARENT(TRUE)
	if(ship_purchase_list.len) //don't build repeatedly
		return

	for(var/datum/map_template/shuttle/voidcrew/shuttles as anything in subtypesof(/datum/map_template/shuttle/voidcrew))
		ship_purchase_list["[initial(shuttles.name)] ([initial(shuttles.faction_prefix)] [initial(shuttles.part_cost)] part\s)"] = shuttles

		switch(initial(shuttles.faction_prefix))
			if(NANOTRASEN_SHIP)
				nt_ship_list[initial(shuttles.name)] = shuttles
			if(SYNDICATE_SHIP)
				syn_ship_list[initial(shuttles.name)] = shuttles

/datum/controller/subsystem/mapping/get_station_center()
	return SSovermap.overmap_centre || locate(OVERMAP_LEFT_SIDE_COORD, OVERMAP_NORTH_SIDE_COORD, OVERMAP_Z_LEVEL)

/datum/controller/subsystem/mapping/get_turf_above(turf/T)
	return SSovermap.calculate_turf_above(T)

/datum/controller/subsystem/mapping/get_turf_below(turf/T)
	return SSovermap.calculate_turf_below(T)
