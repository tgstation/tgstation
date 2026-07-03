/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "Вы пьянеете медленнее и испытываете меньше проблем от алкоголя."
	icon = FA_ICON_BEER
	value = 4
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = span_notice("Вам кажется, что вы можете выпить целую кегу пива!")
	lose_text = span_danger("Вы больше не испытываете особой стойкости к алкоголю.")
	medical_record_text = "Пациент демонстрирует высокую переносимость алкоголя."
	mail_goodies = list(/obj/item/skillchip/wine_taster)
