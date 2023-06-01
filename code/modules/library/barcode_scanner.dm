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
	///The scan mode we are currently on.
	///Selections: BARCODE_SCANNER_CHECKIN: check in books, BARCODE_SCANNER_INVENTORY: add scanned books to inventory.
	var/scan_mode = BARCODE_SCANNER_CHECKIN

/obj/item/barcodescanner/attack_self(mob/user)
	. = ..()
	if(!computer_ref?.resolve())
		user.balloon_alert(user, "not connected to computer!")
		return
	scan_mode = !scan_mode
	if(scan_mode)
		user.balloon_alert(user, "inventory adding mode")
	else
		user.balloon_alert(user, "check-in mode")
