/datum/round_event_control/aprilfools
	name = "The Skub Debate"
	holidayID = APRIL_FOOLS
	typepath = /datum/round_event/aprilfools
	weight = -1
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/aprilfools/start()
	..()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		to_chat(H, "<span class = 'danger'>You are [pick("pro-skub", "anti-skub")].</span>")
