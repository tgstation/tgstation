// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables
// Toilets are a type of disposal bin for small objects only and work on magic. By magic, I mean torque rotation
#define SEND_PRESSURE 0.05*ONE_ATMOSPHERE

/obj/machinery/disposal
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "disposal"
	anchored = 1
	density = 1
	var/datum/gas_mixture/air_contents	// internal reservoir
	var/mode = 1	// item mode 0=off 1=charging 2=charged
	var/flush = 0	// true if flush handle is pulled
	var/obj/structure/disposalpipe/trunk/trunk = null // the attached pipe trunk
	var/flushing = 0	// true if flushing in progress
	var/flush_every_ticks = 30 //Every 30 ticks it will look whether it is ready to flush
	var/flush_count = 0 //this var adds 1 once per tick. When it reaches flush_every_ticks it resets and tries to flush.
	var/last_sound = 0

	// create a new disposal
	// find the attached trunk (if present) and init gas resvr.
	New()
		..()
		spawn(5)
			trunk = locate() in src.loc
			if(!trunk)
				mode = 0
				flush = 0
			else
				trunk.linked = src	// link the pipe trunk to self

			air_contents = new/datum/gas_mixture()
			//gas.volume = 1.05 * CELLSTANDARD
			update()


	// attack by item places it in to disposal
	attackby(var/obj/item/I, var/mob/user)
		if(stat & BROKEN || !I || !user)
			return

		if(isrobot(user) && !istype(I, /obj/item/weapon/trashbag))
			return
		src.add_fingerprint(user)
		if(mode<=0) // It's off
			if(istype(I, /obj/item/weapon/screwdriver))
				if(contents.len > 0)
					user << "Eject the items first!"
					return
				if(mode==0) // It's off but still not unscrewed
					mode=-1 // Set it to doubleoff l0l
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					user << "You remove the screws around the power connection."
					return
				else if(mode==-1)
					mode=0
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					user << "You attach the screws around the power connection."
					return
			else if(istype(I,/obj/item/weapon/weldingtool) && mode==-1)
				if(contents.len > 0)
					user << "Eject the items first!"
					return
				var/obj/item/weapon/weldingtool/W = I
				if(W.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
					user << "You start slicing the floorweld off the disposal unit."

					if(do_after(user,20))
						if(!src || !W.isOn()) return
						user << "You sliced the floorweld off the disposal unit."
						var/obj/structure/disposalconstruct/C = new (src.loc)
						src.transfer_fingerprints_to(C)
						C.ptype = 6 // 6 = disposal unit
						C.anchored = 1
						C.density = 1
						C.update()
						del(src)
					return
				else
					user << "You need more welding fuel to complete this task."
					return

		if(istype(I, /obj/item/weapon/melee/energy/blade))
			user << "You can't place that item inside the disposal unit."
			return

		if(istype(I, /obj/item/weapon/trashbag))
			user << "\blue You empty the bag."
			for(var/obj/item/O in I.contents)
				O.loc = src
				I.contents -= O
			I.update_icon()
			update()
			return

		var/obj/item/weapon/grab/G = I
		if(istype(G))	// handle grabbed mob
			if(ismob(G.affecting))
				var/mob/GM = G.affecting
				for (var/mob/V in viewers(usr))
					V.show_message("[usr] starts putting [GM.name] into the disposal.", 3)
				if(do_after(usr, 20))
					if (GM.client)
						GM.client.perspective = EYE_PERSPECTIVE
						GM.client.eye = src
					GM.loc = src
					for (var/mob/C in viewers(src))
						C.show_message("\red [GM.name] has been placed in the [src] by [user].", 3)
					del(G)
					log_attack("<font color='red'>[usr] ([usr.ckey]) placed [GM] ([GM.ckey]) in a disposals unit.</font>")
					log_admin("ATTACK: [usr] ([usr.ckey]) placed [GM] ([GM.ckey]) in a disposals unit.")
					msg_admin_attack("ATTACK: [usr] ([usr.ckey]) placed [GM] ([GM.ckey]) in a disposals unit.")
			return

		if(!I)	return

		user.drop_item()
		if(I)
			I.loc = src

		user << "You place \the [I] into the [src]."
		for(var/mob/M in viewers(src))
			if(M == user)
				continue
			M.show_message("[user.name] places \the [I] into the [src].", 3)

		update()

	// mouse drop another mob or self
	//
	MouseDrop_T(mob/target, mob/user)
		if (!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || istype(user, /mob/living/silicon/ai))
			return
		src.add_fingerprint(user)
		var/msg
		for (var/mob/V in viewers(usr))
			if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
				V.show_message("[usr] starts climbing into the disposal.", 3)
			if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
				if(target.anchored) return
				V.show_message("[usr] starts stuffing [target.name] into the disposal.", 3)
		if(!do_after(usr, 20))
			return
		if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)	// if drop self, then climbed in
												// must be awake, not stunned or whatever
			msg = "[user.name] climbs into the [src]."
			user << "You climb into the [src]."
		else if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
			msg = "[user.name] stuffs [target.name] into the [src]!"
			user << "You stuff [target.name] into the [src]!"
		else
			return
		if (target.client)
			target.client.perspective = EYE_PERSPECTIVE
			target.client.eye = src
		target.loc = src

		for (var/mob/C in viewers(src))
			if(C == user)
				continue
			C.show_message(msg, 3)

		update()
		return

	// can breath normally in the disposal
	alter_health()
		return get_turf(src)

	// attempt to move while inside
	relaymove(mob/user as mob)
		if(user.stat || src.flushing)
			return
		src.go_out(user)
		return

	// leave the disposal
	proc/go_out(mob/user)

		if (user.client)
			user.client.eye = user.client.mob
			user.client.perspective = MOB_PERSPECTIVE
		user.loc = src.loc
		update()
		return


	// monkeys can only pull the flush lever
	attack_paw(mob/user as mob)
		if(stat & BROKEN)
			return

		flush = !flush
		update()
		return

	// ai as human but can't flush
	attack_ai(mob/user as mob)
		interact(user, 1)

	// human interact with machine
	attack_hand(mob/user as mob)
		if(user && user.loc == src)
			usr << "\red You cannot reach the controls from inside."
			return
		/*
		if(mode==-1)
			usr << "\red The disposal units power is disabled."
			return
		*/
		interact(user, 0)

	// user interaction
	proc/interact(mob/user, var/ai=0)

		src.add_fingerprint(user)
		if(stat & BROKEN)
			user.machine = null
			return

		var/dat = "<head><title>Waste Disposal Unit</title></head><body><TT><B>Waste Disposal Unit</B><HR>"

		if(!ai)  // AI can't pull flush handle
			if(flush)
				dat += "Disposal handle: <A href='?src=\ref[src];handle=0'>Disengage</A> <B>Engaged</B>"
			else
				dat += "Disposal handle: <B>Disengaged</B> <A href='?src=\ref[src];handle=1'>Engage</A>"

			dat += "<BR><HR><A href='?src=\ref[src];eject=1'>Eject contents</A><HR>"

		if(mode <= 0)
			dat += "Pump: <B>Off</B> <A href='?src=\ref[src];pump=1'>On</A><BR>"
		else if(mode == 1)
			dat += "Pump: <A href='?src=\ref[src];pump=0'>Off</A> <B>On</B> (pressurizing)<BR>"
		else
			dat += "Pump: <A href='?src=\ref[src];pump=0'>Off</A> <B>On</B> (idle)<BR>"

		var/per = 100* air_contents.return_pressure() / (SEND_PRESSURE)

		dat += "Pressure: [round(per, 1)]%<BR></body>"


		user.machine = src
		user << browse(dat, "window=disposal;size=360x170")
		onclose(user, "disposal")

	// handle machine interaction

	Topic(href, href_list)
		if(usr.loc == src)
			usr << "\red You cannot reach the controls from inside."
			return

		if(mode==-1 && !href_list["eject"]) // only allow ejecting if mode is -1
			usr << "\red The disposal units power is disabled."
			return
		..()
		src.add_fingerprint(usr)
		if(stat & BROKEN)
			return
		if(usr.stat || usr.restrained() || src.flushing)
			return

		if (in_range(src, usr) && istype(src.loc, /turf))
			usr.machine = src

			if(href_list["close"])
				usr.machine = null
				usr << browse(null, "window=disposal")
				return

			if(href_list["pump"])
				if(text2num(href_list["pump"]))
					mode = 1
				else
					mode = 0
				update()

			if(href_list["handle"])
				flush = text2num(href_list["handle"])
				update()

			if(href_list["eject"])
				eject()
		else
			usr << browse(null, "window=disposal")
			usr.machine = null
			return
		return

	// eject the contents of the disposal unit
	proc/eject()
		for(var/atom/movable/AM in src)
			AM.loc = src.loc
			AM.pipe_eject(0)
		update()

	// update the icon & overlays to reflect mode & status
	proc/update()
		overlays = null
		if(stat & BROKEN)
			icon_state = "disposal-broken"
			mode = 0
			flush = 0
			return

		// flush handle
		if(flush)
			overlays += image('icons/obj/pipes/disposal.dmi', "dispover-handle")

		// only handle is shown if no power
		if(stat & NOPOWER || mode == -1)
			return

		// 	check for items in disposal - occupied light
		if(contents.len > 0)
			overlays += image('icons/obj/pipes/disposal.dmi', "dispover-full")

		// charging and ready light
		if(mode == 1)
			overlays += image('icons/obj/pipes/disposal.dmi', "dispover-charge")
		else if(mode == 2)
			overlays += image('icons/obj/pipes/disposal.dmi', "dispover-ready")

	// timed process
	// charge the gas reservoir and perform flush if ready
	process()
		if(stat & BROKEN)			// nothing can happen if broken
			return

		if(!air_contents) // Potentially causes a runtime otherwise (if this is really shitty, blame pete //Donkie)
			return

		flush_count++
		if( flush_count >= flush_every_ticks )
			if( contents.len )
				if(mode == 2)
					spawn(0)
						feedback_inc("disposal_auto_flush",1)
						flush()
			flush_count = 0

		src.updateDialog()

		if(flush && air_contents.return_pressure() >= SEND_PRESSURE )	// flush can happen even without power
			flush()

		if(stat & NOPOWER)			// won't charge if no power
			return

		use_power(100)		// base power usage

		if(mode != 1)		// if off or ready, no need to charge
			return

		// otherwise charge
		use_power(500)		// charging power usage

		var/atom/L = loc						// recharging from loc turf

		var/datum/gas_mixture/env = L.return_air()
		var/pressure_delta = (SEND_PRESSURE*1.01) - air_contents.return_pressure()

		if(env.temperature > 0)
			var/transfer_moles = 0.1 * pressure_delta*air_contents.volume/(env.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			air_contents.merge(removed)


		// if full enough, switch to ready mode
		if(air_contents.return_pressure() >= SEND_PRESSURE)
			mode = 2
			update()
		return

	// perform a flush
	proc/flush()

		flushing = 1
		flick("[icon_state]-flush", src)

		var/wrapcheck = 0
		var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
											// travels through the pipes.
		for(var/obj/item/smallDelivery/O in src)
			wrapcheck = 1

		if(wrapcheck == 1)
			H.tomail = 1

		H.init(src)	// copy the contents of disposer to holder

		air_contents = new()		// new empty gas resv.

		sleep(10)
		if(last_sound < world.time + 1)
			playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
			last_sound = world.time
		sleep(5) // wait for animation to finish


		H.start(src) // start the holder processing movement
		flushing = 0
		// now reset disposal state
		flush = 0
		if(mode == 2)	// if was ready,
			mode = 1	// switch to charging
		update()
		return


	// called when area power changes
	power_change()
		..()	// do default setting/reset of stat NOPOWER bit
		update()	// update icon
		return


	// called when holder is expelled from a disposal
	// should usually only occur if the pipe network is modified
	proc/expel(var/obj/structure/disposalholder/H)

		var/turf/target
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		if(H) // Somehow, someone managed to flush a window which broke mid-transit and caused the disposal to go in an infinite loop trying to expel null, hopefully this fixes it
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

				AM.loc = src.loc
				AM.pipe_eject(0)
				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)

			H.vent_gas(loc)
			del(H)

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if (istype(mover,/obj/item) && mover.throwing)
			var/obj/item/I = mover
			if(istype(I, /obj/item/weapon/dummy) || istype(I, /obj/item/projectile))
				return
			if(prob(75))
				I.loc = src
				for(var/mob/M in viewers(src))
					M.show_message("\the [I] lands in \the [src].", 3)
			else
				for(var/mob/M in viewers(src))
					M.show_message("\the [I] bounces off of \the [src]'s rim!.", 3)
			return 0
		else
			return ..(mover, target, height, air_group)

// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/structure/disposalholder
	invisibility = 101
	var/datum/gas_mixture/gas = null	// gas used to flush, will appear at exit point
	var/active = 0	// true if the holder is moving, otherwise inactive
	dir = 0
	var/count = 1000	//*** can travel 1000 steps before going inactive (in case of loops)
	var/has_fat_guy = 0	// true if contains a fat person
	var/destinationTag = 0 // changes if contains a delivery container
	var/tomail = 0 //changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob


	// initialize a holder from the contents of a disposal unit
	proc/init(var/obj/machinery/disposal/D)
		gas = D.air_contents// transfer gas resv. into holder object

		//Check for any living mobs trigger hasmob.
		//hasmob effects whether the package goes to cargo or its tagged destination.
		for(var/mob/living/M in D)
			if(M && M.stat != 2)
				hasmob = 1

		//Checks 1 contents level deep. This means that players can be sent through disposals...
		//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
		for(var/obj/O in D)
			if(O.contents)
				for(var/mob/living/M in O.contents)
					if(M && M.stat != 2)
						hasmob = 1

		// now everything inside the disposal gets put into the holder
		// note AM since can contain mobs or objs
		for(var/atom/movable/AM in D)
			AM.loc = src
			if(istype(AM, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = AM
				if(FAT in H.mutations)		// is a human and fat?
					has_fat_guy = 1			// set flag on holder
			if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
				var/obj/structure/bigDelivery/T = AM
				src.destinationTag = T.sortTag
			if(istype(AM, /obj/item/smallDelivery) && !hasmob)
				var/obj/item/smallDelivery/T = AM
				src.destinationTag = T.sortTag


	// start the movement process
	// argument is the disposal unit the holder started in
	proc/start(var/obj/machinery/disposal/D)
		if(!D.trunk)
			D.expel(src)	// no trunk connected, so expel immediately
			return

		loc = D.trunk
		active = 1
		dir = DOWN
		spawn(1)
			move()		// spawn off the movement process

		return

	// movement process, persists while holder is moving through pipes
	proc/move()
		var/obj/structure/disposalpipe/last
		while(active)
			if(has_fat_guy && prob(2)) // chance of becoming stuck per segment if contains a fat guy
				active = 0
				// find the fat guys
				for(var/mob/living/carbon/human/H in src)

				break
			sleep(1)		// was 1
			var/obj/structure/disposalpipe/curr = loc
			last = curr
			curr = curr.transfer(src)
			if(!curr)
				last.expel(src, loc, dir)

			//
			if(!(count--))
				active = 0
		return



	// find the turf which should contain the next pipe
	proc/nextloc()
		return get_step(loc,dir)

	// find a matching pipe on a turf
	proc/findpipe(var/turf/T)

		if(!T)
			return null

		var/fdir = turn(dir, 180)	// flip the movement direction
		for(var/obj/structure/disposalpipe/P in T)
			if(fdir & P.dpdir)		// find pipe direction mask that matches flipped dir
				return P
		// if no matching pipe, return null
		return null

	// merge two holder objects
	// used when a a holder meets a stuck holder
	proc/merge(var/obj/structure/disposalholder/other)
		for(var/atom/movable/AM in other)
			AM.loc = src		// move everything in other holder to this one
			if(ismob(AM))
				var/mob/M = AM
				if(M.client)	// if a client mob, update eye to follow this holder
					M.client.eye = src

		if(other.has_fat_guy)
			has_fat_guy = 1
		del(other)


	// called when player tries to move while in a pipe
	relaymove(mob/user as mob)
		if (user.stat)
			return
		if (src.loc)
			for (var/mob/M in hearers(src.loc.loc))
				M << "<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>"

		playsound(src.loc, 'sound/effects/clang.ogg', 50, 0, 0)

	// called to vent all gas in holder to a location
	proc/vent_gas(var/atom/location)
		location.assume_air(gas)  // vent all gas to turf
		return

// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0

	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	layer = 2.3			// slightly lower than wires and other pipes
	var/base_icon_state	// initial icon state on map

	// new pipe, set the icon_state as on map
	New()
		..()
		base_icon_state = icon_state
		return


	// pipe is deleted
	// ensure if holder is present, it is expelled
	Del()
		var/obj/structure/disposalholder/H = locate() in src
		if(H)
			// holder was present
			H.active = 0
			var/turf/T = src.loc
			if(T.density)
				// deleting pipe is inside a dense turf (wall)
				// this is unlikely, but just dump out everything into the turf in case

				for(var/atom/movable/AM in H)
					AM.loc = T
					AM.pipe_eject(0)
				del(H)
				..()
				return

			// otherwise, do normal expel from turf
			if(H)
				expel(H, T, 0)
		..()

	// returns the direction of the next pipe object, given the entrance dir
	// by default, returns the bitmask of remaining directions
	proc/nextdir(var/fromdir)
		return dpdir & (~turn(fromdir, 180))

	// transfer the holder through this pipe segment
	// overriden for special behaviour
	//
	proc/transfer(var/obj/structure/disposalholder/H)
		var/nextdir = nextdir(H.dir)
		H.dir = nextdir
		var/turf/T = H.nextloc()
		var/obj/structure/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/structure/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.loc = P
		else			// if wasn't a pipe, then set loc to turf
			H.loc = T
			return null

		return P


	// update the icon_state to reflect hidden status
	proc/update()
		var/turf/T = src.loc
		hide(T.intact && !istype(T,/turf/space))	// space never hides pipes

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = intact ? 101: 0	// hide if floor is intact
		updateicon()

	// update actual icon_state depending on visibility
	// if invisible, append "f" to icon_state to show faded version
	// this will be revealed if a T-scanner is used
	// if visible, use regular icon_state
	proc/updateicon()
		if(invisibility)
			icon_state = "[base_icon_state]f"
		else
			icon_state = base_icon_state
		return


	// expel the held objects into a turf
	// called when there is a break in the pipe
	//

	proc/expel(var/obj/structure/disposalholder/H, var/turf/T, var/direction)

		var/turf/target

		if(T.density)		// dense ouput turf, so stop holder
			H.active = 0
			H.loc = src
			return
		if(T.intact && istype(T,/turf/simulated/floor)) //intact floor, pop the tile
			var/turf/simulated/floor/F = T
			//F.health	= 100
			F.burnt	= 1
			F.intact	= 0
			F.levelupdate()
			new /obj/item/stack/tile(H)	// add to holder so it will be thrown with other stuff
			F.icon_state = "Floor[F.burnt ? "1" : ""]"

		if(direction)		// direction is specified
			if(istype(T, /turf/space)) // if ended in space, then range is unlimited
				target = get_edge_target_turf(T, direction)
			else						// otherwise limit to 10 tiles
				target = get_ranged_target_turf(T, direction, 10)

			playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
			if(H)
				for(var/atom/movable/AM in H)
					AM.loc = T
					AM.pipe_eject(direction)
					spawn(1)
						if(AM)
							AM.throw_at(target, 100, 1)
				H.vent_gas(T)
				del(H)

		else	// no specified direction, so throw in random direction

			playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
			if(H)
				for(var/atom/movable/AM in H)
					target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

					AM.loc = T
					AM.pipe_eject(0)
					spawn(1)
						if(AM)
							AM.throw_at(target, 5, 1)

				H.vent_gas(T)	// all gas vent to turf
				del(H)

		return

	// call to break the pipe
	// will expel any holder inside at the time
	// then delete the pipe
	// remains : set to leave broken pipe pieces in place
	proc/broken(var/remains = 0)
		if(remains)
			for(var/D in cardinal)
				if(D & dpdir)
					var/obj/structure/disposalpipe/broken/P = new(src.loc)
					P.dir = D

		src.invisibility = 101	// make invisible (since we won't delete the pipe immediately)
		var/obj/structure/disposalholder/H = locate() in src
		if(H)
			// holder was present
			H.active = 0
			var/turf/T = src.loc
			if(T.density)
				// broken pipe is inside a dense turf (wall)
				// this is unlikely, but just dump out everything into the turf in case

				for(var/atom/movable/AM in H)
					AM.loc = T
					AM.pipe_eject(0)
				del(H)
				return

			// otherwise, do normal expel from turf
			if(H)
				expel(H, T, 0)

		spawn(2)	// delete pipe after 2 ticks to ensure expel proc finished
			del(src)


	// pipe affected by explosion
	ex_act(severity)

		switch(severity)
			if(1.0)
				broken(0)
				return
			if(2.0)
				health -= rand(5,15)
				healthcheck()
				return
			if(3.0)
				health -= rand(0,15)
				healthcheck()
				return


	// test health for brokenness
	proc/healthcheck()
		if(health < -2)
			broken(0)
		else if(health<1)
			broken(1)
		return

	//attack by item
	//weldingtool: unfasten and convert to obj/disposalconstruct

	attackby(var/obj/item/I, var/mob/user)

		var/turf/T = src.loc
		if(T.intact)
			return		// prevent interaction with T-scanner revealed pipes
		src.add_fingerprint(user)
		if(istype(I, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/W = I

			if(W.remove_fuel(0,user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
				// check if anything changed over 2 seconds
				var/turf/uloc = user.loc
				var/atom/wloc = W.loc
				user << "Slicing the disposal pipe."
				sleep(30)
				if(!W.isOn()) return
				if(user.loc == uloc && wloc == W.loc)
					welded()
				else
					user << "You must stay still while welding the pipe."
			else
				user << "You need more welding fuel to cut the pipe."
				return

	// called when pipe is cut with welder
	proc/welded()

		var/obj/structure/disposalconstruct/C = new (src.loc)
		switch(base_icon_state)
			if("pipe-s")
				C.ptype = 0
			if("pipe-c")
				C.ptype = 1
			if("pipe-j1")
				C.ptype = 2
			if("pipe-j2")
				C.ptype = 3
			if("pipe-y")
				C.ptype = 4
			if("pipe-t")
				C.ptype = 5
		src.transfer_fingerprints_to(C)
		C.dir = dir
		C.density = 0
		C.anchored = 1
		C.update()

		del(src)

// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = 0

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

	New()
		..()
		if(icon_state == "pipe-s")
			dpdir = dir | turn(dir, 180)
		else
			dpdir = dir | turn(dir, -90)

		update()
		return




//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

	New()
		..()
		if(icon_state == "pipe-j1")
			dpdir = dir | turn(dir, -90) | turn(dir,180)
		else if(icon_state == "pipe-j2")
			dpdir = dir | turn(dir, 90) | turn(dir,180)
		else // pipe-y
			dpdir = dir | turn(dir,90) | turn(dir, -90)
		update()
		return


	// next direction to move
	// if coming in from secondary dirs, then next is primary dir
	// if coming in from primary dir, then next is equal chance of other dirs

	nextdir(var/fromdir)
		var/flipdir = turn(fromdir, 180)
		if(flipdir != dir)	// came from secondary dir
			return dir		// so exit through primary
		else				// came from primary
							// so need to choose either secondary exit
			var/mask = ..(fromdir)

			// find a bit which is set
			var/setbit = 0
			if(mask & NORTH)
				setbit = NORTH
			else if(mask & SOUTH)
				setbit = SOUTH
			else if(mask & EAST)
				setbit = EAST
			else
				setbit = WEST

			if(prob(50))	// 50% chance to choose the found bit or the other one
				return setbit
			else
				return mask & (~setbit)

//a three-way junction that sorts objects
/obj/structure/disposalpipe/sortjunction

	desc = "An underfloor disposal pipe with a package sorting mechanism."
	icon_state = "pipe-j1s"
	var/sortType = 0
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

	New()
		..()
		posdir = dir
		if(icon_state == "pipe-j1s")
			sortdir = turn(posdir, -90)
			negdir = turn(posdir, 180)
		else
			icon_state = "pipe-j2s"
			sortdir = turn(posdir, 90)
			negdir = turn(posdir, 180)
		dpdir = sortdir | posdir | negdir

		update()
		return


	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

	nextdir(var/fromdir, var/sortTag)
		//var/flipdir = turn(fromdir, 180)
		if(fromdir != sortdir)	// probably came from the negdir

			if(src.sortType == sortTag) //if destination matches filtered type...
				return sortdir		// exit through sortdirection
			else
				return posdir
		else				// came from sortdir
							// so go with the flow to positive direction
			return posdir

	transfer(var/obj/structure/disposalholder/H)
		var/nextdir = nextdir(H.dir, H.destinationTag)
		H.dir = nextdir
		var/turf/T = H.nextloc()
		var/obj/structure/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/structure/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.loc = P
		else			// if wasn't a pipe, then set loc to turf
			H.loc = T
			return null

		return P


//a three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction

	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

	New()
		..()
		posdir = dir
		if(icon_state == "pipe-j1s")
			sortdir = turn(posdir, -90)
			negdir = turn(posdir, 180)
		else
			icon_state = "pipe-j2s"
			sortdir = turn(posdir, 90)
			negdir = turn(posdir, 180)
		dpdir = sortdir | posdir | negdir

		update()
		return


	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

	nextdir(var/fromdir, var/istomail)
		//var/flipdir = turn(fromdir, 180)
		if(fromdir != sortdir)	// probably came from the negdir

			if(istomail) //if destination matches filtered type...
				return sortdir		// exit through sortdirection
			else
				return posdir
		else				// came from sortdir
							// so go with the flow to positive direction
			return posdir

	transfer(var/obj/structure/disposalholder/H)
		var/nextdir = nextdir(H.dir, H.tomail)
		H.dir = nextdir
		var/turf/T = H.nextloc()
		var/obj/structure/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/structure/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.loc = P
		else			// if wasn't a pipe, then set loc to turf
			H.loc = T
			return null

		return P





//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/New()
	..()
	dpdir = dir
	spawn(1)
		getlinked()

	update()
	return

/obj/structure/disposalpipe/trunk/proc/getlinked()
	linked = null
	var/obj/machinery/disposal/D = locate() in src.loc
	if(D)
		linked = D
		if (!D.trunk)
			D.trunk = src

	var/obj/structure/disposaloutlet/O = locate() in src.loc
	if(O)
		linked = O

	update()
	return

	// Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(var/obj/item/I, var/mob/user)

	//Disposal bins or chutes
	/*
	These shouldn't be required
	var/obj/machinery/disposal/D = locate() in src.loc
	if(D && D.anchored)
		return

	//Disposal outlet
	var/obj/structure/disposaloutlet/O = locate() in src.loc
	if(O && O.anchored)
		return
	*/

	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in src.loc
	if(C && C.anchored)
		return

	var/turf/T = src.loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes
	src.add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if(W.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
			// check if anything changed over 2 seconds
			var/turf/uloc = user.loc
			var/atom/wloc = W.loc
			user << "Slicing the disposal pipe."
			sleep(30)
			if(!W.isOn()) return
			if(user.loc == uloc && wloc == W.loc)
				welded()
			else
				user << "You must stay still while welding the pipe."
		else
			user << "You need more welding fuel to cut the pipe."
			return

	// would transfer to next pipe segment, but we are in a trunk
	// if not entering from disposal bin,
	// transfer to linked object (outlet or bin)

/obj/structure/disposalpipe/trunk/transfer(var/obj/structure/disposalholder/H)

	if(H.dir == DOWN)		// we just entered from a disposer
		return ..()		// so do base transfer proc
	// otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O) && (H))
			O.expel(H)	// expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			if(H)
				D.expel(H)	// expel at disposal
	else
		if(H)
			src.expel(H, src.loc, 0)	// expel at turf
	return null

	// nextdir

/obj/structure/disposalpipe/trunk/nextdir(var/fromdir)
	if(fromdir == DOWN)
		return dir
	else
		return 0

// a broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

	New()
		..()
		update()
		return

	// called when welded
	// for broken pipe, remove and turn into scrap

	welded()
//		var/obj/item/scrap/S = new(src.loc)
//		S.set_components(200,0,0)
		del(src)

// the disposal outlet machine

/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "outlet"
	density = 1
	anchored = 1
	var/active = 0
	var/turf/target	// this will be where the output objects are 'thrown' to.
	var/mode = 0

	New()
		..()

		spawn(1)
			target = get_ranged_target_turf(src, dir, 10)


			var/obj/structure/disposalpipe/trunk/trunk = locate() in src.loc
			if(trunk)
				trunk.linked = src	// link the pipe trunk to self

	// expel the contents of the holder object, then delete it
	// called when the holder exits the outlet
	proc/expel(var/obj/structure/disposalholder/H)

		flick("outlet-open", src)
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, 0)
		sleep(20)	//wait until correct animation frame
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)

		if(H)
			for(var/atom/movable/AM in H)
				AM.loc = src.loc
				AM.pipe_eject(dir)
				spawn(5)
					AM.throw_at(target, 3, 1)
			H.vent_gas(src.loc)
			del(H)

		return

	attackby(var/obj/item/I, var/mob/user)
		if(!I || !user)
			return
		src.add_fingerprint(user)
		if(istype(I, /obj/item/weapon/screwdriver))
			if(mode==0)
				mode=1
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "You remove the screws around the power connection."
				return
			else if(mode==1)
				mode=0
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "You attach the screws around the power connection."
				return
		else if(istype(I,/obj/item/weapon/weldingtool) && mode==1)
			var/obj/item/weapon/weldingtool/W = I
			if(W.remove_fuel(0,user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
				user << "You start slicing the floorweld off the disposal outlet."
				if(do_after(user,20))
					if(!src || !W.isOn()) return
					user << "You sliced the floorweld off the disposal outlet."
					var/obj/structure/disposalconstruct/C = new (src.loc)
					src.transfer_fingerprints_to(C)
					C.ptype = 7 // 7 =  outlet
					C.update()
					C.anchored = 1
					C.density = 1
					del(src)
				return
			else
				user << "You need more welding fuel to complete this task."
				return



// called when movable is expelled from a disposal pipe or outlet
// by default does nothing, override for special behaviour

/atom/movable/proc/pipe_eject(var/direction)
	return

// check if mob has client, if so restore client view on eject
/mob/pipe_eject(var/direction)
	if (src.client)
		src.client.perspective = MOB_PERSPECTIVE
		src.client.eye = src

	return

/obj/effect/decal/cleanable/blood/gibs/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)

/obj/effect/decal/cleanable/robot_debris/gib/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)
