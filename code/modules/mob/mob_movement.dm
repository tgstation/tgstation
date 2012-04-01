/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !density || lying)
	else
		return (!mover.density || !density || lying)
	return


/client/North()
	..()


/client/South()
	..()


/client/West()
	..()


/client/East()
	..()


/client/Northeast()
	swap_hand()
	return


/client/Southeast()
	attack_self()
	return


/client/Southwest()
	toggle_throw_mode()
	return


/client/Northwest()
	drop_item()
	return


/client/verb/swap_hand()
	set hidden = 1
	if(istype(mob, /mob/living/carbon))
		mob:swap_hand()
	return


/client/verb/attack_self()
	set hidden = 1
	var/obj/item/weapon/W = mob.equipped()
	if (W)
		W.attack_self(mob)
	return


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))	return
	if((mob.stat || mob.restrained()) || !(isturf(mob.loc)))	return
	mob:toggle_throw_mode()
	return


/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob))
		mob.drop_item_v()
	return


/client/Center()
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	return


/atom/movable/Move(NewLoc, direct)
	if (direct & direct - 1)
		if (direct & 1)
			if (direct & 4)
				if (step(src, NORTH))
					step(src, EAST)
				else
					if (step(src, EAST))
						step(src, NORTH)
			else
				if (direct & 8)
					if (step(src, NORTH))
						step(src, WEST)
					else
						if (step(src, WEST))
							step(src, NORTH)
		else
			if (direct & 2)
				if (direct & 4)
					if (step(src, SOUTH))
						step(src, EAST)
					else
						if (step(src, EAST))
							step(src, SOUTH)
				else
					if (direct & 8)
						if (step(src, SOUTH))
							step(src, WEST)
						else
							if (step(src, WEST))
								step(src, SOUTH)
	else
		. = ..()
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
	if(mob.control_object)	Move_object(direct)

	if(isobserver(mob))	return mob.Move(n,direct)

	if(moving)	return 0

	if(world.time < move_delay)	return

	if(!mob)	return

	if(mob.stat==2)	return

	if(isAI(mob))	return AIMove(n,direct,mob)

	if(mob.monkeyizing)	return//This is sota the goto stop mobs from moving var

	if(mob.incorporeal_move)//Move though walls
		Process_Incorpmove(direct)
		return

	if(Process_Grab())	return

//Making mob movememnt changes instant.
	if(mob.paralysis || mob.stunned || mob.resting || mob.weakened || mob.buckled || (mob.changeling && mob.changeling.changeling_fakedeath))
		mob.canmove = 0
		return
	else
		mob.canmove = 1

	if(istype(mob.loc, /turf/space) || (mob.flags & NOGRAV))
		if(!mob.Process_Spacemove(0))	return 0

	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(isturf(mob.loc))

		if(mob.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(mob, 1))
				if(((M.pulling == mob && (!( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
					src << "\blue You're restrained! You can't move!"
					return 0

		move_delay = world.time//set move delay
		mob.last_move_intent = world.time + 10
		switch(mob.m_intent)
			if("run")
				if(mob.drowsyness > 0)
					move_delay += 5
//				if(mob.organStructure && mob.organStructure.legs)
//					move_delay += mob.organStructure.legs.moveRunDelay
				move_delay += 2
			if("walk")
//				if(mob.organStructure && mob.organStructure.legs)
//					move_delay += mob.organStructure.legs.moveWalkDelay
				move_delay += 5
		move_delay += mob.movement_delay()
		move_delay += mob.grav_delay

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
					if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
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
							step(M, direct)
							return
						spawn( 1 )
							M.other_mobs = null
							M.animate_movement = 2
							return

		else if(mob.confused && prob(30))
			step(mob, pick(cardinal))
		else
			. = ..()
			for(var/obj/effect/speech_bubble/S in range(1, mob))
				if(S.parent == mob)
					S.loc = mob.loc
		moving = 0

		return .

	return


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
			if((G.state == 1)&&(!grabbing.Find(G.assailant)))	del(G)
			if(G.state == 2)
				move_delay = world.time + 10
				if(!prob(25))	return 1
				mob.visible_message("\red [mob] has broken free of [G.assailant]'s grip!")
				del(G)
			if(G.state == 3)
				move_delay = world.time + 10
				if(!prob(5))	return 1
				mob.visible_message("\red [mob] has broken free of [G.assailant]'s headlock!")
				del(G)
	return 0


///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	switch(mob.incorporeal_move)
		if(1)
			mob.loc = get_step(mob, direct)
			mob.dir = direct
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
				mob.loc = locate(locx,locy,mobloc.z)
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, mob.loc))
						spawn(0)
							anim(T,mob,'mob.dmi',,"shadow",,mob.dir)
						limit--
						if(limit<=0)	break
			else
				spawn(0)
					anim(mobloc,mob,'mob.dmi',,"shadow",,mob.dir)
				mob.loc = get_step(mob, direct)
			mob.dir = direct
	return 1


///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/proc/Process_Spacemove(var/check_drift = 0)
	//First check to see if we can do things
	if(restrained())	return 0

	var/dense_object = 0
	for(var/turf/turf in oview(1,src))
		if(istype(turf,/turf/space))
			continue
		if(istype(turf,/turf/simulated/floor) && (src.flags & NOGRAV))
			continue
		dense_object++
		break

	if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
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
	if(!dense_object)	return 0

	//Check to see if we slipped
	if(prob(Process_Spaceslipping(5)))
		src << "\blue <B>You slipped!</B>"
		src.inertia_dir = src.last_move
		step(src, src.inertia_dir)
		return 0
	//If not then we can reset inertia and move
	inertia_dir = 0
	return 1


/mob/proc/Process_Spaceslipping(var/prob_slip = 5)
	//Setup slipage
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)	prob_slip += 50

	prob_slip = round(prob_slip)
	return(prob_slip)
