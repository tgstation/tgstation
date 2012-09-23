/mob/living/carbon/alien
	name = "alien"
	voice_name = "alien"
	voice_message = "hisses"
	say_message = "hisses"
	icon = 'icons/mob/alien.dmi'
	gender = NEUTER

	var/storedPlasma = 250
	var/max_plasma = 500

	alien_talk_understand = 1

	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = 0

	var/move_delay_add = 0 // movement delay to add

	status_flags = CANPARALYSE
	var/heal_rate = 5
	var/plasma_rate = 5

/mob/living/carbon/alien/adjustToxLoss(amount)
	storedPlasma = min(max(storedPlasma + amount,0),max_plasma) //upper limit of max_plasma, lower limit of 0
	return

/mob/living/carbon/alien/proc/getPlasma()
	return storedPlasma

/mob/living/carbon/alien/eyecheck()
	return 2

/mob/living/carbon/alien/New()
	..()

	for(var/obj/item/clothing/mask/facehugger/facehugger in world)
		if(facehugger.stat == CONSCIOUS)
			var/image/activeIndicator = image('icons/mob/alien.dmi', loc = facehugger, icon_state = "facehugger_active")
			activeIndicator.override = 1
			if(client)
				client.images += activeIndicator

/mob/living/carbon/alien/IsAdvancedToolUser()
	return has_fine_manipulation


/mob/living/carbon/alien/Stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
	else
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 2), 10) // a maximum delay of 10
	return


/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/alien/proc/AddInfectionImages()
	if (client)
		for (var/mob/living/carbon/C in world)
			if(C.status_flags & XENO_HOST)
				var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected")
				client.images += I
	return


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if (client)
		for(var/image/I in client.images)
			if(I.icon_state == "infected")
				del(I)
	return

