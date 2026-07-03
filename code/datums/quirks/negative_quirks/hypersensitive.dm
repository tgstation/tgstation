/datum/quirk/hypersensitive
	name = "Hypersensitive"
	desc = "К сожалению или к счастью, вам кажется, что всё влияет на ваше настроение сильнее обычного."
	icon = FA_ICON_FLUSHED
	value = -2
	gain_text = span_danger("Вы, кажется, делаете из мухи слона где только возможно.")
	lose_text = span_notice("Кажется, вы больше не придаете всему так много значения.")
	medical_record_text = "Пациент демонстрирует высокий уровень эмоциональной неустойчивости."
	medical_symptom_text = "Exhibits heightened emotional responses to stimuli, \
		leading to greatly increased sensitivity and reactivity in social situations."
	hardcore_value = 3
	mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie_delux)
	quirk_flags = QUIRK_TRAUMALIKE

/datum/quirk/hypersensitive/add(client/client_source)
	if (quirk_holder.mob_mood)
		quirk_holder.mob_mood.mood_modifier += 0.5

/datum/quirk/hypersensitive/remove()
	if (quirk_holder.mob_mood)
		quirk_holder.mob_mood.mood_modifier -= 0.5
