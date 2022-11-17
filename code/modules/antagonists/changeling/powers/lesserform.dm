/datum/action/changeling/lesserform
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 5 chemicals."
	helptext = "The transformation greatly reduces our size, allowing us to slip out of cuffs and climb through vents."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	dna_cost = 1
	req_human = TRUE

/datum/action/changeling/lesserform/Grant(mob/granted_to)
	. = ..()
	RegisterSignal(granted_to, COMSIG_HUMAN_MONKEYIZE, PROC_REF(swap_powers))

/datum/action/changeling/lesserform/Remove(mob/remove_from)
	UnregisterSignal(remove_from, COMSIG_HUMAN_MONKEYIZE)
	return ..()

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return FALSE
	..()
	to_chat(user, span_warning("Our genes cry out!"))
	user.monkeyize()
	return TRUE

/**
 * Called on COMSIG_HUMAN_MONKEYIZE
 * Handles giving the new human force ability and removing ourselves
 *
 * Args:
 * source - Human user who is now turning into a monkey
 */
/datum/action/changeling/lesserform/proc/swap_powers(mob/living/carbon/source)
	SIGNAL_HANDLER

	var/datum/antagonist/changeling/changeling = source.mind.has_antag_datum(/datum/antagonist/changeling)
	// Drops all flesh disguise items after monkeyizing, because they don't drop automatically like real clothing.
	for(var/slot in changeling.slot2type)
		if(istype(source.vars[slot], changeling.slot2type[slot]))
			qdel(source.vars[slot])
	for(var/datum/scar/iter_scar as anything in source.all_scars)
		if(iter_scar.fake)
			qdel(iter_scar)
	source.regenerate_icons()

	var/datum/action/changeling/humanform/from_monkey/human_form_ability = new()
	changeling.purchased_powers += human_form_ability
	changeling.purchased_powers -= src

	human_form_ability.Grant(source)
	Remove(source)
	qdel(src)
