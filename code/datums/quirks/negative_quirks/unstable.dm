/datum/quirk/unstable
	name = "Unstable"
	desc = "Из-за прошлых неприятностей вы не сможете восстановить рассудок, если потеряете его. Будьте очень осторожны в управлении своим настроением!"
	icon = FA_ICON_ANGRY
	value = -10
	mob_trait = TRAIT_UNSTABLE
	gain_text = span_danger("У вас сейчас довольно много разных мыслей на уме.")
	lose_text = span_notice("Ваш разум наконец-то успокоился.")
	medical_record_text = "Сознание пациента находится в уязвимом состоянии и не может восстановиться после травмирующих событий."
	medical_symptom_text = "Exhibits severe mood instability and an inability to recover from psychological stressors."
	hardcore_value = 9
	mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie)
	quirk_flags = QUIRK_TRAUMALIKE
