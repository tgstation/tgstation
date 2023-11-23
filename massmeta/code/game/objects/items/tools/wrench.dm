/obj/item/wrench/makeshift
	name = "makeshift wrench"
	desc = "A crude, self-wrought wrench with common uses. Can be found in your hand."
	icon = 'massmeta/icons/obj/improvised.dmi'
	icon_state = "wrench_makeshift"
	toolspeed = 2

/obj/item/wrench/makeshift/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(prob(5))
		to_chat(user, span_danger("[src] crumbles apart in your hands!"))
		qdel(src)
		return
