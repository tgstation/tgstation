///Machinery that blocks nebula's and generates gasses. This is just for easy of use, you don't need to use this subtype
/obj/machinery/nebula_shielding
	density = TRUE

	icon = 'icons/obj/machines/nebula_shielding.dmi'
	pixel_x = -16

	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE

	///Strength of the shield we apply
	var/shielding_strength
	///The type of nebula that we shield against
	var/nebula_type
	///How much power we use every time we block the nebula's effects
	var/power_use_per_block = BASE_MACHINE_ACTIVE_CONSUMPTION * 2
	///State we use when actively blocking a nebula
	var/active_icon_state

/obj/machinery/nebula_shielding/Initialize(mapload)
	. = ..()

	add_to_nebula_shielding(src, nebula_type, PROC_REF(get_nebula_shielding))

/obj/machinery/nebula_shielding/proc/get_nebula_shielding()
	if(!powered())
		icon_state = initial(icon_state)
		return

	use_power_from_net(power_use_per_block)
	generate_reward()
	icon_state = active_icon_state
	return shielding_strength

/obj/machinery/nebula_shielding/proc/generate_reward()
	return

/obj/machinery/nebula_shielding/emergency
	density = TRUE
	anchored = FALSE //so some handsome rogue could potentially move it off the station z-level
	shielding_strength = 999 //should block the nebula completely

	///How long we work untill we self-destruct
	var/detonate_in = 10 MINUTES

/obj/machinery/nebula_shielding/emergency/Initialize()
	. = ..()

	addtimer(CALLBACK(src, PROC_REF(self_destruct)), detonate_in)

/obj/machinery/nebula_shielding/emergency/proc/self_destruct()
	explosion(src, light_impact_range = 5, flame_range = 3, explosion_cause = src)
	qdel(src)

/obj/machinery/nebula_shielding/emergency/examine(mob/user)
	. = ..()

	. += span_notice("Will block the nebula for [round(detonate_in / MINUTES)] minutes with a shield strength of [shielding_strength].")

/obj/machinery/nebula_shielding/emergency/get_nebula_shielding()
	return shielding_strength //no strings attached, we will always produce shielding

/obj/machinery/nebula_shielding/emergency/generate_reward()
	return //no reward for you

/obj/machinery/nebula_shielding/radiation
	name = "radioactive nebula shielder"
	desc = "Generates a field around the station, protecting it from a radioactive nebula."

	icon_state = "radioactive_shielding"
	active_icon_state = "radioactive_shielding_on"

	nebula_type = /datum/station_trait/nebula/hostile/radiation
	shielding_strength = 4

/obj/machinery/nebula_shielding/radiation/examine(mob/user)
	. = ..()

	. += span_notice("Passively generates tritium. Provides [shielding_strength] levels of nebula shielding when active.")

/obj/machinery/nebula_shielding/radiation/generate_reward()
	var/turf/open/turf = get_turf(src)
	if(isopenturf(turf))
		turf.atmos_spawn_air("[GAS_TRITIUM]=4;[TURF_TEMPERATURE(T20C)]")

/obj/machinery/nebula_shielding/emergency/radiation
	name = "emergency nebula radiation shielder"
	desc = "Generates a field around the station to protect it from a radioactive nebula."

	icon = 'icons/obj/power.dmi'
	icon_state = "portgen1_1"
	pixel_x = 0

	nebula_type = /datum/station_trait/nebula/hostile/radiation

/obj/machinery/nebula_shielding/emergency/radiation/self_destruct()
	var/turf/open/turf = get_turf(src)
	if(isopenturf(turf))
		turf.atmos_spawn_air("[GAS_TRITIUM]=50;[TURF_TEMPERATURE(T20C)]")

	..()
