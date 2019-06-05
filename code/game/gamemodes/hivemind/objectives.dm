/datum/objective/hivemind

/datum/objective/hivemind/hivesize
	explanation_text = "This is a bug. Error:HIVE2"
	target_amount = 10

/datum/objective/hivemind/hivesize/New()
	target_amount = ( max(8, round(GLOB.joined_player_list.len/3)) + rand(0,3) )
	update_explanation_text()

/datum/objective/hivemind/hivesize/update_explanation_text()
	explanation_text = "End the round with at least [target_amount] beings assimilated into the hive."

/datum/objective/hivemind/hivesize/check_completion()
	var/datum/antagonist/hivemind/host = owner.has_antag_datum(/datum/antagonist/hivemind)
	if(!host)
		return FALSE
	return host.hive_size >= target_amount

/datum/objective/hivemind/hiveescape
	explanation_text = "This is a bug. Error:HIVE2"
	target_amount = 10

/datum/objective/hivemind/hiveescape/New()
	target_amount = ( max(5, round(GLOB.joined_player_list.len/6)) + rand(0,2) )
	update_explanation_text()

/datum/objective/hivemind/hiveescape/update_explanation_text()
	explanation_text = "Have at least [target_amount] members of the hive escape on the shuttle alive and free."

/datum/objective/hivemind/hiveescape/check_completion()
	var/count = 0
	var/datum/antagonist/hivemind/host = owner.has_antag_datum(/datum/antagonist/hivemind)
	if(!host)
		return FALSE
	for(var/datum/mind/M in host.hivemembers)
		if(considered_escaped(M))
			count++
	return count >= target_amount

/datum/objective/hivemind/biggest
	explanation_text = "End the round with more vessels than any other hivemind host."

/datum/objective/hivemind/biggest/check_completion()
	var/datum/antagonist/hivemind/host = owner.has_antag_datum(/datum/antagonist/hivemind)
	if(!host)
		return FALSE
	for(var/datum/antagonist/hivemind/H in GLOB.antagonists)
		if(H == host)
			continue
		if(H.hive_size >= host.hive_size)
			return FALSE
	return TRUE
