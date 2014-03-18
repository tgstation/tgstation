/obj/effect/proc_holder/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating arachnids which will grow into deadly beasts."
	helptext = "The spiders are thoughtless creatures, and may attack their creators when fully grown. Requires at least 5 DNA absorptions."
	chemical_cost = 50
	dna_cost = 1
	req_dna = 5

//Makes some spiderlings. Good for setting traps and causing general trouble.
/obj/effect/proc_holder/changeling/spiders/sting_action(var/mob/user)
	for(var/i=0, i<2, i++)
		var/obj/effect/spider/spiderling/S = new(user.loc)
		S.grow_as = /mob/living/simple_animal/hostile/giant_spider/hunter

	feedback_add_details("changeling_powers","SI")
	return 1
