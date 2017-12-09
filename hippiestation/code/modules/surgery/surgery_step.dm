/datum/surgery_step/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user] just about succeeds, but makes a mess!</span>", "<span class='warning'>You succeed... just about!</span>")
	var/obj/item/bodypart/affecting = target.get_bodypart(check_zone(target_zone))
	var/damage_amount = 20

	if (tool.force)
		damage_amount = tool.force * 2 // You managed to do it, but also hurt the patient

	if (!affecting)
		target_zone = "chest" // Couldn't find limb, just try attack chest

	target.apply_damage(damage_amount, BRUTE, target_zone)
	target.emote("scream")

	return TRUE

/datum/surgery_step/add_prosthetic/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	// The last stage of this is adding the arm. 
	// The success() is overridden so I need to override the failure to make sure success is still run (and attaches the body part)
	success(user, target, target_zone, tool, surgery)
	return ..()