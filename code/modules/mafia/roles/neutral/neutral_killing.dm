/datum/mafia_role/traitor
	name = "Предатель"
	desc = "Вы - одинокий предатель. У вас есть иммунитет к ночным убийствам, вы можете убивать каждую ночь и побеждаете за счет перевеса над всеми остальными."
	win_condition = "убьет всех."
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
		to_chat(body,span_userdanger("На вас напали, но им придется постараться, чтобы завалить вас.."))
		return MAFIA_PREVENT_KILL

/datum/mafia_role/nightmare
	name = "Кошмар"
	desc = "Вы - одинокий монстр, которого не могут обнаружить детективные роли. Каждую ночь вы можете мерцать светом в другой комнате, становясь неуязвимым для атак этих ролей. Вместо этого вы можете устроить охоту, убив всех в мерцающей комнате. Убейте всех, чтобы победить."
	win_condition = "убьет всех."
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
