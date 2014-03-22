/obj/effect/proc_holder/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey."
	chemical_cost = 5
	dna_cost = 1
	genetic_damage = 3
	req_human = 1

//Transform into a monkey.
/obj/effect/proc_holder/changeling/lesserform/sting_action(var/mob/living/carbon/human/user)
	user << "<span class='warning'>Our genes cry out!</span>"

	var/mob/living/carbon/monkey/O = user.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPSE | TR_KEEPSRC)

	O.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
	feedback_add_details("changeling_powers","LF")
	.=1
	qdel(user)
