/// Scan only
#define SCAN_ONLY 0
/// Scan and set buffer
#define SET_BUFFER 1
/// Scan and attempt to check in
#define CHECK_IN CHECK_IN
/// Scan and attempt to add to inventory
#define ADD_INVENTORY 3

/*
 * Barcode Scanner
 */
/obj/item/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	desc = "A fabulous tool if you need to scan a barcode."
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	/// A weakref to our associated computer - Modes SET_BUFFER to ADD_INVENTORY use this
	var/datum/weakref/computer_ref
	/// Currently scanned book
	var/datum/book_info/book_data
	/// Mode for the scanner
	var/mode = SCAN_ONLY

/obj/item/barcodescanner/attack_self(mob/user)
	mode += 1
	if(mode > ADD_INVENTORY)
		mode = SCAN_ONLY
	to_chat(user, "[src] Status Display:")
	var/modedesc
	switch(mode)
		if(SCAN_ONLY)
			modedesc = "Scan book to local buffer."
		if(SET_BUFFER)
			modedesc = "Scan book to local buffer and set associated computer buffer to match."
		if(CHECK_IN)
			modedesc = "Scan book to local buffer, attempt to check in scanned book."
		if(ADD_INVENTORY)
			modedesc = "Scan book to local buffer, attempt to add book to general inventory."
		else
			modedesc = "ERROR"
	to_chat(user, " - Mode [mode] : [modedesc]")
	if(computer_ref?.resolve())
		to_chat(user, "<font color=green>Computer has been associated with this unit.</font>")
	else
		to_chat(user, "<font color=red>No associated computer found. Only local scans will function properly.</font>")
	to_chat(user, "\n")

#undef SCAN_ONLY
#undef SET_BUFFER
#undef CHECK_IN
#undef ADD_INVENTORY
