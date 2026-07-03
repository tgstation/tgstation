/datum/mafia_role/detective
	name = "Детектив"
	desc = "Вы можете исследовать одного человека в каждую ночь, чтобы узнать его команду.."
	revealed_outfit = /datum/outfit/mafia/detective
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/detective

	hud_icon = SECHUD_DETECTIVE
	revealed_icon = "detective"

	role_unique_actions = list(/datum/mafia_ability/investigate)

/datum/mafia_role/psychologist
	name = "Психолог"
	desc = "Вы можете посетить кого-то ОДИН раз за игру, чтобы раскрыть его истинную роль утром!"
	revealed_outfit = /datum/outfit/mafia/psychologist
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/psychologist

	hud_icon = SECHUD_PSYCHOLOGIST
	revealed_icon = "psychologist"

	role_unique_actions = list(/datum/mafia_ability/reveal_role)

/datum/mafia_role/coroner
	name = "Коронер"
	desc = "Вы можете проводить вскрытия тел умерших каждую ночь, чтобы выяснить их роль."
	revealed_outfit = /datum/outfit/mafia/coroner
	role_type = TOWN_INVEST
	hud_icon = SECHUD_CORONER
	revealed_icon = "coroner"
	winner_award = /datum/award/achievement/mafia/coroner

	role_unique_actions = list(/datum/mafia_ability/autopsy)
