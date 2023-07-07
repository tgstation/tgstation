/datum/mafia_role/lawyer
	name = "Lawyer"
	desc = "You can choose a person to provide extensive legal advice to, preventing night actions."
	revealed_outfit = /datum/outfit/mafia/lawyer
	role_type = TOWN_SUPPORT
	hud_icon = "hudlawyer"
	revealed_icon = "lawyer"
	winner_award = /datum/award/achievement/mafia/lawyer

	role_unique_actions = list(/datum/mafia_ability/roleblock)

/datum/mafia_role/hop
	name = "Head of Personnel"
	desc = "You can reveal yourself once per game, tripling your vote power but becoming unable to be protected!"
	role_type = TOWN_SUPPORT
	role_flags = ROLE_UNIQUE
	role_flags = ROLE_CAN_KILL
	hud_icon = "hudheadofpersonnel"
	revealed_icon = "headofpersonnel"
	revealed_outfit = /datum/outfit/mafia/hop
	winner_award = /datum/award/achievement/mafia/hop

	role_unique_actions = list(/datum/mafia_ability/self_reveal)
