/datum/limb
	var/name = "limb"
	var/mob/owner = null
	var/icon_name = null
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0

/datum/limb/chest
	name = "chest"
	icon_name = "chest"
	max_damage = 200
	body_part = CHEST

/datum/limb/head
	name = "head"
	icon_name = "head"
	max_damage = 200
	body_part = HEAD

/datum/limb/l_arm
	name = "l_arm"
	icon_name = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT

/datum/limb/l_leg
	name = "l_leg"
	icon_name = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT

/datum/limb/r_arm
	name = "r_arm"
	icon_name = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT

/datum/limb/r_leg
	name = "r_leg"
	icon_name = "r_leg"
	max_damage = 75
	body_part = LEG_RIGHT

/*Leaving these here in case we want to use them later
/datum/limb/l_foot
	name = "l foot"
	icon_name = "l_foot"
	body_part = FOOT_LEFT

/datum/limb/r_foot
	name = "r foot"
	icon_name = "r_foot"
	body_part = FOOT_RIGHT

/datum/limb/r_hand
	name = "r hand"
	icon_name = "r_hand"
	body_part = HAND_RIGHT

/datum/limb/l_hand
	name = "l hand"
	icon_name = "l_hand"
	body_part = HAND_LEFT

/datum/limb/groin
	name = "groin"
	icon_name = "groin"
	body_part = GROIN
*/

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/datum/limb/proc/take_damage(brute, burn)
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
	return update_icon()


//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/datum/limb/proc/heal_damage(brute, burn)
	brute	= max(brute, 0)
	burn	= max(burn, 0)
	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	return update_icon()


//Returns total damage...kinda pointless really
/datum/limb/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/datum/limb/proc/update_icon()
	var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
	var/tburn	= round( (burn_dam/max_damage)*3, 1 )
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return 1
	return 0

//Returns a display name for the organ
/datum/limb/proc/getDisplayName()
	switch(name)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		else			return name
