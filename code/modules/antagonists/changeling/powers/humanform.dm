/datum/action/changeling/humanform
	name = "Human Form"
	desc = "We change into a human. Costs 5 chemicals."
	button_icon_state = "human_form"
	chemical_cost = 5
	req_dna = 1

//Transform into a human.
/datum/action/changeling/humanform/sting_action(mob/living/carbon/user)
	if(user.movement_type & VENTCRAWLING)
		to_chat(user, span_notice("We must exit the pipes before we can transform back!"))
		return FALSE
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/datum/changeling_profile/chosen_prof = changeling.select_dna()
	if(!chosen_prof)
		return
	if(!user || user.notransform)
		return FALSE
	to_chat(user, span_notice("We transform our appearance."))
	..()
	changeling.purchased_powers -= src
	Remove(user)

	var/datum/dna/chosen_dna = chosen_prof.dna
	var/datum/species/chosen_species = chosen_dna.species
	user.humanize(chosen_species)

	changeling.transform(user, chosen_prof)
	user.regenerate_icons()
	// Delete ourselves when we're done.
	qdel(src)
	return TRUE

// Subtype used when a changeling uses lesser form.
/datum/action/changeling/humanform/from_monkey
	desc = "We change back into a human. Costs 5 chemicals."

/datum/action/changeling/humanform/from_monkey/Grant(mob/granted_to)
	. = ..()
	RegisterSignal(granted_to, COMSIG_MONKEY_HUMANIZE, PROC_REF(give_lesserform))

/datum/action/changeling/humanform/from_monkey/Remove(mob/remove_from)
	UnregisterSignal(remove_from, COMSIG_MONKEY_HUMANIZE)
	return ..()

/**
 * Called on COMSIG_MONKEY_HUMANIZE
 * Handles giving the new lesserform ability
 * Removing ourselves is handled by parent already, so it's not needed here like it is on lesserform.
 *
 * Args:
 * source - Monkey user who is now turning into a human
 */
/datum/action/changeling/humanform/from_monkey/proc/give_lesserform(mob/living/carbon/source)
	SIGNAL_HANDLER

	var/datum/antagonist/changeling/changeling = source.mind.has_antag_datum(/datum/antagonist/changeling)
	var/datum/action/changeling/lesserform/monkey_form_ability = new()
	changeling.purchased_powers += monkey_form_ability

	monkey_form_ability.Grant(source)
