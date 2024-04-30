/datum/borer_focus
	/// Name of the focus
	var/name = ""
	/// Cost of the focus
	var/cost = 5
	/// Traits to add/remove
	var/list/traits = list()
	/// Text that we send to the host when we give them a focus, if set
	var/gain_text = FALSE
	/// Text that we send to the host when the host loses a focus, if set
	var/lose_text = FALSE

/// Effects to take when the focus is added
/datum/borer_focus/proc/on_add(mob/living/carbon/human/host, mob/living/basic/cortical_borer/borer)
	SHOULD_CALL_PARENT(TRUE)
	if(gain_text)
		to_chat(host, span_notice("[gain_text]"))
	for(var/trait in traits)
		ADD_TRAIT(host, trait, REF(borer))

/// Effects to take when the focus is removed
/datum/borer_focus/proc/on_remove(mob/living/carbon/human/host, mob/living/basic/cortical_borer/borer)
	SHOULD_CALL_PARENT(TRUE)
	if(lose_text)
		to_chat(host, span_notice("[lose_text]"))
	REMOVE_TRAITS_IN(host, REF(borer))

/datum/borer_focus/head
	name = "head focus"
	traits = list(TRAIT_NOFLASH, TRAIT_TRUE_NIGHT_VISION, TRAIT_KNOW_ENGI_WIRES)
	gain_text = "Your eyes begin to feel strange..."
	lose_text = "Your eyes begin to return to normal..."

/datum/borer_focus/head/on_add(mob/living/carbon/human/host, mob/living/basic/cortical_borer/borer)
	host.update_sight()
	return ..()

/datum/borer_focus/head/on_remove(mob/living/carbon/human/host, mob/living/basic/cortical_borer/borer)
	host.update_sight()
	return ..()

/datum/borer_focus/chest
	name = "chest focus"
	traits = list(TRAIT_NOBREATH, TRAIT_NOHUNGER, TRAIT_STABLEHEART)
	gain_text = "Your chest begins to slow down..."
	lose_text = "Your chest begins to heave again..."

/datum/borer_focus/chest/on_add(mob/living/carbon/human/host, mob/living/basic/cortical_borer/borer)
	host.set_safe_hunger_level()
	return ..()

/datum/borer_focus/arms
	name = "arm focus"
	traits = list(TRAIT_QUICKER_CARRY, TRAIT_QUICK_BUILD, TRAIT_SHOCKIMMUNE)
	gain_text = "Your arms start to feel funny..."
	lose_text = "Your arms start to feel normal again..."

/datum/borer_focus/arms/on_add(mob/living/carbon/human/host, mob/living/basic/cortical_borer/borer)
	borer.human_host.add_actionspeed_modifier(/datum/actionspeed_modifier/focus_speed)
	return ..()

/datum/borer_focus/arms/on_remove(mob/living/carbon/human/host, mob/living/basic/cortical_borer/borer)
	borer.human_host.remove_actionspeed_modifier(ACTIONSPEED_ID_BORER)
	return ..()

/datum/borer_focus/legs
	name = "leg focus"
	traits = list(TRAIT_LIGHT_STEP, TRAIT_FREERUNNING, TRAIT_SILENT_FOOTSTEPS)
	gain_text = "You feel faster..."
	lose_text = "You feel slower..."

/datum/borer_focus/legs/on_add(mob/living/carbon/human/host, mob/living/basic/cortical_borer/borer)
	host.add_movespeed_modifier(/datum/movespeed_modifier/focus_speed)
	return ..()

/datum/borer_focus/legs/on_remove(mob/living/carbon/human/host, mob/living/basic/cortical_borer/borer)
	host.remove_movespeed_modifier(/datum/movespeed_modifier/focus_speed)
	return ..()
