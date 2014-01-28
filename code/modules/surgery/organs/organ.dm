/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/status = ORGAN_ORGANIC
	var/state = ORGAN_FINE

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

//Old Datum Limbs:
// code/modules/unused/limbs.dm


/obj/item/organ/limb
	name = "limb"
	var/mob/owner = null
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/dam_icon = "chest"

/obj/item/organ/limb/chest
	name = "chest"
	desc = "why is it detached..."
	icon_state = "chest"
	max_damage = 200
	body_part = CHEST


/obj/item/organ/limb/head
	name = "head"
	desc = "what a way to get a head in life..."
	icon_state = "head"
	max_damage = 200
	body_part = HEAD
	dam_icon = "head"


/obj/item/organ/limb/l_arm
	name = "l_arm"
	desc = "why is it detached..."
	icon_state = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT
	dam_icon = "l_arm"


/obj/item/organ/limb/l_leg
	name = "l_leg"
	desc = "why is it detached..."
	icon_state = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT
	dam_icon = "l_leg"


/obj/item/organ/limb/r_arm
	name = "r_arm"
	desc = "why is it detached..."
	icon_state = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT
	dam_icon = "r_arm"


/obj/item/organ/limb/r_leg
	name = "r_leg"
	desc = "why is it detached..."
	icon_state = "r_leg"
	max_damage = 75
	body_part = LEG_RIGHT
	dam_icon = "r_leg"



//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/organ/limb/proc/take_damage(brute, burn)
	if(owner && (owner.status_flags & GODMODE))	return 0	//godmode
	brute	= max(brute,0)
	burn	= max(burn,0)


	if(status == ORGAN_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)

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
/obj/item/organ/limb/proc/heal_damage(brute, burn, var/robotic)

	if(robotic && status != ORGAN_ROBOTIC) // This makes organic limbs not heal when the proc is in Robotic mode.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	if(!robotic && status == ORGAN_ROBOTIC) // This makes robolimbs not healable by chems.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	return update_organ_icon()


/obj/item/proc/item_heal_robotic(var/mob/living/carbon/human/H, var/mob/user, var/brute, var/burn)
	var/obj/item/organ/limb/affecting = H.get_organ(check_zone(user.zone_sel.selecting))

	var/dam //changes repair text based on how much brute/burn was supplied

	if(brute > burn)
		dam = 1
	else
		dam = 0

	if(affecting.status == ORGAN_ROBOTIC)
		if(brute > 0 && affecting.brute_dam > 0 || burn > 0 && affecting.burn_dam > 0)
			affecting.heal_damage(brute,burn,1)
			H.update_damage_overlays(0)
			H.updatehealth()
			for(var/mob/O in viewers(user, null))
				O.show_message(text("<span class='notice'>[user] has fixed some of the [dam ? "dents on" : "burnt wires in"] [H]'s [affecting.getDisplayName()]!</span>"), 1)
			return
		else
			user << "<span class='notice'>[H]'s [affecting.getDisplayName()] is already in good condition</span>"
			return
	else
		return

//Returns total damage...kinda pointless really
/obj/item/organ/limb/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/organ/limb/proc/update_organ_icon()
	if(status == ORGAN_ORGANIC) //Robotic limbs show no damage - RR
		var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
		var/tburn	= round( (burn_dam/max_damage)*3, 1 )
		if((tbrute != brutestate) || (tburn != burnstate))
			brutestate = tbrute
			burnstate = tburn
			return 1
		return 0

//Returns a display name for the organ
/obj/item/organ/limb/proc/getDisplayName() //Added "Chest" and "Head" just in case, this may not be needed - RR.
	switch(name)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		if("chest")     return "chest"
		if("head")		return "head"
		else			return name


//////////////// DISMEMBERMENT \\\\\\\\\\\\\\\\

/obj/item/organ/limb/proc/dismember(var/obj/item/I, var/removal_type)
	var/obj/item/organ/limb/affecting = src

	var/mob/living/carbon/human/owner = affecting.owner

	var/dismember_chance = 0 //Chance for the limb to fall off, if an Item is used the it is the item's sharp_power

	switch(removal_type)
		if(EXPLOSION_DISM)
			dismember_chance = 45
		if(GUN_DISM)
			dismember_chance = 30
		if(MELEE_DISM)
			if(I)
				dismember_chance = I.sharp_power
		else
			world << "<span class='notice'> Error, Invalid removal_type in dismemberment call: [removal_type]</span>" //Easy way to let everyone know someone fucked up
			return


	if(affecting.brute_dam >= (affecting.max_damage / 2) && affecting.state != ORGAN_REMOVED) //if it has taken significant enough damage
		if(prob(dismember_chance))
			var/Loc = get_turf(owner)

			if(affecting.body_part == HEAD)
				return

			if(affecting.body_part == CHEST)
				for(var/obj/item/organ/O in owner.internal_organs)
					if(!istype(O, /obj/item/organ/brain))
						owner.internal_organs -= O
						O.loc = Loc

			if(affecting.body_part == ARM_RIGHT || affecting.body_part == ARM_LEFT)
				if(owner.handcuffed)
					owner.handcuffed.loc = Loc
					owner.handcuffed = null
					owner.update_inv_handcuffed(0)

			if(affecting.body_part == LEG_RIGHT || affecting.body_part == LEG_LEFT)
				if(owner.legcuffed)
					owner.legcuffed.loc = Loc
					owner.legcuffed = null
					owner.update_inv_legcuffed(0)

			affecting.state = ORGAN_REMOVED

			owner.apply_damage(30,"brute","[affecting]")

			affecting.drop_limb(owner)

			if(affecting.body_part != CHEST)
				owner.visible_message("<span class='danger'><B>[owner]'s [affecting.getDisplayName()] has been violently dismembered!</B></span>")
			else
				owner.visible_message("<span class='danger'><B>[owner]'s internal organs have spilled onto the floor!</B></span>")

			owner.drop_both_hands() //Removes any items they may be carrying in their now non existant arms
		owner.update_body()


//////////////// AUGMENTATION \\\\\\\\\\\\\\\\

/mob/living/carbon/human/proc/augmentation(var/obj/item/organ/limb/affecting, var/mob/user, var/obj/item/I)
	if(affecting.state == ORGAN_REMOVED)
		var/obj/item/augment/AUG = I

		if(affecting.body_part == AUG.limb_part)
			affecting.change_organ(ORGAN_ROBOTIC)
			visible_message("<span class='notice'>[user] has attached [src]'s new limb!</span>")

			if(affecting.body_part == CHEST)
				for(var/datum/disease/appendicitis/A in viruses)
					A.cure(1)
		else
			user << "<span class='notice'>You can't attach a [AUG.name] where [src]'s [affecting.getDisplayName()] should be!</span>"
			return

		user.drop_item()
		del(AUG)
		update_body()
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [src.name]'s [parse_zone(user.zone_sel.selecting)] ([src.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		src.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [src.name] ([src.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")


//////////////// LIMB STATUS \\\\\\\\\\\\\\\\

//Informs us if the user has atleast 1 functional Arm.
/mob/living/carbon/human/proc/arm_ok()
	var/num_of_arms = 0

	for(var/obj/item/organ/limb/affecting in organs)
		if(affecting.body_part == ARM_RIGHT || affecting.body_part == ARM_LEFT)
			if(affecting.state == ORGAN_FINE)
				num_of_arms += 1

	if(num_of_arms >= 1)
		return num_of_arms
	else
		return 0

//Informs us if the user has atleast 1 functional Leg.
/mob/living/carbon/human/proc/leg_ok()
	var/num_of_legs = 0

	for(var/obj/item/organ/limb/affecting in organs)
		if(affecting.body_part == LEG_RIGHT || affecting.body_part == LEG_LEFT)
			if(affecting.state == ORGAN_FINE)
				num_of_legs += 1

	if(num_of_legs >= 1)
		return num_of_legs
	else
		return 0

//////////////// QUICK ORGAN CHANGE PROCS \\\\\\\\\\\\\\\\

/mob/living/carbon/human/proc/change_all_organs(var/type)
	for(var/obj/item/organ/O in organs)
		O.change_organ(type)
		if(istype(O, /obj/item/organ/limb))
			var/obj/item/organ/limb/L = O
			if(L.owner)
				var/mob/living/carbon/human/H = L.owner //Only humans have limbs
				H.updatehealth()
				H.update_body()

/obj/item/organ/proc/change_organ(var/type)
	status = type
	state = ORGAN_FINE

	if(istype(src, /obj/item/organ/limb))
		var/obj/item/organ/limb/L = src
		L.burn_dam = 0
		L.brute_dam = 0
		if(L.owner)
			var/mob/living/carbon/human/H = L.owner
			H.update_body()

//////////////// DROP LIMB \\\\\\\\\\\\\\\\

/obj/item/organ/limb/proc/drop_limb(var/location) //Dummy limbs.
	var/obj/item/organ/limb/LIMB
	var/Loc

	if(location)
		Loc = get_turf(location)
	else
		Loc = get_turf(src)

	if(status == ORGAN_ORGANIC)	//No chests, heads, they can't be removed
		switch(body_part)
			if(ARM_RIGHT)
				LIMB = new /obj/item/organ/limb/r_arm (Loc)
			if(ARM_LEFT)
				LIMB = new /obj/item/organ/limb/l_arm (Loc)
			if(LEG_RIGHT)
				LIMB = new /obj/item/organ/limb/r_leg (Loc)
			if(LEG_LEFT)
				LIMB = new /obj/item/organ/limb/l_leg (Loc)

	else if(status == ORGAN_ROBOTIC)
		switch(body_part)
			if(ARM_RIGHT)
				LIMB = new /obj/item/augment/r_arm (Loc)
			if(ARM_LEFT)
				LIMB = new /obj/item/augment/l_arm (Loc)
			if(LEG_RIGHT)
				LIMB = new /obj/item/augment/r_leg (Loc)
			if(LEG_LEFT)
				LIMB = new /obj/item/augment/l_leg (Loc)

	var/direction = pick(cardinal)
	step(LIMB,direction) //Make the limb fly off
