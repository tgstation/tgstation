/obj/effect/proc_holder/spell/targeted/genetic
	name = "Genetic"
	desc = "This spell inflicts a set of mutations and disabilities upon the target."

	var/disabilities = 0 //bits
	var/list/mutations = list() //mutation strings
	var/duration = 100 //deciseconds
	/*
		Disabilities
			1st bit - ?
			2nd bit - ?
			3rd bit - ?
			4th bit - ?
			5th bit - ?
			6th bit - ?
	*/

/obj/effect/proc_holder/spell/targeted/genetic/cast(list/targets)

	for(var/mob/target in targets)
		for(var/x in mutations)
			target.mutations.Add(x)
		var/old_disabilities = target.disabilities
		target.disabilities |= disabilities
		spawn(duration)
			for(var/x in mutations)
				target.mutations.Remove(x)
			target.disabilities = old_disabilities

	return