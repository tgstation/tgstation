/datum/round_event_control/wizard/embedpocalypse
	name = "Make Everything Embeddable"
	weight = 2
	typepath = /datum/round_event/wizard/embedpocalypse
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/embedpocalypse/start()
	for(var/obj/item/I in world)
		CHECK_TICK

		if(!(I.flags_1 & INITIALIZED_1))
			continue

		if(!I.embedding || I.embedding == EMBED_HARMLESS)
			I.embedding = EMBED_POINTY
			I.AddElement(/datum/element/embed, I.embedding)
			I.name = "pointy [I.name]"

	GLOB.embedpocalypse = TRUE
	GLOB.stickpocalypse = FALSE // embedpocalypse takes precedence over stickpocalypse

/datum/round_event_control/wizard/embedpocalypse/sticky
	name = "Make Everything Sticky"
	weight = 6
	typepath = /datum/round_event/wizard/embedpocalypse/sticky
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event_control/wizard/embedpocalypse/sticky/canSpawnEvent(players_amt, gamemode)
	if(GLOB.embedpocalypse)
		return FALSE

/datum/round_event/wizard/embedpocalypse/sticky/start()
	for(var/obj/item/I in world)
		CHECK_TICK

		if(!(I.flags_1 & INITIALIZED_1))
			continue

		if(!I.embedding)
			I.embedding = EMBED_HARMLESS
			I.AddElement(/datum/element/embed, I.embedding)
			I.name = "sticky [I.name]"

	GLOB.stickpocalypse = TRUE
