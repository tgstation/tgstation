<<<<<<< HEAD
/mob/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover, /obj/item/projectile) || mover.throwing)
		return (!density || lying)
	if(mover.checkpass(PASSMOB))
		return 1
	if(buckled == mover)
		return 1
	if(ismob(mover))
		if (mover in buckled_mobs)
			return 1
	return (!mover.density || !density || lying)



/client/Northeast()
	swap_hand()
	return


/client/Southeast()
	attack_self()
	return


/client/Southwest()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()
	else
		usr << "<span class='danger'>This mob type cannot throw items.</span>"
	return


/client/Northwest()
	if(!usr.get_active_hand())
		usr << "<span class='warning'>You have nothing to drop in your hand!</span>"
		return
	usr.drop_item()
=======
/mob/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0)) return 1

	if(ismob(mover))
		var/mob/moving_mob = mover

		if ((other_mobs && moving_mob.other_mobs))
			return 1

	return (!mover.density || !density || lying)

/client/North()
	..()


/client/South()
	..()


/client/West()
	..()


/client/East()
	..()


/client/Northeast()
	treat_hotkeys(NORTHEAST)

/client/Southeast()
	treat_hotkeys(SOUTHEAST)

/client/Southwest()
	treat_hotkeys(SOUTHWEST)

/client/Northwest()
	treat_hotkeys(NORTHWEST)

/client/proc/treat_hotkeys(var/keypress)
	keypress = turn(keypress, dir)
	switch(keypress)
		if(NORTHEAST)
			swap_hand()
		if(SOUTHEAST)
			attack_self()
		if(SOUTHWEST)
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.toggle_throw_mode()
			else
				to_chat(usr, "<span class='warning'>This mob type cannot throw items.</span>")
		if(NORTHWEST)
			if(mob.remove_spell_channeling()) //Interrupt to remove spell channeling on dropping
				to_chat(usr, "<span class='notice'>You cease waiting to use your power")
				return
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(!C.get_active_hand())
					to_chat(usr, "<span class='warning'>You have nothing to drop in your hand.</span>")
					return
				if(ishuman(C))
					var/mob/living/carbon/human/H = C
					var/list/borers_in_host = H.get_brain_worms()
					if(borers_in_host && borers_in_host.len) //to allow a host to drop an item at-range mid-extension
						for(var/mob/living/simple_animal/borer/B in borers_in_host)
							if((B.hostlimb == LIMB_RIGHT_ARM && H.get_active_hand() == H.get_held_item_by_index(GRASP_RIGHT_HAND)) || (B.hostlimb == "l_arm" && H.get_active_hand() == H.get_held_item_by_index(GRASP_LEFT_HAND)))
								var/obj/item/weapon/gun/hookshot/flesh/F = B.extend_o_arm
								F.to_be_dropped = H.get_active_hand()
								F.item_overlay = null
				drop_item()
			else if(isMoMMI(usr))
				var/mob/living/silicon/robot/mommi/M = usr
				if(!M.get_active_hand())
					to_chat(M, "<span class='warning'>You have nothing to drop or store.</span>")
					return
				M.uneq_active()
			else if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(!R.module_active)
					return
				R.uneq_active()
			else
				if(istype(usr, /mob/living/simple_animal/borer))
					var/mob/living/simple_animal/borer/B = usr
					if(B.host && ishuman(B.host))
						var/mob/living/carbon/human/H = B.host
						if(B.hostlimb == LIMB_RIGHT_ARM)
							if(B.extend_o_arm)
								var/obj/item/weapon/gun/hookshot/flesh/F = B.extend_o_arm
								if(H.get_held_item_by_index(GRASP_RIGHT_HAND))
									F.to_be_dropped = H.get_held_item_by_index(GRASP_RIGHT_HAND)
									F.item_overlay = null
								F.attack_self(H)
								H.drop_item(H.get_held_item_by_index(GRASP_RIGHT_HAND))
								return
							else
								to_chat(usr, "<span class='warning'>Your host has nothing to drop in [H.gender == FEMALE ? "her" : "his"] right hand.</span>")
								return
						else if(B.hostlimb == LIMB_LEFT_ARM)
							if(B.extend_o_arm)
								var/obj/item/weapon/gun/hookshot/flesh/F = B.extend_o_arm
								if(H.get_held_item_by_index(GRASP_LEFT_HAND))
									F.to_be_dropped = H.get_held_item_by_index(GRASP_LEFT_HAND)
									F.item_overlay = null
								F.attack_self(H)
								H.drop_item(H.get_held_item_by_index(GRASP_LEFT_HAND))
								return
							else
								to_chat(usr, "<span class='warning'>Your host has nothing to drop in [H.gender == FEMALE ? "her" : "his"] left hand.</span>")
								return
				to_chat(usr, "<span class='warning'>This mob type cannot drop items.</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
<<<<<<< HEAD
		usr << "<span class='notice'>You are not pulling anything.</span>"
=======
		to_chat(usr, "<span class='notice'>You are not pulling anything.</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return
	usr.stop_pulling()

/client/verb/swap_hand()
<<<<<<< HEAD
	set category = "IC"
	set name = "Swap hands"

	if(mob)
		mob.swap_hand()

/client/verb/attack_self()
=======
	set hidden = 1
	if(istype(mob, /mob/living/carbon))
		mob:swap_hand()
	if(istype(mob,/mob/living/silicon/robot/mommi))
		return // MoMMIs only have one tool slot.
	if(istype(mob,/mob/living/silicon/robot))//Oh nested logic loops, is there anything you can't do? -Sieve
		var/mob/living/silicon/robot/R = mob
		if(!R.module_active)
			if(!R.module_state_1)
				if(!R.module_state_2)
					if(!R.module_state_3)
						return
					else
						R:inv1.icon_state = "inv1"
						R:inv2.icon_state = "inv2"
						R:inv3.icon_state = "inv3 +a"
						R:module_active = R:module_state_3
				else
					R:inv1.icon_state = "inv1"
					R:inv2.icon_state = "inv2 +a"
					R:inv3.icon_state = "inv3"
					R:module_active = R:module_state_2
			else
				R:inv1.icon_state = "inv1 +a"
				R:inv2.icon_state = "inv2"
				R:inv3.icon_state = "inv3"
				R:module_active = R:module_state_1
		else
			if(R.module_active == R.module_state_1)
				if(!R.module_state_2)
					if(!R.module_state_3)
						return
					else
						R:inv1.icon_state = "inv1"
						R:inv2.icon_state = "inv2"
						R:inv3.icon_state = "inv3 +a"
						R:module_active = R:module_state_3
				else
					R:inv1.icon_state = "inv1"
					R:inv2.icon_state = "inv2 +a"
					R:inv3.icon_state = "inv3"
					R:module_active = R:module_state_2
			else if(R.module_active == R.module_state_2)
				if(!R.module_state_3)
					if(!R.module_state_1)
						return
					else
						R:inv1.icon_state = "inv1 +a"
						R:inv2.icon_state = "inv2"
						R:inv3.icon_state = "inv3"
						R:module_active = R:module_state_1
				else
					R:inv1.icon_state = "inv1"
					R:inv2.icon_state = "inv2"
					R:inv3.icon_state = "inv3 +a"
					R:module_active = R:module_state_3
			else if(R.module_active == R.module_state_3)
				if(!R.module_state_1)
					if(!R.module_state_2)
						return
					else
						R:inv1.icon_state = "inv1"
						R:inv2.icon_state = "inv2 +a"
						R:inv3.icon_state = "inv3"
						R:module_active = R:module_state_2
				else
					R:inv1.icon_state = "inv1 +a"
					R:inv2.icon_state = "inv2"
					R:inv3.icon_state = "inv3"
					R:module_active = R:module_state_1
			else
				return
	return



/client/verb/attack_self() //Called when pagedown or Z is pressed
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	set hidden = 1
	if(mob)
		mob.mode()
	return


<<<<<<< HEAD
=======
/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return


>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob))
		mob.drop_item_v()
	return


/client/Center()
<<<<<<< HEAD
	if(isobj(mob.loc))
		var/obj/O = mob.loc
		if(mob.canmove)
			return O.relaymove(mob, 0)
	return


=======
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
<<<<<<< HEAD
			if(!mob.control_object)
				return
			mob.control_object.setDir(direct)
=======
			if(!mob.control_object)	return
			mob.control_object.dir = direct
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	return

<<<<<<< HEAD

/client/Move(n, direct)
	if(!mob || !mob.loc)
		return 0
	if(mob.notransform)
		return 0	//This is sota the goto stop mobs from moving var
	if(mob.control_object)
		return Move_object(direct)
	if(world.time < move_delay)
		return 0
	if(!isliving(mob))
		return mob.Move(n,direct)
	if(mob.stat == DEAD)
		mob.ghostize()
		return 0
	if(moving)
		return 0
	if(isliving(mob))
		var/mob/living/L = mob
		if(L.incorporeal_move)	//Move though walls
			Process_Incorpmove(direct)
			return 0

	if(mob.remote_control)					//we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		return AIMove(n,direct,mob)

	if(Process_Grab()) //are we restrained by someone's grip?
		return

	if(mob.buckled)							//if we're buckled to something, tell it we moved.
		return mob.buckled.relaymove(mob, direct)

	if(!mob.canmove)
		return 0

	if(isobj(mob.loc) || ismob(mob.loc))	//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return 0

	//We are now going to move
	moving = 1
	move_delay = mob.movement_delay() + world.time

	if(mob.confused)
		if(mob.confused > 40)
			step(mob, pick(cardinal))
		else if(prob(mob.confused * 1.5))
			step(mob, angle2dir(dir2angle(direct) + pick(90, -90)))
		else if(prob(mob.confused * 3))
			step(mob, angle2dir(dir2angle(direct) + pick(45, -45)))
		else
			step(mob, direct)
	else
		. = ..()

	moving = 0
	if(mob && .)
		mob.throwing = 0

	return .

=======
/client/proc/Dir_object(direct)
	if(mob && mob.orient_object)
		var/obj/O = mob.orient_object
		O.dir = direct

/client/Move(loc,dir)
	if(move_delayer.next_allowed > world.time)
		return 0

	// /vg/ - Deny clients from moving certain mobs. (Like cluwnes :^)
	if(mob.deny_client_move)
		to_chat(src, "<span class='warning'>You cannot move this mob.</span>")
		return

	if(mob.control_object)
		Move_object(dir)

	if(mob.orient_object)
		Dir_object(dir)
		return

	if(mob.incorporeal_move)
		Process_Incorpmove(dir)
		return

	if(mob.stat == DEAD)
		return

	if(isAI(mob))
		return AIMove(loc,dir,mob)

	if(mob.monkeyizing)
		return//This is sota the goto stop mobs from moving var

	if(Process_Grab())
		return

	if(mob.locked_to) //if we're locked_to to something, tell it we moved.
		return mob.locked_to.relaymove(mob, dir)

	if(!mob.canmove)
		return

	//if(istype(mob.loc, /turf/space) || (mob.flags & NOGRAV))
	//	if(!mob.Process_Spacemove(0))	return 0

	// If we're in space or our area has no gravity...
	if(istype(mob.loc, /turf/space) || (mob.areaMaster && mob.areaMaster.has_gravity == 0))
		var/can_move_without_gravity = 0

		// Here, we check to see if the object we're in doesn't need gravity to send relaymove().
		if(istype(mob.loc, /atom/movable))
			var/atom/movable/AM = mob.loc
			if(AM.internal_gravity) // Best name I could come up with, sorry. - N3X
				can_move_without_gravity=1

		// Block relaymove() if needed.
		if(!can_move_without_gravity && !mob.Process_Spacemove(0))
			return 0

	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, dir)

	if(isturf(mob.loc))
		if(mob.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(mob, 1))
				if(M.pulling == mob)
					if(!M.restrained() && M.stat == 0 && M.canmove && mob.Adjacent(M))
						to_chat(src, "<span class='notice'>You're restrained! You can't move!</span>")
						return 0
					else
						M.stop_pulling()
			if(mob.tether)
				var/datum/chain/chain_datum = mob.tether.chain_datum
				if(chain_datum.extremity_A == mob)
					if(istype(chain_datum.extremity_B,/mob/living))
						to_chat(src, "<span class='notice'>You're restrained! You can't move!</span>")
						return 0
				else if(chain_datum.extremity_B == mob)
					if(istype(chain_datum.extremity_A,/mob/living))
						to_chat(src, "<span class='notice'>You're restrained! You can't move!</span>")
						return 0

		if(mob.pinned.len)
			to_chat(src, "<span class='notice'>You're pinned to a wall by [mob.pinned[1]]!</span>")
			return 0

		// COMPLEX MOVE DELAY SHIT
		////////////////////////////
		var/move_delay=0 // set move delay
		mob.last_move_intent = world.time + 10
		switch(mob.m_intent)
			if("run")
				if(mob.drowsyness > 0)
					move_delay += 6
				move_delay += 1+config.run_speed
			if("walk")
				move_delay += 7+config.walk_speed
		move_delay += mob.movement_delay()

		var/obj/item/weapon/grab/Findgrab = locate() in mob
		if(Findgrab)
			move_delay += 7

		//We are now going to move
		move_delay = max(move_delay,1)
		if(mob.movement_speed_modifier)
			move_delay *= (1/mob.movement_speed_modifier)
		mob.delayNextMove(move_delay)
		//Something with pulling things
		if(Findgrab)
			var/list/L = mob.ret_grab()
			if(istype(L, /list))
				if(L.len == 2)
					L -= mob
					var/mob/M = L[1]
					if(M)
						if ((mob.Adjacent(M) || M.loc == mob.loc))
							var/turf/T = mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
				else
					for(var/mob/M in L)
						M.other_mobs = 1
						if(mob != M)
							M.animate_movement = 3
					for(var/mob/M in L)
						spawn( 0 )
							step(M, dir)
							return
						spawn( 1 )
							M.other_mobs = null
							M.animate_movement = 2
							return

		else if(mob.confused)
			step_rand(mob)
			mob.last_movement=world.time
		else
			. = ..()
			mob.last_movement=world.time
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

///Process_Grab()
///Called by client/Move()
///Checks to see if you are being grabbed and if so attemps to break it
/client/proc/Process_Grab()
<<<<<<< HEAD
	if(mob.pulledby)
		if(mob.incapacitated(ignore_restraints = 1))
			move_delay = world.time + 10
			return 1
		else if(mob.restrained(ignore_grab = 1))
			move_delay = world.time + 10
			src << "<span class='warning'>You're restrained! You can't move!</span>"
			return 1
		else
			return mob.resist_grab(1)
=======
	if(locate(/obj/item/weapon/grab, locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
		var/list/grabbing = list()

		for(var/obj/item/weapon/grab/G in mob.held_items)
			grabbing += G.affecting

		for(var/obj/item/weapon/grab/G in mob.grabbed_by)
			if((G.state == GRAB_PASSIVE)&&(!grabbing.Find(G.assailant)))	del(G)
			if(G.state == GRAB_AGGRESSIVE)
				mob.delayNextMove(10)
				if(!prob(25))	return 1
				mob.visible_message("<span class='warning'>[mob] has broken free of [G.assailant]'s grip!</span>",
					drugged_message="<span class='warning'>[mob] has broken free of [G.assailant]'s hug!</span>")
				returnToPool(G)
			if(G.state == GRAB_NECK)
				mob.delayNextMove(10)
				if(!prob(5))	return 1
				mob.visible_message("<span class='warning'>[mob] has broken free of [G.assailant]'s headlock!</span>",
					drugged_message="<span class='warning'>[mob] has broken free of [G.assailant]'s passionate hug!</span>")
				returnToPool(G)
	return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488


///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
<<<<<<< HEAD
	if(!isliving(mob))
		return
	var/mob/living/L = mob
	switch(L.incorporeal_move)
		if(1)
			L.loc = get_step(L, direct)
			L.setDir(direct)
		if(2)
=======

	switch(mob.incorporeal_move)
		if(INCORPOREAL_GHOST)
			if(isobserver(mob)) //Typecast time
				var/mob/dead/observer/observer = mob
				if(observer.locked_to) //Ghosts can move at any time to unlock themselves (in theory from following a mob)
					observer.manual_stop_follow(observer.locked_to)
			var/turf/T = get_step(mob, direct)
			var/area/A = get_area(T)
			if(A && A.anti_ethereal && !isAdminGhost(mob))
				to_chat(mob, "<span class='sinister'>A dark forcefield prevents you from entering the area.</span>")
			else
				if((T && T.holy) && isobserver(mob) && ((mob.invisibility == 0) || (ticker.mode && (mob.mind in ticker.mode.cult))))
					to_chat(mob, "<span class='warning'>You cannot get past holy grounds while you are in this plane of existence!</span>")
				else
					mob.forceEnter(get_step(mob, direct))
					mob.dir = direct
			if(isobserver(mob))
				var/mob/dead/observer/observer = mob
				mob.delayNextMove(observer.movespeed)
			else
				mob.delayNextMove(1)
		if(INCORPOREAL_NINJA)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
<<<<<<< HEAD
				L.loc = locate(locx,locy,mobloc.z)
				var/limit = 2//For only two trailing shadows.
				for(var/turf/T in getline(mobloc, L.loc))
					spawn(0)
						anim(T,L,'icons/mob/mob.dmi',,"shadow",,L.dir)
					limit--
					if(limit<=0)
						break
			else
				spawn(0)
					anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,L.dir)
				L.loc = get_step(L, direct)
			L.setDir(direct)
		if(3) //Incorporeal move, but blocked by holy-watered tiles and salt piles.
			var/turf/open/floor/stepTurf = get_step(L, direct)
			for(var/obj/effect/decal/cleanable/salt/S in stepTurf)
				L << "<span class='warning'>[S] bars your passage!</span>"
				if(istype(L, /mob/living/simple_animal/revenant))
					var/mob/living/simple_animal/revenant/R = L
					R.reveal(20)
					R.stun(20)
				return
			if(stepTurf.flags & NOJAUNT)
				L << "<span class='warning'>Holy energies block your path.</span>"
			else
				L.loc = get_step(L, direct)
				L.setDir(direct)
=======
				mob.loc = locate(locx,locy,mobloc.z)
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, mob.loc))
						anim(T,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
						limit--
						if(limit<=0)	break
			else
				anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
				mob.forceEnter(get_step(mob, direct))
			mob.dir = direct
			mob.delayNextMove(1)
		if(INCORPOREAL_ETHEREAL) //Jaunting, without needing to be done through relaymove
			var/turf/newLoc = get_step(mob,direct)
			if(!(newLoc.flags & NOJAUNT))
				mob.forceEnter(newLoc)
				mob.dir = direct
			else
				to_chat(mob, "<span class='warning'>Some strange aura is blocking the way!</span>")
			mob.delayNextMove(2)
			return 1
	// Crossed is always a bit iffy
	for(var/obj/S in mob.loc)
		if(istype(S,/obj/effect/step_trigger) || istype(S,/obj/effect/beam))
			S.Crossed(mob)

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return 1


///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
<<<<<<< HEAD
/mob/Process_Spacemove(movement_dir = 0)
	if(..())
		return 1
	var/atom/movable/backup = get_spacemove_backup()
	if(backup)
		if(istype(backup) && movement_dir && !backup.anchored)
			if(backup.newtonian_move(turn(movement_dir, 180))) //You're pushing off something movable, so it moves
				src << "<span class='info'>You push off of [backup] to propel yourself.</span>"
		return 1
	return 0

/mob/get_spacemove_backup()
	var/atom/movable/dense_object_backup
	for(var/A in orange(1, get_turf(src)))
		if(isarea(A))
			continue
		else if(isturf(A))
			var/turf/turf = A
			if(istype(turf,/turf/open/space))
				continue
			if(!turf.density && !mob_negates_gravity())
				continue
			return A
		else
			var/atom/movable/AM = A
			if(AM == buckled) //Kind of unnecessary but let's just be sure
				continue
			if(!AM.CanPass(src) || AM.density)
				if(AM.anchored)
					return AM
				if(pulling == AM)
					continue
				dense_object_backup = AM
				break
	. = dense_object_backup

/mob/proc/mob_has_gravity(turf/T)
	return has_gravity(src, T)

/mob/proc/mob_negates_gravity()
	return 0

//moves the mob/object we're pulling
/mob/proc/Move_Pulled(atom/A)
	if (!pulling)
		return
	if (pulling.anchored || !pulling.Adjacent(src))
		stop_pulling()
		return
	if (A == loc && pulling.density)
		return
	if (!Process_Spacemove(get_dir(pulling.loc, A)))
		return
	step(pulling, get_dir(pulling.loc, A))


/mob/proc/slip(s_amount, w_amount, obj/O, lube)
	return

/mob/proc/update_gravity()
=======
/mob/proc/Process_Spacemove(var/check_drift = 0,var/ignore_slip = 0)
	//First check to see if we can do things
	if(restrained())
		return 0

	/*
	if(istype(src,/mob/living/carbon))
		if(src.l_hand && src.r_hand)
			return 0
	*/

	var/dense_object = 0
	for(var/turf/turf in oview(1,src))
		if(istype(turf,/turf/space))
			continue

		var/mob/living/carbon/human/H = src
		if(istype(turf,/turf/simulated/floor) && (src.areaMaster && src.areaMaster.has_gravity == 0) && !(istype(H) && istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags & NOSLIP)))
			continue

		dense_object++
		break

	if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
		dense_object++
	if(!dense_object && (locate(/obj/structure/catwalk) in oview(1, src)))
		dense_object++
	if(!dense_object && (locate(/obj/effect/blob) in oview(1, src)))
		dense_object++

	//Lastly attempt to locate any dense objects we could push off of
	//TODO: If we implement objects drifing in space this needs to really push them
	//Due to a few issues only anchored and dense objects will now work.
	if(!dense_object)
		for(var/obj/O in oview(1, src))
			if((O) && (O.density) && (O.anchored))
				dense_object++
				break

	//Nothing to push off of so end here
	if(!dense_object)
		return 0



	//Check to see if we slipped
	if(!ignore_slip && prob(Process_Spaceslipping(5)))
		to_chat(src, "<span class='notice'><B>You slipped!</B></span>")
		src.inertia_dir = src.last_move
		step(src, src.inertia_dir)
		return 0
	//If not then we can reset inertia and move
	inertia_dir = 0
	return 1


/mob/proc/Process_Spaceslipping(var/prob_slip = 5)
	//Setup slipage
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0  // Changing this to zero to make it line up with the comment.

	prob_slip = round(prob_slip)
	return(prob_slip)


/mob/proc/Move_Pulled(var/atom/A)
	if(!canmove || restrained() || !pulling)
		return
	if(pulling.anchored)
		return
	if(src.locked_to == pulling)
		return
	if(!pulling.Adjacent(src))
		return
	if(!isturf(pulling.loc))
		return
	if(A == loc && pulling.density)
		return
	if(!Process_Spacemove(,1))
		return
	if(ismob(pulling))
		var/mob/M = pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()
		step(pulling, get_dir(pulling.loc, A))
		if(M)
			M.start_pulling(t)
	else
		step(pulling, get_dir(pulling.loc, A))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return
