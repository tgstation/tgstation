/obj/item/gun/energy/disabler/personal
	name = "personal self-defense disabler"
	desc = "The Personal Self-Defense disabler is a small disabler, originally intended for self-defense. However, product testing in the field revealed arming crewmembers with weaponry en masse - of any kind - was a bad idea. Who would have thought?"
	icon = 'modular_frontier/modules/PSDForTraitors/icons/obj/guns/energy.dmi'
	icon_state = "personal"
	w_class = WEIGHT_CLASS_TINY // Just enough to stash just about anywhere.
	cell_type = /obj/item/stock_parts/cell{charge = 300; maxcharge = 300} // Can disable one person with two shots leeway.
	ammo_x_offset = 2
	charge_sections = 2
	can_flashlight = FALSE // This is a bare-bones weapon, no fancy features like these newfangled 'flash-lights'
	flight_x_offset = 13
	flight_y_offset = 12