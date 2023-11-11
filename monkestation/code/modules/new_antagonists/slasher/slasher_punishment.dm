/datum/antagonist/slasher/proc/check_soul_punishment()
	if(last_soul_sucked + soul_digestion < world.time)
		return
	soul_punishment++
	addtimer(CALLBACK(src, PROC_REF(remove_punishment_layer)), 5 MINUTES)

/datum/antagonist/slasher/proc/remove_punishment_layer()
	soul_punishment--
