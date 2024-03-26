/datum/quirk/hypersensitive
	name = "Hypersensitive"
	desc = "When things are bad, they're BAD."
	icon = FA_ICON_FLUSHED
	value = -4
	mob_trait = TRAIT_HYPERSENSITIVE
	gain_text = span_danger("You seem to make a big deal out of all the awful, no-good, terrible things that happen to you and you alone.")
	lose_text = span_notice("You don't seem to make a big deal out of everything anymore.")
	medical_record_text = "Patient demonstrates a high level of emotional volatility."
	hardcore_value = 3
	mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie_delux)

/datum/quirk/hypersensitive/add(client/client_source)
	if (quirk_holder.mob_mood)
		quirk_holder.mob_mood.mood_modifier[MOOD_MODIFIER_BAD] += 1

/datum/quirk/hypersensitive/remove()
	if (quirk_holder.mob_mood)
		quirk_holder.mob_mood.mood_modifier[MOOD_MODIFIER_BAD] -= 1
