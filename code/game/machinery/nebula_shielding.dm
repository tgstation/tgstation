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
	var/power_use_per_block = BASE_MACHINE_ACTIVE_CONSUMPTION * 10
	///State we use when actively blocking a nebula
	var/active_icon_state

/obj/machinery/nebula_shielding/Initialize(mapload)
	. = ..()

	add_to_nebula_shielding(src, nebula_type, PROC_REF(get_nebula_shielding))

/obj/machinery/nebula_shielding/proc/get_nebula_shielding()
	if(!powered())
		icon_state = initial(icon_state)
		return

	use_power_from_net(BASE_MACHINE_ACTIVE_CONSUMPTION)
	generate_reward()
	icon_state = active_icon_state
	return shielding_strength

/obj/machinery/nebula_shielding/proc/generate_reward()
	return

/obj/machinery/nebula_shielding/radiation
	name = "radioactive nebula shielder"
	desc = "Generates a field around the station, protecting it from a radioactive nebula."

	icon_state = "radioactive_shielding"
	active_icon_state = "radioactive_shielding_on"

	nebula_type = /datum/station_trait/nebula/hostile/radiation
	shielding_strength = 4

/obj/machinery/nebula_shielding/radiation/examine(mob/user)
	. = ..()

	. += span_notice("Generates tritium from the radioactive nebula. Needs to be emptied of tritium to work.")

/obj/machinery/nebula_shielding/radiation/generate_reward()
	var/turf/open/turf = get_turf(src)
	if(isopenturf(turf))
		turf.atmos_spawn_air("[GAS_TRITIUM]=10;[TURF_TEMPERATURE(T20C)]")


