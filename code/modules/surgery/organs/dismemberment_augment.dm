
//Dismember a limb
/obj/item/organ/limb/proc/dismember()
	if(state_flags & ORGAN_REMOVED)
		return

	if(owner)
		owner.apply_damage(30, "brute", "[src]")
		owner.visible_message("<span class='danger'><B>[owner]'s [getDisplayName()] has been violently dismembered!</B></span>")
		owner.drop_r_hand()
		owner.drop_l_hand()
		owner.regenerate_icons()
		owner.update_canmove()

	state_flags = ORGAN_REMOVED|ORGAN_AUGMENTABLE
	drop_limb()
	brutestate = 0
	burnstate = 0

/obj/item/organ/limb/head/dismember()
	state_flags = ORGAN_AUGMENTABLE
	if(!owner)
		return
	owner.visible_message("<span class='danger'><B>[owner] doesn't look too good...</B></span>")
	return

/obj/item/organ/limb/chest/dismember()
	state_flags = ORGAN_AUGMENTABLE

	if(!owner)
		return
	owner.visible_message("<span class='danger'><B>[owner]'s internal organs spill out onto the floor!</B></span>")
	for(var/obj/item/organ/O in owner.internal_organs)
		if(istype(O, /obj/item/organ/brain))
			continue
		owner.internal_organs -= O
		O.loc = get_turf(owner)

	return

/obj/item/organ/limb/r_arm/dismember()
	..()

	if(!owner)
		return
	if(owner.handcuffed)
		owner.handcuffed.loc = get_turf(owner)
		owner.handcuffed = null
		owner.update_inv_handcuffed(0)

/obj/item/organ/limb/l_arm/dismember()
	..()

	if(!owner)
		return
	if(owner.handcuffed)
		owner.handcuffed.loc = get_turf(owner)
		owner.handcuffed = null
		owner.update_inv_handcuffed(0)

/obj/item/organ/limb/r_leg/dismember()
	..()

	if(!owner)
		return
	if(owner.legcuffed)
		owner.legcuffed.loc = get_turf(owner)
		owner.legcuffed = null
		owner.update_inv_legcuffed(0)

/obj/item/organ/limb/l_leg/dismember()
	..()

	if(!owner)
		return
	if(owner.legcuffed)
		owner.legcuffed.loc = get_turf(owner)
		owner.legcuffed = null
		owner.update_inv_legcuffed(0)


//Augment a limb
/obj/item/organ/limb/proc/augment(var/obj/item/I, var/mob/user)
//	if((state_flags & ~ORGAN_REMOVED) && (state_flags & ~ORGAN_AUGMENTABLE)|| !owner)
//		return

	var/who = "[owner]'s"
	if(user == owner)
		who = "their"

	owner.visible_message("<span class='notice'>[user] has attatched [who] new limb!</span>")
	change_organ(ORGAN_ROBOTIC)
	user.drop_item()
	qdel(I)
	owner.regenerate_icons()
	owner.update_canmove()


//Limb numbers
/mob/living/carbon/human/proc/get_num_arms()
	. = 0
	for(var/obj/item/organ/limb/affecting in organs)
		switch(affecting.body_part)
			if(ARM_RIGHT)
				.++
			if(ARM_LEFT)
				.++

/mob/living/carbon/human/proc/get_num_legs()
	. = 0
	for(var/obj/item/organ/limb/affecting in organs)
		switch(affecting.body_part)
			if(LEG_RIGHT)
				.++
			if(LEG_LEFT)
				.++

//Change organ status
/obj/item/organ/limb/proc/change_organ(var/type)
	status = type
	state_flags = ORGAN_FINE
	burn_dam = 0
	brute_dam = 0
	brutestate = 0
	burnstate = 0
	if(owner)
		owner.updatehealth()
		owner.regenerate_icons()


//Drop dummy limb
/obj/item/organ/limb/proc/drop_limb()
	if(!owner)
		return

	var/turf/T = get_turf(owner)
	var/_path = null

	switch(status)
		if(ORGAN_ORGANIC)
			_path = text2path("/obj/item/organ/limb/[Bodypart2name(body_part)]")
		if(ORGAN_ROBOTIC)
			_path = text2path("/obj/item/robot_parts/[Bodypart2name(body_part)]")

	if(!_path||!ispath(_path))
		return

	var/obj/item/L = new _path (T)

	if(L)
		L.name = "[owner]'s [getDisplayName()]"
		var/direction = pick(cardinal)
		step(L,direction)


//Helper for cleaner code, used above in drop_limb()
/proc/Bodypart2name(var/part)
	. = 0
	switch(part)
		if(CHEST)
			. = "chest"
		if(HEAD)
			. = "head"
		if(ARM_RIGHT)
			. = "r_arm"
		if(ARM_LEFT)
			. = "l_arm"
		if(LEG_RIGHT)
			. = "r_leg"
		if(LEG_LEFT)
			. = "l_leg"


//Mob has their active hand
/mob/proc/has_active_hand()
	return 1

/mob/living/carbon/human/has_active_hand()
	var/obj/item/organ/limb/L
	if(hand)
		L = get_organ("l_arm")
	else
		L = get_organ("r_arm")
	if(L)
		if(L.state_flags & ORGAN_REMOVED)
			return 0
	return 1




//simplifies species and mutations into one var
/mob/living/carbon/human/proc/get_race()
	var/sm_type = "human"//that's speciesist!
	var/datum/species/race = dna ? dna.species : null
	if(race)
		sm_type = race.id

	if(HULK in mutations)
		sm_type = "hulk"
	if(HUSK in mutations)
		sm_type = "husk"

	return sm_type


//draws an icon from a limb
/mob/living/carbon/human/proc/generate_icon(var/obj/item/organ/limb/affecting)
	if(affecting.state_flags & ORGAN_REMOVED)
		return 0

	var/image/I
	var/icon_gender = (gender == FEMALE) ? "f" : "m"

	var/race = get_race()

	if(affecting.body_part == HEAD || affecting.body_part == CHEST) //these have gender in their icons
		if(affecting.status == ORGAN_ORGANIC)
			if(race != "human")
				if(stat == DEAD)
					if(race == "plant")
						I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_[icon_gender]_dead_s", "layer"=-BODYPARTS_LAYER)
						world << "1"
						world << "[race]_[affecting.name]_[icon_gender]_dead_s"
					if(race == "husk")
						I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_s", "layer"=-BODYPARTS_LAYER)
						world << "2"
						world << "[race]_[affecting.name]_s"
				else
					I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER)
					world << "3"
					world << "[race]_[affecting.name]_[icon_gender]_s"
			else
				I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[skin_tone]_[affecting.name]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER)
				world << "4"
				world << "[skin_tone]_[affecting.name]_[icon_gender]_s"
		else if(affecting.status == ORGAN_ROBOTIC)
			I = image("icon"='icons/mob/augments.dmi',"icon_state"="[affecting.name]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER)
			world << "5"
			world << "[affecting.name]_[icon_gender]_s"
	else
		if(affecting.status == ORGAN_ORGANIC) //thse do not have gender in their icons
			if(race != "human")
				if(stat == DEAD)
					if(race == "plant")
						I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_dead_s", "layer"=-BODYPARTS_LAYER)
						world << "6"
						world << "[race]_[affecting.name]_dead_s"
					else
						I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_s", "layer"=-BODYPARTS_LAYER)
						world << "7"
						world << "[race]_[affecting.name]_s"
				else
					I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[race]_[affecting.name]_s", "layer"=-BODYPARTS_LAYER)
					world << "8"
					world << "[race]_[affecting.name]_s"
			else
				I = image("icon"='icons/mob/human_parts.dmi', "icon_state"="[skin_tone]_[affecting.name]_s", "layer"=-BODYPARTS_LAYER)
				world << "9"
				world << "[skin_tone]_[affecting.name]_s"
		else if(affecting.status == ORGAN_ROBOTIC)
			I = image("icon"='icons/mob/augments.dmi', "icon_state"="[affecting.name]_[icon_gender]_s", "layer"=-BODYPARTS_LAYER)
			world << "10"
			world << "[affecting.name]_[icon_gender]_s"

	if(I)
		world << "generate_icon() NEW ICON [I]"
		return I
	world << "generate_icon() FAILED TO GENERATE ICON"
	return 0

