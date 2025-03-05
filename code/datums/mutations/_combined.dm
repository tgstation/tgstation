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
	input_one = /datum/mutation/human/strong
	input_two = /datum/mutation/human/radioactive
	result = /datum/mutation/human/hulk

/datum/generecipe/mindread
	input_one = /datum/mutation/human/antenna
	input_two = /datum/mutation/human/paranoia
	result = /datum/mutation/human/mindreader

/datum/generecipe/shock
	input_one = /datum/mutation/human/insulated
	input_two = /datum/mutation/human/radioactive
	result = /datum/mutation/human/shock

/datum/generecipe/cindikinesis
	input_one = /datum/mutation/human/geladikinesis
	input_two = /datum/mutation/human/fire // fiery sweat NOT fiery breath
	result = /datum/mutation/human/cindikinesis

/datum/generecipe/pyrokinesis
	input_one = /datum/mutation/human/cryokinesis
	input_two = /datum/mutation/human/fire // fiery sweat NOT fiery breath
	result = /datum/mutation/human/pyrokinesis

/datum/generecipe/thermal_adaptation
	input_one = /datum/mutation/human/adaptation/cold
	input_two = /datum/mutation/human/adaptation/heat
	result = /datum/mutation/human/adaptation/thermal

/datum/generecipe/antiglow
	input_one = /datum/mutation/human/glow
	input_two = /datum/mutation/human/void
	result = /datum/mutation/human/glow/anti

/datum/generecipe/tonguechem
	input_one = /datum/mutation/human/tongue_spike
	input_two = /datum/mutation/human/stimmed
	result = /datum/mutation/human/tongue_spike/chem

/datum/generecipe/martyrdom
	input_one = /datum/mutation/human/strong
	input_two = /datum/mutation/human/stimmed
	result = /datum/mutation/human/martyrdom

/datum/generecipe/heckacious
	input_one = /datum/mutation/human/wacky
	input_two = /datum/mutation/human/stoner
	result = /datum/mutation/human/heckacious

/datum/generecipe/ork
	input_one = /datum/mutation/human/hulk
	input_two = /datum/mutation/human/clumsy
	result = /datum/mutation/human/hulk/ork
