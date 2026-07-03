/datum/mafia_role/medical_doctor
	name = "Врач"
	desc = "Каждую ночь вы можете защитить от убийства одного человека. Вы можете исцелить себя один раз."
	revealed_outfit = /datum/outfit/mafia/md
	role_type = TOWN_PROTECT
	hud_icon = SECHUD_MEDICAL_DOCTOR
	revealed_icon = "medicaldoctor"
	winner_award = /datum/award/achievement/mafia/md

	role_unique_actions = list(/datum/mafia_ability/heal)

/datum/mafia_role/security_officer
	name = "Сотрудник службы безопасности"
	desc = "Каждую ночь вы можете защитить одного человека. Если на него нападут, вы ответите, убив себя и нападавшего. Вы можете защитить себя один раз."
	revealed_outfit = /datum/outfit/mafia/security
	revealed_icon = "securityofficer"
	hud_icon = SECHUD_SECURITY_OFFICER
	role_type = TOWN_PROTECT
	role_flags = ROLE_CAN_KILL
	winner_award = /datum/award/achievement/mafia/officer

	role_unique_actions = list(/datum/mafia_ability/heal/defend)
