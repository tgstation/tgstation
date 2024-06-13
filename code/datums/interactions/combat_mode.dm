/datum/interaction_mode/combat_mode
	shift_to_open_context_menu = TRUE
	var/combat_mode = FALSE

/datum/interaction_mode/combat_mode/update_istate(mob/M, modifiers)
	M.istate = NONE

	// Makes player face mouse on combat mode
	M.face_mouse = (M?.client.prefs?.read_preference(/datum/preference/toggle/face_cursor_combat_mode) && combat_mode) ? TRUE : FALSE

	if(combat_mode)
		M.istate |= ISTATE_HARM|ISTATE_BLOCKING
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		M.istate |= ISTATE_SECONDARY
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		M.istate |= ISTATE_CONTROL

/datum/interaction_mode/combat_mode/procure_hud(mob/M, datum/hud/H)
	if (!M.hud_used?.has_interaction_ui)
		return
	var/atom/movable/screen/combattoggle/flashy/CT = new
	CT.hud = H
	CT.icon = H.ui_style
	CT.combat_mode = src
	UI = CT
	return CT

/datum/interaction_mode/combat_mode/keybind_act(type)
	var/old_state = combat_mode
	switch (type)
		if (1)
			combat_mode = FALSE
		if (3)
			combat_mode = TRUE
		if (4)
			combat_mode = !combat_mode

	if(old_state != combat_mode && (owner.prefs.read_preference(/datum/preference/toggle/sound_combatmode)))
		if(combat_mode)
			SEND_SOUND(owner, sound('sound/misc/ui_togglecombat.ogg', volume = 25))
		else
			SEND_SOUND(owner, sound('sound/misc/ui_toggleoffcombat.ogg', volume = 25))

	update_istate(owner.mob, null)
	UI?.update_icon_state()

/datum/interaction_mode/combat_mode/set_combat_mode(new_state, silent)
	. = ..()
	if(combat_mode == new_state)
		return

	keybind_act(3)
	if(silent || !(owner.prefs.read_preference(/datum/preference/toggle/sound_combatmode)))
		return

	if(combat_mode)
		SEND_SOUND(src, sound('sound/misc/ui_togglecombat.ogg', volume = 25)) //Sound from interbay!
	else
		SEND_SOUND(src, sound('sound/misc/ui_toggleoffcombat.ogg', volume = 25)) //Slightly modified version of the above
