/obj/item/crowbar/makeshift
	name = "makeshift crowbar"
	desc = "A crude, self-wrought crowbar. Heavy."
	icon = 'massmeta/icons/obj/improvised.dmi'
	icon_state = "crowbar_makeshift"
	worn_icon_state = "crowbar"
	force = 12 //same as large crowbar, but bulkier and slower
	w_class = WEIGHT_CLASS_BULKY
	toolspeed = 2

/obj/item/crowbar/makeshift/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(prob(5))
		to_chat(user, span_danger("[src] crumbles apart in your hands!"))
		qdel(src)
		return
