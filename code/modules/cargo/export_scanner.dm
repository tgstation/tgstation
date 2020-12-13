/obj/item/export_scanner
	name = "export scanner"
	desc = "A device used to check objects against Nanotrasen exports database."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL

/obj/item/export_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return
	// Before you fix it:
	// yes, checking manifests is a part of intended functionality.
	
	var/datum/export_report/ex = export_item_and_contents(O, dry_run=TRUE)
	var/price = 0
	for(var/x in ex.total_amount)
		price += ex.total_value[x]
	if(price)
		to_chat(user, "<span class='notice'>Scanned [O], value: <b>[price]</b> credits[O.contents.len ? " (contents included)" : ""].</span>")
	else
		to_chat(user, "<span class='warning'>Scanned [O], no export value.</span>")
