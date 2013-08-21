/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use.

	Note that at present cyborg restrained() returns 0 in all cases
*/



/mob/living/silicon/robot/ClickOn(var/atom/A, var/doubleclick, var/params)
	if(!A)
		return

	if(stat || lockcharge || weakened || stunned || paralysis)
		return

	if(next_move >= world.time)
		return

	face_atom(A) // change direction to face what you clicked on

	if(restrained())
		A.hand_r(src)
		return

	var/obj/item/W = get_active_hand()

	// Cyborgs have no range-checking unless there is item use
	if(!W)
		A.attack_robot(src)
		return

	// buckled cannot prevent machine interlinking but stops arm movement
	if( buckled )
		return

	if(W == A)
		next_move = world.time + 10
		if(W.flags&USEDELAY)
			next_move += 5

		W.attack_self(src)
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
	if(A == loc || (A in loc) || (A in contents))
		// No adjacency checks
		next_move = world.time + 10
		if(W.flags&USEDELAY)
			next_move += 5

		var/resolved = A.attackby(W,src)
		if(!resolved && A && W)
			W.afterattack(A,src,1,params)
		return

	if(!isturf(loc))
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc && isturf(A.loc.loc))
	if(isturf(A) || isturf(A.loc))
		if(A.Adjacent(src)) // see adjacent.dm
			next_move = world.time + 10
			if(W.flags&USEDELAY)
				next_move += 5

			var/resolved = A.attackby(W, src)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, params)
			return
		else
			next_move = world.time + 10
			W.afterattack(A, src, 0, params)
			return
	return

/atom/proc/attack_robot(mob/user as mob)
	attack_ai(user)
	return

/atom/proc/hand_r(mob/user as mob)			//Cyborg (robot) - restrained
	src.hand_a(user)
	return