/mob/living/carbon/alien/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(!.) //dead or deleted
		return
	findQueen()

/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return 0

	if(health <= HEALTH_THRESHOLD_CRIT)
		adjust_oxy_loss(2)

	var/plasma_used = 0
	var/plas_detect_threshold = 0.02
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
	var/list/breath_moles = breath.moles

	breath.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)

	//Partial pressure of the plasma in our breath
	var/plasma_pp = (breath_moles[/datum/gas/plasma] / breath.total_moles()) * breath_pressure

	if(plasma_pp > plas_detect_threshold) // Detect plasma in air
		adjustPlasma(breath_moles[/datum/gas/plasma] * 250)
		throw_alert(ALERT_XENO_PLASMA, /atom/movable/screen/alert/alien_plas)

		plasma_used = breath_moles[/datum/gas/plasma]

	else
		clear_alert(ALERT_XENO_PLASMA)

	//Breathe in plasma and out oxygen
	breath_moles[/datum/gas/plasma] -= plasma_used
	breath_moles[/datum/gas/oxygen] += plasma_used

	breath.garbage_collect()

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

/mob/living/carbon/alien/adult/Life(seconds_per_tick)
	. = ..()
	if(QDELETED(src))
		return
	handle_organs(seconds_per_tick)
