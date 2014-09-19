//Floorbot assemblies
/obj/item/weapon/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS
	var/created_name = "Floorbot"

/obj/item/weapon/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS
	var/created_name = "Floorbot"

// Tell other floorbots what we're fucking with so two floorbots don't dick with the same tile.
var/global/list/floorbot_targets=list()

//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	//weight = 1.0E7
	var/mode = 0
#define FLOORBOT_IDLE 		    0		// idle
#define FLOORBOT_FIXING_SHIT    1
#define FLOORBOT_START_PATROL	2		// start patrol
#define FLOORBOT_PATROL		    3		// patrolling

	var/auto_patrol = 0		// set to make bot automatically patrol
	var/amount = 10
	var/repairing = 0
	var/improvefloors = 0
	var/eattiles = 0
	var/maketiles = 0
	var/turf/target
	var/turf/oldtarget
	var/oldloc = null
	req_access = list(access_construction)
	var/path[] = new()
	var/targetdirection
	var/beacon_freq = 1445		// navigation beacon frequency


	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route
	var/list/patpath = new				// list of path turfs

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/nearest_beacon			// the nearest beacon's tag
	var/turf/nearest_beacon_loc	// the nearest beacon's location


/obj/machinery/bot/floorbot/New()
	. = ..()
	src.updateicon()

/obj/machinery/bot/floorbot/turn_on()
	. = ..()
	src.updateicon()
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/turn_off()
	..()
	if(!isnull(src.target))
		floorbot_targets -= src.target
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.updateicon()
	src.path = new()
	src.patpath = new()
	src.updateUsrDialog()
	src.mode=FLOORBOT_IDLE

/obj/machinery/bot/floorbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/floorbot/interact(mob/user as mob)
	var/dat
	dat += "<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [src.open ? "opened" : "closed"]<BR>"
	dat += "Tiles left: [src.amount]<BR>"
	dat += "Behvaiour controls are [src.locked ? "locked" : "unlocked"]<BR>"
	if(!src.locked || issilicon(user))
		dat += "Improves floors: <A href='?src=\ref[src];operation=improve'>[src.improvefloors ? "Yes" : "No"]</A><BR>"
		dat += "Finds tiles: <A href='?src=\ref[src];operation=tiles'>[src.eattiles ? "Yes" : "No"]</A><BR>"
		dat += "Make single pieces of metal into tiles when empty: <A href='?src=\ref[src];operation=make'>[src.maketiles ? "Yes" : "No"]</A><BR>"

	user << browse("<HEAD><TITLE>Repairbot v1.0 controls</TITLE></HEAD>[dat]", "window=autorepair")
	onclose(user, "autorepair")
	return


/obj/machinery/bot/floorbot/proc/speak(var/message)
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)
	return

/obj/machinery/bot/floorbot/attackby(var/obj/item/W , mob/user as mob)
	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(src.amount >= 50)
			return
		var/loaded = min(50-src.amount, T.amount)
		T.use(loaded)
		src.amount += loaded
		user << "<span class='notice'>You load [loaded] tiles into the floorbot. He now contains [src.amount] tiles.</span>"
		src.updateicon()
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(src.allowed(usr) && !open && !emagged)
			src.locked = !src.locked
			user << "<span class='notice'>You [src.locked ? "lock" : "unlock"] the [src] behaviour controls.</span>"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='warning'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='warning'>Access denied.</span>"
		src.updateUsrDialog()
	else
		..()

/obj/machinery/bot/floorbot/Emag(mob/user as mob)
	..()
	if(open && !locked)
		if(user) user << "<span class='notice'>The [src] buzzes and beeps.</span>"

/obj/machinery/bot/floorbot/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	switch(href_list["operation"])
		if("start")
			if (src.on)
				turn_off()
			else
				turn_on()
		if("improve")
			src.improvefloors = !src.improvefloors
			src.updateUsrDialog()
		if("tiles")
			src.eattiles = !src.eattiles
			src.updateUsrDialog()
		if("make")
			src.maketiles = !src.maketiles
			src.updateUsrDialog()

/obj/machinery/bot/floorbot/proc/is_obj_valid_target(var/atom/T,var/list/floorbottargets)
	if(T in floorbottargets)
		return 0
	if(T == src.oldtarget)
		return 0
	if(istype(T.loc, /turf/simulated/wall))
		return 0
	if(!T.loc.Enter(src))
		return 0
	return 1

/obj/machinery/bot/floorbot/proc/hunt_for_tiles(var/list/shit_in_view, var/list/floorbottargets)
	for(var/obj/item/stack/tile/plasteel/T in shit_in_view)
		if(!(T in floorbot_targets) && src.is_obj_valid_target(T,floorbottargets))
			src.oldtarget = T
			src.target = T
			floorbot_targets +=T
			mode=FLOORBOT_FIXING_SHIT
			return

/obj/machinery/bot/floorbot/proc/hunt_for_metal(var/list/shit_in_view, var/list/floorbottargets)
	for(var/obj/item/stack/sheet/metal/M in shit_in_view)
		if(!(M in floorbot_targets) && src.is_obj_valid_target(M) && M.amount == 1)
			src.oldtarget = M
			src.target = M
			floorbot_targets += M
			mode=FLOORBOT_FIXING_SHIT
			return

/obj/machinery/bot/floorbot/proc/have_target()
	return (src.target != null)

/obj/machinery/bot/floorbot/process()
	//set background = 1

	if(!src.on)
		return
	if(src.repairing)
		return

	switch(mode)
		if(FLOORBOT_IDLE)		// idle
			walk_to(src,0)
			if(checkforwork())	// see if any criminals are in range
				return
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = FLOORBOT_START_PATROL	// switch to patrol mode
		if(FLOORBOT_FIXING_SHIT)
			src.fix_shit()
			return
		if(FLOORBOT_START_PATROL)	// start a patrol
			if(patpath.len > 0 && patrol_target)	// have a valid path, so just resume
				mode = FLOORBOT_PATROL
				return

			else if(patrol_target)		// has patrol target already
				spawn(0)
					calc_path()		// so just find a route to it
					if(patpath.len == 0)
						patrol_target = 0
						return
					mode = FLOORBOT_PATROL


			else					// no patrol target, so need a new one
				find_patrol_target()
				speak("That's done, what's next?")


		if(FLOORBOT_PATROL)		// patrol mode
			patrol_step()
			spawn(5)
				if(mode == FLOORBOT_PATROL)
					patrol_step()

/obj/machinery/bot/floorbot/proc/fix_shit()
	if(!src.have_target())
		if(src.loc != src.oldloc)
			src.oldtarget = null
		return 0
	if(!src.path)
		src.path = new()
	if(src.target && (src.target != null) && src.path.len == 0)
		spawn(0)
			if(!istype(src.target, /turf/))
				src.path = AStar(src.loc, src.target.loc, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30, id=botcard)
			else
				src.path = AStar(src.loc, src.target, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30, id=botcard)
			if (!src.path) src.path = list()
			if(src.path.len == 0)
				src.oldtarget = src.target
				floorbot_targets -= src.target
				src.target = null
		return 1
	if(src.path.len > 0 && src.target && (src.target != null))
		step_to(src, src.path[1])
		src.path -= src.path[1]
	else if(src.path.len == 1)
		step_to(src, target)
		src.path = new()

	if(src.loc == src.target || src.loc == src.target.loc)
		if(istype(src.target, /obj/item/stack/tile/plasteel))
			src.eattile(src.target)
			mode=FLOORBOT_IDLE
		else if(istype(src.target, /obj/item/stack/sheet/metal))
			src.maketile(src.target)
			mode=FLOORBOT_IDLE
		//else if(istype(src.target, /turf/) && emagged < 2)
		else if((src.target.is_plating() || istype(src.target,/turf/space/)) && emagged < 2)
			repair(src.target)
			mode=FLOORBOT_IDLE
		else if(src.target.is_plasteel_floor() && (src.target:broken || src.target:burnt) && emagged < 2)
			var/turf/simulated/floor/F = src.target
			src.anchored = 1
			src.repairing = 1
			F.break_tile_to_plating()
			spawn(50)
				src.anchored = 0
				src.repairing = 0
				src.target = null
				floorbot_targets -= src.target
			mode=FLOORBOT_IDLE
		else if(src.target.is_plating() && emagged == 2)
			var/turf/simulated/floor/F = src.target
			src.anchored = 1
			src.repairing = 1
			if(prob(90))
				F.break_tile_to_plating()
			else
				F.ReplaceWithLattice()
			visible_message("\red [src] makes an excited booping sound.")
			spawn(50)
				src.amount ++
				src.anchored = 0
				src.repairing = 0
				src.target = null
				floorbot_targets -= src.target
			mode=FLOORBOT_IDLE
		src.path = new()
		mode=FLOORBOT_IDLE
		return 1

	src.oldloc = src.loc
	return 1

/obj/machinery/bot/floorbot/proc/checkforwork()
	if(src.have_target())
		return 0
	var/list/floorbottargets = list()

	// Needed because we used to look this up 15 goddamn times per process. - Nexypoo
	var/list/shitICanSee = view(7, src)

	if(src.amount <= 0 && !src.have_target())
		if(src.eattiles)
			if(src.hunt_for_tiles(shitICanSee, floorbottargets))
				return 1
		if(src.maketiles && !src.have_target())
			if(src.hunt_for_metal(shitICanSee, floorbottargets))
				return 1
		else
			return 0

	if(prob(5))
		visible_message("[src] makes an excited booping beeping sound!")

	if(!src.have_target() && emagged < 2)
		if(targetdirection != null)
			/*
			for (var/turf/space/D in shitICanSee)
				if(!(D in floorbottargets) && D != src.oldtarget)			// Added for bridging mode -- TLE
					if(get_dir(src, D) == targetdirection)
						src.oldtarget = D
						src.target = D
						break
			*/
			var/turf/T = get_step(src, targetdirection)
			if(istype(T, /turf/space) && !(T in floorbot_targets))
				src.oldtarget = T
				src.target = T
				floorbot_targets+=T
				mode=FLOORBOT_FIXING_SHIT
				return 1
		if(!src.have_target())
			for (var/turf/space/D in shitICanSee)
				if(!(D in floorbottargets) && D != src.oldtarget && (D.loc.name != "Space") && !(D in floorbot_targets))
					src.oldtarget = D
					src.target = D
					floorbot_targets += D
					mode=FLOORBOT_FIXING_SHIT
					return 1
		if((!src.target || src.target == null ) && src.improvefloors)
			for (var/turf/simulated/floor/F in shitICanSee)
			    // So, what the dick are we doing, here?
			    // ORIGINAL: if(!(F in floorbottargets) && F != src.oldtarget && F.icon_state == "Floor1" && !(istype(F, /turf/simulated/floor/plating)))
			    // Using new erro flags:
				if(!(F in floorbottargets) && F != src.oldtarget && F.is_plating() && !(istype(F, /turf/simulated/wall)) && !(F in floorbot_targets))
					if(!F.broken && !F.burnt)
						src.oldtarget = F
						src.target = F
						floorbot_targets += F
						mode=FLOORBOT_FIXING_SHIT
						return 1
				if(!(F in floorbottargets) && !(F in floorbot_targets) && F != src.oldtarget && F.is_plasteel_floor() && (F.broken||F.burnt))
					src.oldtarget = F
					src.target = F
					floorbot_targets += F
					mode=FLOORBOT_FIXING_SHIT
					return 1

	if(!src.have_target() && emagged == 2)
		for (var/turf/simulated/floor/D in shitICanSee)
			//if(!(D in floorbottargets) && D != src.oldtarget && D.floor_tile)
			if(!(D in floorbottargets) && D != src.oldtarget && D.is_plasteel_floor() && !(D in floorbot_targets))
				src.oldtarget = D
				src.target = D
				floorbot_targets += D
				mode=FLOORBOT_FIXING_SHIT
				return 1
	return 0

/obj/machinery/bot/floorbot/proc/repair(var/turf/target)
	if(istype(target, /turf/space/))
		if(target.loc.name == "Space")
			return
	else if(!istype(target, /turf/simulated/floor))
		return
	if(src.amount <= 0)
		return
	src.anchored = 1
	src.icon_state = "floorbot-c"
	if(istype(target, /turf/space/))
		visible_message("\red [src] begins to repair the hole")
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		src.repairing = 1
		spawn(50)
			T.build(src.loc)
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			floorbot_targets -= src.target
			src.target = null
	else
		var/turf/simulated/floor/F = src.loc
		if(!F.broken && !F.burnt)
			visible_message("\red [src] begins to improve the floor.")
			src.repairing = 1
			spawn(50)
				F.make_plasteel_floor()
				src.repairing = 0
				src.amount -= 1
				src.updateicon()
				src.anchored = 0
				floorbot_targets -= src.target
				src.target = null
		else
			if(F.is_plating())
				visible_message("\red [src] begins to fix dents in the floor.")
				src.repairing = 1
				spawn(20)
					src.repairing = 0
					// Cheap, and does the job.
					F.icon_state = "plating"
					F.burnt = 0
					F.broken = 0
					floorbot_targets -= src.target
					src.target = null

/obj/machinery/bot/floorbot/proc/eattile(var/obj/item/stack/tile/plasteel/T)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		return
	visible_message("\red [src] begins to collect tiles.")
	src.repairing = 1
	spawn(20)
		if(isnull(T))
			src.target = null
			src.repairing = 0
			return
		if(src.amount + T.amount > 50)
			var/i = 50 - src.amount
			src.amount += i
			T.amount -= i
		else
			src.amount += T.amount
			del(T)
		src.updateicon()
		floorbot_targets -= src.target
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/maketile(var/obj/item/stack/sheet/metal/M)
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	if(M.amount > 1)
		return
	visible_message("\red [src] begins to create tiles.")
	src.repairing = 1
	spawn(20)
		if(isnull(M))
			src.target = null
			src.repairing = 0
			return
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		T.amount = 4
		T.loc = M.loc
		if(M.amount==1)
			del(M)
		else
			M.amount--
		floorbot_targets -= src.target
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/updateicon()
	if(src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"


/obj/machinery/bot/floorbot/proc/calc_path(var/turf/avoid = null)
	src.path = AStar(src.loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=avoid)
	src.path = reverseRange(src.path)

// perform a single patrol step

/obj/machinery/bot/floorbot/proc/patrol_step()

	if(loc == patrol_target)		// reached target
		at_patrol_target()
		return

	else if(patpath.len > 0 && patrol_target)		// valid path

		var/turf/next = patpath[1]
		if(next == loc)
			patpath -= next
			return


		if(istype( next, /turf/simulated))

			var/moved = step_towards(src, next)	// attempt to move
			if(moved)	// successful move
				blockcount = 0
				patpath -= loc

				checkforwork()
			else		// failed to move

				blockcount++

				if(blockcount > 5)	// attempt 5 times before recomputing
					// find new path excluding blocked turf

					spawn(2)
						calc_path(next)
						if(patpath.len == 0)
							find_patrol_target()
						else
							blockcount = 0

					return

				return

		else	// not a valid turf
			mode = FLOORBOT_IDLE
			return

	else	// no path, so calculate new one
		mode = FLOORBOT_START_PATROL


// finds a new patrol target
/obj/machinery/bot/floorbot/proc/find_patrol_target()
//	send_status()
	if(awaiting_beacon)			// awaiting beacon response
		awaiting_beacon++
		if(awaiting_beacon > 5)	// wait 5 secs for beacon response
			find_nearest_beacon()	// then go to nearest instead
		return

	if(next_destination)
		set_destination(next_destination)
	else
		find_nearest_beacon()
	return


// finds the nearest beacon to self
// signals all beacons matching the patrol code
/obj/machinery/bot/floorbot/proc/find_nearest_beacon()
	nearest_beacon = null
	new_destination = "__nearest__"
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1
	spawn(10)
		awaiting_beacon = 0
		if(nearest_beacon)
			set_destination(nearest_beacon)
		else
			auto_patrol = 0
			mode = FLOORBOT_IDLE
			speak("Disengaging patrol mode.")
			//send_status()


/obj/machinery/bot/floorbot/proc/at_patrol_target()
	find_patrol_target()
	return

/obj/machinery/bot/floorbot/Bump(M as mob|obj) //Leave no door unopened!
	if((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
		var/obj/machinery/door/D = M
		if(!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard))
			D.open()
	return

/obj/machinery/bot/floorbot/receive_signal(datum/signal/signal)
	//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/bot/secbot/receive_signal([signal.debug_print()])")
	if(!on)
		return

	var/recv = signal.data["command"]

	// receive response from beacon
	recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	if(recv == new_destination)	// if the recvd beacon location matches the set destination
								// the we will navigate there
		destination = new_destination
		patrol_target = signal.source.loc
		next_destination = signal.data["next_patrol"]
		awaiting_beacon = 0

	// if looking for nearest beacon
	else if(new_destination == "__nearest__")
		var/dist = get_dist(src,signal.source.loc)
		if(nearest_beacon)

			// note we ignore the beacon we are located at
			if(dist>1 && dist<get_dist(src,nearest_beacon_loc))
				nearest_beacon = recv
				nearest_beacon_loc = signal.source.loc
				return
			else
				return
		else if(dist > 1)
			nearest_beacon = recv
			nearest_beacon_loc = signal.source.loc
	return

// send a radio signal with a single data key/value pair
/obj/machinery/bot/floorbot/proc/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/floorbot/proc/post_signal_multiple(var/freq, var/list/keyval)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency) return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	//for(var/key in keyval)
	//	signal.data[key] = keyval[key]
	signal.data = keyval
		//world << "sent [key],[keyval[key]] on [freq]"
	if(signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else
		frequency.post_signal(src, signal)

// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/floorbot/proc/set_destination(var/new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1

/obj/machinery/bot/floorbot/explode()
	src.on = 0
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/storage/toolbox/mechanical/N = new /obj/item/weapon/storage/toolbox/mechanical(Tsec)
	N.contents = list()

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	if(src.target)
		floorbot_targets -= src.target

	while (amount)//Dumps the tiles into the appropriate sized stacks
		if(amount >= 16)
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = 16
			amount -= 16
		else
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = src.amount
			amount = 0

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	del(src)
	return


/obj/item/weapon/storage/toolbox/mechanical/attackby(var/obj/item/stack/tile/plasteel/T, mob/user as mob)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		..()
		return
	if(src.contents.len >= 1)
		user << "<span class='notice'>They wont fit in as there is already stuff inside.</span>"
		return
	if(user.s_active)
		user.s_active.close(user)
	del(T)
	var/obj/item/weapon/toolbox_tiles/B = new /obj/item/weapon/toolbox_tiles
	user.put_in_hands(B)
	user << "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>"
	user.drop_from_inventory(src)
	del(src)

/obj/item/weapon/toolbox_tiles/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(isprox(W))
		del(W)
		var/obj/item/weapon/toolbox_tiles_sensor/B = new /obj/item/weapon/toolbox_tiles_sensor()
		B.created_name = src.created_name
		user.put_in_hands(B)
		user << "<span class='notice'>You add the sensor to the toolbox and tiles!</span>"
		user.drop_from_inventory(src)
		del(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t

/obj/item/weapon/toolbox_tiles_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		del(W)
		var/turf/T = get_turf(user.loc)
		var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot(T)
		A.name = src.created_name
		user << "<span class='notice'>You add the robot arm to the odd looking toolbox assembly! Boop beep!</span>"
		user.drop_from_inventory(src)
		del(src)
	else if (istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter new robot name", src.name, src.created_name)

		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t