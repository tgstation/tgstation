
/mob/living/proc/get_bodypart(zone)
	return

/mob/living/carbon/get_bodypart(zone)
	RETURN_TYPE(/obj/item/bodypart)

	if(!zone)
		zone = BODY_ZONE_CHEST
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(bodypart.body_zone == zone)
			return bodypart


/mob/living/carbon/has_hand_for_held_index(i)
	if(!i)
		return FALSE
	var/obj/item/bodypart/hand_instance = hand_bodyparts[i]
	if(hand_instance && !hand_instance.bodypart_disabled)
		return hand_instance
	return FALSE


///Get the bodypart for whatever hand we have active, Only relevant for carbons
/mob/proc/get_active_hand()
	return FALSE

/mob/living/carbon/get_active_hand()
	var/which_hand = BODY_ZONE_PRECISE_L_HAND
	if(!(active_hand_index % 2))
		which_hand = BODY_ZONE_PRECISE_R_HAND
	return get_bodypart(check_zone(which_hand))


/mob/proc/has_left_hand(check_disabled = TRUE)
	return TRUE


/mob/living/carbon/has_left_hand(check_disabled = TRUE)
	for(var/obj/item/bodypart/hand_instance in hand_bodyparts)
		if(!(hand_instance.held_index % 2) || (check_disabled && hand_instance.bodypart_disabled))
			continue
		return TRUE
	return FALSE


/mob/living/carbon/alien/larva/has_left_hand()
	return TRUE


/mob/proc/has_right_hand(check_disabled = TRUE)
	return TRUE


/mob/living/carbon/has_right_hand(check_disabled = TRUE)
	for(var/obj/item/bodypart/hand_instance in hand_bodyparts)
		if(hand_instance.held_index % 2 || (check_disabled && hand_instance.bodypart_disabled))
			continue
		return TRUE
	return FALSE


/mob/living/carbon/alien/larva/has_right_hand()
	return TRUE


/mob/living/proc/get_missing_limbs()
	return list()

/mob/living/carbon/get_missing_limbs()
	RETURN_TYPE(/list)
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

/mob/living/carbon/alien/larva/get_missing_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST)
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

/mob/living/proc/get_disabled_limbs()
	return list()

/mob/living/carbon/get_disabled_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/list/disabled = list()
	for(var/zone in full)
		var/obj/item/bodypart/affecting = get_bodypart(zone)
		if(affecting?.bodypart_disabled)
			disabled += zone
	return disabled

/mob/living/carbon/alien/larva/get_disabled_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST)
	var/list/disabled = list()
	for(var/zone in full)
		var/obj/item/bodypart/affecting = get_bodypart(zone)
		if(affecting?.bodypart_disabled)
			disabled += zone
	return disabled

///Remove a specific embedded item from the carbon mob
/mob/living/carbon/proc/remove_embedded_object(obj/item/embedded)
	SEND_SIGNAL(src, COMSIG_CARBON_EMBED_REMOVAL, embedded)

///Remove all embedded objects from all limbs on the carbon mob
/mob/living/carbon/proc/remove_all_embedded_objects()
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		for(var/obj/item/embedded in bodypart.embedded_objects)
			remove_embedded_object(embedded)

/mob/living/carbon/proc/has_embedded_objects(include_harmless=FALSE)
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		for(var/obj/item/embedded in bodypart.embedded_objects)
			if(!include_harmless && embedded.isEmbedHarmless())
				continue
			return TRUE

//Helper for quickly creating a new limb - used by augment code in species.dm spec_attacked_by
/mob/living/carbon/proc/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/new_bodypart
	switch(zone)
		if(BODY_ZONE_L_ARM)
			new_bodypart = new /obj/item/bodypart/l_arm()
		if(BODY_ZONE_R_ARM)
			new_bodypart = new /obj/item/bodypart/r_arm()
		if(BODY_ZONE_HEAD)
			new_bodypart = new /obj/item/bodypart/head()
		if(BODY_ZONE_L_LEG)
			new_bodypart = new /obj/item/bodypart/l_leg()
		if(BODY_ZONE_R_LEG)
			new_bodypart = new /obj/item/bodypart/r_leg()
		if(BODY_ZONE_CHEST)
			new_bodypart = new /obj/item/bodypart/chest()
	if(new_bodypart)
		new_bodypart.update_limb(fixed_icon, src)
		if(robotic)
			new_bodypart.change_bodypart_status(BODYPART_ROBOTIC)
	. = new_bodypart

/mob/living/carbon/human/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/bodypart
	var/datum/species/species = dna.species
	var/obj/item/bodypart/selected_type = species.bodypart_overides[zone]
	bodypart = new selected_type()
	if(bodypart)
		bodypart.update_limb(fixed_icon, src)
		if(robotic)
			bodypart.change_bodypart_status(BODYPART_ROBOTIC)
	. = bodypart

/mob/living/carbon/alien/larva/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/new_bodypart
	switch(zone)
		if(BODY_ZONE_HEAD)
			new_bodypart = new /obj/item/bodypart/head/larva()
		if(BODY_ZONE_CHEST)
			new_bodypart = new /obj/item/bodypart/chest/larva()
	if(new_bodypart)
		new_bodypart.update_limb(fixed_icon, src)
		if(robotic)
			new_bodypart.change_bodypart_status(BODYPART_ROBOTIC)
	. = new_bodypart

/mob/living/carbon/alien/humanoid/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/new_bodypart
	switch(zone)
		if(BODY_ZONE_L_ARM)
			new_bodypart = new /obj/item/bodypart/l_arm/alien()
		if(BODY_ZONE_R_ARM)
			new_bodypart = new /obj/item/bodypart/r_arm/alien()
		if(BODY_ZONE_HEAD)
			new_bodypart = new /obj/item/bodypart/head/alien()
		if(BODY_ZONE_L_LEG)
			new_bodypart = new /obj/item/bodypart/l_leg/alien()
		if(BODY_ZONE_R_LEG)
			new_bodypart = new /obj/item/bodypart/r_leg/alien()
		if(BODY_ZONE_CHEST)
			new_bodypart = new /obj/item/bodypart/chest/alien()
	if(new_bodypart)
		new_bodypart.update_limb(fixed_icon, src)
		if(robotic)
			new_bodypart.change_bodypart_status(BODYPART_ROBOTIC)
	. = new_bodypart


/proc/skintone2hex(skin_tone)
	. = 0
	switch(skin_tone)
		if("caucasian1")
			. = "#ffe0d1"
		if("caucasian2")
			. = "#fcccb3"
		if("caucasian3")
			. = "#e8b59b"
		if("latino")
			. = "#d9ae96"
		if("mediterranean")
			. = "#c79b8b"
		if("asian1")
			. = "#ffdeb3"
		if("asian2")
			. = "#e3ba84"
		if("arab")
			. = "#c4915e"
		if("indian")
			. = "#b87840"
		if("african1")
			. = "#754523"
		if("african2")
			. = "#471c18"
		if("albino")
			. = "#fff4e6"
		if("orange")
			. = "#ffc905"

/mob/living/carbon/proc/Digitigrade_Leg_Swap(swap_back)
	var/body_plan_changed = FALSE
	for(var/obj/item/bodypart/existing_bodypart as anything in bodyparts)
		var/obj/item/bodypart/new_bodypart
		if((!existing_bodypart.use_digitigrade && swap_back == FALSE) || (existing_bodypart.use_digitigrade && swap_back == TRUE))
			if(existing_bodypart.body_part == LEG_LEFT)
				if(swap_back == TRUE)
					new_bodypart = new /obj/item/bodypart/l_leg
				else
					new_bodypart = new /obj/item/bodypart/l_leg/digitigrade
			else if(existing_bodypart.body_part == LEG_RIGHT)
				if(swap_back == TRUE)
					new_bodypart = new /obj/item/bodypart/r_leg
				else
					new_bodypart = new /obj/item/bodypart/r_leg/digitigrade
		if(!new_bodypart)
			continue
		body_plan_changed = TRUE
		existing_bodypart.drop_limb(1)
		qdel(existing_bodypart)
		new_bodypart.attach_limb(src) //no sanity for if this fails here because we just dropped out a limb of the same zone, SHOULD be okay
	if(body_plan_changed && ishuman(src))
		var/mob/living/carbon/human/leg_owner = src
		if(leg_owner.w_uniform)
			var/obj/item/clothing/under/uniform = leg_owner.w_uniform
			if(uniform.mutantrace_variation)
				if(swap_back)
					uniform.adjusted = NORMAL_STYLE
				else
					uniform.adjusted = DIGITIGRADE_STYLE
				leg_owner.update_inv_w_uniform()
		if(leg_owner.shoes && !(leg_owner.shoes.item_flags & IGNORE_DIGITIGRADE) && !swap_back)
			leg_owner.dropItemToGround(leg_owner.shoes)
