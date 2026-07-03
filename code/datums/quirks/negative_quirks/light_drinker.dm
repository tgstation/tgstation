/datum/quirk/light_drinker
	name = "Light Drinker"
	desc = "Вы просто не умеете обращаться с напитками и очень быстро пьянеете."
	icon = FA_ICON_COCKTAIL
	value = -2
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = span_notice("От одной мысли об употреблении алкоголя голова идет кругом.")
	lose_text = span_danger("Вы больше не подвержены сильному влиянию алкоголя.")
	medical_record_text = "Пациент демонстрирует низкую толерантность к алкоголю. (Слабак)"
	hardcore_value = 3
	mail_goodies = list(/obj/item/reagent_containers/cup/glass/waterbottle)
