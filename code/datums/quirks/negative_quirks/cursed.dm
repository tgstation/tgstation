/datum/quirk/cursed
	name = "Cursed"
	desc = "Вы прокляты невезением. Вы гораздо чаще попадаете в аварии и казусы. Беда не приходит одна."
	icon = FA_ICON_CLOUD_SHOWERS_HEAVY
	value = -8
	mob_trait = TRAIT_CURSED
	gain_text = span_danger("Вы чувствуете, что у вас сегодня будет неудачный день.")
	lose_text = span_notice("Вы чувствуете, что у вас сегодня день пойдет по плану.")
	medical_record_text = "Пациент проклят невезением."
	hardcore_value = 8

/datum/quirk/cursed/add(client/client_source)
	quirk_holder.AddComponent(/datum/component/omen/quirk)
