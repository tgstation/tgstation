
/mob/living/proc/get_bodypart(zone)
	return

/mob/living/carbon/get_bodypart(zone)
	if(!zone)
		zone = "chest"
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		if(L.body_zone == zone)
			return L

//Mob has their active hand
/mob/proc/has_active_hand()
	return 1

/mob/living/carbon/human/has_active_hand()
	var/obj/item/bodypart/L
	if(hand)
		L = get_bodypart("l_arm")
	else
		L = get_bodypart("r_arm")
	if(!L)
		return 0
	return 1

/mob/living/carbon/proc/has_left_hand()
	return 1

/mob/living/carbon/human/has_left_hand()
	var/obj/item/bodypart/L
	L = get_bodypart("l_arm")
	if(!L)
		return 0
	return 1

/mob/living/carbon/proc/has_right_hand()
	return 1

/mob/living/carbon/human/has_right_hand()
	var/obj/item/bodypart/L
	L = get_bodypart("r_arm")
	if(!L)
		return 0
	return 1


//Limb numbers
/mob/proc/get_num_arms()
	return 2
/mob/proc/get_num_legs()
	return 2

/mob/living/carbon/human/get_num_arms()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == ARM_RIGHT)
			.++
		if(affecting.body_part == ARM_LEFT)
			.++

/mob/living/carbon/human/get_num_legs()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == LEG_RIGHT)
			.++
		if(affecting.body_part == LEG_LEFT)
			.++

/mob/living/proc/get_missing_limbs()
	return list()

/mob/living/carbon/human/get_missing_limbs()
	var/list/full = list("head", "chest", "r_arm", "l_arm", "r_leg", "l_leg")
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full


//Remove all embedded objects from all limbs on the human mob
/mob/living/carbon/human/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			L.embedded_objects -= I
			I.loc = T

	clear_alert("embeddedobject")

/mob/living/carbon/human/proc/has_embedded_objects()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			return 1


//Helper for quickly creating a new limb - used by augment code in species.dm spec_attacked_by
/proc/newBodyPart(zone, robotic, fixed_icon, mob/living/carbon/human/source)
	var/obj/item/bodypart/L
	switch(zone)
		if("l_arm")
			L = new /obj/item/bodypart/l_arm()
		if("r_arm")
			L = new /obj/item/bodypart/r_arm()
		if("head")
			L = new /obj/item/bodypart/head()
		if("l_leg")
			L = new /obj/item/bodypart/l_leg()
		if("r_leg")
			L = new /obj/item/bodypart/r_leg()
		if("chest")
			L = new /obj/item/bodypart/chest()
	if(L)
		if(source)
			L.update_limb(fixed_icon, source)
		else if(fixed_icon)
			L.no_update = 1//when attached, the limb won't be affected by the appearance changes of its mob owner.
		if(robotic)
			L.change_bodypart_status(ORGAN_ROBOTIC)

	. = L


/proc/skintone2hex(skin_tone)
	. = 0
	switch(skin_tone)
		if("caucasian1")
			. = "ffe0d1"
		if("caucasian2")
			. = "fcccb3"
		if("caucasian3")
			. = "e8b59b"
		if("latino")
			. = "d9ae96"
		if("mediterranean")
			. = "c79b8b"
		if("asian1")
			. = "ffdeb3"
		if("asian2")
			. = "e3ba84"
		if("arab")
			. = "c4915e"
		if("indian")
			. = "b87840"
		if("african1")
			. = "754523"
		if("african2")
			. = "471c18"
		if("albino")
			. = "fff4e6"
