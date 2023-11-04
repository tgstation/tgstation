/obj/item/bear_armor
	name = "pile of bear armor"
	desc = "A scattered pile of various shaped armor pieces fitted for a bear, some duct tape, and a nail filer. Crude instructions \
		are written on the back of one of the plates in russian. This seems like an awful idea."
	icon = 'icons/obj/device.dmi'
	icon_state = "bear_armor_upgrade"

/obj/item/bear_armor/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	if(!istype(target, /mob/living/basic/bear))
		return
	var/mob/living/basic/bear/bear_target = target
	if(bear_target.armored)
		to_chat(user, span_warning("[bear_target] has already been armored up!"))
		return
	bear_target.armored = TRUE
	bear_target.maxHealth += 60
	bear_target.health += 60
	bear_target.armour_penetration += 20
	bear_target.melee_damage_lower += 3
	bear_target.melee_damage_upper += 5
	bear_target.wound_bonus += 5
	bear_target.update_icons()
	to_chat(user, span_info("You strap the armor plating to [bear_target] and sharpen [bear_target.p_their()] claws with the nail filer. This was a great idea."))
	qdel(src)
