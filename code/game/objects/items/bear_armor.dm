/obj/item/bear_armor
	name = "pile of bear armor"
	desc = "A scattered pile of various shaped armor pieces fitted for a bear, some duct tape, and a nail filer. Crude instructions \
		are written on the back of one of the plates in Russian. This seems like an awful idea."
	icon = 'icons/obj/tools.dmi'
	icon_state = "bear_armor_upgrade"

/obj/item/bear_armor/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /mob/living/basic/bear))
		return NONE
	var/mob/living/basic/bear/bear = interacting_with
	if(bear.armored)
		to_chat(user, span_warning("[bear] has already been armored up!"))
		return ITEM_INTERACT_BLOCKING
	bear.armored = TRUE
	bear.maxHealth += 60
	bear.health += 60
	bear.armour_penetration += 20
	bear.melee_damage_lower += 3
	bear.melee_damage_upper += 5
	bear.wound_bonus += 5
	bear.update_icons()
	to_chat(user, span_info("You strap the armor plating to [bear] and sharpen [bear.p_their()] claws with the nail filer. This was a great idea."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS
