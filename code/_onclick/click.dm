/*
	Click code cleanup
	~Sayu
*/

/*
	Before anything else, defer these calls to a per-mobtype handler.  This allows us to
	remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.

	Alternately, you could hardcode every mob's variation in a flat ClickOn() proc; however,
	that's a lot of code duplication and is hard to maintain.

	Note that this proc can be overridden, and is in the case of screen objects.
*/
/atom/Click(location,control,params)
	usr.ClickOn(src, params)
/atom/DblClick(location,control,params)
	usr.DblClickOn(src,params)

/*
	Standard mob ClickOn()
	Handles exceptions: Buildmode, middle click, modified clicks, mech actions

	After that, mostly just check your state, check whether you're holding an item,
	check whether you're adjacent to the target, then pass off the click to whoever
	is recieving it.
	The most common are:
	* mob/UnarmedAttack(atom,adjacent,params) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
	* atom/attackby(item,user,params) - used only when adjacent
	* item/afterattack(atom,user,adjacent,params) - used both ranged and adjacent
	* mob/RangedAttack(atom,params) - used only ranged, only used for tk and laser eyes but could be changed
*/

#define MAX_ITEM_DEPTH	3 //how far we can recurse before we can't get an item

/mob/proc/ClickOn( var/atom/A, var/params )
	if(!click_delayer) click_delayer = new
	if(timestopped) return 0 //under effects of time magick

	if(click_delayer.blocked())
		return
	click_delayer.setDelay(1)

	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
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

	if(isStunned())
		return

	face_atom(A) // change direction to face what you clicked on

	if(attack_delayer.blocked()) // This was next_move.  next_attack makes more sense.
		return
//	to_chat(world, "next_attack is [next_attack] and world.time is [world.time]")
	if(istype(loc,/obj/mecha))
		if(!locate(/turf) in list(A,A.loc)) // Prevents inventory from being drilled
			return
		var/obj/mecha/M = loc
		return M.click_action(A,src)

	if(restrained())
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		throw_item(A)
		return

	var/obj/item/W = get_active_hand()
	var/item_attack_delay = 0

	if(W == A)
		/*next_move = world.time + 6
		if(W.flags&USEDELAY)
			next_move += 5*/
		W.attack_self(src, params)
		if(hand)
			update_inv_l_hand(0)
		else
			update_inv_r_hand(0)

		return

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	// Allows you to click on a box's contents, if that box is on the ground, but no deeper than that
	if(A.Adjacent(src, MAX_ITEM_DEPTH)) // see adjacent.dm
		if(W)
			item_attack_delay = W.attack_delay
			var/resolved = W.preattack(A, src, 1, params)
			if(!resolved)
				resolved = A.attackby(W,src, params)
				if(ismob(A) || istype(A, /obj/mecha) || istype(W, /obj/item/weapon/grab))
					delayNextAttack(item_attack_delay)
				if(!resolved && A && W)
					W.afterattack(A,src,1,params) // 1 indicates adjacency
				else
					delayNextAttack(item_attack_delay)
		else
			if(ismob(A) || istype(W, /obj/item/weapon/grab))
				delayNextAttack(10)
			if(INVOKE_EVENT(on_uattack,list("atom"=A))) //This returns 1 when doing an action intercept
				return
			UnarmedAttack(A, 1, params)
		return
	else // non-adjacent click
		if(W)
			if(ismob(A))
				delayNextAttack(item_attack_delay)
			if(!W.preattack(A, src, 0,  params))
				W.afterattack(A,src,0,params) // 0: not Adjacent
		else
			if(ismob(A))
				delayNextAttack(10)
			if(INVOKE_EVENT(on_uattack,list("atom"=A))) //This returns 1 when doing an action intercept
				return
			RangedAttack(A, params)
	return

// Default behavior: ignore double clicks, consider them normal clicks instead
/mob/proc/DblClickOn(var/atom/A, var/params)
	//ClickOn(A,params)
	return


/*
	Translates into attack_hand, etc.

	Note: proximity_flag here is used to distinguish between normal usage (flag=1),
	and usage when clicking on things telekinetically (flag=0).  This proc will
	not be called at ranged except with telekinesis.

	proximity_flag is not currently passed to attack_hand, and is instead used
	in human click code to allow glove touches only at melee range.
*/
/mob/proc/UnarmedAttack(var/atom/A, var/proximity_flag, var/params)
	if(ismob(A))
		delayNextAttack(10)
	return

/*
	Ranged unarmed attack:

	This currently is just a default for all mobs, involving
	laser eyes and telekinesis.  You could easily add exceptions
	for things like ranged glove touches, spitting alien acid/neurotoxin,
	animals lunging, etc.
*/
/mob/proc/RangedAttack(var/atom/A, var/params)
	if(!mutations || !mutations.len) return
	if((M_LASER in mutations) && a_intent == I_HURT)
		LaserEyes(A) // moved into a proc below
	else if(M_TK in mutations)
		/*switch(get_dist(src,A))
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
		*/
		A.attack_tk(src)
/*
	Restrained ClickOn

	Used when you are handcuffed and click things.
	Not currently used by anything but could easily be.
*/
/mob/proc/RestrainedClickOn(var/atom/A)
	return

/*
	Middle click
	Only used for swapping hands
*/
/mob/proc/MiddleClickOn(var/atom/A)
	return
/mob/living/carbon/MiddleClickOn(var/atom/A)
	swap_hand()

// In case of use break glass
/*
/atom/proc/MiddleClick(var/mob/M as mob)
	return
*/

/*
	Shift click
	For most mobs, examine.
	This is overridden in ai.dm
*/
/mob/proc/ShiftClickOn(var/atom/A)
	A.ShiftClick(src)
	return
/atom/proc/ShiftClick(var/mob/user)
	if(user.client && user.client.eye == user)
		user.examination(src)
	return

/*
	Ctrl click
	For most objects, pull
*/
/mob/proc/CtrlClickOn(var/atom/A)
	A.CtrlClick(src)
	return
/atom/proc/CtrlClick(var/mob/user)
	user.stop_pulling()
	return

/atom/movable/CtrlClick(var/mob/user)
	if(Adjacent(user))
		user.start_pulling(src)


/*
	Alt click
	Unused except for AI
*/
/mob/proc/AltClickOn(var/atom/A)
	A.AltClick(src)
	return

/atom/proc/AltClick(var/mob/user)
	if(!(user == src) && !(isrobot(user)) && ishuman(src) && user.Adjacent(src))
		src:give_item(user)
		return
	var/turf/T = get_turf(src)
	if(T && T.Adjacent(user))
		if(user.listed_turf == T)
			user.listed_turf = null
		else
			user.listed_turf = T
			user.client.statpanel = T.name
	return

/*
	Misc helpers

	Laser Eyes: as the name implies, handles this since nothing else does currently
	face_atom: turns the mob towards what you clicked on
*/
/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	//next_move = world.time + 6
	delayNextAttack(4)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A)

	var/obj/item/projectile/beam/LE = getFromPool(/obj/item/projectile/beam, loc)
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/laser2.ogg', 75, 1)

	LE.firer = src
	LE.def_zone = get_organ_target()
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	LE.starting = T
	LE.original = A
	LE.target = U

	spawn( 1 )
		LE.OnFired()
		LE.process()

/mob/living/carbon/human/LaserEyes()
	if(burn_calories(0.5))
		nutrition = max(0,nutrition-2)
		..()
		handle_regular_hud_updates()
	else
		to_chat(src, "<span class='warning'>You're out of energy!  You need food!</span>")

// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(var/atom/A)
	if(stat != CONSCIOUS || locked_to || !A || !x || !y || !A.x || !A.y )
		return

	var/dx = A.x - x
	var/dy = A.y - y

	if(!dx && !dy) // Wall items are graphically shifted but on the floor
		if(A.pixel_y > 16)
			change_dir(NORTH)
		else if(A.pixel_y < -16)
			change_dir(SOUTH)
		else if(A.pixel_x > 16)
			change_dir(EAST)
		else if(A.pixel_x < -16)
			change_dir(WEST)

		return

	if(abs(dx) < abs(dy))
		if(dy > 0)
			change_dir(NORTH)
		else
			change_dir(SOUTH)
	else
		if(dx > 0)
			change_dir(EAST)
		else
			change_dir(WEST)
