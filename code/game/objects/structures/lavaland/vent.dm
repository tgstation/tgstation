/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent
	name = "bluespace vent"
	desc = "A vent, outputting a constant stream of gas into the atmosphere. Strangely, the surroundings don't seem to be pressuized, and the gas is flickering..."
	icon = 'icons/obj/lavaland/vent.dmi'
	icon_state = "ventflicker"
	anchored = TRUE
	can_unwrench = FALSE
	pixel_x = -16
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	
	var/gas_types = LAVALAND_DEFAULT_ATMOS // What kind of gasses it can pick from, either a atmosphere type or a string
	var/naturally_spawned = FALSE // Naturally spawned vents have this set to TRUE. This is so these can be manually spawned without having the vent immediately qdel itself if other vents already exist.
	var/gastype = null
	var/vent_id = null // By default, just the z-level it spawns on. Natural vents of the same ID will not have duplicate gases

/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/LateInitialize()
	var/turf/T = loc

	if(!isopenturf(T))
		return

	if(!vent_id)
		vent_id = src.z

	var/list/possible_gases = list()

	var/datum/gas_mixture/gastypes = new type

	gastypes.parse_gas_string(gas_types)

	for(var/gas in gastypes)
		if(gastypes[gas][MOLES] > 0)
			possible_gases += gas

	var/list/remaining_gases = possible_gases

	for(var/vent in GLOB.atmospheric_vents)
		var/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/V = vent
		if(V.vent_id == vent_id)
			remaining_gases -= V.gastype

	gastype = pick([remaining_gases.len ? available_gases : possible_gases]) // If we have one of each, just spawn at random now

	GLOB.atmospheric_vents += src


/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/Destroy()
	GLOB.atmospheric_vents -= src
	return ..()
