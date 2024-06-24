//--- BOWIE'S KNIFE (bowie knife)---


/obj/item/knife/bowie
	name = "\improper Bowie knife"
	desc = "A frontiersman's classic, closer to a shortsword than a knife. It boasts a full-tanged build, a brass handguard and pommel, a wicked sharp point, and a large, heavy blade, It's almost everything you could want in a knife, besides portability."
	icon = 'monkestation/code/modules/blueshift/icons/bowie.dmi'
	icon_state = "bowiehand"
	inhand_icon_state = "bowiehand"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/bowie_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/bowie_righthand.dmi'
	worn_icon_state = "knife"
	force = 20 // Zoowee Momma!
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 15
	wound_bonus = 10 //scalpel tier
	bare_wound_bonus = 20 // Very-bigly

/obj/item/storage/belt/bowie_sheath
	name = "\improper Bowie knife sheath"
	desc = "A dressed-up leather sheath featuring a brass tip. It has a large pocket clip right in the center, for ease of carrying an otherwise burdensome knife."
	icon = 'monkestation/code/modules/blueshift/icons/bowiepocket.dmi'
	icon_state = "bowiesheath"
	slot_flags = ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE

/obj/item/storage/belt/bowie_sheath/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.max_total_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(list(
		/obj/item/knife/bowie,
		))

/obj/item/storage/belt/bowie_sheath/AltClick(mob/user)
	if(length(contents))
		var/obj/item/knife = contents[1]
		user.visible_message(span_notice("[user] takes [knife] out of [src]."), span_notice("You take [knife] out of [src]."))
		user.put_in_hands(knife)
		update_appearance()
		return TRUE
	else
		to_chat(user, span_warning("[src] is empty!"))
		return FALSE

/obj/item/storage/belt/bowie_sheath/update_icon_state()
	icon_state = initial(icon_state)
	if(contents.len)
		icon_state += "e-knife"
	return ..()

/obj/item/storage/belt/bowie_sheath/PopulateContents()
	new /obj/item/knife/bowie(src)
	update_appearance()
