/obj/item/storage/exosuit
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 18

/obj/exosuit
	name = "exosuit"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "engineering_pod"

	max_integrity = 50
	obj_integrity = 50

	var/move_delay = 2
	var/move_power = 2

	var/next_move = 0

	var/movement = MULTIMOVE
	var/features = HAS_RADIO|HAS_INTERNALS|HAS_TEMPCONTROL|HAS_STORAGE

	var/gps_name = "EXO1"

	var/mob/living/list/occupants = list()
	var/obj/item/storage/exosuit/internal_storage
	var/obj/item/device/radio/internal_radio
	var/obj/item/device/gps/internal_gps

	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell

	var/datum/gas_mixture/cabin_air

/obj/exosuit/Initialize()
	. = ..()
	if(features & HAS_STORAGE)
		internal_storage = new
	if(features & HAS_RADIO)
		internal_radio = new
		internal_radio.subspace_transmission = TRUE
	if(features & HAS_INTERNALS)
		cabin_air = new
		cabin_air.temperature = T20C
		cabin_air.volume = 200
		cabin_air.assert_gases("o2","n2")
		cabin_air.gases["o2"][MOLES] = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
		cabin_air.gases["n2"][MOLES] = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	if(features & HAS_GPS)
		internal_gps = new
		internal_gps.gpstag = gps_name
	cell = new cell_type

/obj/exosuit/proc/canmove()
	if(!obj_integrity)
		return FALSE
	if(features & NO_POWER)
		return TRUE
	if(cell && cell.use(move_power))
		return TRUE
	return FALSE

/obj/exosuit/Process_Spacemove(direction)
	. = ..(direction)
	if((movement & MULTIMOVE) || (movement & SPACEMOVE_ONLY))
		. = TRUE

/obj/exosuit/proc/move_override(mob/user, direction)
	return FALSE

/obj/exosuit/proc/on_move(turf/T)
	return FALSE

/obj/exosuit/relaymove(mob/user, direction)
	if(occupants[user] && occupants[user] != OCCUPANT_CAN_DRIVE)
		return FALSE
	if(world.time < next_move)
		return FALSE
	if(canmove())
		setDir(direction)
		if(!move_override(user, direction))
			if(!Process_Spacemove(direction))
				return FALSE
			. = Move(get_step(src, direction), direction)
			on_move(get_turf(src))
			next_move = world.time + move_delay