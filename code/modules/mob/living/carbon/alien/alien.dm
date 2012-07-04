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
			var/image/activeIndicator = image('alien.dmi', loc = facehugger, icon_state = "facehugger_active")
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