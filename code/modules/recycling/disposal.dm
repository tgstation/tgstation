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

	holomap = TRUE
	auto_holomap = TRUE

// create a new disposal
// find the attached trunk (if present) and init gas resvr.
/obj/machinery/disposal/New()
	..()
	spawn(5)
		for(var/obj/structure/disposalpipe/trunk/O in loc.contents)//This is more efficient than locate()
			trunk = O

		if(trunk)
			if(trunk.disposal != src)
				trunk.disposal = src

			if(trunk.linked != trunk.disposal)
				trunk.linked = trunk.disposal
		else
			mode = 0
			flush = 0

		air_contents = new/datum/gas_mixture()
		//gas.volume = 1.05 * CELLSTANDARD
	update_icon()

/obj/machinery/disposal/Destroy()
	if(trunk)
		if(trunk.disposal)
			trunk.disposal = null
		if(trunk.linked)
			trunk.linked = null

		trunk = null

	..()

/obj/machinery/disposal/ex_act(var/severity,var/child=null)
	var/child_severity=severity
	if(!child)
		child_severity++
	if(child_severity <= 3)
		for(var/obj/O in contents)
			O.ex_act(child_severity)
	switch(severity)
		if(2 to INFINITY)
			if(prob(50))
				eject()
				if(severity==2)
					qdel(src)
		if(1)
			qdel(src)


// attack by item places it in to disposal
/obj/machinery/disposal/attackby(var/obj/item/I, var/mob/user)
	if(stat & BROKEN || !I || !user)
		return

	if(isrobot(user) && !istype(I, /obj/item/weapon/storage/bag/trash) && !istype(user,/mob/living/silicon/robot/mommi))
		return
	src.add_fingerprint(user)
	if(mode<=0) // It's off
		if(isscrewdriver(I))
			if(contents.len > 0)
				to_chat(user, "Eject the items first!")
				return
			if(mode==0) // It's off but still not unscrewed
				mode=-1 // Set it to doubleoff l0l
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "You remove the screws around the power connection.")
				return
			else if(mode==-1)
				mode=0
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "You attach the screws around the power connection.")
				return
		else if(istype(I,/obj/item/weapon/weldingtool) && mode==-1)
			if(contents.len > 0)
				to_chat(user, "Eject the items first!")
				return
			var/obj/item/weapon/weldingtool/W = I
			if(W.remove_fuel(0,user))
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 100, 1)
				to_chat(user, "You start slicing the floorweld off the disposal unit.")

				if(do_after(user, src,20))
					if(!src || !W.isOn()) return
					to_chat(user, "You sliced the floorweld off the disposal unit.")
					var/obj/structure/disposalconstruct/C = new (src.loc)
					src.transfer_fingerprints_to(C)
					C.ptype = 6 // 6 = disposal unit
					C.anchored = 1
					C.density = 1
					C.update_icon()
					qdel(src)
				return
			else
				to_chat(user, "You need more welding fuel to complete this task.")
				return

	if(istype(I, /obj/item/weapon/storage/bag/))
		var/obj/item/weapon/storage/bag/B = I
		if(B.contents.len == 0)
			if(user.drop_item(I, src))
				to_chat(user, "<span class='notice'>You throw away the empty [B].</span>")
				return
		to_chat(user, "<span class='notice'>You empty the [B].</span>")
		B.mass_remove(src)
		B.update_icon()
		update_icon()
		return

	var/obj/item/weapon/grab/G = I
	if(istype(G))	// handle grabbed mob
		if(ismob(G.affecting))
			var/mob/GM = G.affecting
			user.attack_log += "<span class='warning'> [user]([user.ckey]) has attempted to put [GM]([GM.ckey]) in disposals.</span>"
			GM.attack_log += "<span class='warning'> [user]([user.ckey]) has attempted to put [GM]([GM.ckey]) in disposals.</span>"
			user.visible_message("[usr] starts putting [GM.name] into \the [src].", "You start putting \the [GM.name] into the [src].", "You hear some clunking.")
			if(do_after(usr, src, 20))
				if (GM.client)
					GM.client.perspective = EYE_PERSPECTIVE
					GM.client.eye = src
				GM.loc = src
				user.visible_message("<span class='warning'>[GM.name] has been placed in \the [src] by [user].</span>", "<span class='warning'>[GM.name] has been placed in \the [src] by you.</span>", "<span class='warning'>You hear a loud clunk.</span>")
				qdel(G)
				log_attack("<font color='red'>[usr] ([usr.ckey]) placed [GM] ([GM.ckey]) in a disposals unit.</font>")
		return

	if(!I)	return

	if(user.drop_item(I, src))
		user.visible_message("[user.name] places \the [I] into the [src].", "You place \the [I] into the [src].")

	update_icon()

// can breath normally in the disposal
/obj/machinery/disposal/alter_health()
	return get_turf(src)

// attempt to move while inside
/obj/machinery/disposal/relaymove(mob/user as mob)
	if(user.stat || src.flushing)
		return
	src.go_out(user)
	return

// leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)


	if (user.client)
		user.client.eye = user.client.mob
		user.client.perspective = MOB_PERSPECTIVE
	user.loc = src.loc
	update_icon()
	return


// monkeys can only pull the flush lever
/obj/machinery/disposal/attack_paw(mob/user as mob)
	if(stat & BROKEN)
		return

	flush = !flush
	update_icon()
	return

// ai as human but can't flush
/obj/machinery/disposal/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	ui_interact(user)

// human interact with machine
/obj/machinery/disposal/attack_hand(mob/user as mob)
	if(user && user.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return
	/*
	if(mode==-1)
		to_chat(usr, "<span class='warning'>The disposal units power is disabled.</span>")
		return
	*/
	src.add_fingerprint(user)
	ui_interact(user)

// user interaction
/obj/machinery/disposal/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/list/data[0]

	data["pressure"] = round(100 * air_contents.return_pressure() / (SEND_PRESSURE))
	data["flush"] = flush
	data["mode"] = mode
	data["isAI"] = isAI(user)

	// update the ui with data if it exists, returns null if no ui is passed/found or if force_open is 1/true
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "disposalsbin.tmpl", "Waste Disposal Unit", 430, 150)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// Make the UI auto-update.
		ui.set_auto_update(1)

// handle machine interaction
/obj/machinery/disposal/Topic(href, href_list)
	if(usr.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return

	if(mode==-1 && !href_list["eject"]) // only allow ejecting if mode is -1
		to_chat(usr, "<span class='warning'>The disposal units power is disabled.</span>")
		return
	if(..())
		usr << browse(null, "window=disposal")
		usr.unset_machine()
		return 1
	else
		src.add_fingerprint(usr)
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
			update_icon()

		if(href_list["handle"])
			flush = text2num(href_list["handle"])
			update_icon()

		if(href_list["eject"])
			eject()

		nanomanager.update_uis(src)

	return

// eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.loc = src.loc
		AM.pipe_eject(0)
	update_icon()

// update the icon & overlays to reflect mode & status
/obj/machinery/disposal/update_icon()
	overlays.len = 0
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
		spawn(0)
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
		update_icon()
	return

// perform a flush
/obj/machinery/disposal/proc/flush()


	flushing = 1
	flick("[icon_state]-flush", src)

	var/wrapcheck = 0
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
										// travels through the pipes.
	for(var/obj/item/delivery/O in src)
		wrapcheck = 1

	if(wrapcheck == 1)
		H.tomail = 1


	air_contents = new()		// new empty gas resv.

	sleep(10)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		last_sound = world.time
	sleep(5) // wait for animation to finish


	H.init(src)	// copy the contents of disposer to holder

	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update_icon()
	return


// called when area power changes
/obj/machinery/disposal/power_change()
	..()	// do default setting/reset of stat NOPOWER bit
	update_icon()	// update icon
	return


// called when holder is expelled from a disposal
// should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(var/obj/structure/disposalholder/H)


	var/turf/target
	playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
	if(H) // Somehow, someone managed to flush a window which broke mid-transit and caused the disposal to go in an infinite loop trying to expel null, hopefully this fixes it
		H.active = 0 // Stop disposalholder's move() processing so we don't call the trunk's expel() too
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.loc = src.loc
			AM.pipe_eject(0)
			spawn(1)
				if(AM)
					AM.throw_at(target, 5, 1)

		H.vent_gas(loc)
		qdel(H)

/obj/machinery/disposal/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if (istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/weapon/dummy) || istype(I, /obj/item/projectile))
			return
		if(prob(75))
			I.loc = src
			for(var/mob/M in viewers(src))
				M.show_message("\the [I] lands in \the [src].", 1)
		else
			for(var/mob/M in viewers(src))
				M.show_message("\the [I] bounces off of \the [src]'s rim!.", 1)
		return 0
	else
		return ..(mover, target, height, air_group)

/obj/machinery/disposal/MouseDrop_T(atom/movable/dropping, mob/user)

	if(isAI(user))
		return

	//We are restrained or can't move, this will compromise taking out the trash
	if(user.restrained() || !user.canmove)
		return

	if(!ismob(dropping)) //Not a mob, so we can expect it to be an item
		if(istype(dropping, /obj/item))

			if(dropping.locked_to) //Items can very specifically be locked to something, check that here
				return

			attackby(dropping, user)
		return

	//From there, we are working on a mob (as our target, user is supposed to be a mob)

	var/locHolder = dropping.loc
	var/mob/target = dropping

	//Our target, now confirmed to be a mob, is locked to something, same thing
	if(target.locked_to)
		return

	if(target == user)
		target.visible_message("[target] starts climbing into \the [src].", "You start climbing into \the [src].")

	else

		if(isanimal(user))
			return //Animals cannot put mobs other than themselves into disposal

		user.visible_message("[user] starts stuffing \the [target] into \the [src].", "You start stuffing \the [target] into \the [src].")

	if(!do_after(user, src, 20))
		return

	if(user.restrained() || !user.canmove)
		return

	if(target.locked_to)
		return

	if(locHolder != target.loc)
		return

	if(target == user)
		target.visible_message("[target] climbs into \the [src].", "You climb into \the [src].")

	else

		user.visible_message("[user] stuffed \the [target] into \the [src]!", "You stuffed \the [target] into \the [src]!")
		log_attack("<span class='warning'>[key_name(user)] stuffed [key_name(target)] into a disposal unit/([src]).</span>")

	add_fingerprint(user)
	target.forceMove(src)
	update_icon()

/obj/machinery/disposal/Destroy()
	eject()
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
	var/has_fat_guy = 0	// true if contains a fat person
	var/destinationTag = "DISPOSALS"// changes if contains a delivery container
	var/tomail = 0 //changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob


	// initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(var/obj/machinery/disposal/D)
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
		AM.forceMove(src)
		if(istype(AM, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = AM
			if(((M_FAT in H.mutations) && (H.species && H.species.flags & CAN_BE_FAT)) || H.species.flags & IS_BULKY)		// is a human and fat?
				has_fat_guy = 1			// set flag on holder
		if(istype(AM, /obj/item/delivery/large) && !hasmob)
			var/obj/item/delivery/large/T = AM
			src.destinationTag = T.sortTag
		if(istype(AM, /obj/item/delivery) && !hasmob)
			var/obj/item/delivery/T = AM
			src.destinationTag = T.sortTag

// start the movement process
// argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(var/obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src)	// no trunk connected, so expel immediately
		return

	forceMove(D.trunk)
	active = 1
	dir = DOWN
	spawn(1)
		move()		// spawn off the movement process

// movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()
	var/obj/structure/disposalpipe/last
	while(active)
		/* vg edit
		if(hasmob && prob(3))
			for(var/mob/living/H in src)
				H.take_overall_damage(20, 0, "Blunt Trauma")//horribly maim any living creature jumping down disposals.  c'est la vie
				*/

		if(has_fat_guy && prob(2)) // chance of becoming stuck per segment if contains a fat guy
			active = 0
			// find the fat guys
			for(var/mob/living/carbon/human/H in src)

			break
		sleep(1)		// was 1
		if(!loc || isnull(loc))
			qdel(src)
			return

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
		AM.forceMove(src)		// move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)	// if a client mob, update eye to follow this holder
				M.client.eye = src

	if(other.has_fat_guy)
		has_fat_guy = 1
	qdel(other)


// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user as mob)
	if (user.stat)
		return
	if (src.loc)
		for (var/mob/M in hearers(src.loc.loc))
			to_chat(M, "<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>")

	playsound(get_turf(src), 'sound/effects/clang.ogg', 50, 0, 0)

/obj/machinery/disposal/is_airtight() //No polyacid smoke while inside the pipes. The disposals bins, inlets/outlets and such aren't counted for this purpose
	return 1

// called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(var/atom/location)
	location.assume_air(gas)  // vent all gas to turf
	return

// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0

	holomap = TRUE
	auto_holomap = TRUE
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
	Destroy()
		var/obj/structure/disposalholder/H = locate() in src
		if(H)
			// holder was present
			H.active = 0
			var/turf/T = src.loc
			if(T.density)
				// deleting pipe is inside a dense turf (wall)
				// this is unlikely, but just dump out everything into the turf in case

				for(var/atom/movable/AM in H)
					AM.forceMove(T)
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

			H.forceMove(P)
		else			// if wasn't a pipe, then set loc to turf
			H.forceMove(T)
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
		if(!T || isnull(T))
			T = loc
		if(T.density)		// dense ouput turf, so stop holder
			H.active = 0
			H.forceMove(src)
			return
		if(T.intact && istype(T,/turf/simulated/floor)) //intact floor, pop the tile
			var/turf/simulated/floor/F = T
			//F.health	= 100
			F.break_tile()

		if(direction)		// direction is specified
			if(istype(T, /turf/space)) // if ended in space, then range is unlimited
				target = get_edge_target_turf(T, direction)
			else						// otherwise limit to 10 tiles
				target = get_ranged_target_turf(T, direction, 10)

			playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
			if(H)
				for(var/atom/movable/AM in H)
					AM.forceMove(T)
					AM.pipe_eject(direction)
					spawn(1)
						if(AM)
							AM.throw_at(target, 100, 1)
				H.vent_gas(T)
				qdel(H)

		else	// no specified direction, so throw in random direction

			playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
			if(H)
				for(var/atom/movable/AM in H)
					target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

					AM.forceMove(T)
					AM.pipe_eject(0)
					spawn(1)
						if(AM)
							AM.throw_at(target, 5, 1)

				H.vent_gas(T)	// all gas vent to turf
				qdel(H)

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
					AM.forceMove(T)
					AM.pipe_eject(0)
				qdel(H)
				return

			// otherwise, do normal expel from turf
			if(H)
				expel(H, T, 0)

		spawn(2)	// delete pipe after 2 ticks to ensure expel proc finished
			qdel(src)


	// pipe affected by explosion
	ex_act(severity)

		for(var/atom/movable/A in src)
			A.ex_act(severity)
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
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 100, 1)
				// check if anything changed over 2 seconds
				var/turf/uloc = user.loc
				var/atom/wloc = W.loc
				to_chat(user, "Slicing the disposal pipe.")
				sleep(30)
				if(!W.isOn()) return
				if(user.loc == uloc && wloc == W.loc)
					welded()
				else
					to_chat(user, "You must stay still while welding the pipe.")
			else
				to_chat(user, "You need more welding fuel to cut the pipe.")
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
			if("pipe-j1s")
				C.ptype = 9
			if("pipe-j2s")
				C.ptype = 10
		src.transfer_fingerprints_to(C)
		C.change_dir(dir)
		C.density = 0
		C.anchored = 1
		C.update()

		qdel(src)

// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = 0

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/New()
	..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)

	update()

//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/New()
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
	var/sortType = 0 //Deprecated, here for legacy support.
	var/sort_tag //Replacement of the above, more construction friendly.

	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/sortjunction/proc/updatedesc()
	desc = "An underfloor disposal pipe with a package sorting mechanism."
	if(sort_tag)
		desc += "\nIt's tagged with [sort_tag]."

/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)

	dpdir = sortdir | posdir | negdir

/obj/structure/disposalpipe/sortjunction/New()
	. = ..()
	if(sortType && !sort_tag)
		sort_tag = uppertext(map.default_tagger_locations[sortType])

	else if(sort_tag)
		sort_tag = uppertext(sort_tag)

	updatedir()
	updatedesc()
	update()

/obj/structure/disposalpipe/sortjunction/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I

		if(O.currTag)// Tag set
			sort_tag = uppertext(O.destinations[O.currTag])
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 100, 1)
			to_chat(user, "<span class='notice'>Changed filter to [sort_tag]</span>")
			updatedesc()
		return 1

	. = ..()
	// next direction to move
	// if coming in from negdir, then next is primary dir or sortdir
	// if coming in from posdir, then flip around and go back to posdir
	// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(var/fromdir, var/sortTag)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(sort_tag == sortTag) //if destination matches filtered type...
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

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return

	return P

////////////////// SortJunctionSubtypes//////////////////

/obj/structure/disposalpipe/sortjunction/Disposals
	sort_tag = DISP_DISPOSALS

/obj/structure/disposalpipe/sortjunction/Disposals/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Cargo
	sort_tag = DISP_CARGO_BAY

/obj/structure/disposalpipe/sortjunction/Cargo/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/QM
	sort_tag = DISP_QM_OFFICE

/obj/structure/disposalpipe/sortjunction/QM/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Engineering
	sort_tag = DISP_ENGINEERING

/obj/structure/disposalpipe/sortjunction/Engineering/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/CE
	sort_tag = DISP_CE_OFFICE

/obj/structure/disposalpipe/sortjunction/CE/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Atmos
	sort_tag = DISP_ATMOSPHERICS

/obj/structure/disposalpipe/sortjunction/Atmos/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Security
	sort_tag = DISP_SECURITY

/obj/structure/disposalpipe/sortjunction/Security/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/HoS
	sort_tag = DISP_HOS_OFFICE

/obj/structure/disposalpipe/sortjunction/HoS/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Medbay
	sort_tag = DISP_MEDBAY

/obj/structure/disposalpipe/sortjunction/Medbay/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/CMO
	sort_tag = DISP_CMO_OFFICE

/obj/structure/disposalpipe/sortjunction/CMO/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Chemistry
	sort_tag = DISP_CHEMISTRY

/obj/structure/disposalpipe/sortjunction/Chemistry/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Research
		sort_tag = DISP_RESEARCH

/obj/structure/disposalpipe/sortjunction/Research/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/RD
		sort_tag = DISP_RD_OFFICE

/obj/structure/disposalpipe/sortjunction/RD/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Robotics
		sort_tag = DISP_ROBOTICS

/obj/structure/disposalpipe/sortjunction/Robotics/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/HoP
		sort_tag = DISP_HOP_OFFICE

/obj/structure/disposalpipe/sortjunction/HoP/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Library
		sort_tag = DISP_LIBRARY

/obj/structure/disposalpipe/sortjunction/Library/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Chapel
		sort_tag = DISP_CHAPEL

/obj/structure/disposalpipe/sortjunction/Chapel/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Theatre
		sort_tag = DISP_THEATRE

/obj/structure/disposalpipe/sortjunction/Theatre/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Bar
		sort_tag = DISP_BAR

/obj/structure/disposalpipe/sortjunction/Bar/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Kitchen
		sort_tag = DISP_KITCHEN

/obj/structure/disposalpipe/sortjunction/Kitchen/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Hydroponics
		sort_tag = DISP_HYDROPONICS

/obj/structure/disposalpipe/sortjunction/Hydroponics/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Janitor
		sort_tag = DISP_JANITOR_CLOSET

/obj/structure/disposalpipe/sortjunction/Janitor/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Genetics
		sort_tag = DISP_GENETICS

/obj/structure/disposalpipe/sortjunction/Genetics/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Telecomms
		sort_tag = DISP_TELECOMMS

/obj/structure/disposalpipe/sortjunction/Telecomms/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Mechanics
		sort_tag = DISP_MECHANICS

/obj/structure/disposalpipe/sortjunction/Mechanics/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/Telescience
		sort_tag = DISP_TELESCIENCE

/obj/structure/disposalpipe/sortjunction/Telescience/mirrored
	icon_state = "pipe-j2s"

//////////////////
//a three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction

	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/wrapsortjunction/mirrored
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/wrapsortjunction/New()
	. = ..()

	update_dir()
	update()

/obj/structure/disposalpipe/wrapsortjunction/update_dir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)
	dpdir = sortdir | posdir | negdir

	. = ..()

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

		H.forceMove(P)
	else			// if wasn't a pipe, then set loc to turf
		H.forceMove(T)
		return

	return P

//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/machinery/disposal/disposal
	var/obj/structure/disposaloutlet/disposaloutlet
	var/obj/linked

/obj/structure/disposalpipe/trunk/New()
	. = ..()
	dpdir = dir

	spawn(1)
		getlinked()

	update()

/obj/structure/disposalpipe/trunk/proc/getlinked()
	disposal = locate() in loc

	if(disposal)
		if(disposal.trunk != src)
			disposal.trunk = src

		linked = disposal

	disposaloutlet = locate() in loc

	if(disposaloutlet)
		if(disposaloutlet.trunk != src)
			disposaloutlet.trunk = src

		linked = disposaloutlet

/obj/structure/disposalpipe/trunk/Destroy()
	if(disposal)
		if(disposal.trunk)
			disposal.trunk = null

		disposal = null

	if(disposaloutlet)
		if(disposaloutlet.trunk)
			disposaloutlet.trunk = null

		disposaloutlet = null

	if(linked)
		linked = null

	..()

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
			playsound(get_turf(src), 'sound/items/Welder2.ogg', 100, 1)
			// check if anything changed over 2 seconds
			var/turf/uloc = user.loc
			var/atom/wloc = W.loc
			to_chat(user, "Slicing the disposal pipe.")
			sleep(30)
			if(!W.isOn()) return
			if(user.loc == uloc && wloc == W.loc)
				welded()
			else
				to_chat(user, "You must stay still while welding the pipe.")
		else
			to_chat(user, "You need more welding fuel to cut the pipe.")
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
		qdel(src)

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
	var/obj/structure/disposalpipe/trunk/trunk

	holomap = TRUE
	auto_holomap = TRUE

	New()
		. = ..()

		spawn(1)
			target = get_ranged_target_turf(src, dir, 10)

			trunk = locate() in loc

			if(trunk)
				if(trunk.disposaloutlet != src)
					trunk.disposaloutlet = src

				if(trunk.linked != trunk.disposaloutlet)
					trunk.linked = trunk.disposaloutlet

	Destroy()
		if(trunk)
			if(trunk.disposaloutlet)
				trunk.disposaloutlet = null

			if(trunk.linked)
				trunk.linked = null

			trunk = null

		..()

	// expel the contents of the holder object, then delete it
	// called when the holder exits the outlet
	proc/expel(var/obj/structure/disposalholder/H)


		flick("outlet-open", src)
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, 0)
		sleep(20)	//wait until correct animation frame
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)

		if(H)
			for(var/atom/movable/AM in H)
				AM.forceMove(src.loc)
				AM.pipe_eject(dir)
				spawn(5)
					if(AM)
						AM.throw_at(target, 3, 1)
			H.vent_gas(src.loc)
			qdel(H)

		return

	attackby(var/obj/item/I, var/mob/user)
		if(!I || !user)
			return
		src.add_fingerprint(user)
		if(isscrewdriver(I))
			if(mode==0)
				mode=1
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "You remove the screws around the power connection.")
				return
			else if(mode==1)
				mode=0
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "You attach the screws around the power connection.")
				return
		else if(istype(I,/obj/item/weapon/weldingtool) && mode==1)
			var/obj/item/weapon/weldingtool/W = I
			if(W.remove_fuel(0,user))
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 100, 1)
				to_chat(user, "You start slicing the floorweld off the disposal outlet.")
				if(do_after(user, src,20))
					if(!src || !W.isOn()) return
					to_chat(user, "You sliced the floorweld off the disposal outlet.")
					var/obj/structure/disposalconstruct/C = new (src.loc)
					src.transfer_fingerprints_to(C)
					C.ptype = 7 // 7 =  outlet
					C.update()
					C.anchored = 1
					C.density = 1
					qdel(src)
				return
			else
				to_chat(user, "You need more welding fuel to complete this task.")
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

/obj/effect/decal/cleanable/blood/gibs/robot/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)
