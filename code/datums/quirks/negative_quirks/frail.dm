/datum/quirk/frail
	name = "Frail"
	desc = "У вас кожа из бумаги и кости из стекла! Вы получаете раны гораздо легче, чем остальные."
	icon = FA_ICON_SKULL
	value = -6
	mob_trait = TRAIT_EASILY_WOUNDED
	gain_text = span_danger("Вы чувствуете себя хрупким.")
	lose_text = span_notice("Вы снова чувствуете себя крепким.")
	medical_record_text = "Пациент абсурдно легко получает раны. Пожалуйста, примите все меры, чтобы избежать возможных исков о халатности."
	hardcore_value = 4
	mail_goodies = list(/obj/effect/spawner/random/medical/minor_healing)
