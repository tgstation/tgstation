//CONTAINS: Detective's Scanner

// TODO: Split everything into easy to manage procs.

/obj/item/device/detective_scanner
	name = "forensic scanner"
	desc = "don't use this"
	icon_state = "forensicnew"
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	var/scanning = 0
	var/list/log = list()
	origin_tech = "engineering=4;biotech=2;programming=5"
	var/range = 8
	var/view_check = TRUE

