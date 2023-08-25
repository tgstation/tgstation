/datum/mafia_role/traitor
	name = "Traitor"
	desc = "You're a solo traitor. You are immune to night kills, can kill every night and you win by outnumbering everyone else."
	win_condition = "kill everyone."
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_KILL
	role_flags = ROLE_CAN_KILL
	winner_award = /datum/award/achievement/mafia/traitor
	revealed_outfit = /datum/outfit/mafia/traitor
	revealed_icon = "traitor"
	hud_icon = "hudtraitor"
	special_ui_theme = "neutral"

	role_unique_actions = list(/datum/mafia_ability/attack_player)

/datum/mafia_role/traitor/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src, COMSIG_MAFIA_ON_KILL, PROC_REF(nightkill_immunity))

/datum/mafia_role/traitor/proc/nightkill_immunity(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if(game.phase == MAFIA_PHASE_NIGHT && !lynch)
		to_chat(body,span_userdanger("You were attacked, but they'll have to try harder than that to put you down."))
		return MAFIA_PREVENT_KILL

/datum/mafia_role/nightmare
	name = "Nightmare"
	desc = "You're a solo monster that cannot be detected by detective roles. You can flicker lights of another room each night, becoming immune to attacks from those roles. You can instead decide to hunt, killing everyone in a flickering room. Kill everyone to win."
	win_condition = "kill everyone."
	revealed_outfit = /datum/outfit/mafia/nightmare
	role_flags = ROLE_UNDETECTABLE | ROLE_CAN_KILL
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_KILL
	special_ui_theme = "neutral"
	hud_icon = "hudnightmare"
	revealed_icon = "nightmare"
	winner_award = /datum/award/achievement/mafia/nightmare

	role_unique_actions = list(/datum/mafia_ability/flicker_rampage)

/datum/mafia_role/nightmare/special_reveal_equip()
	body.set_species(/datum/species/shadow)
	body.update_body()
