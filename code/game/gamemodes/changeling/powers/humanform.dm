/obj/effect/proc_holder/changeling/humanform
	name = "Human form"
	desc = "We change into a human."
	chemical_cost = 5
	genetic_damage = 3
	req_dna = 1
	max_genetic_damage = 3

//Transform into a human.
/obj/effect/proc_holder/changeling/humanform/sting_action(var/mob/living/carbon/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/chosen_name = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!chosen_name)
		return

	var/datum/dna/chosen_dna = changeling.get_dna(chosen_name)
	if(!chosen_dna)
		return

	user << "<span class='notice'>We transform our appearance.</span>"
	user.dna = chosen_dna

	user.humanize((TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPSRC),chosen_dna.real_name)

	changeling.purchasedpowers -= src
	feedback_add_details("changeling_powers","LFT")
	qdel(user)
	return 1

