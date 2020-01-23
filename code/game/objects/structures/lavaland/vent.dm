/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent
	name = "bluespace vent"
	desc = "A vent, outputting a constant stream of gas into the atmosphere. Strangely, the surroundings don't seem to be pressuized, and the gas is flickering..."
	icon = 'icons/obj/lavaland/vent.dmi'
	icon_state = "ventflicker"
	anchored = TRUE
	can_unwrench = FALSE
	pixel_x = -16
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	has_tank_slot = FALSE
	
	var/naturally_spawned = FALSE // Naturally spawned vents have this set to TRUE. This is so these can be manually spawned without having the vent immediately qdel itself if other vents already exist.
	var/gastype = null

/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/set_gas), 10) // This breaks if done immediately for whatever reason.

/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/proc/set_gas()
	var/turf/T = loc

	if(!isopenturf(T))
		return

	var/datum/gas_mixture/env = T.return_air()
	var/list/possible_gases = list()
	
	for(var/gastype in GLOB.meta_gas_info)
		env.assert_gas(gastype)
	for(var/gas in env.gases)
		if(env.gases[gas][MOLES] > 0)
			possible_gases += gas

	for(var/obj/structure/atmosphere_vent/vent in GLOB.atmospheric_vents)
		if(vent.z == src.z)
			possible_gases -= vent.gastype

	if(!possible_gases.len && naturally_spawned)
		qdel(src)
		return

	GLOB.atmospheric_vents += src

	gastype = pick(possible_gases)

/obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/Destroy()
	. = ..()
	GLOB.atmospheric_vents -= src