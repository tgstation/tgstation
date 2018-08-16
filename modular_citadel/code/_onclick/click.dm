/mob/proc/RightClickOn(atom/A, params) //mostly a copy-paste from ClickOn()
	var/list/modifiers = params2list(params)
	if(incapacitated(ignore_restraints = 1))
		return

	face_atom(A)

	if(next_move > world.time) // in the year 2000...
		return

	if(!modifiers["catcher"] && A.IsObscured())
		return

	if(ismecha(loc))
		var/obj/mecha/M = loc
		return M.click_action(A,src,params)

	if(restrained())
		changeNext_move(CLICK_CD_HANDCUFFED)   //Doing shit in cuffs shall be vey slow
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		throw_item(A)//todo: make it plausible to lightly toss items via right-click
		return

	var/obj/item/W = get_active_held_item()

	if(W == A)
		if(!W.rightclick_attack_self(src))
			W.attack_self(src)
		update_inv_hands()
		return

	//These are always reachable.
	//User itself, current loc, and user inventory
	if(A in DirectAccess())
		if(W)
			W.rightclick_melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			if(!AltUnarmedAttack(A))
				UnarmedAttack(A)
		return

	//Can't reach anything else in lockers or other weirdness
	if(!loc.AllowClick())
		return

	//Standard reach turf to turf or reaching inside storage
	if(CanReach(A,W))
		if(W)
			W.rightclick_melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			if(!AltUnarmedAttack(A,1))
				UnarmedAttack(A,1)
	else
		if(W)
			if(!W.altafterattack(A, src, FALSE, params))
				W.afterattack(A, src, FALSE, params)
		else
			if(!AltRangedAttack(A,params))
				RangedAttack(A,params)

/mob/proc/AltUnarmedAttack(atom/A, proximity_flag)
	if(ismob(A))
		changeNext_move(CLICK_CD_MELEE)
	return FALSE

/mob/proc/AltRangedAttack(atom/A, params)
	return FALSE

/mob/proc/mouse_face_atom(atom/A)	//Basically a copy of face_atom but with ismousemovement set to TRUE
	if( buckled || stat != CONSCIOUS || !A || !x || !y || !A.x || !A.y )
		return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) // Wall items are graphically shifted but on the floor
		if(A.pixel_y > 16)
			setDir(NORTH, ismousemovement = TRUE)
		else if(A.pixel_y < -16)
			setDir(SOUTH, ismousemovement = TRUE)
		else if(A.pixel_x > 16)
			setDir(EAST, ismousemovement = TRUE)
		else if(A.pixel_x < -16)
			setDir(WEST, ismousemovement = TRUE)
		return

	if(abs(dx) < abs(dy))
		if(dy > 0)
			setDir(NORTH, ismousemovement = TRUE)
		else
			setDir(SOUTH, ismousemovement = TRUE)
	else
		if(dx > 0)
			setDir(EAST, ismousemovement = TRUE)
		else
			setDir(WEST, ismousemovement = TRUE)
