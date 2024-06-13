/datum/interaction_mode/intents3
	shift_to_open_context_menu = TRUE
	var/intent = INTENT_HELP

/datum/interaction_mode/intents3/update_istate(mob/M, modifiers)
	M.istate = NONE

	// Makes player face mouse on harm intent
	M.face_mouse = M?.client.prefs?.read_preference(/datum/preference/toggle/face_cursor_combat_mode) && intent == INTENT_HARM

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		M.istate = ISTATE_SECONDARY
		return

	switch (intent)
		if (INTENT_DISARM)
			M.istate |= ISTATE_SECONDARY
		if (INTENT_GRAB)
			M.istate |= ISTATE_CONTROL
			M.istate |= ISTATE_BLOCKING
		if (INTENT_HARM)
			M.istate |= ISTATE_HARM
			M.istate |= ISTATE_BLOCKING

	if(!UI)
		return

	UI.icon_state = "[intent]"

/datum/interaction_mode/intents3/procure_hud(mob/M, datum/hud/H)
	if (!M.hud_used?.has_interaction_ui)
		return
	var/atom/movable/screen/act_intent3/AI = new
	AI.hud = H
	AI.intents = src
	UI = AI
	return AI

/datum/interaction_mode/intents3/keybind_act(type)
	var/static/next_intent = list(
		INTENT_HELP = INTENT_DISARM,
		INTENT_DISARM = INTENT_GRAB,
		INTENT_GRAB = INTENT_HARM,
		INTENT_HARM = INTENT_HELP)
	switch (type)
		if (1)
			intent = INTENT_HELP
		if (2)
			intent = INTENT_DISARM
		if (3)
			intent = INTENT_GRAB
		if (4)
			intent = INTENT_HARM
		if (5)
			intent = next_intent[intent]
	update_istate(owner.mob, null)

/datum/interaction_mode/intents3/set_combat_mode(new_state, silent)
	. = ..()
	if(intent == INTENT_HARM)
		return
	intent = INTENT_HARM
	update_istate(owner.mob)
