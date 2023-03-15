/datum/plant_gene/trait/noreact
	// Makes plant reagents not react until squashed.
	name = "Separated Chemicals"

/datum/plant_gene/trait/noreact/on_new_late(obj/item/food/grown/G, newloc)
	..()
	ENABLE_BITFIELD(G.reagents.flags, NO_REACT)

/datum/plant_gene/trait/noreact/on_squashreact(obj/item/food/grown/G, atom/target)
	DISABLE_BITFIELD(G.reagents.flags, NO_REACT)
	G.reagents.handle_reactions()
