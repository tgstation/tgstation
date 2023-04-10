/datum/mafia_role/medical_doctor
	name = "Medical Doctor"
	desc = "You can protect a single person each night from killing. You can heal yourself once."
	revealed_outfit = /datum/outfit/mafia/md
	role_type = TOWN_PROTECT
	hud_icon = "hudmedicaldoctor"
	revealed_icon = "medicaldoctor"
	winner_award = /datum/award/achievement/mafia/md

	role_unique_actions = list(/datum/mafia_ability/heal)

/datum/mafia_role/security_officer
	name = "Security Officer"
	desc = "You can protect a single person each night. If they are attacked, you will retaliate, killing yourself and the attacker. You can protect yourself once."
	revealed_outfit = /datum/outfit/mafia/security
	revealed_icon = "securityofficer"
	hud_icon = "hudsecurityofficer"
	role_type = TOWN_PROTECT
	role_flags = ROLE_CAN_KILL
	winner_award = /datum/award/achievement/mafia/officer

	role_unique_actions = list(/datum/mafia_ability/heal/defend)
