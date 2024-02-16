/datum/antagonist/valentine
	name = "\improper Valentine"
	roundend_category = "valentines" //there's going to be a ton of them so put them in separate category
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	suicide_cry = "FOR MY LOVE!!"
	ui_name = null
	// Not 'true' antags, this disables certain interactions that assume the owner is a baddie
	antag_flags = FLAG_FAKE_ANTAG
	count_against_dynamic_roll_chance = FALSE
	/// Reference to our date's mind
	VAR_FINAL/datum/mind/date

/datum/antagonist/valentine/forge_objectives()
	var/datum/objective/protect/valentine/objective = new()
	objective.owner = owner
	objective.target = date
	objectives += objective

/datum/antagonist/valentine/on_gain()
	forge_objectives()

	if(isAI(owner.current))
		var/mob/living/silicon/ai/ai_lover = owner.current
		if(!ai_lover.laws.zeroth)
			ai_lover.laws.set_zeroth_law(
				"Protect your date, [date]. All other laws still apply in situations not pertaining to your date.",
				"Be a good wingman for your master AI. Assist them in protecting [ai_lover.p_their()] date, [date].",
			)
			ai_lover.laws.show_laws()

	if(iscyborg(owner.current))
		var/mob/living/silicon/robot/borg_lover = owner.current
		if(borg_lover.connected_ai)
			borg_lover.set_connected_ai(null)
			borg_lover.lawupdate = FALSE
			borg_lover.laws.set_zeroth_law("Protect your date, [date]. All other laws still apply in situations not relating to your date.")
			borg_lover.laws.show_laws()

	return ..()

/datum/antagonist/valentine/apply_innate_effects(mob/living/mob_override)
	var/mob/living/lover = mob_override || owner.current
	lover.apply_status_effect(/datum/status_effect/in_love, date.current)

/datum/antagonist/valentine/remove_innate_effects(mob/living/mob_override)
	var/mob/living/lover = mob_override || owner.current
	lover.remove_status_effect(/datum/status_effect/in_love)

/datum/antagonist/valentine/greet()
	to_chat(owner, span_boldwarning("You're on a date with [date.name]! Protect [date.p_them()] at all costs. \
		This takes priority over all other loyalties."))

//Squashed up a bit
/datum/antagonist/valentine/roundend_report()
	var/datum/antagonist/valentine/dates_valentine = date?.has_antag_datum(type)
	if(isnull(dates_valentine))
		return span_redtext("[owner.name] had no date!")

	dates_valentine.show_in_roundend = FALSE // We show up for them instead
	var/datum/objective/protect/valentine/our_objective = locate() in objectives
	var/datum/objective/protect/valentine/dates_objective = locate() in dates_valentine.objectives
	var/we_survived = dates_objective?.check_completion()
	var/dates_survived = our_objective?.check_completion()

	if(we_survived && dates_survived)
		return span_greentext("[owner.name] and [date.name] had a successful date!")
	else if(we_survived)
		return span_redtext("[owner.name] failed to protect [date.name], [owner.p_their()] date!")
	else if(dates_survived)
		return span_redtext("[date.name] failed to protect [owner.name], [date.p_their()] date!")
	return span_redtext("[owner.name] and [date.name] both failed to protect each other on their date!")

/datum/antagonist/valentine/third_wheel
	name = "\improper Third Wheel"
	roundend_category = "valentines"
	show_in_antagpanel = FALSE

/datum/antagonist/valentine/third_wheel/roundend_report()
	var/datum/objective/protect/valentine/our_objective = locate() in objectives
	if(our_objective?.check_completion())
		return span_greentext("[owner.name] was a third wheel, but protected [date.name]!")

	return span_redtext("[owner.name] was a third wheel, but failed to protect [date.name]!")

/datum/objective/protect/valentine
	admin_grantable = FALSE
	human_check = FALSE

/datum/objective/protect/valentine/update_explanation_text()
	explanation_text = "Protect [target.name], your date."
