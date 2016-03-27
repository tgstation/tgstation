//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/brain
	languages = HUMAN
	var/obj/item/device/mmi/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	has_limbs = 0
	stat = DEAD //we start dead by default
	see_invisible = SEE_INVISIBLE_MINIMUM

/mob/living/carbon/brain/New(loc)
	..()
	if(isturf(loc)) //not spawned in an MMI or brain organ (most likely adminspawned)
		var/obj/item/organ/internal/brain/OB = new(loc) //we create a new brain organ for it.
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

/mob/living/carbon/brain/blob_act()
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
