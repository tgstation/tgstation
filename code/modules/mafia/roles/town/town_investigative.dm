/datum/mafia_role/detective
	name = "Detective"
	desc = "You can investigate a single person each night to learn their team."
	revealed_outfit = /datum/outfit/mafia/detective
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/detective

	hud_icon = "huddetective"
	revealed_icon = "detective"

	role_unique_actions = list(/datum/mafia_ability/investigate)

/datum/mafia_role/psychologist
	name = "Psychologist"
	desc = "You can visit someone ONCE PER GAME to reveal their true role in the morning!"
	revealed_outfit = /datum/outfit/mafia/psychologist
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/psychologist

	hud_icon = "hudpsychologist"
	revealed_icon = "psychologist"

	role_unique_actions = list(/datum/mafia_ability/reveal_role)

/datum/mafia_role/chaplain
	name = "Chaplain"
	desc = "You can communicate with spirits of the dead each night to discover dead crewmember roles."
	revealed_outfit = /datum/outfit/mafia/chaplain
	role_type = TOWN_INVEST
	hud_icon = "hudchaplain"
	revealed_icon = "chaplain"
	winner_award = /datum/award/achievement/mafia/chaplain

	role_unique_actions = list(/datum/mafia_ability/seance)
