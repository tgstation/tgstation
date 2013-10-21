/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'


/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	var/beating = 1

/obj/item/organ/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"


/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	var/inflamed = 1

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"


//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

/obj/item/organ/limb
	name = "limb"
	var/mob/owner = null
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0

/obj/item/organ/limb/chest
	name = "chest"
	icon_state = "chest"
	max_damage = 200
	body_part = CHEST

/obj/item/organ/limb/head
	name = "head"
	icon_state = "head"
	max_damage = 200
	body_part = HEAD

/obj/item/organ/limb/l_arm
	name = "l_arm"
	icon_state = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT

/obj/item/organ/limb/l_leg
	name = "l_leg"
	icon_state = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT

/obj/item/organ/limb/r_arm
	name = "r_arm"
	icon_state = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT

/obj/item/organ/limb/r_leg
	name = "r_leg"
	icon_state = "r_leg"
	max_damage = 75
	body_part = LEG_RIGHT


//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/organ/limb/proc/take_damage(brute, burn)
	if(owner && (owner.status_flags & GODMODE))	return 0	//godmode
	brute	= max(brute,0)
	burn	= max(burn,0)

	var/can_inflict = max_damage - (brute_dam + burn_dam)
	if(!can_inflict)	return 0

	if((brute + burn) < can_inflict)
		brute_dam	+= brute
		burn_dam	+= burn
	else
		if(brute > 0)
			if(burn > 0)
				brute	= round( (brute/(brute+burn)) * can_inflict, 1 )
				burn	= can_inflict - brute	//gets whatever damage is left over
				brute_dam	+= brute
				burn_dam	+= burn
			else
				brute_dam	+= can_inflict
		else
			if(burn > 0)
				burn_dam	+= can_inflict
			else
				return 0
	return update_organ_icon()


//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/organ/limb/proc/heal_damage(brute, burn)
	brute	= max(brute, 0)
	burn	= max(burn, 0)
	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	return update_organ_icon()


//Returns total damage...kinda pointless really
/obj/item/organ/limb/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/organ/limb/proc/update_organ_icon()
	var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
	var/tburn	= round( (burn_dam/max_damage)*3, 1 )
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return 1
	return 0

//Returns a display name for the organ
/obj/item/organ/limb/proc/getDisplayName()
	switch(name)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		else			return name


