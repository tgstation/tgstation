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
		var/mob/moving_mob = mover
		if ((other_mobs && moving_mob.other_mobs))
			return 1
		if (mover == buckled_mob)
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

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		usr << "<span class='notice'>You are not pulling anything.</span>"
		return
	usr.stop_pulling()

/client/verb/swap_hand()
	set category = "IC"
	set name = "Swap hands"

	if(mob)
		mob.swap_hand()

/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.mode()
	return


/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob))
		mob.drop_item_v()
	return


/client/Center()
	if(isobj(mob.loc))
		var/obj/O = mob.loc
		if(mob.canmove)
			return O.relaymove(mob, 0)
	return


/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)	return
			mob.control_object.dir = direct
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	return


/client/Move(n, direct)
	if(!mob)
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

	if(Process_Grab())	return

	if(mob.buckled)							//if we're buckled to something, tell it we moved.
		return mob.buckled.relaymove(mob, direct)

	if(mob.remote_control)					//we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		return AIMove(n,direct,mob)

	if(!mob.canmove)
		return 0

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)


	if(isobj(mob.loc) || ismob(mob.loc))	//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return 0

	if(isturf(mob.loc))


		var/turf/T = mob.loc
		move_delay = world.time//set move delay

		move_delay += T.slowdown

		if(mob.restrained())	//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(mob, 1))
				if(M.pulling == mob)
					if(!M.incapacitated() && mob.Adjacent(M))
						src << "<span class='warning'>You're restrained! You can't move!</span>"
						move_delay += 10
						return 0
					else
						M.stop_pulling()

		switch(mob.m_intent)
			if(SPRINT)
				move_delay += config.run_speed
			if(RUN)
				if(mob.drowsyness > 0)
					move_delay += 6
				move_delay += config.run_speed
			if(WALK)
				move_delay += config.walk_speed
		move_delay += mob.movement_delay()

		if(mob.m_intent == SPRINT && ishuman(mob))
			var/mob/living/L = mob
			var/old_move_delay = move_delay
			move_delay = world.time
			L.adjustStaminaLoss(old_move_delay-move_delay) //The more you're overcoming slowdown, the faster you tire

		if(config.Tickcomp)
			move_delay -= 1.3
			var/tickcomp = (1 / (world.tick_lag)) * 1.3
			move_delay = move_delay + tickcomp

		//We are now going to move
		moving = 1
		//Something with pulling things
		if(locate(/obj/item/weapon/grab, mob))
			move_delay = max(move_delay, world.time + 7)
			var/list/L = mob.ret_grab()
			if(istype(L, /list))
				if(L.len == 2)
					L -= mob
					var/mob/M = L[1]
					if(M)
						if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
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
							step(M, direct)
							return
						spawn( 1 )
							M.other_mobs = null
							M.animate_movement = 2
							return

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


///Process_Grab()
///Called by client/Move()
///Checks to see if you are being grabbed and if so attemps to break it
/client/proc/Process_Grab()
	if(locate(/obj/item/weapon/grab, locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
		var/list/grabbing = list()

		if(istype(mob.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.l_hand
			grabbing += G.affecting

		if(istype(mob.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.r_hand
			grabbing += G.affecting

		for(var/obj/item/weapon/grab/G in mob.grabbed_by)
			if(G.state == GRAB_PASSIVE && !grabbing.Find(G.assailant))
				qdel(G)

			if(G.state == GRAB_AGGRESSIVE)
				move_delay = world.time + 10
				if(!prob(25))
					return 1
				mob.visible_message("<span class='warning'>[mob] has broken free of [G.assailant]'s grip!</span>")
				qdel(G)

			if(G.state == GRAB_NECK)
				move_delay = world.time + 10
				if(!prob(5))
					return 1
				mob.visible_message("<span class='warning'>[mob] has broken free of [G.assailant]'s headlock!</span>")
				qdel(G)
	return 0


///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	if(!isliving(mob))
		return
	var/mob/living/L = mob
	switch(L.incorporeal_move)
		if(1)
			L.loc = get_step(L, direct)
			L.dir = direct
		if(2)
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
				L.loc = locate(locx,locy,mobloc.z)
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, L.loc))
						spawn(0)
							anim(T,L,'icons/mob/mob.dmi',,"shadow",,L.dir)
						limit--
						if(limit<=0)	break
			else
				spawn(0)
					anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,L.dir)
				L.loc = get_step(L, direct)
			L.dir = direct
		if(3) //Incorporeal move, but blocked by holy-watered tiles
			var/turf/simulated/floor/stepTurf = get_step(L, direct)
			if(stepTurf.flags & NOJAUNT)
				L << "<span class='warning'>Holy energies block your path.</span>"
				L.notransform = 1
				spawn(2)
					L.notransform = 0
			else
				L.loc = get_step(L, direct)
				L.dir = direct
	return 1


///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/Process_Spacemove(movement_dir = 0)

	if(..())
		return 1

	var/atom/movable/dense_object_backup
	for(var/atom/A in orange(1, get_turf(src)))
		if(isarea(A))
			continue

		else if(isturf(A))
			var/turf/turf = A
			if(istype(turf,/turf/space))
				continue

			if(!turf.density && !mob_negates_gravity())
				continue

			return 1

		else
			var/atom/movable/AM = A
			if(AM == buckled) //Kind of unnecessary but let's just be sure
				continue
			if(AM.density)
				if(AM.anchored)
					return 1
				if(pulling == AM)
					continue
				dense_object_backup = AM

	if(movement_dir && dense_object_backup)
		if(dense_object_backup.newtonian_move(turn(movement_dir, 180))) //You're pushing off something movable, so it moves
			src << "<span class='info'>You push off of [dense_object_backup] to propel yourself.</span>"


		return 1
	return 0

/mob/proc/mob_has_gravity(turf/T)
	return has_gravity(src, T)

/mob/proc/mob_negates_gravity()
	return 0

/mob/proc/Move_Pulled(atom/A)
	if (!canmove || restrained() || !pulling)
		return
	if (pulling.anchored)
		return
	if (!pulling.Adjacent(src))
		return
	if (A == loc && pulling.density)
		return
	if (!Process_Spacemove(get_dir(pulling.loc, A)))
		return
	if (ismob(pulling))
		var/mob/M = pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()
		step(pulling, get_dir(pulling.loc, A))
		if(M)
			M.start_pulling(t)
	else
		step(pulling, get_dir(pulling.loc, A))
	return

/mob/proc/slip(s_amount, w_amount, obj/O, lube)
	return

/mob/proc/update_gravity()
	return