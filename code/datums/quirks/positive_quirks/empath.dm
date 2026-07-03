/datum/quirk/empath
	name = "Empath"
	desc = "Будь то шестое чувство или тщательное изучение языка тела, вам достаточно одного взгляда на человека, чтобы понять, что он чувствует."
	icon = FA_ICON_SMILE_BEAM
	value = 8
	gain_text = span_notice("Вы чувствуете единение с окружающими вас людьми.")
	lose_text = span_danger("Вы чувствуете себя отстраненным от окружающих вас людей.")
	medical_record_text = "Пациент очень восприимчив и чувствителен к социальным сигналам, возможно, у него есть экстрасенсорные способности. Необходимо дальнейшее тестирование."
	mail_goodies = list(/obj/item/toy/foamfinger)

/datum/quirk/empath/add(client/client_source)
	quirk_holder.AddComponentFrom(REF(src), /datum/component/empathy)

/datum/quirk/empath/remove(client/client_source)
	quirk_holder.RemoveComponentSource(REF(src), /datum/component/empathy)
