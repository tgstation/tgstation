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
	changeling.purchasedpowers += human_form_ability
	changeling.purchasedpowers -= src

	Remove(user)
	human_form_ability.Grant(user)

	qdel(src)
	return TRUE
