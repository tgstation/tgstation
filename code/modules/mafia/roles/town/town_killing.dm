/datum/mafia_role/hos
	name = "Глава службы безопасности"
	desc = "Вы можете принять решение о казни ночью, убив и раскрыв их роль. Если они невиновны, вы умрете в начале следующей ночи.."
	role_type = TOWN_KILLING
	role_flags = ROLE_CAN_KILL | ROLE_UNIQUE
	revealed_outfit = /datum/outfit/mafia/hos
	revealed_icon = "headofsecurity"
	hud_icon = SECHUD_HEAD_OF_SECURITY
	winner_award = /datum/award/achievement/mafia/hos

	role_unique_actions = list(/datum/mafia_ability/attack_player/execution)

/datum/mafia_role/warden
	name = "Смотритель"
	desc = "Вы можете запереться на ночь один раз, убивая всех посетителей, включая членов города."

	role_type = TOWN_KILLING
	role_flags = ROLE_CAN_KILL
	revealed_outfit = /datum/outfit/mafia/warden
	revealed_icon = "warden"
	hud_icon = SECHUD_WARDEN
	winner_award = /datum/award/achievement/mafia/warden

	role_unique_actions = list(/datum/mafia_ability/attack_visitors)
