/datum/mafia_role/mafia
	name = "Changeling"
	desc = "You're a member of the changeling hive. Use ':j' talk prefix to talk to your fellow lings."
	team = MAFIA_TEAM_MAFIA
	role_type = MAFIA_REGULAR
	hud_icon = "hudchangeling"
	revealed_icon = "changeling"
	winner_award = /datum/award/achievement/mafia/changeling

	revealed_outfit = /datum/outfit/mafia/changeling
	special_theme = "syndicate"
	win_condition = "become majority over the town and no solo killing role can stop them."

/datum/mafia_role/mafia/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game, COMSIG_MAFIA_SUNDOWN, PROC_REF(mafia_text))

/datum/mafia_role/mafia/proc/mafia_text(datum/mafia_controller/source)
	SIGNAL_HANDLER

	to_chat(body, "<b>Vote for who to kill tonight. The killer will be chosen randomly from voters.</b>")
