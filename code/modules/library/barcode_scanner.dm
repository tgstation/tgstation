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
	///The current scanning mode (BARCODE_SCANNER_CHECKIN|BARCODE_SCANNER_INVENTORY)
	var/scan_mode = BARCODE_SCANNER_CHECKIN

/obj/item/barcodescanner/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!computer_ref?.resolve())
		user.balloon_alert(user, "not connected to computer!")
		return
	switch(scan_mode)
		if(BARCODE_SCANNER_CHECKIN)
			scan_mode = BARCODE_SCANNER_INVENTORY
			user.balloon_alert(user, "inventory adding mode")
		if(BARCODE_SCANNER_INVENTORY)
			scan_mode = BARCODE_SCANNER_CHECKIN
			user.balloon_alert(user, "check-in mode")
