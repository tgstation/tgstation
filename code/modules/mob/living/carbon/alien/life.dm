/mob/living/carbon/alien/Life()
	findQueen()
	return..()

/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return 0

	var/toxins_used = 0
	var/tox_detect_threshold = 0.02
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.return_temperature())/BREATH_VOLUME

	//Partial pressure of the toxins in our breath
	var/Toxins_pp = (breath.get_moles(/datum/gas/plasma) / breath.total_moles()) * breath_pressure

	if(Toxins_pp > tox_detect_threshold) // Detect toxins in air
		adjustPlasma(breath.get_moles(/datum/gas/plasma) * 250)
		throw_alert("alien_tox", /obj/screen/alert/alien_tox)

		toxins_used = breath.get_moles(/datum/gas/plasma)

	else
		clear_alert("alien_tox")

	//Breathe in toxins and out oxygen
	breath.adjust_moles(/datum/gas/plasma, -toxins_used)
	breath.adjust_moles(/datum/gas/oxygen, toxins_used)


	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

/mob/living/carbon/alien/handle_status_effects()
	..()
	//natural reduction of movement delay due to stun.
	if(move_delay_add > 0)
		move_delay_add = max(0, move_delay_add - rand(1, 2))

/mob/living/carbon/alien/handle_changeling()
	return

/mob/living/carbon/alien/handle_fire()//Aliens on fire code
	. = ..()
	if(.) //if the mob isn't on fire anymore
		return
	adjust_bodytemperature(BODYTEMP_HEATING_MAX) //If you're on fire, you heat up!
