/datum/surgery_step/proc/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user] just about succeeds, but makes a mess!</span>", 
						 "<span class='warning'>You succeed... just about!</span>")
	target.apply_damage(tool.force * 2, BRUTE, target_zone) // You managed to do it, but also hurt the patient
	target.emote("scream")
	return TRUE