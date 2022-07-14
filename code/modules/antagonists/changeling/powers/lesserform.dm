/datum/action/changeling/lesserform
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 5 chemicals."
	helptext = "The transformation greatly reduces our size, allowing us to slip out of cuffs and climb through vents."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	dna_cost = 1
	req_human = TRUE

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return FALSE
	to_chat(user, span_warning("Our genes cry out!"))
	..()

	user.monkeyize()

	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/datum/action/changeling/humanform/from_monkey/human_form_ability = new()
	changeling.purchased_powers += human_form_ability
	changeling.purchased_powers -= src
	
	// Drops all flesh disguise items after monkeyizing, because they don't drop automatically like real clothing.
	for(var/slot in changeling.slot2type)
		if(istype(user.vars[slot], changeling.slot2type[slot]))
			qdel(user.vars[slot])
	for(var/datum/scar/iter_scar as anything in user.all_scars)
		if(iter_scar.fake)
			qdel(iter_scar)
	user.regenerate_icons()

	Remove(user)
	human_form_ability.Grant(user)

	qdel(src)
	return TRUE
