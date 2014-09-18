
//**************************************************************
//
// Adjacency Checks
// --------------------
// This can be optimized more, at the cost of clarity.
//
//**************************************************************

// Adjacency ///////////////////////////////////////////////////

/atom/proc/Adjacent(atom/A)
	if((!src.loc) || (!A.loc)) return 0 //If we're at null, no good.
	if(get_turf(src) == get_turf(A)) return 1 //If we're on the same tile, it's good.
	if(get_dist(src,A) > 1) return 0 //If we're more than 1 tile apart, not good.
	if(src.x == A.x || src.y == A.y) //If we're orthogonal, it's simple
		if(src.canPassTo(A)) return 1 //If we can reach straight to A, we're good
	else //We're diagonal, so we need to check if we can reach around to it
		. = get_dir(src,A) //Our diagonal direction				//eg south-west
		var/dA = . & (. - 1) //One of our cardinal directions	//eg south
		var/dB = (. - dA) //Our other cardinal direction		//eg west
		if(!src.canPassTo(get_step(src,dA)) && src.canPassTo(get_step(dA,dB)))
			return 1 //If we can use dA then dB, we're good		//eg south then west
		else if(src.canPassTo(get_step(src,dB)) && src.canPassTo(get_step(dB,dA)))
			return 1 //If we can use dB then dA, we're good		//eg west then south
	return

/atom/proc/canPassTo(atom/A)
	for(var/obj/O in get_turf(A)) //We need to check if anything can block us
		if((!O.density) || (O == A) || O.throwpass) continue //These things are fine
		if(O.flags & ON_BORDER) //If it's only on the border, we need to check its dir
			if(O.dir & get_dir(A,src)) return 0 //If it's facing toward us, it blocks us
			if(O.dir & (O.dir-1)) return 0 //If it's a full-tile window, it blocks us
	. = 1 //If nothing went wrong, we're good to go.
	return
