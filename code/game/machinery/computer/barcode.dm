/obj/machinery/computer/barcode
	name = "Barcode Computer"
	desc = "Used to print barcode stickers for the cargo routing system."
	icon = 'goon/icons/obj/barcode.dmi'
	icon_state = "barcode_base"
	icon_keyboard = "barcode_keyboard"
	icon_screen = "barcode_screen"
	clockwork = TRUE //That'd look weird.
	var/printing = 0
	var/list/destinations = list("Airbridge", "Cafeteria", "EVA", "Engine", "Disposals", "QM", "Catering", "MedSci", "Security") //These have to match the ones on the cargo routers for the routers to work.

/obj/machinery/computer/barcode/attack_hand(var/mob/user as mob)
	if (..(user))
		return

	var/dat = ""
	dat += "<b>Available Destinations:</b><BR>"
	for(var/I in destinations)
		dat += "<b><A href='?src=\ref[src];print=[I]'>[I]</A></b><BR>"
	user.machine = src
	user << browse("<TITLE>Barcode Computer</TITLE><BR>[dat]", "window=bc_computer;size=400x300")
	onclose(user, "bc_computer")
	return

/obj/machinery/computer/barcode/Topic(href, href_list)
	if (..(href, href_list))
		return

	if (href_list["print"] && !printing)
		printing = 1
		playsound(src.loc, "goon/sound/machines/printer_thermal.ogg", 50, 0)
		sleep(28)
		var/obj/item/barcodesticker/B = new/obj/item/barcodesticker(src.loc)
		B.name = "Barcode Sticker ([href_list["print"]])"
		B.destination = href_list["print"]
		printing = 0

		usr << browse(null, "window=bc_computer")
		src.updateUsrDialog()
		return


/obj/item/barcodesticker
	name = "Barcode Sticker"
	desc = "A barcode sticker used in the cargo routing system."
	icon = 'goon/icons/obj/barcode.dmi'
	icon_state = "barcodesticker"
	item_state = "paper"
	var/destination = "QM Dock"

/obj/item/barcodesticker/proc/attachTo(atom/movable/target)
	if(get_dist(get_turf(target), get_turf(src)) <= 1 )
		if(target==loc && target != usr)
			return //Backpack or something
		target.delivery_destination = destination
		usr.visible_message("<span style=\"color:blue\">[usr] puts a [src.name] on [target].</span>")
		qdel(src)
	return

/obj/item/barcodesticker/attack(mob/M as mob, mob/user as mob, def_zone)
	attachTo(M)
	return

/obj/item/barcodesticker/afterattack(atom/target as mob|obj|turf, mob/user as mob)
	attachTo(target)
	return

/obj/item/barcodesticker/MouseDrop(over_object, src_location, over_location)
	attachTo(over_object)
	return