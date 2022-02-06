/obj/machinery/computer/prisoner
	var/obj/item/card/id/advanced/prisoner/contained_id

/obj/machinery/computer/prisoner/Destroy()
	if(contained_id)
		contained_id.forceMove(get_turf(src))
	return ..()


/obj/machinery/computer/prisoner/examine(mob/user)
	. = ..()
	if(contained_id)
		. += span_notice("<b>Alt-click</b> to eject the ID card.")



/obj/machinery/computer/prisoner/AltClick(mob/user)
	id_eject(user)
	return ..()

/obj/machinery/computer/prisoner/proc/id_insert(mob/user, obj/item/card/id/advanced/prisoner/P)
	if(istype(P))
		if(contained_id)
			to_chat(user, span_warning("There's already an ID card in the console!"))
			return
		if(!user.transferItemToLoc(P, src))
			return
		contained_id = P
		user.visible_message(span_notice("[user] inserts an ID card into the console."), \
							span_notice("You insert the ID card into the console."))
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		updateUsrDialog()

/obj/machinery/computer/prisoner/proc/id_eject(mob/user)
	if(!contained_id)
		to_chat(user, span_warning("There's no ID card in the console!"))
		return
	else
		contained_id.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(contained_id)
		contained_id = null
		user.visible_message(span_notice("[user] gets an ID card from the console."), \
							span_notice("You get the ID card from the console."))
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		updateUsrDialog()

/obj/machinery/computer/prisoner/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/card/id/advanced/prisoner))
		id_insert(user, I)
	else
		return ..()
