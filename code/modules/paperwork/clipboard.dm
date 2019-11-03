/obj/item/storage/bag/clipboard
	name = "clipboard"
	desc = "A cheap clipboard, it seems to have a magnetic strip for common bureaucratic tools."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	var/top = FALSE

/obj/item/storage/bag/clipboard/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/bag/clipboard/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 30
	STR.max_items = 14
	STR.insert_preposition = "on"
	STR.set_holdable(list(/obj/item/paper,
						  /obj/item/pen,
						  /obj/item/stamp,
						  /obj/item/ticket_machine_ticket,
						  /obj/item/toy/crayon,
						  /obj/item/photo,
						  /obj/item/laser_pointer))

/obj/item/storage/bag/clipboard/update_icon()
	cut_overlays()
	var/top = FALSE
	for(var/obj/item/I in contents)
		if(!top && istype(I, /obj/item/paper))
			top = TRUE
			var/obj/item/paper/P = I
			var/list/dat = list()
			dat += P.icon_state
			dat += P.overlays.Copy()
			add_overlay(dat)
		if(istype(I, /obj/item/pen))
			add_overlay("clipboard_pen")
		if(istype(I, /obj/item/stamp))
			add_overlay("clipboard_stamp")
	add_overlay("clipboard_over")

/obj/item/storage/bag/clipboard/Entered()
	. = ..()
	update_icon()

/obj/item/storage/bag/clipboard/Exited()
	. = ..()
	update_icon()
