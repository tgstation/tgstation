/obj/proc_holder/spell/targeted/genetic
	name = "Genetic"
	desc = "This spell inflicts a set of mutations and disabilities upon the target."

	var/disabilities = 0 //bits
	var/mutations = 0 //bits
	var/duration = 100 //deciseconds
	/*
		Disabilities
			1st bit - ?
			2nd bit - ?
			3rd bit - ?
			4th bit - ?
			5th bit - ?
			6th bit - ?
		Mutations
			1st bit - portals
			2nd bit - cold resist
			3rd bit - xray
			4th bit - hulk
			5th bit - clown
			6th bit - fat
	*/

/obj/proc_holder/spell/targeted/genetic/cast(list/targets)

	for(var/mob/target in targets)
		target.mutations |= mutations
		target.disabilities |= disabilities
		spawn(duration)
			target.mutations &= ~mutations
			target.disabilities &= ~disabilities

	return