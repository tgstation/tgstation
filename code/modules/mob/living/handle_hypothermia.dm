var/global/list/coldwarning_light = list("You feel cold.","Your nose feels numb.","It's pretty cold!","You should probably wrap up some more.","You feel pretty cold.","You feel like taking a nap.")
var/global/list/coldwarning_hard = list("Holy shit, it's freezing cold!","You should probably get warmed up quickly!","You can't feel your hands!","You can't feel anything!","You're absolutely exhausted!")

/mob/living/proc/undergoing_hypothermia()
	if((status_flags & GODMODE) || (flags & INVULNERABLE) || istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return NO_HYPOTHERMIA
	var/body_temp_celcius = src.bodytemperature - T0C
	switch(body_temp_celcius)
		if(32 to 35)
			return MILD_HYPOTHERMIA // awake and shivering
		if(28 to 32)
			return MODERATE_HYPOTHERMIA // drowsy and not shivering
		if(24 to 28)
			return SEVERE_HYPOTHERMIA // unconcious, not shivering
		if(-T0C to 24)
			return PROFOUND_HYPOTHERMIA // no vital signs
	return NO_HYPOTHERMIA

/mob/living/carbon/human/undergoing_hypothermia()
	. = ..()
	if(.)
		if(species && !(species.can_be_hypothermic))
			return NO_HYPOTHERMIA
		else return .

/mob/living/silicon/undergoing_hypothermia()
	return NO_HYPOTHERMIA

/mob/living/carbon/alien/undergoing_hypothermia()
	return NO_HYPOTHERMIA

/mob/living/simple_animal/undergoing_hypothermia()
	return NO_HYPOTHERMIA

/mob/living/proc/is_vessel_dilated() // finds out if the blood vessel is dilated - ie expanded and more subsceptible to hypothermia.
	if(!reagents)
		return 0
	var/datum/reagents/blood = reagents
	if(blood.reagent_list)
		for(var/datum/reagent/chem in blood.reagent_list)
			if(istype(chem,/datum/reagent/ethanol)) // alcohol is a vasodilator.
				return 1
			if(istype(chem,/datum/reagent/capsaicin)) // as is capsaicin
				return 1
	if(undergoing_hypothermia() == MODERATE_HYPOTHERMIA && bodytemperature < 29) // conserve our energy for something else.
		return 1
	return 0


/mob/living/proc/get_skin_temperature()
	var/skin_temperature = bodytemperature - T0C
	var/modifier = 0.9 // this results in the skin temperature of a human who is 37C having 33.3C
	if(!is_vessel_dilated())
		modifier -= (1/5)*undergoing_hypothermia()	// Hypothermia takes blood from extremities to prevent heat loss.
	skin_temperature *= modifier
	skin_temperature += T0C
	return skin_temperature


/mob/living/proc/handle_hypothermia() // called in handle_body_temperature.dm
	switch(undergoing_hypothermia())
		if(MILD_HYPOTHERMIA) // shivering + stuttering + slowed down
			// see human_movement.dm for slowdown.
			if(prob(15) && !is_vessel_dilated())
				if(prob(75))
					to_chat(src,"<b>[pick(coldwarning_light)]</b>")
				else to_chat(src,"<span class='danger'>[pick(coldwarning_hard)]</span>")
			if(prob(25)) // shivering
				jitteriness = min(jitteriness + 15,30)
		if(MODERATE_HYPOTHERMIA) // drowsy and not shivering + slowed down
		// at this stage, you have a 25% chance of 'momentarily forgetting' how to use machines, like when braindamaged.
		// see handle_regular_status_updates for the increased dizziness.
		// may stutter - see say.dm
		// may slur words - see a different say.dm there's like a billion.
		// see human_movement.dm for slowdown.
			if(prob(15) && !is_vessel_dilated())
				if(prob(25))
					to_chat(src,"<b>[pick(coldwarning_light)]</b>")
				else to_chat(src,"<span class='danger'>[pick(coldwarning_hard)]</span>")
			burn_calories(0.2)
			if(prob(2) && get_active_hand())
				to_chat(src, "<span class='warning'>You lose your grip of \the [get_active_hand()], and it slides out of your hand!</span>")
				drop_item()
			if(prob(1))
				to_chat(src, "<span class='warning'>Your legs buckle underneath you, and you collapse!</span>")
				emote("collapse")
		if(SEVERE_HYPOTHERMIA) // unconcious, not shivering - we're going to burn up all you've eaten now.
			// at this point, the pulse will go to rougly 30bpm, see handle_pulse for details.
			// at this point, you are unconcious; see handle_regular_status_updates.dm for details.
			if(prob(25))
				src.adjustOxyLoss(5) // this seems pretty deadly but they're still breathing so it'll decay.
		if(PROFOUND_HYPOTHERMIA) // all vital signs are gone, we've can't even burn fuel it's 2cold, try to keep the brain alive.
			// at this point, they will have no pulse, see handle_pulse for details.
			if(prob(25))
				src.adjustOxyLoss(5) //see handle_breath.dm, they aren't breathing.
