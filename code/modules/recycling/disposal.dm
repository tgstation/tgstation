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

//Create a new disposal
//Find the attached trunk (if present) and init gas resvr.
/obj/machinery/disposal/New()
	..()
	spawn(5)
		trunk = locate() in loc

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
	update()

/obj/machinery/disposal/Destroy()
	if(trunk)
		if(trunk.disposal)
			trunk.disposal = null
		if(trunk.linked)
			trunk.linked = null

		trunk = null

	..()

/obj/machinery/disposal/MouseDrop_T(var/obj/item/target, mob/user)
	attackby(target,user)


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
			eject()
			qdel(src)


//Attack by item places it in to disposal
/obj/machinery/disposal/attackby(var/obj/item/I, var/mob/user)
	if(stat & BROKEN || !I || !user)
		return

	if(isrobot(user) && !istype(I, /obj/item/weapon/storage/bag/trash) && !istype(user,/mob/living/silicon/robot/mommi))
		return
	add_fingerprint(user)
	if(mode <= 0) // It's off
		if(istype(I, /obj/item/weapon/screwdriver))
			if(contents.len > 0)
				user << "Eject the items first!"
				return
			if(mode == 0) // It's off but still not unscrewed
				mode =- 1 // Set it to doubleoff l0l
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				user << "You remove the screws around the power connection."
				return
			else if(mode==-1)
				mode=0
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				user << "You attach the screws around the power connection."
				return
		else if(istype(I,/obj/item/weapon/weldingtool) && mode==-1)
			if(contents.len > 0)
				user << "Eject the items first!"
				return
			var/obj/item/weapon/weldingtool/W = I
			if(W.remove_fuel(0,user))
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 100, 1)
				user << "You start slicing the floorweld off the disposal unit."

				if(do_after(user,20))
					if(!src || !W.isOn()) return
					user << "You sliced the floorweld off the disposal unit."
					var/obj/structure/disposalconstruct/C = new (loc)
					transfer_fingerprints_to(C)
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

	if(istype(I, /obj/item/weapon/storage/bag/trash))
		var/obj/item/weapon/storage/bag/trash/T = I
		user << "<span class='notice'>You empty the bag.</span>"
		for(var/obj/item/O in T.contents)
			T.remove_from_storage(O,src)
		T.update_icon()
		update()
		return

	var/obj/item/weapon/grab/G = I
	if(istype(G))	// handle grabbed mob
		if(ismob(G.affecting))
			var/mob/GM = G.affecting
			user.attack_log += "<span class='warning'> [user]([user.ckey]) has attempted to put [GM]([GM.ckey]) in disposals.</span>"
			GM.attack_log += "<span class='warning'> [user]([user.ckey]) has attempted to put [GM]([GM.ckey]) in disposals.</span>"
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
		return

	if(!I)
		return
	if(!isMoMMI(user))
		user.drop_item()
	else
		var/mob/living/silicon/robot/mommi/M = user
		if(is_type_in_list(I,M.module.modules))
			user << "\red You can't throw away what's attached to you."
			return
		else
			M.drop_item()
	if(I)
		I.loc = src

	user << "You place \the [I] into the [src]."
	for(var/mob/M in viewers(src))
		if(M == user)
			continue
		M.show_message("[user.name] places \the [I] into the [src].", 3)

	update()

//Mouse drop another mob or self
/obj/machinery/disposal/MouseDrop_T(mob/target, mob/user)
	if (!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || istype(user, /mob/living/silicon/ai))
		return
	if(isanimal(user) && target != user)
		return //animals cannot put mobs other than themselves into disposal
	add_fingerprint(user)
	var/target_loc = target.loc
	var/msg
	for(var/mob/V in viewers(usr))
		if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
			V.show_message("[usr] starts climbing into the disposal.", 3)
		if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
			if(target.anchored)
				return
			V.show_message("[usr] starts stuffing [target.name] into the disposal.", 3)
	if(!do_after(usr, 20))
		return
	if(target_loc != target.loc)
		return
	if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)	//If dropped self, then climbed in. Must be able to climb in
		msg = "[user.name] climbs into the [src]."
		user << "You climb into the [src]."
	else if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
		msg = "[user.name] stuffs [target.name] into the [src]!"
		user << "You stuff [target.name] into the [src]!"
		log_attack("<font color='red'>[user] ([user.ckey]) placed [target] ([target.ckey]) in a disposals unit.</font>")
	else
		return
	if(target.client)
		target.client.perspective = EYE_PERSPECTIVE
		target.client.eye = src
	target.loc = src

	for(var/mob/C in viewers(src))
		if(C == user)
			continue
		C.show_message(msg, 3)

	update()
	return

//Can breath normally in the disposal
/obj/machinery/disposal/alter_health()
	return get_turf(src)

//Attempt to move while inside
/obj/machinery/disposal/relaymove(mob/user as mob)
	if(user.stat || flushing)
		return
	go_out(user)
	return

//Leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)
	if(user.client)
		user.client.eye = user.client.mob
		user.client.perspective = MOB_PERSPECTIVE
	user.loc = loc
	update()
	return

//Monkeys can only pull the flush lever
/obj/machinery/disposal/attack_paw(mob/user as mob)
	if(stat & BROKEN)
		return

	flush = !flush
	update()
	return

//AI acts like humans but can't flush
/obj/machinery/disposal/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	interact(user, 1)

//Human interaction with the machine
/obj/machinery/disposal/attack_hand(mob/user as mob)
	if(user && user.loc == src)
		usr << "\red You cannot reach the controls from inside."
		return
	/*
	if(mode == -1)
		usr << "\red The disposal units power is disabled."
		return
	*/
	interact(user, 0)

//User interaction
/obj/machinery/disposal/interact(mob/user, var/ai=0)

	add_fingerprint(user)
	if(stat & BROKEN)
		user.unset_machine()
		return

	var/dat = "<head><title>Waste Disposal Unit</title></head><body><TT><B>Waste Disposal Unit</B><HR>"

	if(!ai)  //AI can't pull flush handle
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

	var/per = 100 * air_contents.return_pressure() / (SEND_PRESSURE)

	dat += "Pressure: [round(per, 1)]%<BR></body>"


	user.set_machine(src)
	user << browse(dat, "window=disposal;size=360x170")
	onclose(user, "disposal")

//Handle machine interaction
/obj/machinery/disposal/Topic(href, href_list)
	if(usr.loc == src)
		usr << "\red You cannot reach the controls from inside."
		return

	if(mode==-1 && !href_list["eject"]) // only allow ejecting if mode is -1
		usr << "\red The disposal units power is disabled."
		return
	..()
	add_fingerprint(usr)
	if(stat & BROKEN)
		return
	if(usr.stat || usr.restrained() || flushing)
		return

	if(in_range(src, usr) && istype(loc, /turf))
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
	else
		usr << browse(null, "window=disposal")
		usr.unset_machine()
		return
	return

//Eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.loc = loc
		AM.pipe_eject(0)
	update()

//Update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	overlays.Cut()
	if(stat & BROKEN)
		icon_state = "disposal-broken"
		mode = 0
		flush = 0
		return

	//Flush handle
	if(flush)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-handle")

	//Only handle is shown if no power
	if(stat & NOPOWER || mode == -1)
		return

	//Check for items in disposal - occupied light
	if(contents.len > 0)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-full")

	//Charging and ready light
	if(mode == 1)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-charge")
	else if(mode == 2)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-ready")

//Timed process, charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/process()
	if(stat & BROKEN)			//Nothing can happen if broken
		return

	if(!air_contents) //Potentially causes a runtime otherwise (if this is really shitty, blame pete //Donkie)
		return

	flush_count++
	if(flush_count >= flush_every_ticks)
		if(contents.len)
			if(mode == 2)
				spawn(0)
					feedback_inc("disposal_auto_flush",1)
					flush()
		flush_count = 0

	updateDialog()

	if(flush && air_contents.return_pressure() >= SEND_PRESSURE )	//Flush can happen even without power
		spawn(0)
			flush()

	if(stat & NOPOWER)			//Won't charge if no power
		return

	use_power(100)		//Base power usage

	if(mode != 1)		//If off or ready, no need to charge
		return

	//Otherwise charge
	use_power(500)		//Charging power usage

	var/atom/L = loc						//Recharging from loc turf

	var/datum/gas_mixture/env = L.return_air()
	var/pressure_delta = (SEND_PRESSURE * 1.01) - air_contents.return_pressure()

	if(env.temperature > 0)
		var/transfer_moles = 0.1 * pressure_delta * air_contents.volume/(env.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = env.remove(transfer_moles)
		air_contents.merge(removed)


	//If full enough, switch to ready mode
	if(air_contents.return_pressure() >= SEND_PRESSURE)
		mode = 2
		update()
	return

//Perform a flush
/obj/machinery/disposal/proc/flush()

	flushing = 1
	flick("[icon_state]-flush", src)

	var/wrapcheck = 0
	var/obj/structure/disposalholder/H = new()	//Virtual holder object which actually
											//Travels through the pipes.
	for(var/obj/item/smallDelivery/O in src)
		wrapcheck = 1

	if(wrapcheck == 1)
		H.tomail = 1

	air_contents = new()		//New empty gas resv.

	sleep(10)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		last_sound = world.time
	sleep(5) //Wait for animation to finish


	H.init(src)	//Copy the contents of disposer to holder

	H.start(src) //Start the holder processing movement
	flushing = 0
	//Now reset disposal state
	flush = 0
	if(mode == 2)	//If was ready,
		mode = 1	//Switch to charging
	update()
	return

//Called when area power changes
/obj/machinery/disposal/power_change()
	..()	//Do default setting/reset of stat NOPOWER bit
	update()	//Update icon
	return


// called when holder is expelled from a disposal, should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(var/obj/structure/disposalholder/H)

	var/turf/target
	playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
	if(H) //Somehow, someone managed to flush a window which broke mid-transit and caused the disposal to go in an infinite loop trying to expel null, hopefully this fixes it
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.loc = loc
			AM.pipe_eject(0)
			spawn(1)
				if(AM)
					AM.throw_at(target, 5, 1)

		H.vent_gas(loc)
		qdel(H)

/obj/machinery/disposal/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/item) && mover.throwing)
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

//Virtual disposal object, travels through pipes in lieu of actual items
//Contents will be items flushed by the disposal, this allows the gas flushed to be tracked
/obj/structure/disposalholder
	invisibility = 101
	var/datum/gas_mixture/gas = null	//Gas used to flush, will appear at exit point
	var/active = 0	//True if the holder is moving, otherwise inactive
	dir = 0
	var/count = 1000	//Can travel 1000 steps before going inactive (in case of loops)
	var/has_fat_guy = 0	//True if contains a fat person
	var/destinationTag = 0 //Changes if contains a delivery container
	var/tomail = 0 //Changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob

//Initialize a holder from the contents of a disposal unit
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

	//Now everything inside the disposal gets put into the holder
	//Note AM since can contain mobs or objs
	for(var/atom/movable/AM in D)
		AM.loc = src
		if(istype(AM, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = AM
			if(M_FAT in H.mutations)		// is a human and fat?
				has_fat_guy = 1			// set flag on holder
		if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
			var/obj/structure/bigDelivery/T = AM
			destinationTag = T.sortTag
		if(istype(AM, /obj/item/smallDelivery) && !hasmob)
			var/obj/item/smallDelivery/T = AM
			destinationTag = T.sortTag

//Start the movement process
//Argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(var/obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src)	//No trunk connected, so expel immediately
		return

	loc = D.trunk
	active = 1
	dir = DOWN
	spawn(1)
		move()		//Spawn off the movement process

	return

//Movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()
	var/obj/structure/disposalpipe/last
	while(active)
		/* vg edit
		if(hasmob && prob(3))
			for(var/mob/living/H in src)
				H.take_overall_damage(20, 0, "Blunt Trauma") //Horribly maim any living creature jumping down disposals. C'est la vie //I like faux French too, andouille
				*/

		if(has_fat_guy && prob(2)) //Chance of becoming stuck per segment if contains a fat guy
			active = 0
			//Find the fat guys
			for(var/mob/living/carbon/human/H in src)

			break
		sleep(1)
		if(!loc || isnull(loc))
			del(src)
		var/obj/structure/disposalpipe/curr = loc
		last = curr
		curr = curr.transfer(src)
		if(!curr)
			last.expel(src, loc, dir)
		if(!(count--))
			active = 0
	return

//Find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(loc,dir)

//Find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(var/turf/T)

	if(!T)
		return null

	var/fdir = turn(dir, 180)	//Flip the movement direction
	for(var/obj/structure/disposalpipe/P in T)
		if(fdir & P.dpdir)		//Find pipe direction mask that matches flipped dir
			return P
	//If no matching pipe, return null
	return null

//Merge two holder objects
//Used when a a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(var/obj/structure/disposalholder/other)
	for(var/atom/movable/AM in other)
		AM.loc = src		//Move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)	//If a client mob, update eye to follow this holder
				M.client.eye = src

	if(other.has_fat_guy)
		has_fat_guy = 1
	qdel(other)

//Called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user as mob)
	if(user.stat)
		return
	if(loc)
		for(var/mob/M in hearers(loc.loc))
			M << "<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>"

	playsound(get_turf(src), 'sound/effects/clang.ogg', 50, 0, 0)

	//Called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(var/atom/location)
	location.assume_air(gas)  //Vent all gas to turf
	return

//Disposal pipes
/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0

	level = 1			//Underfloor only
	var/dpdir = 0		//Bitmask of pipe directions
	dir = 0				//Dir will contain dominant direction for junction pipes
	var/health = 10 	//Health points
	layer = 2.3			//Slightly lower than wires and other pipes
	var/base_icon_state	//Initial icon state on map

//New pipe, set the icon_state as on map
/obj/structure/disposalpipe/New()
	..()
	base_icon_state = icon_state
	return


//Pipe is deleted, ensure that if a holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		//Holder present
		H.active = 0
		var/turf/T = loc
		if(T.density)
			//Deleting pipe that is inside a dense turf (can't move through)
			//This is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			qdel(H)
			..()
			return

		//Otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)
	..()

//Returns the direction of the next pipe object, given the entrance dir
//By default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(var/fromdir)
	return dpdir & (~turn(fromdir, 180))

//Transfer the holder through this pipe segment, overriden for special behaviour
/obj/structure/disposalpipe/proc/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		//Find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else			//If wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P

//Update the icon_state to reflect hidden status
/obj/structure/disposalpipe/proc/update()
	var/turf/T = loc
	hide(T.intact && !istype(T,/turf/space))	//Space never hides pipes

//Hide called by levelupdate if turf intact status changes, change visibility status and force update of icon
/obj/structure/disposalpipe/hide(var/intact)
	invisibility = intact ? 101:0	//Hide if floor is intact
	updateicon()

//Update actual icon_state depending on visibility
//If invisible, append "f" to icon_state to show faded version, this will be revealed if a T-scanner is used
//If visible, use regular icon_state
/obj/structure/disposalpipe/proc/updateicon()
	if(invisibility)
		icon_state = "[base_icon_state]f"
	else
		icon_state = base_icon_state
	return

//Expel the held objects into a turf, called when there is a break in the pipe
/obj/structure/disposalpipe/proc/expel(var/obj/structure/disposalholder/H, var/turf/T, var/direction)

	var/turf/target
	if(!T || isnull(T))
		T = loc
	if(T.density)		//Dense ouput turf, so stop holder
		H.active = 0
		H.loc = src
		return
	if(T.intact && istype(T,/turf/simulated/floor)) //Intact floor, pop the tile
		var/turf/simulated/floor/F = T
		//F.health	= 100
		F.burnt	= 1
		F.intact	= 0
		F.levelupdate()
		new /obj/item/stack/tile(H)	//Add to holder so it will be thrown with other stuff
		F.icon_state = "Floor[F.burnt ? "1" : ""]"

	if(direction)		//Direction is specified
		if(istype(T, /turf/space)) //If ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						//Otherwise limit to 10 tiles
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
			qdel(H)

	else	//No specified direction, so throw in random direction

		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		if(H)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

				AM.loc = T
				AM.pipe_eject(0)
				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)

			H.vent_gas(T)	//All gas vent to turf
			qdel(H)

	return

//Call to break the pipe, will expel any holder inside at the time then delete the pipe
//Remains : set to leave broken pipe pieces in place
/obj/structure/disposalpipe/proc/broken(var/remains = 0)
	if(remains)
		for(var/D in cardinal)
			if(D & dpdir)
				var/obj/structure/disposalpipe/broken/P = new(loc)
				P.dir = D

	invisibility = 101	//Make invisible (since we won't delete the pipe immediately)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		//Holder was present
		H.active = 0
		var/turf/T = loc
		if(T.density)
			//Broken pipe is inside a dense turf (wall)
			//This is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			qdel(H)
			return

		//Otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)

	spawn(2)	//Delete pipe after 2 ticks to ensure expel proc finished
		del(src)

//Pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity)

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


//Test health for brokenness
/obj/structure/disposalpipe/proc/healthcheck()
	if(health < -2)
		broken(0)
	else if(health<1)
		broken(1)
	return

//Attacked by item
//Welding tool : unfasten and convert to obj/disposalconstruct
/obj/structure/disposalpipe/attackby(var/obj/item/I, var/mob/user)

	var/turf/T = loc
	if(T.intact)
		return		//Prevent interaction with T-scanner revealed pipes
	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if(W.remove_fuel(0,user))
			playsound(get_turf(src), 'sound/items/Welder2.ogg', 100, 1)
			//Check if anything changed over 2 seconds
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

//Called when pipe is cut with welder
/obj/structure/disposalpipe/proc/welded()

	var/obj/structure/disposalconstruct/C = new (loc)
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
	transfer_fingerprints_to(C)
	C.dir = dir
	C.density = 0
	C.anchored = 1
	C.update()

	del(src)

/*
//For testing purposes only
client/verb/dispstop()
	for(var/obj/structure/disposalholder/H in world)
		H.active = 0
*/

//A straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/New()
	..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)

	update()
	return

//A three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/New()
	..()
	if(icon_state == "pipe-j1")
		dpdir = dir | turn(dir, -90) | turn(dir,180)
	else if(icon_state == "pipe-j2")
		dpdir = dir | turn(dir, 90) | turn(dir,180)
	else //Pipe-y
		dpdir = dir | turn(dir,90) | turn(dir, -90)
	update()
	return

//Next direction to move
//If coming in from secondary dirs, then next is primary dir
//If coming in from primary dir, then next is equal chance of other dirs
/obj/structure/disposalpipe/junction/nextdir(var/fromdir)
	var/flipdir = turn(fromdir, 180)
	if(flipdir != dir)	//Came from secondary dir, so exit through primary
		return dir
	else				//Came from primary, so need to choose either secondary exit
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

//A three-way junction that sorts objects
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

	if(icon_state == "pipe-j1s")
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

/obj/structure/disposalpipe/sortjunction/attackby(var/obj/item/I, var/mob/user)
	if(..())
		return

	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I

		if(O.currTag > 0)// Tag set
			sortType = O.currTag
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 100, 1)
			var/tag = uppertext(TAGGERLOCATIONS[O.currTag])
			user << "\blue Changed filter to [tag]"
			updatedesc()

//Next direction to move
//If coming in from negdir, then next is primary dir or sortdir
//If coming in from posdir, then flip around and go back to posdir
//If coming in from sortdir, go to posdir
/obj/structure/disposalpipe/sortjunction/nextdir(var/fromdir, var/sortTag)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	//Probably came from the negdir
		if(sortType == sortTag) //If destination matches filtered type, exit through sortdirection
			return sortdir
		else
			return posdir
	else				//Came from sortdir, so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P) //Find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else	//If it wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P

//A three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction
	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/wrapsortjunction/New()
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

//Next direction to move
//If coming in from negdir, then next is primary dir or sortdir
//If coming in from posdir, then flip around and go back to posdir
//If coming in from sortdir, go to posdir
/obj/structure/disposalpipe/wrapsortjunction/nextdir(var/fromdir, var/istomail)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	//Probably came from the negdir
		if(istomail) //If destination matches filtered type, exit through sortdirection
			return sortdir
		else
			return posdir
	else //Came from sortdir, so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/wrapsortjunction/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.tomail)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P) //Find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else			//If wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P

//A trunk joining to a disposal bin or outlet on the same turf
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

//Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(var/obj/item/I, var/mob/user)

	//Disposal bins or chutes
	/*
	These shouldn't be required
	var/obj/machinery/disposal/D = locate() in loc
	if(D && D.anchored)
		return

	//Disposal outlet
	var/obj/structure/disposaloutlet/O = locate() in loc
	if(O && O.anchored)
		return
	*/

	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in loc
	if(C && C.anchored)
		return

	var/turf/T = loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes
	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if(W.remove_fuel(0,user))
			playsound(get_turf(src), 'sound/items/Welder2.ogg', 100, 1)
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

//Would transfer to next pipe segment, but we are in a trunk
//If not entering from disposal bin, transfer to linked object (outlet or bin)
/obj/structure/disposalpipe/trunk/transfer(var/obj/structure/disposalholder/H)

	if(H.dir == DOWN)		//We just entered from a disposer
		return ..()		//So do base transfer proc
	//Otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O) && (H))
			O.expel(H)	//Expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			if(H)
				D.expel(H)	//Expel at disposal
	else
		if(H)
			expel(H, loc, 0)	//Expel at turf
	return null

//Nextdir
/obj/structure/disposalpipe/trunk/nextdir(var/fromdir)
	if(fromdir == DOWN)
		return dir
	else
		return 0

//A broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		//Broken pipes have dpdir = 0 so they're not found as 'real' pipes
					//i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

/obj/structure/disposalpipe/broken/New()
	..()
	update()
	return

//Called when welded
//For broken pipe, remove and turn into scrap
/obj/structure/disposalpipe/broken/welded()
	//var/obj/item/scrap/S = new(loc)
	//S.set_components(200,0,0)
	del(src)

//The disposal outlet machine
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

/obj/structure/disposaloutlet/New()
	. = ..()

	spawn(1)
		target = get_ranged_target_turf(src, dir, 10)
		trunk = locate() in loc

		if(trunk)
			if(trunk.disposaloutlet != src)
				trunk.disposaloutlet = src

			if(trunk.linked != trunk.disposaloutlet)
				trunk.linked = trunk.disposaloutlet

/obj/structure/disposaloutlet/Destroy()
	if(trunk)
		if(trunk.disposaloutlet)
			trunk.disposaloutlet = null

		if(trunk.linked)
			trunk.linked = null

		trunk = null

	..()

//Expel the contents of the holder object, then delete it
//Called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(var/obj/structure/disposalholder/H)

	flick("outlet-open", src)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, 0)
	sleep(20)	//wait until correct animation frame
	playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)

	if(H)
		for(var/atom/movable/AM in H)
			AM.loc = loc
			AM.pipe_eject(dir)
			spawn(5)
				AM.throw_at(target, 3, 1)
		H.vent_gas(loc)
		qdel(H)

	return

/obj/structure/disposaloutlet/attackby(var/obj/item/I, var/mob/user)
	if(!I || !user)
		return
	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(mode == 0)
			mode = 1
			playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
			user << "You remove the screws around the power connection."
			return
		else if(mode == 1)
			mode = 0
			playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
			user << "You attach the screws around the power connection."
			return
	else if(istype(I,/obj/item/weapon/weldingtool) && mode==1)
		var/obj/item/weapon/weldingtool/W = I
		if(W.remove_fuel(0,user))
			playsound(get_turf(src), 'sound/items/Welder2.ogg', 100, 1)
			user << "You start slicing the floorweld off the disposal outlet."
			if(do_after(user,20))
				if(!src || !W.isOn()) return
				user << "You sliced the floorweld off the disposal outlet."
				var/obj/structure/disposalconstruct/C = new (loc)
				transfer_fingerprints_to(C)
				C.ptype = 7 // 7 =  outlet
				C.update()
				C.anchored = 1
				C.density = 1
				del(src)
			return
		else
			user << "You need more welding fuel to complete this task."
			return

//Called when movable is expelled from a disposal pipe or outlet
//By default does nothing, override for special behaviour
/atom/movable/proc/pipe_eject(var/direction)
	return

//Check if mob has client, if so restore client view on eject
/mob/pipe_eject(var/direction)
	if(client)
		client.perspective = MOB_PERSPECTIVE
		client.eye = src

	return

/obj/effect/decal/cleanable/blood/gibs/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/blood/gibs/robot/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	streak(dirs)
