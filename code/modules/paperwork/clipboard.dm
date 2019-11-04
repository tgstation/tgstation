/obj/item/clipboard
	name = "clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	var/component_type = /datum/component/storage/concrete

/obj/item/clipboard/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins putting [user.p_their()] head into the clip of \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS//the clipboard's clip is very strong. industrial duty. can kill a man easily.

/obj/item/clipboard/Initialize()
	. = ..()
	update_icon()

/obj/item/clipboard/AllowDrop()
	return FALSE

/obj/item/clipboard/get_dumping_location(obj/item/storage/source,mob/user)
	return src

/obj/item/clipboard/ComponentInitialize()
	. = ..()
	AddComponent(component_type)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.allow_quick_gather = TRUE
	STR.allow_quick_empty = TRUE
	STR.display_numerical_stacking = TRUE
	STR.click_gather = TRUE
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

/obj/item/clipboard/update_icon()
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

/obj/item/clipboard/Entered()
	. = ..()
	update_icon()

/obj/item/clipboard/Exited()
	. = ..()
	update_icon()
