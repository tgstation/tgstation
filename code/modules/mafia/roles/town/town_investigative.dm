/datum/mafia_role/detective
	name = "Detective"
	desc = "You can investigate a single person each night to learn their team."
	revealed_outfit = /datum/outfit/mafia/detective
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/detective

	hud_icon = SECHUD_DETECTIVE
	revealed_icon = "detective"

	role_unique_actions = list(/datum/mafia_ability/investigate)

/datum/mafia_role/psychologist
	name = "Psychologist"
	desc = "You can visit someone ONCE PER GAME to reveal their true role in the morning!"
	revealed_outfit = /datum/outfit/mafia/psychologist
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/psychologist

	hud_icon = SECHUD_PSYCHOLOGIST
	revealed_icon = "psychologist"

	role_unique_actions = list(/datum/mafia_ability/reveal_role)

/datum/mafia_role/coroner
	name = "Coroner"
	desc = "You can perform autopsies on the dead each night to discover their role."
	revealed_outfit = /datum/outfit/mafia/coroner
	role_type = TOWN_INVEST
	hud_icon = SECHUD_CORONER
	revealed_icon = "coroner"
	winner_award = /datum/award/achievement/mafia/coroner

	role_unique_actions = list(/datum/mafia_ability/autopsy)
