/datum/action/changeling/lesserform
	name = "Lesser Form - We debase ourselves and become lesser. We become a monkey."
	stats_id = "Lesser Form"
	helptext = "The transformation greatly reduces our size, allowing us to slip out of cuffs and climb through vents."
	chemical_cost = 5
	dna_cost = 1
	req_human = 1

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return 0
	to_chat(user, "<span class='warning'>Our genes cry out!</span>")

	user.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)
	return TRUE