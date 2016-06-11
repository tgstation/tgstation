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
			if(!mob.control_object)
				return
			mob.control_object.setDir(direct)
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	return


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


///Process_Grab()
///Called by client/Move()
///Checks to see if you are being grabbed and if so attemps to break it
/client/proc/Process_Grab()
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
			L.setDir(direct)
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
		if(3) //Incorporeal move, but blocked by holy-watered tiles
			var/turf/open/floor/stepTurf = get_step(L, direct)
			if(stepTurf.flags & NOJAUNT)
				L << "<span class='warning'>Holy energies block your path.</span>"
				L.notransform = 1
				spawn(2)
					L.notransform = 0
			else
				L.loc = get_step(L, direct)
				L.setDir(direct)
	return 1


///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
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
	return
