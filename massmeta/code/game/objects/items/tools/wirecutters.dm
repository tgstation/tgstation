/obj/item/wirecutters/makeshift
	name = "makeshift wirecutters"
	desc = "Mind your fingers."
	icon = 'massmeta/icons/obj/improvised.dmi'
	icon_state = "cutters_makeshift"
	toolspeed = 2
	random_color = FALSE

/obj/item/wirecutters/makeshift/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(prob(5))
		to_chat(user, span_danger("[src] crumbles apart in your hands!"))
		qdel(src)
		return
