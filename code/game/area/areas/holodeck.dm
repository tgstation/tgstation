/area/station/holodeck
	name = "Holodeck"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "Holodeck"
	static_lighting = FALSE

	base_lighting_alpha = 255
	flags_1 = NONE
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL

	var/obj/machinery/computer/holodeck/linked
	var/restricted = FALSE // if true, program goes on emag list
/*
	Power tracking: Use the holodeck computer's power grid
	Asserts are to avoid the inevitable infinite loops
*/

/area/station/holodeck/powered(chan)
	if(!requires_power)
		return TRUE
	if(always_unpowered)
		return FALSE
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/station/holodeck))
	return A.powered(chan)

/area/station/holodeck/addStaticPower(value, powerchannel)
	if(!linked)
		return
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/station/holodeck))
	return ..()

/area/station/holodeck/use_energy(amount, chan)
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/station/holodeck))
	return ..()


/*
	This is the standard holodeck.  It is intended to allow you to
	blow off steam by doing stupid things like laying down, throwing
	spheres at holes, or bludgeoning people.
*/
/area/station/holodeck/rec_center
	name = "\improper Recreational Holodeck"

// Don't move this to be organized like with most areas, theres too much touching holodeck code as is
/area/station/holodeck/rec_center/offstation_one
	name = "\improper Recreational Holodeck"
