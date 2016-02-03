/obj/effect/proc_holder/changeling/synaptic_enhancement //Synaptic Enhancement; allows changelings to attack faster
	name = "Synaptic Enhancement"
	desc = "We redirect mental pathways to devote more energy to muscle movement."
	helptext = "The delay between attacks and actions will be halved."
	dna_cost = 5
	chemical_cost = 25
	var/active = FALSE

/obj/effect/proc_holder/changeling/synaptic_enhancement/sting_action(mob/user)
	active = !active
	user << "<span class='notice'>We [active ? "quicken our mind" : "return to normal"].</span>"
	if(active)
		user.next_move_modifier = 0.5
	else
		user.next_move_modifier = initial(user.next_move_modifier)
	feedback_add_details("changeling_powers","SE")
	return 1

/obj/effect/proc_holder/changeling/synaptic_enhancement/on_refund(mob/user)
	user.next_move_modifier = initial(user.next_move_modifier)
