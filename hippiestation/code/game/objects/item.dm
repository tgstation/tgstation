/obj/item
	var/special_attack = FALSE
	var/special_name = "generic"
	var/special_desc = "not supposed to see this"
	var/special_cost = 0

/obj/item/proc/do_special_attack(atom/target, mob/living/carbon/user, proximity_flag)
	return