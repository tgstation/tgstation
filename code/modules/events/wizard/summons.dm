/datum/round_event_control/wizard/summonguns //The Classic
	name = "Summon Guns"
	weight = 1
	typepath = /datum/round_event/wizard/summonguns
	max_occurrences = 1
	earliest_start = ZERO MINUTES

/datum/round_event_control/wizard/summonguns/New()
	if(CONFIG_GET(flag/no_summon_guns))
		weight = ZERO
	..()

/datum/round_event/wizard/summonguns/start()
	rightandwrong(SUMMON_GUNS, null, 10)

/datum/round_event_control/wizard/summonmagic //The Somewhat Less Classic
	name = "Summon Magic"
	weight = 1
	typepath = /datum/round_event/wizard/summonmagic
	max_occurrences = 1
	earliest_start = ZERO MINUTES

/datum/round_event_control/wizard/summonmagic/New()
	if(CONFIG_GET(flag/no_summon_magic))
		weight = ZERO
	..()

/datum/round_event/wizard/summonmagic/start()
	rightandwrong(SUMMON_MAGIC, null, 10)
