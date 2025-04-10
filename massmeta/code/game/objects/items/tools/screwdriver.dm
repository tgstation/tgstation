/obj/item/screwdriver/makeshift
	name = "makeshift screwdriver"
	desc = "Crude driver of screws. A primitive way to screw things up."
	icon = 'massmeta/icons/obj/improvised.dmi'
	icon_state = "screwdriver_makeshift"
	toolspeed = 2
	random_color = FALSE

/obj/item/screwdriver/makeshift/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(prob(5))
		to_chat(user, span_danger("[src] crumbles apart in your hands!"))
		qdel(src)
		return
