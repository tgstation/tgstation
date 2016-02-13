//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_pulse()
	if(life_tick % 5)
		return pulse //Update pulse every 5 life ticks (~1 tick/sec, depending on server load)

	if(undergoing_hypothermia() == SEVERE_HYPOTHERMIA)
		return PULSE_2SLOW
	if(undergoing_hypothermia() == PROFOUND_HYPOTHERMIA)
		return PULSE_NONE

	if(species && species.flags & NO_BLOOD) return PULSE_NONE //No blood, no pulse.

	if(stat == DEAD)
		return PULSE_NONE //That's it, you're dead, nothing can influence your pulse

	var/temp = PULSE_NORM

	if(round(vessel.get_reagent_amount("blood")) <= BLOOD_VOLUME_BAD) //How much blood do we have
		temp = PULSE_THREADY //Not enough :(

	if(status_flags & FAKEDEATH)
		temp = PULSE_NONE //Pretend that we're dead. unlike actual death, can be inflienced by meds

	//Handles different chems' influence on pulse
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.id in bradycardics)
			if(temp <= PULSE_THREADY && temp >= PULSE_NORM)
				temp--

		if(R.id in tachycardics)
			if(temp <= PULSE_FAST && temp >= PULSE_NONE)
				temp++

		if(R.id in heartstopper) //To avoid using fakedeath
			temp = PULSE_NONE

		if(R.id in cheartstopper)  //Conditional heart-stoppage
			if(R.volume >= R.overdose)
				temp = PULSE_NONE

	return temp
