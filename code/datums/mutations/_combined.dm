/datum/generecipe
	var/input_one = null
	var/input_two = null
	var/result = null

/proc/get_mixed_mutation(mutation1, mutation2)
	if(!mutation1 || !mutation2)
		return FALSE
	if(mutation1 == mutation2) //this could otherwise be bad
		return FALSE
	for(var/datum/generecipe/GR as anything in subtypesof(/datum/generecipe))
		if((initial(GR.input_one) == mutation1 && initial(GR.input_two) == mutation2) || (initial(GR.input_one) == mutation2 && initial(GR.input_two) == mutation1))
			return initial(GR.result)

/* RECIPES */

/datum/generecipe/hulk
	input_one = /datum/mutation/strong
	input_two = /datum/mutation/radioactive
	result = /datum/mutation/hulk

/datum/generecipe/mindread
	input_one = /datum/mutation/antenna
	input_two = /datum/mutation/paranoia
	result = /datum/mutation/mindreader

/datum/generecipe/shock
	input_one = /datum/mutation/insulated
	input_two = /datum/mutation/radioactive
	result = /datum/mutation/shock

/datum/generecipe/cindikinesis
	input_one = /datum/mutation/geladikinesis
	input_two = /datum/mutation/fire // fiery sweat NOT fiery breath
	result = /datum/mutation/cindikinesis

/datum/generecipe/pyrokinesis
	input_one = /datum/mutation/cryokinesis
	input_two = /datum/mutation/fire // fiery sweat NOT fiery breath
	result = /datum/mutation/pyrokinesis

/datum/generecipe/thermal_adaptation
	input_one = /datum/mutation/adaptation/cold
	input_two = /datum/mutation/adaptation/heat
	result = /datum/mutation/adaptation/thermal

/datum/generecipe/antiglow
	input_one = /datum/mutation/glow
	input_two = /datum/mutation/void
	result = /datum/mutation/glow/anti

/datum/generecipe/tonguechem
	input_one = /datum/mutation/tongue_spike
	input_two = /datum/mutation/stimmed
	result = /datum/mutation/tongue_spike/chem

/datum/generecipe/martyrdom
	input_one = /datum/mutation/strong
	input_two = /datum/mutation/stimmed
	result = /datum/mutation/martyrdom

/datum/generecipe/heckacious
	input_one = /datum/mutation/wacky
	input_two = /datum/mutation/stoner
	result = /datum/mutation/heckacious

/datum/generecipe/ork
	input_one = /datum/mutation/hulk
	input_two = /datum/mutation/clumsy
	result = /datum/mutation/hulk/ork

/datum/generecipe/rock_absorber
	input_one = /datum/mutation/rock_eater
	input_two = /datum/mutation/stoner
	result = /datum/mutation/rock_absorber
