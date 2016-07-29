<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/brain
	languages_spoken = HUMAN
	languages_understood = HUMAN
	var/obj/item/device/mmi/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	has_limbs = 0
	stat = DEAD //we start dead by default
	see_invisible = SEE_INVISIBLE_MINIMUM

/mob/living/carbon/brain/New(loc)
	..()
	if(isturf(loc)) //not spawned in an MMI or brain organ (most likely adminspawned)
		var/obj/item/organ/brain/OB = new(loc) //we create a new brain organ for it.
		src.loc = OB
		OB.brainmob = src


/mob/living/carbon/brain/Destroy()
	if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat!=DEAD)	//If not dead.
			death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
		ghostize()		//Ghostize checks for key so nothing else is necessary.
	container = null
	return ..()

/mob/living/carbon/brain/update_canmove()
	if(in_contents_of(/obj/mecha))
		canmove = 1
	else
		canmove = 0
	return canmove

/mob/living/carbon/brain/toggle_throw_mode()
	return

/mob/living/carbon/brain/ex_act() //you cant blow up brainmobs because it makes transfer_to() freak out when borgs blow up.
	return

/mob/living/carbon/brain/blob_act(obj/effect/blob/B)
	return

/mob/living/carbon/brain/UnarmedAttack(atom/A)//Stops runtimes due to attack_animal being the default
	return

/mob/living/carbon/brain/check_ear_prot()
	return 1

/mob/living/carbon/brain/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	return // no eyes, no flashing

/mob/living/carbon/brain/update_damage_hud()
	return //no red circles for brain

/mob/living/carbon/brain/can_be_revived()
	. = 1
	if(!container || health <= config.health_threshold_dead)
		return 0

/mob/living/carbon/brain/update_sight()
	return
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	can_butcher = 0
	immune_to_ssd = 1
	use_me = 0 //Can't use the me verb, it's a freaking immobile brain
	hasmouth=0 // Can't feed it.
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain1"
	universal_speak = 1
	universal_understand = 1

/mob/living/carbon/brain/New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		..()

/mob/living/carbon/brain/Destroy()
	if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat!=DEAD)	//If not dead.
			death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
	..()

/mob/living/carbon/brain/update_canmove()
	if(in_contents_of(/obj/mecha))
		canmove = 1
		use_me = 1 //If it can move, let it emote
	else							canmove = 0
	return canmove

/mob/living/carbon/brain/say_understands(var/atom/movable/other)//Goddamn is this hackish, but this say code is so odd
	if(other) other = other.GetSource()
	if (istype(other, /mob/living/silicon/ai))
		if(!(container && istype(container, /obj/item/device/mmi)))
			return 0
		else
			return 1
	if (istype(other, /mob/living/silicon/decoy))
		if(!(container && istype(container, /obj/item/device/mmi)))
			return 0
		else
			return 1
	if (istype(other, /mob/living/silicon/pai))
		if(!(container && istype(container, /obj/item/device/mmi)))
			return 0
		else
			return 1
	if (istype(other, /mob/living/silicon/robot))
		if(!(container && istype(container, /obj/item/device/mmi)))
			return 0
		else
			return 1
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/carbon/slime))
		return 1
	return ..()

/mob/living/carbon/brain/teleport_to(var/atom/A)
	container.forceMove(get_turf(A))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
