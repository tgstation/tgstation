/datum/mafia_role/mafia
	name = "Changeling"
	desc = "You're a member of the changeling hive. You may speak with your fellow Changelings at night."
	team = MAFIA_TEAM_MAFIA
	role_type = MAFIA_REGULAR
	role_flags = ROLE_CAN_KILL
	hud_icon = "hudchangeling"
	revealed_icon = "changeling"
	winner_award = /datum/award/achievement/mafia/changeling

	revealed_outfit = /datum/outfit/mafia/changeling
	special_ui_theme = "syndicate"
	win_condition = "become majority over the town and no solo killing role can stop them."

	role_unique_actions = list(/datum/mafia_ability/changeling_kill)

/datum/mafia_role/mafia/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game, COMSIG_MAFIA_SUNDOWN, PROC_REF(mafia_text))

/datum/mafia_role/mafia/proc/mafia_text(datum/mafia_controller/source)
	SIGNAL_HANDLER

	to_chat(body, "<b>Vote for who to kill tonight. The killer will be chosen randomly from voters.</b>")

/datum/mafia_role/mafia/thoughtfeeder
	name = "Thoughtfeeder"
	desc = "You're a changeling variant that feeds on the memories of others. Use ':j' talk prefix to talk to your fellow lings, and visit people at night to learn their role."
	role_type = MAFIA_SPECIAL
	hud_icon = "hudthoughtfeeder"
	revealed_icon = "thoughtfeeder"
	winner_award = /datum/award/achievement/mafia/thoughtfeeder

	role_unique_actions = list(/datum/mafia_ability/changeling_kill, /datum/mafia_ability/thoughtfeeder)
