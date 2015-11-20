/obj/item/organ/butt
	name = "butt"
	hardpoint = "butt"
	icon_state = "butt"

// These only serve to represent the groin and mouth target zones.
/obj/item/organ/abstract/groin
	name = "groin"
	hardpoint = "groin"

/obj/item/organ/abstract/mouth
	name = "mouth"
	hardpoint = "mouth"

/obj/item/organ/abstract/Insert(mob/living/carbon/M)
	return null

/obj/item/organ/limb
	name = "limb"
	var/originalname = "Error"	//So limbs know how to set their names when removed, according to species
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/list/embedded_objects = list()
	var/list/dependant_items = list()	//Item slots that depend on this limb
	var/counterpart = null



/obj/item/organ/limb/New()
	..()
	originalname = name

/obj/item/organ/limb/Remove(special = 0)
	if(dna && dna.species)
		name = "[dna.species.id] [originalname]"

	if(counterpart)
		var/datum/organ/limb/OR = owner.get_organ(counterpart)
		if(OR && OR.exists())
			return	//No need to remove items if the other arm/leg is left

	for(var/itemname in dependant_items)
		var/obj/item/itemtoremove = owner.get_item_by_slot(itemname)
		if(itemtoremove)
			owner.unEquip(itemtoremove, 1)

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
	dependant_items = list(slot_ears, slot_glasses, slot_head, slot_wear_mask)
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
		brain.loc = src
		brain.transfer_identity(owner)

/obj/item/organ/limb/head/Remove(special = 0)
	..(special)
	if(!special)
		transfer_identity()
	src.name = "[owner]'s head"

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


	if(istype(O,/obj/item/weapon/hemostat))
		var/datum/organ/internal/eyes/E = suborgans["eyes"]
		if(E && E.exists())
			user.visible_message("[user] starts removing \the [E.organitem] with \the [O].", \
								 "<span class='notice'>You start removing \the [E.organitem] with \the [O]...</span>")

			if(do_after(user, 10))
				var/eyes = remove_suborgan("eyes")
				if(eyes)
					user.put_in_hands(eyes) //Give the brain to the surgeon
					user << "<span class='notice'>You pluck the [eyes] out of the head.</span>"
				else
					user << "<span class='notice'>Something else removed the eyes before you were done.</span>"

		else
			user << "<span class='notice'>The head's eyesockets are empty!</span>"

	..()

/obj/item/organ/limb/arm/
	desc = "Looks like someone has been disarmed."
	max_damage = 75
	dependant_items = list(slot_gloves)


/obj/item/organ/limb/arm/Remove(special = 0)
	owner.update_inv_gloves()

	..(special)

/obj/item/organ/limb/arm/l_arm
	name = "left arm"
	hardpoint = "l_arm"
	icon_state = "l_arm"
	body_part = ARM_LEFT
	counterpart = "r_arm"

//Unwields twohanded weapons in right hand and drops any item in left hand
/obj/item/organ/limb/arm/l_arm/Remove(special = 0)
	if(owner.r_hand && istype(owner.r_hand, /obj/item/weapon/twohanded))
		world << "Found [owner.r_hand] in other hand!"
		var/obj/item/weapon/twohanded/TWOH = owner.r_hand
		TWOH.unwield()
	owner.drop_l_hand()

	owner.update_inv_l_hand()

	..(special)

/obj/item/organ/limb/leg/
	desc = "Looks like someone's leg legged it."
	max_damage = 75
	dependant_items = list(slot_shoes)

/obj/item/organ/limb/leg/Remove(special = 0)
	owner.update_inv_shoes()

	..(special)

/obj/item/organ/limb/leg/l_leg
	name = "left leg"
	hardpoint = "l_leg"
	icon_state = "l_leg"
	body_part = LEG_LEFT
	counterpart = "r_leg"

/obj/item/organ/limb/arm/r_arm
	name = "right arm"
	hardpoint = "r_arm"
	icon_state = "r_arm"
	body_part = ARM_RIGHT
	counterpart = "l_arm"

//Pretty much a mirror of the other proc
/obj/item/organ/limb/arm/r_arm/Remove(special = 0)
	if(owner.l_hand && istype(owner.l_hand, /obj/item/weapon/twohanded))
		world << "Found [owner.l_hand] in other hand!"
		var/obj/item/weapon/twohanded/TWOH = owner.l_hand
		TWOH.unwield()
	owner.drop_r_hand()

	owner.update_inv_r_hand()

	..(special)

/obj/item/organ/limb/leg/r_leg
	name = "right leg"
	hardpoint = "r_leg"
	icon_state = "r_leg"
	body_part = LEG_RIGHT
	counterpart = "l_leg"

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

	for(var/datum/organ/limb/limbdata in get_limbs())
		if(limbdata.exists())
			var/obj/item/organ/limb/L = limbdata.organitem
			for(var/obj/item/I in L.embedded_objects)
				L.embedded_objects -= I
				I.loc = T

	clear_alert("embeddedobject")

/mob/living/carbon/human/proc/has_embedded_objects()
	. = 0
	for(var/datum/organ/limb/limbdata in get_limbs())
		if(limbdata.exists())
			var/obj/item/organ/limb/L = limbdata.organitem
			for(var/obj/item/I in L.embedded_objects)
				return 1