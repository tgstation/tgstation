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