/mob/living/proc/undergoing_hypothermia()
	if(!istype(src,/mob/living/carbon/human))
		return NO_HYPOTHERMIA
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return NO_HYPOTHERMIA
	var/body_temp_celcius = src.bodytemperature - T0C
	switch(body_temp_celcius)
		if(32 to 35)
			return MILD_HYPOTHERMIA // awake and shivering
		if(28 to 32)
			return MODERATE_HYPOTHERMIA // drowsy and not shivering
		if(20 to 28)
			return SEVERE_HYPOTHERMIA // unconcious, not shivering
		if(-T0C to 20)
			return PROFOUND_HYPOTHERMIA // no vital signs
	return NO_HYPOTHERMIA

/mob/living/carbon/human/proc/is_vessel_dilated() // finds out if the blood vessel is dilated - ie expanded and more subsceptible to hypothermia.
	if(!reagents)
		return 0
	var/datum/reagents/blood = reagents
	var/vessel_dilated = 0
	if(blood.reagent_list)
		for(var/datum/reagent/chem in blood.reagent_list)
			if(istype(chem,/datum/reagent/ethanol)) // alcohol is a vasodilator.
				vessel_dilated = 1
	if(undergoing_hypothermia() == MODERATE_HYPOTHERMIA && nutrition < 250) // conserve our energy for something else.
		vessel_dilated = 1
	return vessel_dilated


/mob/living/carbon/human/proc/get_skin_temperature()
	var/skin_temperature = bodytemperature - T0C
	var/modifier = 0.9 // this results in the skin temperature of a human who is 37C having 33.3C
	if(!is_vessel_dilated())
		modifier -= (1/5)*undergoing_hypothermia()	// Hypothermia takes blood from extremities to prevent heat loss.
	skin_temperature *= modifier
	skin_temperature += T0C
	return skin_temperature

/mob/living/carbon/human/proc/handle_hypothermia() // called in handle_body_temperature.dm
	switch(undergoing_hypothermia())
		if(MILD_HYPOTHERMIA) // shivering + stuttering + slowed down
			// see human_movement.dm for slowdown.
			// see handle_regular_status_updates for "shivering"
		if(MODERATE_HYPOTHERMIA) // drowsy and not shivering + slowed down
		// at this stage, you have a 25% chance of 'momentarily forgetting' how to use machines, like when braindamaged.
		// see handle_regular_status_updates for the increased dizziness.
		// may stutter - see say.dm
		// may slur words - see a different say.dm there's like a billion.
		// see human_movement.dm for slowdown.
			burn_calories(0.2)
			if(prob(2) && get_active_hand())
				to_chat(src, "<span class='warning'>You lose your grip of \the [get_active_hand()], and it slides out of your hand!</span>")
				drop_item()
			if(prob(1))
				to_chat(src, "<span class='warning'>Your legs buckle underneath you, and you collapse!</span>")
				say("*collapse")
		if(SEVERE_HYPOTHERMIA) // unconcious, not shivering - we're going to burn up all you've eaten now.
			// at this point, the pulse will go to rougly 30bpm, see handle_pulse for details.
			// at this point, you are unconcious; see handle_regular_status_updates.dm for details.
			src.adjustOxyLoss(0.5)
		if(PROFOUND_HYPOTHERMIA) // all vital signs are gone, we've can't even burn fuel it's 2cold, try to keep the brain alive.
			for(var/datum/organ/internal/organ in internal_organs_by_name) // total organ shutdown except the brain, which the body tries to use all the energy it has keep alive.
				if(!istype(organ,/datum/organ/internal/brain))
					organ.take_damage(1,1)
			// at this point, they will have no pulse, see handle_pulse for details.
			src.adjustOxyLoss(1) //see handle_breath.dm, they aren't breathing.