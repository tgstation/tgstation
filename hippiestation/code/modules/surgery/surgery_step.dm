/datum/surgery_step/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	// Do what we wanted anyway, but with consequences
	success(user, target, target_zone, tool, surgery)

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

// Listing failure() overrides that normally return false to return true
/datum/surgery_step/pacify/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	success(user, target, target_zone, tool, surgery)
	..()
	
	return TRUE

/datum/surgery_step/fix_brain/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	success(user, target, target_zone, tool, surgery)
	..()
	
	return TRUE

/datum/surgery_step/fix_eyes/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	success(user, target, target_zone, tool, surgery)
	..()

	return TRUE