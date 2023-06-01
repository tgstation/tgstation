/obj/item/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	desc = "A fabulous tool if you need to scan a barcode."
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	///Weakref to the library computer we are connected to.
	var/datum/weakref/computer_ref
	///Boolean on what mode we're scanning. TRUE is inventory mode, FALSE is check-in mode.
	var/scan_mode = FALSE

/obj/item/barcodescanner/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!computer_ref?.resolve())
		user.balloon_alert(user, "not connected to computer!")
		return
	scan_mode = !scan_mode
	if(scan_mode)
		user.balloon_alert(user, "inventory adding mode")
	else
		user.balloon_alert(user, "check-in mode")
