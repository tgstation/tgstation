/obj/effect/proc_holder/spell/targeted/genetic
	name = "Genetic"
	desc = "This spell inflicts a set of mutations and disabilities upon the target."

	var/list/mutations = list() //mutation strings
	var/list/disabilities = list()
	var/list/conditions = list()
	var/duration = 100 //deciseconds

/obj/effect/proc_holder/spell/targeted/genetic/cast(list/targets)

	for(var/mob/living/target in targets)
		for (var/i in mutations)
			target.mutations.add_mutation(i)
		for (var/i in disabilities)
			target.mutations.add_disability(i)
		for (var/i in conditions)
			target.mutations.add_condition(i)
		spawn(duration)
			for (var/i in mutations)
				target.mutations.remove_mutation(i)
			for (var/i in disabilities)
				target.mutations.remove_disability(i)
			for (var/i in conditions)
				target.mutations.remove_condition(i)

	return