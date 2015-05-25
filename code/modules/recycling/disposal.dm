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
	var/obj/structure/disposalconstruct/stored
	// create a new disposal
	// find the attached trunk (if present) and init gas resvr.
/obj/machinery/disposal/New(loc, var/obj/structure/disposalconstruct/make_from)
	..()

	if(make_from)
		dir = make_from.dir
		make_from.loc = 0
		stored = make_from
	else
		stored = new /obj/structure/disposalconstruct(0,DISP_END_BIN,dir)

	trunk_check()

	air_contents = new/datum/gas_mixture()
	//gas.volume = 1.05 * CELLSTANDARD
	update()

/obj/machinery/disposal/proc/trunk_check()
	trunk = locate() in src.loc
	if(!trunk)
		mode = 0
		flush = 0
	else
		mode = initial(mode)
		flush = initial(flush)
		trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/Destroy()
	eject()
	if(trunk)
		trunk.linked = null
	..()

/obj/machinery/disposal/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		Deconstruct()

/obj/machinery/disposal/initialize()
	// this will get a copy of the air turf and take a SEND PRESSURE amount of air from it
	var/atom/L = loc
	var/datum/gas_mixture/env = new
	env.copy_from(L.return_air())
	var/datum/gas_mixture/removed = env.remove(SEND_PRESSURE + 1)
	air_contents.merge(removed)
	trunk_check()

	// attack by item places it in to disposal
/obj/machinery/disposal/attackby(var/obj/item/I, var/mob/user, params)
	if(stat & BROKEN || !I || !user)
		return

	src.add_fingerprint(user)
	if(mode<=0) // It's off
		if(istype(I, /obj/item/weapon/screwdriver))
			if(contents.len > 0)
				user << "<span class='notice'>Eject the items first!</span>"
				return
			if(mode==0) // It's off but still not unscrewed
				mode=-1 // Set it to doubleoff l0l
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You remove the screws around the power connection.</span>"
				return
			else if(mode==-1)
				mode=0
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You attach the screws around the power connection.</span>"
				return
		else if(istype(I,/obj/item/weapon/weldingtool) && mode==-1)
			if(contents.len > 0)
				user << "<span class='notice'>Eject the items first!</span>"
				return
			var/obj/item/weapon/weldingtool/W = I
			if(W.remove_fuel(0,user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
				user << "<span class='notice'>You start slicing the floorweld off \the [src]...</span>"

				if(do_after(user,20))
					if(!src || !W.isOn()) return
					user << "<span class='notice'>You slice the floorweld off \the [src].</span>"
					Deconstruct()
				return
			else
				return

	if(istype(I, /obj/item/weapon/storage/bag/trash))
		var/obj/item/weapon/storage/bag/trash/T = I
		user << "<span class='warning'> You empty the bag.</span>"
		for(var/obj/item/O in T.contents)
			T.remove_from_storage(O,src)
		T.update_icon()
		update()
		return

	var/obj/item/weapon/grab/G = I
	if(istype(G))	// handle grabbed mob
		if(ismob(G.affecting))
			stuff_mob_in(G.affecting, user)
		return

	if(!I || I.flags & NODROP)	return

	user.drop_item()
	I.loc = src
	user.visible_message("[user.name] places \the [I] into \the [src].", \
						"<span class='notice'>You place \the [I] into \the [src].</span>")

	update()

// mouse drop another mob or self
//
/obj/machinery/disposal/MouseDrop_T(mob/living/target, mob/living/user)
	if(istype(target) && user == target)
		stuff_mob_in(target, user)

/obj/machinery/disposal/proc/stuff_mob_in(mob/living/target, mob/living/user)
	if(!iscarbon(user) && !user.ventcrawler) //only carbon and ventcrawlers can climb into disposal by themselves.
		return
	if(target.mob_size > MOB_SIZE_HUMAN)
		user << "<span class='warning'>[target] doesn't fit inside [src]!</span>"
		return
	src.add_fingerprint(user)
	if(user == target)
		user.visible_message("[user] starts climbing into [src].", \
								"<span class='notice'>You start climbing into [src]...</span>")
	else
		target.visible_message("<span class='danger'>[user] starts putting [target] into [src].</span>", \
								"<span class='userdanger'>[user] starts putting you into [src]!</span>")
	if(do_mob(user, target, 20))
		if (target.client)
			target.client.perspective = EYE_PERSPECTIVE
			target.client.eye = src
		target.loc = src
		if(user == target)
			user.visible_message("[user] climbs into [src].", \
									"<span class='notice'>You climb into [src].</span>")
		else
			target.visible_message("<span class='danger'>[user] has placed [target] in [src].</span>", \
									"<span class='userdanger'>[user] has placed [target] in [src].</span>")
			add_logs(user, target, "stuffed", addition="into [src]")
		update()

// can breath normally in the disposal
/obj/machinery/disposal/alter_health()
	return get_turf(src)

/obj/machinery/disposal/relaymove(mob/user as mob)
	attempt_escape(user)

// resist to escape the bin
/obj/machinery/disposal/container_resist()
	attempt_escape(usr)

/obj/machinery/disposal/proc/attempt_escape(mob/user as mob)
	if(src.flushing)
		return
	go_out(user)
	return

// leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)

	if (user.client)
		user.client.eye = user.client.mob
		user.client.perspective = MOB_PERSPECTIVE
	user.loc = src.loc
	update()
	return


// monkeys and xenos can only pull the flush lever
/obj/machinery/disposal/attack_paw(mob/user as mob)
	if(stat & BROKEN)
		return
	flush = !flush
	update()

// ai as human but can't flush
/obj/machinery/disposal/attack_ai(mob/user as mob)
	interact(user, 1)

// human interact with machine
/obj/machinery/disposal/attack_hand(mob/user as mob)
	if(user && user.loc == src)
		usr << "<span class='warning'>You cannot reach the controls from inside!</span>"
		return
	/*
	if(mode==-1)
		usr << "\red The disposal units power is disabled."
		return
	*/
	interact(user, 0)

// hostile mob escape from disposals
/obj/machinery/disposal/attack_animal(var/mob/living/simple_animal/M)
	if(M.environment_smash)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashes \the [src] apart!</span>")
		qdel(src)
	return

// user interaction
/obj/machinery/disposal/interact(mob/user, var/ai=0)

	src.add_fingerprint(user)
	if(stat & BROKEN)
		user.unset_machine()
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

	var/per = Clamp(100* air_contents.return_pressure() / (SEND_PRESSURE), 0, 100)

	dat += "Pressure: [round(per, 1)]%<BR></body>"


	user.set_machine(src)
	user << browse(dat, "window=disposal;size=360x170")
	onclose(user, "disposal")

// handle machine interaction

/obj/machinery/disposal/Topic(href, href_list)
	if(..())
		return
	if(usr.loc == src)
		usr << "<span class='warning'>You cannot reach the controls from inside!</span>"
		return

	if(mode==-1 && !href_list["eject"]) // only allow ejecting if mode is -1
		usr << "<span class='danger'>\The [src]'s power is disabled.</span>"
		return
	..()
	usr.set_machine(src)

	if(href_list["close"])
		usr.unset_machine()
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
	return

// eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.loc = src.loc
		AM.pipe_eject(0)
	update()

// update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	overlays.Cut()
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
/obj/machinery/disposal/process()
	if(stat & BROKEN)			// nothing can happen if broken
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
		air_update_turf()


	// if full enough, switch to ready mode
	if(air_contents.return_pressure() >= SEND_PRESSURE)
		mode = 2
		update()
	return

// perform a flush
/obj/machinery/disposal/proc/flush()

	flushing = 1
	flick("[icon_state]-flush", src)

	var/wrapcheck = 0
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
										// travels through the pipes.
	for(var/obj/item/smallDelivery/O in src)
		wrapcheck = 1

	if(wrapcheck == 1)
		H.tomail = 1

	sleep(10)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		last_sound = world.time
	sleep(5) // wait for animation to finish

	H.init(src)	// copy the contents of disposer to holder
	air_contents = new()		// new empty gas resv.

	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update()
	return


// called when area power changes
/obj/machinery/disposal/power_change()
	..()	// do default setting/reset of stat NOPOWER bit
	update()	// update icon
	return


// called when holder is expelled from a disposal
// should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(var/obj/structure/disposalholder/H)

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
		qdel(H)

/obj/machinery/disposal/CanPass(atom/movable/mover, turf/target, height=0)
	if (istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(75))
			I.loc = src
			visible_message("<span class='notice'>\the [I] lands in \the [src].</span>")
			update()
		else
			visible_message("<span class='notice'>\the [I] bounces off of \the [src]'s rim!</span>")
		return 0
	else
		return ..(mover, target, height)

/obj/machinery/disposal/Deconstruct()
	if(stored)
		var/turf/T = loc
		stored.loc = T
		src.transfer_fingerprints_to(stored)
		stored.anchored = 0
		stored.density = 1
		stored.update()
	..()
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
	var/destinationTag = 0 // changes if contains a delivery container
	var/tomail = 0 //changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob

/obj/structure/disposalholder/Destroy()
	qdel(gas)
	active = 0
	..()

	// initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(var/obj/machinery/disposal/D)
	gas = D.air_contents// transfer gas resv. into holder object

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	for(var/mob/living/M in D)
		if(M && M.stat != DEAD)
			hasmob = 1

	//Checks 1 contents level deep. This means that players can be sent through disposals...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/obj/O in D)
		if(O.contents)
			for(var/mob/living/M in O.contents)
				if(M && M.stat != DEAD)
					hasmob = 1

	// now everything inside the disposal gets put into the holder
	// note AM since can contain mobs or objs
	for(var/atom/movable/AM in D)
		AM.loc = src
		if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
			var/obj/structure/bigDelivery/T = AM
			src.destinationTag = T.sortTag
		if(istype(AM, /obj/item/smallDelivery) && !hasmob)
			var/obj/item/smallDelivery/T = AM
			src.destinationTag = T.sortTag


// start the movement process
// argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(var/obj/machinery/disposal/D)
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
/obj/structure/disposalholder/proc/move()
	var/obj/structure/disposalpipe/last
	while(active)
		var/obj/structure/disposalpipe/curr = loc
		last = curr
		curr = curr.transfer(src)
		if(!curr && active)
			last.expel(src, loc, dir)

		sleep(1)
		if(!(count--))
			active = 0
	return



// find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(loc,dir)

// find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(var/turf/T)

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
/obj/structure/disposalholder/proc/merge(var/obj/structure/disposalholder/other)
	for(var/atom/movable/AM in other)
		AM.loc = src		// move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)	// if a client mob, update eye to follow this holder
				M.client.eye = src
	qdel(other)


// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user as mob)
	if (user.stat)
		return
	if (src.loc)
		for (var/mob/M in get_hearers_in_view(src.loc.loc))
			M.show_message("<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>", 2)
	playsound(src.loc, 'sound/effects/clang.ogg', 50, 0, 0)

// called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(var/atom/location)
	if(location)
		location.assume_air(gas)  // vent all gas to turf
	air_update_turf()
	return

/obj/structure/disposalholder/allow_drop()
	return 0

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
	var/obj/structure/disposalconstruct/stored

	// new pipe, set the icon_state as on map
/obj/structure/disposalpipe/New(loc,var/obj/structure/disposalconstruct/make_from)
	..()

	if(make_from && !make_from.gc_destroyed)
		base_icon_state = make_from.base_state
		dir = make_from.dir
		dpdir = make_from.dpdir
		make_from.loc = src
		stored = make_from
	else
		base_icon_state = icon_state
		stored = new /obj/structure/disposalconstruct(src,direction=dir)
		switch(base_icon_state)
			if("pipe-s")
				stored.ptype = DISP_PIPE_STRAIGHT
			if("pipe-c")
				stored.ptype = DISP_PIPE_BENT
			if("pipe-j1")
				stored.ptype = DISP_JUNCTION
			if("pipe-j2")
				stored.ptype = DISP_JUNCTION_FLIP
			if("pipe-y")
				stored.ptype = DISP_YJUNCTION
			if("pipe-t")
				stored.ptype = DISP_END_TRUNK
			if("pipe-j1s")
				stored.ptype = DISP_SORTJUNCTION
			if("pipe-j2s")
				stored.ptype = DISP_SORTJUNCTION_FLIP
	return


	// pipe is deleted
	// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
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
			qdel(H)
			..()
			return

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)
	..()

// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(var/fromdir)
	return dpdir & (~turn(fromdir, 180))

// transfer the holder through this pipe segment
// overriden for special behaviour
//
/obj/structure/disposalpipe/proc/transfer(var/obj/structure/disposalholder/H)
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
/obj/structure/disposalpipe/proc/update()
	var/turf/T = src.loc
	hide(T.intact && !istype(T,/turf/space))	// space never hides pipes

// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalpipe/hide(var/intact)
	invisibility = intact ? 101: 0	// hide if floor is intact
	updateicon()

// update actual icon_state depending on visibility
// if invisible, append "f" to icon_state to show faded version
// this will be revealed if a T-scanner is used
// if visible, use regular icon_state
/obj/structure/disposalpipe/proc/updateicon()
	if(invisibility)
		icon_state = "[base_icon_state]f"
	else
		icon_state = base_icon_state
	return


// expel the held objects into a turf
// called when there is a break in the pipe
//

/obj/structure/disposalpipe/proc/expel(var/obj/structure/disposalholder/H, var/turf/T, var/direction)

	var/turf/target

	if(istype(T, /turf/simulated/floor)) //intact floor, pop the tile
		var/turf/simulated/floor/myturf = T
		if(myturf.builtin_tile)
			myturf.builtin_tile.loc = T
			myturf.builtin_tile = null
		myturf.make_plating()

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
	H.vent_gas(T)
	qdel(H)
	return

// call to break the pipe
// will expel any holder inside at the time
// then delete the pipe
// remains : set to leave broken pipe pieces in place
/obj/structure/disposalpipe/proc/broken(var/remains = 0)
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
			qdel(H)
			return

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)

	spawn(2)	// delete pipe after 2 ticks to ensure expel proc finished
		qdel(src)


// pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity, target)

	//pass on ex_act to our contents before calling it on ourself
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		H.contents_explosion(severity, target)

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
/obj/structure/disposalpipe/proc/healthcheck()
	if(health < -2)
		broken(0)
	else if(health<1)
		broken(1)
	return

//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct

/obj/structure/disposalpipe/attackby(var/obj/item/I, var/mob/user, params)

	var/turf/T = src.loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes
	src.add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if(W.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
			user << "<span class='notice'>You start slicing the disposal pipe...</span>"
			// check if anything changed over 2 seconds
			if(do_after(user,30))
				if(!src || !W.isOn()) return
				Deconstruct()
				user << "<span class='notice'>You slice the disposal pipe.</span>"
		else
			return

// called when pipe is cut with welder
/obj/structure/disposalpipe/Deconstruct()
	if(stored)
		var/turf/T = loc
		stored.loc = T
		transfer_fingerprints_to(stored)
		stored.dir = dir
		stored.density = 0
		stored.anchored = 1
		stored.update()
		..()

/obj/structure/disposalpipe/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		Deconstruct()

// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = 0

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/New()
	..()
	if(stored.ptype == DISP_PIPE_STRAIGHT)
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)

	update()
	return




//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/New()
	..()
	switch(stored.ptype)
		if(DISP_JUNCTION)
			dpdir = dir | turn(dir, -90) | turn(dir,180)
		if(DISP_JUNCTION_FLIP)
			dpdir = dir | turn(dir, 90) | turn(dir,180)
		if(DISP_YJUNCTION)
			dpdir = dir | turn(dir,90) | turn(dir, -90)
	update()
	return


// next direction to move
// if coming in from secondary dirs, then next is primary dir
// if coming in from primary dir, then next is equal chance of other dirs

/obj/structure/disposalpipe/junction/nextdir(var/fromdir)
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

	icon_state = "pipe-j1s"
	var/sortType = 0	//Look at the list called TAGGERLOCATIONS in setup.dm
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/sortjunction/proc/updatedesc()
	desc = "An underfloor disposal pipe with a package sorting mechanism."
	if(sortType>0)
		var/tag = uppertext(TAGGERLOCATIONS[sortType])
		desc += "\nIt's tagged with [tag]"

/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(stored.ptype == DISP_SORTJUNCTION)
		sortdir = turn(posdir, -90)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)

	dpdir = sortdir | posdir | negdir

/obj/structure/disposalpipe/sortjunction/New()
	..()
	updatedir()
	updatedesc()
	update()
	return

/obj/structure/disposalpipe/sortjunction/attackby(var/obj/item/I, var/mob/user, params)
	if(..())
		return

	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I

		if(O.currTag > 0)// Tag set
			sortType = O.currTag
			playsound(src.loc, 'sound/machines/twobeep.ogg', 100, 1)
			var/tag = uppertext(TAGGERLOCATIONS[O.currTag])
			user << "<span class='warning'> Changed filter to [tag].</span>"
			updatedesc()


// next direction to move
// if coming in from negdir, then next is primary dir or sortdir
// if coming in from posdir, then flip around and go back to posdir
// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(var/fromdir, var/sortTag)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(src.sortType == sortTag) //if destination matches filtered type...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(var/obj/structure/disposalholder/H)
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

/obj/structure/disposalpipe/wrapsortjunction/New()
	..()
	posdir = dir
	if(stored.ptype == DISP_SORTJUNCTION)
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

/obj/structure/disposalpipe/wrapsortjunction/nextdir(var/fromdir, var/istomail)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(istomail) //if destination matches filtered type...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/wrapsortjunction/transfer(var/obj/structure/disposalholder/H)
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
/obj/structure/disposalpipe/trunk/attackby(var/obj/item/I, var/mob/user, params)

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

		if(linked)
			user << "<span class='warning'>You need to deconstruct disposal machinery above this pipe!</span>"
			return

		if(W.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
			user << "<span class='notice'>You start slicing the disposal pipe...</span>"
			if(do_after(user,30))
				if(!src || !W.isOn()) return
				Deconstruct()
				user << "<span class='notice'>You slice the disposal pipe.</span>"
		else
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

/obj/structure/disposalpipe/broken/New()
	..()
	update()
	return

// the disposal outlet machine

/obj/structure/disposalpipe/broken/Deconstruct()
	qdel(src)

/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "outlet"
	density = 1
	anchored = 1
	var/active = 0
	var/turf/target	// this will be where the output objects are 'thrown' to.
	var/obj/structure/disposalpipe/trunk/trunk = null // the attached pipe trunk
	var/obj/structure/disposalconstruct/stored
	var/mode = 0
	var/start_eject = 0
	var/eject_range = 2

/obj/structure/disposaloutlet/New(loc, var/obj/structure/disposalconstruct/make_from)
	..()

	if(make_from)
		dir = make_from.dir
		make_from.loc = src
		stored = make_from
	else
		stored = new (src, DISP_END_OUTLET,dir)

	spawn(1)
		target = get_ranged_target_turf(src, dir, 10)

		trunk = locate() in src.loc
		if(trunk)
			trunk.linked = src	// link the pipe trunk to self

/obj/structure/disposaloutlet/Destroy()
	if(trunk)
		trunk.linked = null
	..()

// expel the contents of the holder object, then delete it
// called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(var/obj/structure/disposalholder/H)

	flick("outlet-open", src)
	if((start_eject + 30) < world.time)
		start_eject = world.time
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, 0)
		sleep(20)
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
	else
		sleep(20)
	if(H)
		for(var/atom/movable/AM in H)
			AM.loc = src.loc
			AM.pipe_eject(dir)
			spawn(5)
				if(AM)
					AM.throw_at(target, eject_range, 1)
		H.vent_gas(src.loc)
		qdel(H)
	return

/obj/structure/disposaloutlet/attackby(var/obj/item/I, var/mob/user, params)
	if(!I || !user)
		return
	src.add_fingerprint(user)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(mode==0)
			mode=1
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class='notice'>You remove the screws around the power connection.</span>"
			return
		else if(mode==1)
			mode=0
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class='notice'>You attach the screws around the power connection.</span>"
			return
	else if(istype(I,/obj/item/weapon/weldingtool) && mode==1)
		var/obj/item/weapon/weldingtool/W = I
		if(W.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
			user << "<span class='notice'>You start slicing the floorweld off \the [src]...</span>"
			if(do_after(user,20))
				if(!src || !W.isOn()) return
				user << "<span class='notice'>You slice the floorweld off \the [src].</span>"
				stored.loc = loc
				src.transfer_fingerprints_to(stored)
				stored.update()
				stored.anchored = 0
				stored.density = 1
				qdel(src)
			return
		else
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
