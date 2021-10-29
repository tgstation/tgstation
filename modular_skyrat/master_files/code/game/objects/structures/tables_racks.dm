//Lets cyborgs move dragged objects onto tables
/obj/structure/table/attack_robot(mob/user, list/modifiers)
	return attack_hand(user, modifiers)
