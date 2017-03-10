//CONTAINS: Evidence bags

/obj/item/weapon/storage/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	item_state = ""

/obj/item/weapon/storage/evidencebag/Initialize()
	..()
	RecalculateWeightClass(null)

/obj/item/weapon/storage/evidencebag/can_be_inserted(obj/item/W, stop_messages = 0, mob/user)
	. = ..()
	if(.)
		if(ismob(loc))
			var/mob/M = loc
			if(!M.get_held_index_of_item(src))
				//can only insert if holding
				user << "<span class='warning'>You must be holding \the [src] before adding to it!</span>"
				return FALSE
		else if(istype(loc, /obj/item/weapon/storage))
			user << "<span class='warning'>Take \the [src] out of [loc] before adding to it!</span>"
			return FALSE
		return TRUE

/obj/item/weapon/storage/evidencebag/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	. = ..()
	RecalculateWeightClass(user)

/obj/item/weapon/storage/evidencebag/proc/RecalculateWeightClass(mob/user)
	var/old_wc = w_class
	w_class = WEIGHT_CLASS_TINY
	for(var/A in contents)
		var/obj/item/I = A
		if(istype(I))
			w_class = max(w_class, I.w_class + 1)
	if(user)
		var/diff = old_wc - w_class
		if(diff)
			var/msg = "\The [src] "
			switch(diff)
				if(-1)
					msg += "expands slightly."
				if(1)
					msg += "gets a bit smaller."
				if(-2)
					msg += "gets bigger."
				if(2)
					msg += "shrinks."
				if(-3) //possible?
					msg += "grows by a lot!"
				if(3)
					msg += "quickly shirivels up."
				else	//almost certainly not possible but w/e
					msg += "rapidly changes size to accomodate the mass difference."
			user.visible_message(msg)
/obj/item/weapon/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."

/obj/item/weapon/storage/box/evidence/New()
	new /obj/item/weapon/storage/evidencebag(src)
	new /obj/item/weapon/storage/evidencebag(src)
	new /obj/item/weapon/storage/evidencebag(src)
	new /obj/item/weapon/storage/evidencebag(src)
	new /obj/item/weapon/storage/evidencebag(src)
	new /obj/item/weapon/storage/evidencebag(src)
	..()
	return
