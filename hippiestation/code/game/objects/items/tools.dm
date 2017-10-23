/obj/item/weldingtool/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))

	if(affecting && affecting.status == BODYPART_ROBOTIC && user.a_intent != INTENT_HARM)
		if(src.remove_fuel(1))
			playsound(loc, usesound, 50, 1)
			if(user == H)
				item_heal_robotic(H, user, 15, 0)
	else
		return ..()