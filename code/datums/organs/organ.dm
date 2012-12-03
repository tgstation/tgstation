/datum/organ
	var/name = "organ"
	var/mob/living/carbon/human/owner = null
	var/list/datum/autopsy_data/autopsy_data = list()
	
	var/list/trace_chemicals = list() // traces of chemicals in the organ,
									  // links chemical IDs to number of ticks for which they'll stay in the blood


///datum/organ/proc/process()
//	return 0

///datum/organ/proc/receive_chem(chemical as obj)
//	return 0

	proc/process()
		return 0

	proc/receive_chem(chemical as obj)
		return 0
