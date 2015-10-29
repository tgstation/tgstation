/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = 0
	var/organtype = ORGAN_ORGANIC
	var/status_flags
	var/datum/organ/organdatum
	var/list/suborgans = list()

/obj/item/organ/butt
	name = "butt"
	icon_state = "butt"

//Old Datum Limbs:
// code/modules/unused/limbs.dm


/obj/item/organ/limb
	name = "limb"
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/list/embedded_objects = list()



/obj/item/organ/limb/chest
	name = "chest"
	desc = "Not a treasure chest, sadly."
	icon_state = "chest"
	max_damage = 200
	body_part = CHEST


/obj/item/organ/limb/head
	name = "head"
	desc = "What a way to get a head in life."
	icon_state = "head"
	max_damage = 200
	body_part = HEAD
	var/mob/living/carbon/brain/brainmob = null //We're not using this until someone is beheaded.

/obj/item/organ/limb/head/examine(mob/user)
	..()
	if(brainmob && brainmob.client)
		user << "You see a faint spark of life in their eyes."
	else
		user << "Their eyes are completely lifeless. Perhaps they will regain some of their luster later."

/obj/item/organ/limb/head/proc/behead() //Always use this when beheading someone.
	suborgans["brain"] = owner.getorgan("brain")
	if(istype(/mob/living/carbon/human, owner)) //Temporary solution until I expand the organsystems to all subtypes of carbon.
		var/mob/living/carbon/human/H = owner
		H.internal_organs -= suborgans["brain"] //Goodbye brain
	transfer_identity()

/obj/item/organ/limb/head/proc/transfer_identity() //Copied from /obj/item/organ/brain. Use this to turn a human into a head.
	var/obj/item/organ/internal/brain/brain = suborgans["brain"]
	brainmob = new(src)
	brainmob.name = owner.name
	brainmob.real_name = owner.real_name
	if(istype(/mob/living/carbon/human, owner)) //Only humans have DNA right now.
		var/mob/living/carbon/human/H = owner
		brainmob.dna = H.dna
	brainmob.timeofhostdeath = owner.timeofdeath
	name = "[brainmob.name]'s head"
	brain.name = "[brainmob.real_name]'s brain"
	if(owner.mind)
		owner.mind.transfer_to(brainmob)
	brainmob << "<span class='notice'>You can no longer feel the rest of your body.</span>"

/obj/item/organ/limb/head/proc/transfer_identity_from_head_to_brain() //Prepare brain for removal from this head. Call right before you pull the brain out.
	var/obj/item/organ/internal/brain/brain = suborgans["brain"]
	if(brain && brainmob)
		brain.brainmob = brainmob
		brainmob.container = brain
		brainmob.loc = brain
		brainmob = null

/obj/item/organ/limb/head/proc/transfer_identity_from_brain_to_head() //Achieves the reverse effect. Call right after you stuff the brain in.
	var/obj/item/organ/internal/brain/brain = suborgans["brain"]
	if(brain && brain.brainmob)
		brainmob = brain.brainmob
		brain.brainmob = null
		brainmob.container = src
		brainmob.loc = src

/obj/item/organ/limb/head/attackby(var/obj/item/O as obj, var/mob/user as mob, params) //Copied from MMI
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/item/organ/internal/brain/brain = suborgans["brain"]
	if(istype(O,/obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/newbrain = O
		if(brain)
			user << "<span class='warning'>There's already a brain in this head!</span>"
			return
		if(!newbrain.brainmob)
			user << "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain!</span>"
			return

		visible_message("[user] sticks \a [newbrain] into \the [src].")

		brain = newbrain
		newbrain.loc = src
		transfer_identity_from_brain_to_head()

		user.drop_item()

		brain = newbrain

		return

	if(istype(O,/obj/item/weapon/circular_saw))
		if(brain)
			playsound(src.loc, 'sound/weapons/circsawhit.ogg', 100, 1)
			user.visible_message("[user] starts cutting into \the [src] with \the [O].", \
								 "<span class='notice'>You start cutting into \the [src] with \the [O]...</span>", \
								 "<span class='italics'>You hear the sound of a saw.</span>")

			if(do_after(user, 40))
				transfer_identity_from_head_to_brain()
				if(brain)
					user.put_in_hands(brain) //Give the brain to the surgeon
					brain = null //Brain is gone from the head now
					user << "<span class='notice'>You pull the brain out of the head.</span>"
					if(brain.brainmob)
						brain.brainmob << "<span class='notice'>You feel slightly disoriented. That's normal when you're just a brain.</span>"
				else
					user << "<span class='notice'>Something else removed the brain before you were done.</span>"

		else
			user << "<span class='notice'>There is no brain in this head!</span>"

	..()

/obj/item/organ/limb/head/Destroy() //copypasted from MMIs.
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	..()

/obj/item/organ/limb/l_arm
	name = "l_arm"
	desc = "Looks like someone has been disarmed."
	icon_state = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT


/obj/item/organ/limb/l_leg
	name = "l_leg"
	desc = "Looks like someone's leg legged it."
	icon_state = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT


/obj/item/organ/limb/r_arm
	name = "r_arm"
	desc = "Looks like someone has been disarmed."
	icon_state = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT


/obj/item/organ/limb/r_leg
	name = "r_leg"
	desc = "Looks like someone's leg legged it."
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


	if(type == ORGAN_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
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
/obj/item/organ/limb/proc/heal_damage(brute, burn, robotic)

	if(robotic && type != ORGAN_ROBOTIC) // This makes organic limbs not heal when the proc is in Robotic mode.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	if(!robotic && type == ORGAN_ROBOTIC) // This makes robolimbs not healable by chems.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	return update_organ_icon()


//Returns total damage...kinda pointless really
/obj/item/organ/limb/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/organ/limb/proc/update_organ_icon()
	if(type == ORGAN_ORGANIC) //Robotic limbs show no damage - RR
		var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
		var/tburn	= round( (burn_dam/max_damage)*3, 1 )
		if((tbrute != brutestate) || (tburn != burnstate))
			brutestate = tbrute
			burnstate = tburn
			return 1
		return 0

//Returns a display name for the organ
/obj/item/organ/limb/proc/getDisplayName() //Added "Chest" and "Head" just in case, this may not be needed
	switch(name)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		if("chest")     return "chest"
		if("head")		return "head"
		else			return name


//Remove all embedded objects from all limbs on the human mob
/mob/living/carbon/human/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/obj/item/organ/limb/L in organs)
		for(var/obj/item/I in L.embedded_objects)
			L.embedded_objects -= I
			I.loc = T

	clear_alert("embeddedobject")

/mob/living/carbon/human/proc/has_embedded_objects()
	. = 0
	for(var/obj/item/organ/limb/L in organs)
		for(var/obj/item/I in L.embedded_objects)
			return 1