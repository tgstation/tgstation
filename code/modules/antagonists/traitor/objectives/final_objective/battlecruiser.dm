/datum/traitor_objective/ultimate/battlecruiser
	name = "Reveal Station Coordinates to nearby Syndicate Battlecruiser"
	description = "Use a special upload card on a communications console to send the coordinates \
	of the station to a nearby Battlecruiser. You may want to make your syndicate status known to \
	the battlecruiser crew when they arrive - their goal will be to destroy the station."

	/// Checks whether we have sent the card to the traitor yet.
	var/sent_accesscard = FALSE
	/// Battlecruiser team that we get assigned to
	var/datum/team/battlecruiser/team

/datum/traitor_objective/ultimate/battlecruiser/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	// There's no empty space to load a battlecruiser in...
	if(SSmapping.is_planetary())
		return FALSE

	return TRUE

/datum/traitor_objective/ultimate/battlecruiser/on_objective_taken(mob/user)
	. = ..()
	team = new()
	var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.nuke_list
	if(nuke.r_code == NUKE_CODE_UNSET)
		nuke.r_code = random_nukecode()
	team.nuke = nuke
	team.update_objectives()
	handler.owner.add_antag_datum(/datum/antagonist/battlecruiser/ally, team)


/datum/traitor_objective/ultimate/battlecruiser/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_accesscard)
		buttons += add_ui_button("", "Pressing this will materialize an upload card, which you can use on a communication console to contact the fleet.", "phone", "card")
	return buttons

/datum/traitor_objective/ultimate/battlecruiser/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("card")
			if(sent_accesscard)
				return
			sent_accesscard = TRUE
			var/obj/item/card/emag/battlecruiser/emag_card = new()
			emag_card.team = team
			podspawn(list(
				"target" = get_turf(user),
				"style" = STYLE_SYNDICATE,
				"spawn" = emag_card,
			))
