/// Subtype for escape pod ports so that we can give them trait behaviour
/obj/docking_port/stationary/escape_pod
	name = "escape pod loader"
	height = 5
	width = 3
	dwidth = 1
	roundstart_template = /datum/map_template/shuttle/escape_pod/default
	/// Set to true if you have a snowflake escape pod dock which needs to always have the normal pod or some other one
	var/enforce_specific_pod = FALSE

/obj/docking_port/stationary/escape_pod/Initialize(mapload)
	. = ..()
	if (enforce_specific_pod)
		return

	if (HAS_TRAIT(SSstation, STATION_TRAIT_SMALLER_PODS))
		roundstart_template = /datum/map_template/shuttle/escape_pod/cramped
		return
	if (HAS_TRAIT(SSstation, STATION_TRAIT_BIGGER_PODS))
		roundstart_template = /datum/map_template/shuttle/escape_pod/luxury

// should fit the syndicate infiltrator, and smaller ships like the battlecruiser corvettes and fighters
/obj/docking_port/stationary/syndicate
	name = "near the station"
	dheight = 1
	dwidth = 12
	height = 17
	width = 23
	shuttle_id = "syndicate_nearby"

/obj/docking_port/stationary/syndicate/northwest
	name = "northwest of station"
	shuttle_id = "syndicate_nw"

/obj/docking_port/stationary/syndicate/northeast
	name = "northeast of station"
	shuttle_id = "syndicate_ne"

/obj/docking_port/stationary/transit
	name = "In Transit"
	override_can_dock_checks = TRUE
	/// The turf reservation returned by the transit area request
	var/datum/turf_reservation/reserved_area
	/// The area created during the transit area reservation
	var/area/shuttle/transit/assigned_area
	/// The mobile port that owns this transit port
	var/obj/docking_port/mobile/owner

/obj/docking_port/stationary/transit/Initialize(mapload)
	. = ..()
	SSshuttle.transit_docking_ports += src

/obj/docking_port/stationary/transit/Destroy(force=FALSE)
	if(force)
		if(get_docked())
			log_world("A transit dock was destroyed while something was docked to it.")
		SSshuttle.transit_docking_ports -= src
		if(owner)
			if(owner.assigned_transit == src)
				owner.assigned_transit = null
			owner = null
		if(!QDELETED(reserved_area))
			qdel(reserved_area)
		reserved_area = null
	return ..()

/obj/docking_port/stationary/picked
	///Holds a list of map name strings for the port to pick from
	var/list/shuttlekeys

/obj/docking_port/stationary/picked/Initialize(mapload)
	. = ..()
	if(!LAZYLEN(shuttlekeys))
		WARNING("Random docking port [shuttle_id] loaded with no shuttle keys")
		return
	var/selectedid = pick(shuttlekeys)
	roundstart_template = SSmapping.shuttle_templates[selectedid]

/obj/docking_port/stationary/picked/whiteship
	name = "Deep Space"
	shuttle_id = "whiteship_away"
	height = 45 //Width and height need to remain in sync with the size of whiteshipdock.dmm, otherwise we'll get overflow
	width = 44
	dheight = 18
	dwidth = 18
	dir = 2
	shuttlekeys = list(
		"whiteship_meta",
		"whiteship_pubby",
		"whiteship_box",
		"whiteship_cere",
		"whiteship_kilo",
		"whiteship_donut",
		"whiteship_delta",
		"whiteship_tram",
		"whiteship_personalshuttle",
		"whiteship_obelisk",
		"whiteship_birdshot",
	)

