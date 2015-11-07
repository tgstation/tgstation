/obj/item/organ/butt
	name = "butt"
	hardpoint = "butt"
	icon_state = "butt"

// This only serves to represent the groin target zone.
/obj/item/organ/abstract/groin
	name = "groin"
	hardpoint = "groin"

/obj/item/organ/abstract/Insert(mob/living/carbon/M)
	return null

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
	hardpoint = "chest"
	desc = "Not a treasure chest, sadly."
	icon_state = "chest"
	max_damage = 200
	body_part = CHEST


/obj/item/organ/limb/head
	name = "head"
	hardpoint = "head"
	desc = "What a way to get a head in life."
	icon_state = "head"
	max_damage = 200
	body_part = HEAD
//	var/mob/living/carbon/brain/brainmob = null //We're not using this until someone is beheaded.

/obj/item/organ/limb/head/create_suborgan_slots()
	new/datum/organ/internal/brain(src, null)
	new/datum/organ/internal/cyberimp/brain(src, null)
	new/datum/organ/internal/cyberimp/chest(src, null)

/obj/item/organ/limb/head/examine(mob/user)
	..()
	var/datum/organ/internal/brain/B = suborgans["brain"]
	if(B.exists())
		var/obj/item/organ/internal/brain/brain = getsuborgan("brain")
		if(brain.brainmob && brain.brainmob.client)
			user << "You see a faint spark of life in their eyes."
		else
			user << "Their eyes are completely lifeless. Perhaps they will regain some of their luster later."
	else
		user << "There's no brain in this head."

/**
  *	Transforms a person into a brainmob. Since the brain will still be inside of the head, we can just use transfer_identity() on the brain.
  * Call this upon beheading someone to properly transfer their mind to their head.
 **/
/obj/item/organ/limb/head/proc/transfer_identity()
	var/datum/organ/internal/brain/B = suborgans["brain"]
	if(B.exists())
		var/obj/item/organ/internal/brain/brain = getsuborgan("brain")
		brain.transfer_identity(owner)

/obj/item/organ/limb/head/Remove()
	transfer_identity()

/**
  *
 **/
/obj/item/organ/limb/head/attackby(var/obj/item/O as obj, var/mob/user as mob, params) //Copied from MMI
	user.changeNext_move(CLICK_CD_MELEE)
	var/datum/organ/internal/brain/B = suborgans["brain"]
	if(istype(O,/obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/newbrain = O
		if(B && B.exists())
			user << "<span class='warning'>There's already a brain in this head!</span>"
			return
		if(!newbrain.brainmob)
			user << "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain!</span>"
			return

		visible_message("[user] sticks \a [newbrain] into \the [src].")
		user.drop_item()
		set_suborgan(newbrain)

		return

	if(istype(O,/obj/item/weapon/circular_saw))
		if(B && B.exists())
			playsound(src.loc, 'sound/weapons/circsawhit.ogg', 100, 1)
			user.visible_message("[user] starts cutting into \the [src] with \the [O].", \
								 "<span class='notice'>You start cutting into \the [src] with \the [O]...</span>", \
								 "<span class='italics'>You hear the sound of a saw.</span>")

			if(do_after(user, 40))
				var/oldbrain = remove_suborgan("brain")
				if(oldbrain)
					user.put_in_hands(oldbrain) //Give the brain to the surgeon
					user << "<span class='notice'>You pull the brain out of the head.</span>"
				else
					user << "<span class='notice'>Something else removed the brain before you were done.</span>"

		else
			user << "<span class='notice'>There is no brain in this head!</span>"

	..()

/obj/item/organ/limb/l_arm
	name = "left arm"
	hardpoint = "l_arm"
	desc = "Looks like someone has been disarmed."
	icon_state = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT


/obj/item/organ/limb/l_leg
	name = "left leg"
	hardpoint = "l_leg"
	desc = "Looks like someone's leg legged it."
	icon_state = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT


/obj/item/organ/limb/r_arm
	name = "right arm"
	hardpoint = "r_arm"
	desc = "Looks like someone has been disarmed."
	icon_state = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT


/obj/item/organ/limb/r_leg
	name = "right leg"
	hardpoint = "r_leg"
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


	if(organtype == ORGAN_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
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

	if(robotic && organtype != ORGAN_ROBOTIC) // This makes organic limbs not heal when the proc is in Robotic mode.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	if(!robotic && organtype == ORGAN_ROBOTIC) // This makes robolimbs not healable by chems.
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
	if(organtype == ORGAN_ORGANIC) //Robotic limbs show no damage - RR
		var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
		var/tburn	= round( (burn_dam/max_damage)*3, 1 )
		if((tbrute != brutestate) || (tburn != burnstate))
			brutestate = tbrute
			burnstate = tburn
			return 1
		return 0

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