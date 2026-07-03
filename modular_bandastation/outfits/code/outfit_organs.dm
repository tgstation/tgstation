/datum/outfit
	var/list/organs = null

/datum/outfit/equip(mob/living/carbon/human/user, visuals_only = FALSE)
	. = ..()
	if(!.)
		return
	for(var/organ_path in organs)
		var/obj/item/organ/organ_instance = SSwardrobe.provide_type(organ_path, user)
		organ_instance.replace_into(user)
