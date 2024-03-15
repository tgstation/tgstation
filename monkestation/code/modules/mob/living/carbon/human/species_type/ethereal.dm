/datum/species/ethereal/get_laugh_sound(mob/living/carbon/human/ethereal)
	return 'monkestation/sound/voice/laugh/ethereal/ethereal_laugh_1.ogg'

/datum/species/ethereal
	payday_modifier = 1
	sexes = TRUE
	species_traits = list(
		DYNCOLORS,
		NO_UNDERWEAR,
		HAIR,
		FACEHAIR,
	)

/datum/species/ethereal/on_species_gain(mob/living/carbon/new_ethereal, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(new_ethereal, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(on_after_attackedby))

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/former_ethereal, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(former_ethereal, COMSIG_ATOM_AFTER_ATTACKEDBY)

/datum/species/ethereal/proc/on_after_attackedby(mob/living/lightbulb, obj/item/item, mob/living/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	var/obj/item/clothing/mask/cigarette/cig = item
	if(!proximity_flag || !istype(cig) || !istype(user) || cig.lit)
		return
	cig.light()
	user.visible_message(span_notice("[user] quickly strikes [item] across [lightbulb]'s skin, [lightbulb.p_their()] warmth lighting it!"))
	return COMPONENT_NO_AFTERATTACK
