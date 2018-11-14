/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return 0

	var/list/breath_gases = breath.gases

	breath.assert_gases(/datum/gas/plasma, /datum/gas/oxygen)

	var/plasma_moles = breath_gases[/datum/gas/plasma][MOLES]

	if(plasma_moles)
		//Breathe in toxins and out oxygen
		adjustPlasma(plasma_moles * 250)
		breath_gases[/datum/gas/plasma][MOLES] -= plasma_moles
		breath_gases[/datum/gas/oxygen][MOLES] += plasma_moles

	if(plasma_moles * R_IDEAL_GAS_EQUATION * breath.temperature / BREATH_VOLUME > ALIEN_TOX_DETECT)
		throw_alert("alien_tox", /obj/screen/alert/alien_tox)
	else
		clear_alert("alien_tox")

	breath.garbage_collect()

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)
