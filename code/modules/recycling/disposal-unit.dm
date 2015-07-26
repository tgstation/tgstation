
//disposal bin and Delivery chute.

#define SEND_PRESSURE 0.05*ONE_ATMOSPHERE

/obj/machinery/disposal
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	anchored = 1
	density = 1
	var/datum/gas_mixture/air_contents	// internal reservoir
	var/mode = 1	// mode -1=screws removed 0=off 1=charging 2=charged
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

/obj/machinery/disposal/attackby(obj/item/I, mob/user, params)
	if(stat & BROKEN || !I || !user)
		return

	add_fingerprint(user)
	if(mode<=0) // It's off
		if(istype(I, /obj/item/weapon/screwdriver))
			if(contents.len > 0)
				user << "<span class='notice'>Eject the items first!</span>"
				return
			if(mode==0)
				mode=-1
			else
				mode=0
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class='notice'>You [mode==0?"attach":"remove"] the screws around the power connection.</span>"
			return
		else if(istype(I,/obj/item/weapon/weldingtool) && mode==-1)
			var/obj/item/weapon/weldingtool/W = I
			if(W.remove_fuel(0,user))
				if(contents.len > 0)
					user << "<span class='notice'>Eject the items first!</span>"
					return
				playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
				user << "<span class='notice'>You start slicing the floorweld off \the [src]...</span>"
				if(do_after(user,20, target = src))
					if(!W.isOn())
						return
					user << "<span class='notice'>You slice the floorweld off \the [src].</span>"
					Deconstruct()
				return
	return 1

// mouse drop another mob or self
//
/obj/machinery/disposal/MouseDrop_T(mob/living/target, mob/living/user)
	if(istype(target) && user == target)
		stuff_mob_in(target, user)

/obj/machinery/disposal/proc/stuff_mob_in(mob/living/target, mob/living/user)
	if(!iscarbon(user) && !user.ventcrawler) //only carbon and ventcrawlers can climb into disposal by themselves.
		return
	if(target.buckled)
		return
	if(target.mob_size > MOB_SIZE_HUMAN)
		user << "<span class='warning'>[target] doesn't fit inside [src]!</span>"
		return
	add_fingerprint(user)
	if(user == target)
		user.visible_message("[user] starts climbing into [src].", \
								"<span class='notice'>You start climbing into [src]...</span>")
	else
		target.visible_message("<span class='danger'>[user] starts putting [target] into [src].</span>", \
								"<span class='userdanger'>[user] starts putting you into [src]!</span>")
	if(do_mob(user, target, 20))
		if (!loc)
			return
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

/obj/machinery/disposal/relaymove(mob/user)
	attempt_escape(user)

// resist to escape the bin
/obj/machinery/disposal/container_resist()
	attempt_escape(usr)

/obj/machinery/disposal/proc/attempt_escape(mob/user)
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
/obj/machinery/disposal/attack_paw(mob/user)
	if(stat & BROKEN)
		return
	flush = !flush
	update()

// ai as human but can't flush
/obj/machinery/disposal/attack_ai(mob/user)
	interact(user, 1)

// human interact with machine
/obj/machinery/disposal/attack_hand(mob/user)
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
/obj/machinery/disposal/attack_animal(mob/living/simple_animal/M)
	if(M.environment_smash)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashes \the [src] apart!</span>")
		qdel(src)
	return

// eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.loc = src.loc
		AM.pipe_eject(0)
	update()

// update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	return

/obj/machinery/disposal/proc/flush()
	flushing = 1
	flushAnimation()
	sleep(10)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		last_sound = world.time
	sleep(5)
	if(gc_destroyed)
		return
	var/obj/structure/disposalholder/H = new()
	newHolderDestination(H)
	H.init(src)
	air_contents = new()
	H.start(src)
	flushing = 0
	flush = 0

/obj/machinery/disposal/bin/flush()
	..()
	if(mode == 2)
		mode = 1
	update()

/obj/machinery/disposal/proc/newHolderDestination(obj/structure/disposalholder/H)
	for(var/obj/item/smallDelivery/O in src)
		H.tomail = 1
		return

/obj/machinery/disposal/proc/flushAnimation()
	flick("[icon_state]-flush", src)

// called when area power changes
/obj/machinery/disposal/power_change()
	..()	// do default setting/reset of stat NOPOWER bit
	update()	// update icon
	return


// called when holder is expelled from a disposal
// should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(obj/structure/disposalholder/H)

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

/obj/machinery/disposal/Deconstruct()
	if(stored)
		var/turf/T = loc
		stored.loc = T
		src.transfer_fingerprints_to(stored)
		stored.anchored = 0
		stored.density = 1
		stored.update()
	..()

//How disposal handles getting a storage dump from a storage object
/obj/machinery/disposal/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	for(var/obj/item/I in src_object)
		src_object.remove_from_storage(I, src)
	return 1


// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables

/obj/machinery/disposal/bin
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon_state = "disposal"

	// attack by item places it in to disposal
/obj/machinery/disposal/bin/attackby(obj/item/I, mob/user, params)
	if(!..())
		return

	if(istype(I, /obj/item/weapon/storage/bag/trash))
		var/obj/item/weapon/storage/bag/trash/T = I
		user << "<span class='warning'>You empty the bag.</span>"
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

	if(!user.drop_item())
		return

	I.loc = src
	user.visible_message("[user.name] places \the [I] into \the [src].", \
						"<span class='notice'>You place \the [I] into \the [src].</span>")

	update()

// user interaction
/obj/machinery/disposal/bin/interact(mob/user, ai=0)
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

/obj/machinery/disposal/bin/Topic(href, href_list)
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

/obj/machinery/disposal/bin/CanPass(atom/movable/mover, turf/target, height=0)
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

/obj/machinery/disposal/bin/update()
	overlays.Cut()
	if(stat & BROKEN)
		mode = 0
		flush = 0
		return

	// flush handle
	if(flush)
		overlays += image('icons/obj/atmospherics/pipes/disposal.dmi', "dispover-handle")

	// only handle is shown if no power
	if(stat & NOPOWER || mode == -1)
		return

	// 	check for items in disposal - occupied light
	if(contents.len > 0)
		overlays += image('icons/obj/atmospherics/pipes/disposal.dmi', "dispover-full")

	// charging and ready light
	if(mode == 1)
		overlays += image('icons/obj/atmospherics/pipes/disposal.dmi', "dispover-charge")
	else if(mode == 2)
		overlays += image('icons/obj/atmospherics/pipes/disposal.dmi', "dispover-ready")


// timed process
// charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/bin/process()
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
		air_update_turf()


	// if full enough, switch to ready mode
	if(air_contents.return_pressure() >= SEND_PRESSURE)
		mode = 2
		update()
	return


//Delivery Chute

/obj/machinery/disposal/deliveryChute
	name = "delivery chute"
	desc = "A chute for big and small packages alike!"
	density = 1
	icon_state = "intake"
	mode = 0 // the chute doesn't need charging and always works

/obj/machinery/disposal/deliveryChute/New(loc,var/obj/structure/disposalconstruct/make_from)
	..()
	stored.ptype = DISP_END_CHUTE
	spawn(5)
		trunk = locate() in loc
		if(trunk)
			trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/deliveryChute/Bumped(atom/movable/AM) //Go straight into the chute
	if(!AM.disposalEnterTry())
		return
	switch(dir)
		if(NORTH)
			if(AM.loc.y != loc.y+1) return
		if(EAST)
			if(AM.loc.x != loc.x+1) return
		if(SOUTH)
			if(AM.loc.y != loc.y-1) return
		if(WEST)
			if(AM.loc.x != loc.x-1) return

	if(istype(AM, /obj))
		var/obj/O = AM
		O.loc = src
	else if(istype(AM, /mob))
		var/mob/M = AM
		if(prob(2)) // to prevent mobs being stuck in infinite loops
			M << "<span class='warning'>You hit the edge of the chute.</span>"
			return
		M.loc = src
	flush()

/atom/movable/proc/disposalEnterTry()
	return 1

/obj/item/projectile/disposalEnterTry()
	return

/obj/effect/disposalEnterTry()
	return

/obj/mecha/disposalEnterTry()
	return

/obj/machinery/disposal/deliveryChute/newHolderDestination(obj/structure/disposalholder/H)
	H.destinationTag = 1

