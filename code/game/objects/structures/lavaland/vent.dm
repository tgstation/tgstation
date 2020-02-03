/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent
	name = "bluespace vent"
	desc = "A vent, outputting a constant stream of gas into the atmosphere. Strangely, the surroundings don't seem to be pressuized, and the gas is flickering..."
	icon = 'icons/obj/lavaland/vent.dmi'
	icon_state = "ventflicker"
	anchored = TRUE
	can_unwrench = FALSE
	pixel_x = -16
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	
	var/naturally_spawned = FALSE // Naturally spawned vents have this set to TRUE. This is so these can be manually spawned without having the vent immediately qdel itself if other vents already exist.
	var/available_gases = LAVALAND_DEFAULT_ATMOS	
	var/gastype = null
	var/vent_id = null // By default, just the z-level it spawns on. Natural vents of the same ID will not have duplicate gases

/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/LateInitialize()
	var/turf/T = loc

	if(!isopenturf(T))
		return

	if(!vent_id)
		vent_id = src.z

	var/list/possible_gases = list()

	for(var/gastype in GLOB.meta_gas_info)
		env.assert_gas(gastype)
	for(var/gas in LAVALAND_DEFAULT_ATMOS)
		if(env.gases[gas][MOLES] > 0)
			possible_gases += gas

	for(var/vent in GLOB.atmospheric_vents)
		var/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/V = vent
		if(V.vent_id == vent_id)
			possible_gases -= V.gastype

	if(!possible_gases.len && naturally_spawned)
		qdel(src)
		return

	GLOB.atmospheric_vents += src

	gastype = pick(possible_gases)

/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/Destroy()
	GLOB.atmospheric_vents -= src
	return ..()
