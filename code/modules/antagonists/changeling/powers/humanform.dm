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
	var/list/names = list()
	for(var/datum/changeling_profile/prof in changeling.stored_profiles)
		names += "[prof.name]"

	var/chosen_name = tgui_input_list(user, "Target DNA", "Transformation", sort_list(names))
	if(!chosen_name)
		return

	var/datum/changeling_profile/chosen_prof = changeling.get_dna(chosen_name)
	if(!chosen_prof)
		return
	if(!user || user.notransform)
		return FALSE
	to_chat(user, span_notice("We transform our appearance."))
	..()
	changeling.purchased_powers -= src

	var/newmob = user.humanize()

	changeling.transform(newmob, chosen_prof)
	return TRUE
