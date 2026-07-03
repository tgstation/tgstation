/datum/quirk/mute
	name = "Mute"
	desc = "По какой-то причине вы совершенно не можете говорить."
	icon = FA_ICON_VOLUME_XMARK
	value = -4
	mob_trait = TRAIT_MUTE
	gain_text = span_danger("Вы обнаруживаете, что не можете говорить!")
	lose_text = span_notice("Вы чувствуете, как голосовые связки приходят в норму.")
	medical_record_text = "Пациент не может использовать свой голос в каком-либо его проявлении."
	hardcore_value = 4
