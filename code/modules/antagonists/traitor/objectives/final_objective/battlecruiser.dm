/// The minimum number of ghosts and observers needed before handing out battlecruiser objectives.
#define MIN_GHOSTS_FOR_BATTLECRUISER 8

/datum/traitor_objective/final/battlecruiser
	name = "Reveal Station Coordinates to nearby Syndicate Battlecruiser"
	description = "Use a special upload card on a communications console to send the coordinates \
	of the station to a nearby Battlecruiser. You may want to make your syndicate status known to \
	the battlecruiser crew when they arrive - their goal will be to destroy the station."

	/// Checks whether we have sent the card to the traitor yet.
	var/sent_accesscard = FALSE

/datum/traitor_objective/final/battlecruiser/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!can_take_final_objective())
		return FALSE
	// There's no empty space to load a battlecruiser in...
	if(!SSmapping.empty_space)
		return FALSE
	// Check how many observers + ghosts (dead players) we have.
	// If there's not a ton of observers and ghosts to populate the battlecruiser,
	// We won't bother giving the objective out.
	var/num_ghosts = length(GLOB.current_observers_list) + length(GLOB.dead_player_list)
	if(num_ghosts < MIN_GHOSTS_FOR_BATTLECRUISER)
		return FALSE

	return TRUE

/datum/traitor_objective/final/battlecruiser/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_accesscard)
		buttons += add_ui_button("", "Pressing this will materialize an upload card, which you can use on a communication console to contact the fleet.", "phone", "card")
	return buttons

/datum/traitor_objective/final/battlecruiser/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("card")
			if(sent_accesscard)
				return
			sent_accesscard = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = STYLE_SYNDICATE,
				"spawn" = /obj/item/card/emag/battlecruiser,
			))

#undef MIN_GHOSTS_FOR_BATTLECRUISER
