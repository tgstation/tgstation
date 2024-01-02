/**
 * Notifies a human mob of their faction and enemies
 *
 * Arguments:
 * * mob/living/carbon/human/character - the human character mob you want to notify
 * * obj/structure/overmap/ship/ship - Simulated ship that contains the ship's prefix
 */
/proc/NotifyFaction(mob/living/carbon/human/character, obj/structure/overmap/ship/joined_ship)
	switch(joined_ship.source_template.faction_prefix)
		if(NANOTRASEN_SHIP)
			to_chat(character, "<h1>Your faction: Nanotrasen Combat Vessel ([NANOTRASEN_SHIP])</h1>")
			to_chat(character, "<h1>[NANOTRASEN_SHIP] enemies: [SYNDICATE_SHIP] and [NEUTRAL_SHIP].</h1>")
		if(SYNDICATE_SHIP)
			to_chat(character, "<h1>Your faction: Syndicate Combat Vessel ([SYNDICATE_SHIP])</h1>")
			to_chat(character, "<h1>[SYNDICATE_SHIP] ship enemies: [NANOTRASEN_SHIP] and [NEUTRAL_SHIP].</h1>")
		if(NEUTRAL_SHIP)
			to_chat(character, "<h1>Your faction: Neutral ([NEUTRAL_SHIP])</h1>")
			to_chat(character, "<h2>Your enemies are who you make of them independently.</h2>")
