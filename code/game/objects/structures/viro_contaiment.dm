/obj/machinery/puzzle/password/pin/viro
	desc = "A panel that controls Hazardous Gas Door. This one requires a PIN password, so let's start by typing in 1234..."
	password = "424242"
	single_use = FALSE
	pin_length = 6

/obj/machinery/puzzle/password/pin/viro/on_puzzle_complete()
	. = ..()
	for(var/obj/machinery/door/poddoor/viro/door in world)
		if(door.density)
			door.open()


/obj/machinery/door/poddoor/viro

	name = "Hazardous Gas Door"
	desc = "A airtight heavy duty blast door that opens mechanically. Leads to something dangerous."


/obj/machinery/button/viro_steril
	name = "CONTAIMENT BREACH BUTTON"
	desc = "A button for start steril. procedure"

// dont be serious, its fast implementation
// when it will be not draft, it will be replaced
/obj/machinery/button/viro_steril/attempt_press(mob/user)
	. = ..()
	if(!.) // no power, access or something
		return FALSE

	for(var/obj/item/grenade/smokebomb/viro_steri_smoke/grenade in world)
		if(!grenade.dud_flags) // checks, even at fast implementations, yeah
			grenade.detonate()
	playsound(src, 'sound/machines/viro_contaiment_breach.ogg', 50, TRUE)

	var/area/virology_area = locate(/area/station/medical/virology) in GLOB.areas
	if(virology_area)
		remove_plagium_from_area(virology_area)

// dont be serious, its fast implementation
// when it will be not draft, it will be replaced
/obj/machinery/button/viro_steril/proc/remove_plagium_from_area(area/target_area)
	var/turfs_processed = 0

	// getting all turfs at area
	for(var/turf/open/target_turf in get_area_turfs(target_area))
		turfs_processed++
		var/datum/gas_mixture/air = target_turf.return_air()
		if(air && air.gases[/datum/gas/plagium])
			var/list/plagium_data = air.gases[/datum/gas/plagium]
			var/plagium_moles = plagium_data[MOLES]
			if(plagium_moles > 0)
				// delete plagium
				air.adjust_gas(/datum/gas/plagium, -plagium_moles)

// dont be serious, its fast implementation
// when it will be not draft, it will be replaced
/obj/item/grenade/smokebomb/viro_steri_smoke
	name = "steralisation device"
	desc = "Clean viro from"
	det_time = 0
	icon_state = null
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
