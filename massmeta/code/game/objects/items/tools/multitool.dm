/obj/item/multitool/makeshift
	name = "makeshift multitool"
	desc = "As crappy as it is, its still mostly the same as a standard issue Nanotrasen one."
	icon = 'massmeta/icons/obj/improvised.dmi'
	icon_state = "multitool_makeshift"
	toolspeed = 2

/obj/item/multitool/makeshift/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(prob(5))
		to_chat(user, span_danger("[src] crumbles apart in your hands!"))
		qdel(src)
		return
