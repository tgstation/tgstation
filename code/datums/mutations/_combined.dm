/datum/generecipe
	var/required = "" //it hurts so bad but initial is not compatible with lists
	var/result = null

/proc/get_mixed_mutation(mutation1, mutation2)
	if(!mutation1 || !mutation2)
		return FALSE
	if(mutation1 == mutation2) //this could otherwise be bad
		return FALSE
	for(var/A in GLOB.mutation_recipes)
		if(findtext(A, "[mutation1]") && findtext(A, "[mutation2]"))
			return GLOB.mutation_recipes[A]

/* RECIPES */

/datum/generecipe/hulk
	required = "/datum/mutation/human/strong; /datum/mutation/human/radioactive"
	result = /datum/mutation/human/hulk

/datum/generecipe/mindread
	required = "/datum/mutation/human/antenna; /datum/mutation/human/paranoia"
	result = /datum/mutation/human/mindreader

/datum/generecipe/shock
	required = "/datum/mutation/human/insulated; /datum/mutation/human/radioactive"
	result = /datum/mutation/human/shock

/datum/generecipe/antiglow
	required = "/datum/mutation/human/glow; /datum/mutation/human/void"
	result = /datum/mutation/human/glow/anti

/datum/generecipe/tonguechem
	required = "/datum/mutation/human/tongue_spike; /datum/mutation/human/stimmed"
	result = /datum/mutation/human/tongue_spike/chem

/datum/generecipe/martyrdom
	required = "/datum/mutation/human/strong; /datum/mutation/human/stimmed"
	result = /datum/mutation/human/martyrdom
