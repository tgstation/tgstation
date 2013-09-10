/*
	Click code cleanup
	~Sayu
*/
/mob/var/next_click	= 0 // 1 decisecond click delay (above and beyond mob/next_move)

/*
	Click code:
	Before anything else, defer these calls to a per-mobtype handler.  This allows us to
	remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.

	Alternately, you could hardcode every mob's variation in a flat ClickOn() proc; however,
	that's a lot of code duplication and is hard to maintain.
*/
/atom/Click(location,control,params)
	usr.ClickOn(src, params)
/atom/DblClick(location,control,params)
	usr.DblClickOn(src,params)


/mob/proc/face_atom(var/atom/A)
	if(!canface()) return
	if( !A || !x || !y || !A.x || !A.y ) return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) return

	if(abs(dx) < abs(dy))
		if(dy > 0)	usr.dir = NORTH
		else		usr.dir = SOUTH
	else
		if(dx > 0)	usr.dir = EAST
		else		usr.dir = WEST

/mob/proc/ClickOn( var/atom/A, var/params )
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if("middle" in modifiers)
		MiddleClickOn(A)
		return
	if("shift" in modifiers)
		ShiftClickOn(A)
		return
	if("ctrl" in modifiers)
		CtrlClickOn(A)
		return
	if("alt" in modifiers)
		AltClickOn(A)
		return

	if(stat || paralysis || stunned || weakened)
		return

	face_atom(A) // change direction to face what you clicked on

	if(next_move > world.time) // in the year 2000...
		return

	if(istype(loc,/obj/mecha))
		var/obj/mecha/M = loc
		return M.click_action(A,src)

	if(restrained())
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		throw_item(A)
		return

	var/obj/item/W = get_active_hand()

	if(W == A)
		next_move = world.time + 6
		if(W.flags&USEDELAY)
			next_move += 5
		W.attack_self(src)
		if(hand)
			update_inv_l_hand(0)
		else
			update_inv_r_hand(0)

		return

	// operate two levels deep here (item in backpack in src; NOT item in box in backpack in src)
	if(A == loc || (A in loc) || (A in contents) || (A.loc in contents))

		// faster access to objects already on you
		if(A in contents)
			next_move = world.time + 6 // on your person
		else
			next_move = world.time + 8 // in a box/bag or in your square

		// No adjacency needed
		if(W)
			if(W.flags&USEDELAY)
				next_move += 5

			var/resolved = A.attackby(W,src)
			if(!resolved && A && W)
				W.afterattack(A,src,1,params) // 1 indicates adjacency
		else
			UnarmedAttack(A)
		return

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	if(isturf(A) || isturf(A.loc) || (A.loc && isturf(A.loc.loc)))
		next_move = world.time + 10

		if(A.Adjacent(src)) // see adjacent.dm
			if(W)
				if(W.flags&USEDELAY)
					next_move += 5

				// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
				var/resolved = A.attackby(W,src)
				if(!resolved && A && W)
					W.afterattack(A,src,1,params) // 1: clicking something Adjacent
			else
				UnarmedAttack(A, 1)
			return
		else // non-adjacent click
			if(W)
				W.afterattack(A,src,0,params) // 0: not Adjacent
			else
				RangedAttack(A, params)

	return

// Default behavior ignore
/mob/proc/DblClickOn(var/atom/A, var/params)
	ClickOn(A,params)


// translates into attack_hand, attack_paw, etc.  proximity_flag should NOT be true if you are not adjacent (telekinesis)
/mob/proc/UnarmedAttack(var/atom/A, var/proximity_flag)
	return

// unarmed and at range - laser eyes, telekinesis, and mob special abilities
/mob/proc/RangedAttack(var/atom/A, var/params)
	if(!mutations.len) return
	if((LASER in mutations) && a_intent == "harm")
		LaserEyes(A) // moved into a proc below
	else if(TK in mutations)
		switch(get_dist(src,A))
			if(0)
				;
			if(1 to 5) // not adjacent may mean blocked by window
				next_move += 2
			if(5 to 7)
				next_move += 5
			if(8 to tk_maxrange)
				next_move += 10
			else
				return
		A.attack_tk(src)

// Not currently used by anything but could easily be
/mob/proc/RestrainedClickOn(var/atom/A)
	return

// actually just swaps your hands usually
/mob/proc/MiddleClickOn(var/atom/A)
	return
/mob/living/carbon/MiddleClickOn(var/atom/A)
	swap_hand()


// In case of use break glass
/*
/atom/proc/MiddleClick(var/mob/M as mob)
	return
*/

// Shift click: For most mobs, examine
/mob/proc/ShiftClickOn(var/atom/A)
	A.ShiftClick(src)
	return
/atom/proc/ShiftClick(var/mob/user)
	if(user.client && user.client.eye == user)
		examine()
	return

// Ctrl click: For most objects, pull
/mob/proc/CtrlClickOn(var/atom/A)
	A.CtrlClick(src)
	return
/atom/proc/CtrlClick(var/mob/user)
	return

/atom/movable/CtrlClick(var/mob/user)
	if(Adjacent(user))
		user.start_pulling(src)

// Alt click: Unused except for AI
/mob/proc/AltClickOn(var/atom/A)
	A.AltClick(src)
	return

/atom/proc/AltClick(var/mob/user)
	return

// this was moved mostly in order to avoid use of the : path operator
/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	next_move = world.time + 6
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A)

	var/obj/item/projectile/beam/LE = new /obj/item/projectile/beam( loc )
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, 1)

	LE.firer = src
	LE.def_zone = get_organ_target()
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	spawn( 1 )
		LE.process()

/mob/living/carbon/human/LaserEyes()
	if(nutrition>0)
		..()
		nutrition = max(nutrition - rand(1,5),0)
		handle_regular_hud_updates()
	else
		src << "\red You're out of energy!  You need food!"
