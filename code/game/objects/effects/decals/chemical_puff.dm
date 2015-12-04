/obj/effect/decal/chemical_puff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE|PASSGRILLE|PASSMACHINE
	var/turf/initial_turf = null

/obj/effect/decal/chemical_puff/New(var/pos, var/color = null, var/reagent_amt = 5)
	..(pos)
	create_reagents(reagent_amt)
	initial_turf = get_turf(pos)

	if (color != null)
		icon += color

/obj/effect/decal/chemical_puff/Destroy()
	qdel(reagents)
	reagents = null
	..()

// Reacts with the current turf and its contents
/obj/effect/decal/chemical_puff/proc/react(var/iteration_delay = 2)
	var/turf/cur_turf = get_turf(src)
	reagents.reaction(cur_turf)

	for (var/atom/A in cur_turf)
		reagents.reaction(A)

		// When spraying against a wall, react with it but not its contents
		if (get_dist(src, initial_turf) <= 1 && initial_turf.density)
			reagents.reaction(initial_turf)

		if (iteration_delay > 0)
			sleep(iteration_delay) // Oldcode remains, probably unneeded anymore unless it's intended on spray bottles
