/mob/living/silicon/robot/Process_Spacemove()
	if(module)
		for(var/obj/item/clothing/tank/jetpack/J in module.modules)
			if(J && istype(J, /obj/item/clothing/tank/jetpack))
				if(J.allow_thrust(0.01))	return 1
	if(..())	return 1
	return 0

 //No longer needed, but I'll leave it here incase we plan to re-use it.
/mob/living/silicon/robot/movement_delay()
	var/tally = 0 //Incase I need to add stuff other than "speed" later

	tally = speed

	return tally+config.robot_delay
