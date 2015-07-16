/obj/effect/proc_holder/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey."
	chemical_cost = 5
	dna_cost = 1
	genetic_damage = 3
	req_human = 1

//Transform into a monkey.
/obj/effect/proc_holder/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return 0
	user << "<span class='warning'>Our genes cry out!</span>"

	user.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPSE | TR_KEEPSRC)

	// Human-form power now handled in monkeyize()
	feedback_add_details("changeling_powers","LF")
	.=1
	qdel(user)
