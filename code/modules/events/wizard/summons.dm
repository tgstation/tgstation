/datum/round_event_control/wizard/summonguns //The Classic
	name = "Summon Guns"
	weight = 1
	typepath = /datum/round_event/wizard/summonguns/
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/summonguns/start()
	if(!ticker.mode.wizards)	return
	var/datum/mind/M = pick(ticker.mode.wizards)
	if(M.current)
		M.current.rightandwrong(0)

/datum/round_event_control/wizard/summonmagic //The Somewhat Less Classic
	name = "Summon Magic"
	weight = 1
	typepath = /datum/round_event/wizard/summonmagic/
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/summonmagic/start()
	if(!ticker.mode.wizards)	return
	var/datum/mind/M = pick(ticker.mode.wizards)
	if(M.current)
		M.current.rightandwrong(1)