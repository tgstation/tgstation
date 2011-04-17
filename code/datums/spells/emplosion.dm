/obj/spell/targeted/emplosion
	name = "Emplosion"
	desc = "This spell emplodes an area."

	var/emp_heavy = 2
	var/emp_light = 3

/obj/spell/targeted/emplosion/cast(list/targets)

	for(var/mob/target in targets)
		empulse(target.loc, emp_heavy, emp_light)

	return