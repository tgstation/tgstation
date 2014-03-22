/obj/effect/proc_holder/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, genetic disabilities, and removing toxins and radiation."
	helptext = "Can be used while unconscious."
	chemical_cost = 25
	dna_cost = 1
	req_stat = UNCONSCIOUS

//Heals the things that the other regenerative abilities don't.
/obj/effect/proc_holder/changeling/panacea/sting_action(var/mob/user)

	user << "<span class='notice'>We cleanse impurities from our form.</span>"
	user.reagents.add_reagent("ryetalyn", 10)
	user.reagents.add_reagent("hyronalin", 10)
	user.reagents.add_reagent("anti_toxin", 20)

	for(var/datum/disease/D in user.viruses)
		D.cure()

	feedback_add_details("changeling_powers","AP")
	return 1