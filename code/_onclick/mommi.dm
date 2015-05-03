/mob/living/silicon/robot/mommi/ClickOn(var/atom/A, var/params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	if(stat || lockcharge || weakened || stunned || paralysis)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(next_move >= world.time)
		return

	face_atom(A) // change direction to face what you clicked on

	/*
	cyborg restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
		return
	*/

	var/obj/item/W = get_active_hand()

	if(!W)
		A.attack_mommi(src)
		return

	// buckled cannot prevent machine interlinking but stops arm movement
	if( buckled )
		return

	if(W == A)
		W.attack_self(src)
		return

	if(A == loc || (A in loc) || (A in contents) || (A.loc in contents))
		// No adjacency checks
		var/resolved = A.attackby(W,src, params)
		if(!resolved && A && W)
			W.afterattack(A,src,1,params)
		return

	if(!isturf(loc))
		return

	if(isturf(A) || isturf(A.loc) || (A.loc && isturf(A.loc.loc)))
		if(A.Adjacent(src)) // see adjacent.dm
			var/resolved = A.attackby(W, src, params)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, params)
			return
		else
			W.afterattack(A, src, 0, params)
			return
	return

//Middle click toggles their module
/mob/living/silicon/robot/MiddleClickOn(var/atom/A)
	src.toggle_module(1)
	return


/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	A.attack_mommi(src)
/mob/living/silicon/robot/RangedAttack(atom/A)
	A.attack_mommi(src)

/atom/proc/attack_mommi(mob/user as mob)
	src.attack_robot(user)
	return

/obj/item/attack_mommi(mob/user as mob)
	if (src.Adjacent(user))
		user.put_in_hands(src)
	else
		src.attack_robot(user)
	return
