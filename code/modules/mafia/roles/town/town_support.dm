/datum/mafia_role/lawyer
	name = "Адвокат"
	desc = "Вы можете выбрать человека, которому будете предоставлять обширные юридические консультации, предотвращая ночные действия."
	revealed_outfit = /datum/outfit/mafia/lawyer
	role_type = TOWN_SUPPORT
	hud_icon = SECHUD_LAWYER
	revealed_icon = "lawyer"
	winner_award = /datum/award/achievement/mafia/lawyer

	role_unique_actions = list(/datum/mafia_ability/roleblock)

/datum/mafia_role/hop
	name = "Глава персонала"
	desc = "Вы можете раскрыть себя один раз за игру, утроив силу голоса, но лишившись возможности быть защищенным!"
	role_type = TOWN_SUPPORT
	role_flags = ROLE_UNIQUE
	role_flags = ROLE_CAN_KILL
	hud_icon = SECHUD_HEAD_OF_PERSONNEL
	revealed_icon = "headofpersonnel"
	revealed_outfit = /datum/outfit/mafia/hop
	winner_award = /datum/award/achievement/mafia/hop

	role_unique_actions = list(/datum/mafia_ability/self_reveal)

/datum/mafia_role/chaplain
	name = "Chaplain"
	desc = "You can communicate with spirits of the dead each night to discover dead crewmember roles."
	role_type = TOWN_INVEST
	team = MAFIA_TEAM_TOWN | MAFIA_TEAM_DEAD
	hud_icon = SECHUD_CHAPLAIN
	revealed_icon = "chaplain"
	revealed_outfit = /datum/outfit/mafia/chaplain
	winner_award = /datum/award/achievement/mafia/chaplain

	role_unique_actions = list(/datum/mafia_ability/seance)
