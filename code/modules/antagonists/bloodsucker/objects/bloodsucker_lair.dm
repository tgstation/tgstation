

// Created by claiming a Coffin.



// 		THINGS TO SPAWN:
//
//	/obj/effect/decal/cleanable/cobweb && /obj/effect/decal/cleanable/cobweb/cobweb2
//	/obj/effect/decal/cleanable/generic
//	/obj/effect/decal/cleanable/dirt/dust <-- Pretty cool, just stains the tile itself.
//	/obj/effect/decal/cleanable/blood/old

/*
/area/
	// All coffins assigned to this area
	var/list/obj/structure/closet/crate/laircoffins = new list()

// Called by Coffin when an area is claimed as a vamp's lair
/area/proc/ClaimAsLair(/obj/structure/closet/crate/inClaimant)
	set waitfor = FALSE // Don't make on_gain() wait for this function to finish. This lets this code run on the side.

	laircoffins += laircoffins
	sleep()

	// Cancel!
	if (laircoffins.len == 0)
		return
		*/