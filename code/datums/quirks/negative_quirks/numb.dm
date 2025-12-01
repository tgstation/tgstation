/datum/quirk/numb
	name = "Numb"
	desc = "You can't feel pain at all."
	icon = FA_ICON_STAR_OF_LIFE
	value = -4
	gain_text = "You feel your body becoming numb."
	lose_text = "The numbness subsides."
	medical_record_text = "The patient exhibits congenital hypoesthesia, making them insensitive to pain stimuli."
	hardcore_value = 4

/datum/quirk/numb/add(client/client_source)
	quirk_holder.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	quirk_holder.add_traits(list(TRAIT_ANALGESIA, TRAIT_NO_DAMAGE_OVERLAY), QUIRK_TRAIT)

/datum/quirk/numb/remove(client/client_source)
	quirk_holder.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	quirk_holder.remove_traits(list(TRAIT_ANALGESIA, TRAIT_NO_DAMAGE_OVERLAY), QUIRK_TRAIT)
