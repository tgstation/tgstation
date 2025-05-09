/datum/quirk/floating_items
	name = "Psionic Holding"
	desc = "You find holding items with your hands so inconvenient, and use your mind powers to do so instead."
	value = 0
	icon = FA_ICON_METEOR
	medical_record_text = "Subject's mind is capable of extremely limited telekinesis."
	gain_text = "Your mind feels like it can lift weights!"
	lose_text = "Your mind feels like it took a cheat day."
	mob_trait = TRAIT_FLOATING_HELD

/datum/quirk_constant_data/floating_items
	associated_typepath = /datum/quirk/floating_items
	customization_options = list(/datum/preference/color/floating_items)

/datum/preference/color/floating_items
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "floating_items"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/color/floating_items/apply_to_human(mob/living/carbon/human/target, value)
	target.held_hover_color = value

/datum/quirk/floating_items/add(client/client_source)
	. = ..()
	var/datum/action/innate/toggle_floating_items/toggle = new
	toggle.Grant(quirk_holder)

/datum/preference/color/floating_items/create_default_value()
	return "#FF99FF"

/datum/action/innate/toggle_floating_items
	name = "Toggle Psionic Holding"
	button_icon = 'modular_doppler/psychicshit/icons/effects/tele_effects.dmi'
	button_icon_state = "telekinesishead"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS

/datum/action/innate/toggle_floating_items/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_FLOATING_HELD))
			REMOVE_TRAIT(owner, TRAIT_FLOATING_HELD, QUIRK_TRAIT)
			if(ishuman(owner))
				var/mob/living/carbon/human/owner_human = owner
				owner_human.update_held_items()
		else
			ADD_TRAIT(owner, TRAIT_FLOATING_HELD, QUIRK_TRAIT)
			if(ishuman(owner))
				var/mob/living/carbon/human/owner_human = owner
				owner_human.update_held_items()
	return TRUE
