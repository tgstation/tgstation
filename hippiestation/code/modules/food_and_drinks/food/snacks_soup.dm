#define DELICIA_SPAM_COOLDOWN 300

/obj/item/reagent_containers/food/snacks/soup/monkey
	name = "Sopa de Macaco"
	desc = "Monkey soup. A delicacy in Space Brazil."
	icon_state = "monkeysdelight"
	list_reagents = list("nutriment" = 6, "vitamin" = 3)
	tastes = list("delicia" = 1)
	foodtype = MEAT | GROSS
	var/next_uma = 0

/obj/item/reagent_containers/food/snacks/soup/monkey/attack(mob/M, mob/user, def_zone)
	if(..())
		if(world.time > next_uma)
			M.say("Uma delicia!")
			next_uma = world.time + DELICIA_SPAM_COOLDOWN

#undef DELICIA_SPAM_COOLDOWN