/obj/item/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/service/library.dmi'
	icon_state ="scanner"
	desc = "A fabulous tool if you need to scan a barcode."
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2)
	///Weakref to the library computer we are connected to.
	var/datum/weakref/computer_ref
	///The current scanning mode (BARCODE_SCANNER_CHECKIN|BARCODE_SCANNER_INVENTORY)
	var/scan_mode = BARCODE_SCANNER_CHECKIN

/obj/item/barcodescanner/Initialize(mapload)
	. = ..()
	register_item_context()
	register_context()

/obj/item/barcodescanner/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(!istype(target, /obj/item/book))
		return NONE

	switch(scan_mode)
		if(BARCODE_SCANNER_CHECKIN)
			context[SCREENTIP_CONTEXT_LMB] = "Check in"
		if(BARCODE_SCANNER_INVENTORY)
			context[SCREENTIP_CONTEXT_LMB] = "Add to inventory"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/barcodescanner/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(held_item == src)
		context[SCREENTIP_CONTEXT_LMB] = "Toggle scanning mode"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/item/barcodescanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/item/book))
		return interact_with_book(interacting_with, user)
	return NONE

/obj/item/barcodescanner/proc/interact_with_book(obj/item/book/target_book, mob/living/user)
	var/obj/machinery/computer/libraryconsole/bookmanagement/linked_computer = computer_ref?.resolve()
	if(isnull(linked_computer))
		user.balloon_alert(user, "not connected to computer!")
		return ITEM_INTERACT_BLOCKING

	switch(scan_mode)
		if(BARCODE_SCANNER_CHECKIN)
			var/list/checkouts = linked_computer.checkouts
			for(var/checkout_ref in checkouts)
				var/datum/borrowbook/maybe_ours = checkouts[checkout_ref]
				if(!target_book.book_data.compare(maybe_ours.book_data))
					continue
				checkouts -= checkout_ref
				linked_computer.checkout_update()
				balloon_alert(user, "checked in")
				playsound(src, 'sound/items/barcodebeep.ogg', 20, FALSE)
				return ITEM_INTERACT_SUCCESS

			user.balloon_alert(user, "isn't checked out!")
			return ITEM_INTERACT_BLOCKING

		if(BARCODE_SCANNER_INVENTORY)
			var/datum/book_info/our_copy = target_book.book_data.return_copy()
			linked_computer.inventory[ref(our_copy)] = our_copy
			linked_computer.inventory_update()
			balloon_alert(user, "added to inventory")
			playsound(src, 'sound/items/barcodebeep.ogg', 20, FALSE)
			return ITEM_INTERACT_SUCCESS

	return NONE

/obj/item/barcodescanner/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!computer_ref?.resolve())
		balloon_alert(user, "connect to computer!")
		return
	switch(scan_mode)
		if(BARCODE_SCANNER_CHECKIN)
			scan_mode = BARCODE_SCANNER_INVENTORY
			balloon_alert(user, "inventory adding mode")
		if(BARCODE_SCANNER_INVENTORY)
			scan_mode = BARCODE_SCANNER_CHECKIN
			balloon_alert(user, "check-in mode")
	playsound(loc, 'sound/items/click.ogg', 20, TRUE)
