/obj/machinery/bot/secbot
	name = "Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5
//	weight = 1.0E7
	req_access = list(access_security)
	var/locked = 1 //Behavior Controls lock
	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/frustration = 0
//	var/emagged = 0 //Emagged Secbots view everyone as a criminal
	var/idcheck = 0 //If false, all station IDs are authorized for weapons.
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff

	var/mode = 0
#define SECBOT_IDLE 		0		// idle
#define SECBOT_HUNT 		1		// found target, hunting
#define SECBOT_PREP_ARREST 	2		// at target, preparing to arrest
#define SECBOT_ARREST		3		// arresting target
#define SECBOT_START_PATROL	4		// start patrol
#define SECBOT_PATROL		5		// patrolling
#define SECBOT_SUMMON		6		// summoned by PDA

	var/auto_patrol = 0		// set to make bot automatically patrol

	var/obj/machinery/camera/cam //Camera for the AI to find them I guess

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = 1447		// bot control frequency


	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route
	var/list/path = new				// list of path turfs

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/nearest_beacon			// the nearest beacon's tag
	var/turf/nearest_beacon_loc	// the nearest beacon's location


/obj/machinery/bot/secbot/beepsky
	name = "Officer Beep O'sky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey."
	idcheck = 0
	auto_patrol = 1

/obj/item/weapon/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess



/obj/machinery/bot/secbot
	New()
		..()
		src.icon_state = "secbot[src.on]"
		spawn(3)
			src.botcard = new /obj/item/weapon/card/id(src)
			src.botcard.access = get_access("Detective")
			src.cam = new /obj/machinery/camera(src)
			src.cam.c_tag = src.name
			src.cam.network = "SS13"
			if(radio_controller)
				radio_controller.add_object(src, control_freq, filter = RADIO_SECBOT)
				radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)


/obj/machinery/bot/secbot/turn_on()
	..()
	src.icon_state = "secbot[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/secbot/turn_off()
	..()
	src.target = null
	src.oldtarget_name = null
	src.anchored = 0
	src.mode = SECBOT_IDLE
	walk_to(src,0)
	src.icon_state = "secbot[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/secbot/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	usr.machine = src
	interact(user)

/obj/machinery/bot/secbot/proc/interact(mob/user as mob)
	var/dat

	dat += text({"
<TT><B>Automatic Security Unit v1.3</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )

	if(!src.locked)
		dat += text({"<BR>
Check for Weapon Authorization: []<BR>
Check Security Records: []<BR>
Operating Mode: []<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=idcheck'>[src.idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[src.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[src.arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )


	user << browse("<HEAD><TITLE>Securitron v1.3 controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/bot/secbot/Topic(href, href_list)
	usr.machine = src
	src.add_fingerprint(usr)
	if((href_list["power"]) && (src.allowed(usr)))
		if(src.on)
			turn_off()
		else
			turn_on()
		return

	switch(href_list["operation"])
		if("idcheck")
			src.idcheck = !src.idcheck
			src.updateUsrDialog()
		if("ignorerec")
			src.check_records = !src.check_records
			src.updateUsrDialog()
		if("switchmode")
			src.arrest_type = !src.arrest_type
			src.updateUsrDialog()
		if("patrol")
			auto_patrol = !auto_patrol
			mode = SECBOT_IDLE
			updateUsrDialog()

/obj/machinery/bot/secbot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(src.allowed(user))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."
	else
		..()
		if(!istype(W, /obj/item/weapon/screwdriver) && (W.force) && (!src.target))
			src.target = user
			src.mode = SECBOT_HUNT

/obj/machinery/bot/secbot/Emag(mob/user as mob)
	if(user) user << "\red You short out [src]'s target assessment circuits."
	spawn(0)
		for(var/mob/O in hearers(src, null))
			O.show_message("\red <B>[src] buzzes oddly!</B>", 1)
	src.target = null
	if(user) src.oldtarget_name = user.name
	src.last_found = world.time
	src.anchored = 0
	src.emagged = 1
	src.on = 1
	src.icon_state = "secbot[src.on]"
	mode = SECBOT_IDLE

/obj/machinery/bot/secbot/process()
	set background = 1

	if(!src.on)
		return

	switch(mode)

		if(SECBOT_IDLE)		// idle

			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = SECBOT_START_PATROL	// switch to patrol mode

		if(SECBOT_HUNT)		// hunting for perp

			// if can't reach perp for long enough, go idle
			if(src.frustration >= 8)
		//		for(var/mob/O in hearers(src, null))
		//			O << "<span class='game say'><span class='name'>[src]</span> beeps, \"Backup requested! Suspect has evaded arrest.\""
				src.target = null
				src.last_found = world.time
				src.frustration = 0
				src.mode = 0
				walk_to(src,0)

			if(target)		// make sure target exists
				if(get_dist(src, src.target) <= 1)		// if right next to perp
					playsound(src.loc, 'Egloves.ogg', 50, 1, -1)
					src.icon_state = "secbot-c"
					spawn(2)
						src.icon_state = "secbot[src.on]"
					var/mob/living/carbon/M = src.target
					var/maxstuns = 4
					if(istype(M, /mob/living/carbon/human))
						if(M.stuttering < 10 && (!(HULK in M.mutations)))
							M.stuttering = 10
						M.Stun(10)
						M.Weaken(10)
					else
						M.Weaken(10)
						M.stuttering = 10
						M.Stun(10)
					maxstuns--
					if(maxstuns <= 0)
						target = null
					for(var/mob/O in viewers(src, null))
						O.show_message("\red <B>[src.target] has been stunned by [src]!</B>", 1, "\red You hear someone fall", 2)

					mode = SECBOT_PREP_ARREST
					src.anchored = 1
					src.target_lastloc = M.loc
					return

				else								// not next to perp
					var/turf/olddist = get_dist(src, src.target)
					walk_to(src, src.target,1,4)
					if((get_dist(src, src.target)) >= (olddist))
						src.frustration++
					else
						src.frustration = 0

		if(SECBOT_PREP_ARREST)		// preparing to arrest target

			// see if he got away
			if((get_dist(src, src.target) > 1) || ((src.target:loc != src.target_lastloc) && src.target:weakened < 2))
				src.anchored = 0
				mode = SECBOT_HUNT
				return

			if(!src.target.handcuffed && !src.arrest_type)
				playsound(src.loc, 'handcuffs.ogg', 30, 1, -2)
				mode = SECBOT_ARREST
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src] is trying to put handcuffs on [src.target]!</B>", 1)

				spawn(60)
					if(get_dist(src, src.target) <= 1)
						if(src.target.handcuffed)
							return

						if(istype(src.target,/mob/living/carbon))
							target.handcuffed = new /obj/item/weapon/handcuffs(target)
							target.update_inv_handcuffed()	//update the handcuffs overlay

						mode = SECBOT_IDLE
						src.target = null
						src.anchored = 0
						src.last_found = world.time
						src.frustration = 0

						playsound(src.loc, pick('bgod.ogg', 'biamthelaw.ogg', 'bsecureday.ogg', 'bradio.ogg', 'binsult.ogg', 'bcreep.ogg'), 50, 0)
	//					var/arrest_message = pick("Have a secure day!","I AM THE LAW.", "God made tomorrow for the crooks we don't catch today.","You can't outrun a radio.")
	//					src.speak(arrest_message)

		if(SECBOT_ARREST)		// arresting

			if(!target || target.handcuffed)
				src.anchored = 0
				mode = SECBOT_IDLE
				return


		if(SECBOT_START_PATROL)	// start a patrol

			if(path.len > 0 && patrol_target)	// have a valid path, so just resume
				mode = SECBOT_PATROL
				return

			else if(patrol_target)		// has patrol target already
				spawn(0)
					calc_path()		// so just find a route to it
					if(path.len == 0)
						patrol_target = 0
						return
					mode = SECBOT_PATROL


			else					// no patrol target, so need a new one
				find_patrol_target()
				speak("Engaging patrol mode.")


		if(SECBOT_PATROL)		// patrol mode

			patrol_step()
			spawn(5)
				if(mode == SECBOT_PATROL)
					patrol_step()

		if(SECBOT_SUMMON)		// summoned to PDA
			patrol_step()
			spawn(4)
				if(mode == SECBOT_SUMMON)
					patrol_step()
					sleep(4)
					patrol_step()

	return


// perform a single patrol step

/obj/machinery/bot/secbot/proc/patrol_step()

	if(loc == patrol_target)		// reached target
		at_patrol_target()
		return

	else if(path.len > 0 && patrol_target)		// valid path

		var/turf/next = path[1]
		if(next == loc)
			path -= next
			return


		if(istype( next, /turf/simulated))

			var/moved = step_towards(src, next)	// attempt to move
			if(moved)	// successful move
				blockcount = 0
				path -= loc

				look_for_perp()
			else		// failed to move

				blockcount++

				if(blockcount > 5)	// attempt 5 times before recomputing
					// find new path excluding blocked turf

					spawn(2)
						calc_path(next)
						if(path.len == 0)
							find_patrol_target()
						else
							blockcount = 0

					return

				return

		else	// not a valid turf
			mode = SECBOT_IDLE
			return

	else	// no path, so calculate new one
		mode = SECBOT_START_PATROL


// finds a new patrol target
/obj/machinery/bot/secbot/proc/find_patrol_target()
	send_status()
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
/obj/machinery/bot/secbot/proc/find_nearest_beacon()
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
			mode = SECBOT_IDLE
			speak("Disengaging patrol mode.")
			send_status()


/obj/machinery/bot/secbot/proc/at_patrol_target()
	find_patrol_target()
	return


// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/secbot/proc/set_destination(var/new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1


// receive a radio signal
// used for beacon reception

/obj/machinery/bot/secbot/receive_signal(datum/signal/signal)
	//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/bot/secbot/receive_signal([signal.debug_print()])")
	if(!on)
		return

	/*
	world << "rec signal: [signal.source]"
	for(var/x in signal.data)
		world << "* [x] = [signal.data[x]]"
	*/

	var/recv = signal.data["command"]
	// process all-bot input
	if(recv=="bot_status")
		send_status()

	// check to see if we are the commanded bot
	if(signal.data["active"] == src)
	// process control input
		switch(recv)
			if("stop")
				mode = SECBOT_IDLE
				auto_patrol = 0
				return

			if("go")
				mode = SECBOT_IDLE
				auto_patrol = 1
				return

			if("summon")
				patrol_target = signal.data["target"]
				next_destination = destination
				destination = null
				awaiting_beacon = 0
				mode = SECBOT_SUMMON
				calc_path()
				speak("Responding.")

				return



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
/obj/machinery/bot/secbot/proc/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/secbot/proc/post_signal_multiple(var/freq, var/list/keyval)

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
	else if(signal.data["type"] == "secbot")
		frequency.post_signal(src, signal, filter = RADIO_SECBOT)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/secbot/proc/send_status()
	var/list/kv = list(
	"type" = "secbot",
	"name" = name,
	"loca" = loc.loc,	// area
	"mode" = mode
	)
	post_signal_multiple(control_freq, kv)



// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/secbot/proc/calc_path(var/turf/avoid = null)
	src.path = AStar(src.loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=avoid)
	src.path = reverselist(src.path)


// look for a criminal in view of the bot

/obj/machinery/bot/secbot/proc/look_for_perp()
	src.anchored = 0
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == src.oldtarget_name) && (world.time < src.last_found + 100))
			continue

		if(istype(C, /mob/living/carbon/human))
			src.threatlevel = src.assess_perp(C)
		else if((src.idcheck) && (istype(C, /mob/living/carbon/monkey)))
			src.threatlevel = 4

		if(!src.threatlevel)
			continue

		else if(src.threatlevel >= 4)
			src.target = C
			src.oldtarget_name = C.name
			src.speak("Level [src.threatlevel] infraction alert!")
			playsound(src.loc, pick('bcriminal.ogg', 'bjustice.ogg', 'bfreeze.ogg'), 50, 0)
			src.visible_message("<b>[src]</b> points at [C.name]!")
			mode = SECBOT_HUNT
			spawn(0)
				process()	// ensure bot quickly responds to a perp
			break
		else
			continue


//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
/obj/machinery/bot/secbot/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0

	if(src.emagged) return 10 //Everyone is a criminal!

	if(src.idcheck && !src.allowed(perp))

		if(istype(perp.l_hand, /obj/item/weapon/gun) || istype(perp.l_hand, /obj/item/weapon/melee))
			if(!istype(perp.l_hand, /obj/item/weapon/gun/energy/laser/bluetag) \
			&& !istype(perp.l_hand, /obj/item/weapon/gun/energy/laser/redtag) \
			&& !istype(perp.l_hand, /obj/item/weapon/gun/energy/laser/practice))
				threatcount += 4

		if(istype(perp.r_hand, /obj/item/weapon/gun) || istype(perp.r_hand, /obj/item/weapon/melee))
			if(!istype(perp.r_hand, /obj/item/weapon/gun/energy/laser/bluetag) \
			&& !istype(perp.r_hand, /obj/item/weapon/gun/energy/laser/redtag) \
			&& !istype(perp.r_hand, /obj/item/weapon/gun/energy/laser/practice))
				threatcount += 4

		if(istype(perp:belt, /obj/item/weapon/gun) || istype(perp:belt, /obj/item/weapon/melee))
			if(!istype(perp:belt, /obj/item/weapon/gun/energy/laser/bluetag) \
			&& !istype(perp:belt, /obj/item/weapon/gun/energy/laser/redtag) \
			&& !istype(perp:belt, /obj/item/weapon/gun/energy/laser/practice))
				threatcount += 2

		if(istype(perp:wear_suit, /obj/item/clothing/suit/wizrobe))
			threatcount += 2

		if(perp.dna && perp.dna.mutantrace && perp.dna.mutantrace != "none")
			threatcount += 2

		//Agent cards lower threatlevel.
		if(istype(perp:wear_id, /obj/item/weapon/card/id/syndicate))
			threatcount -= 2

	if(src.check_records)
		for (var/datum/data/record/E in data_core.general)
			var/perpname = perp.name
			if(perp:wear_id)
				var/obj/item/weapon/card/id/id = perp:wear_id
				if(istype(perp:wear_id, /obj/item/device/pda))
					var/obj/item/device/pda/pda = perp:wear_id
					id = pda.id
				if(id)
					perpname = id.registered_name
				else
					var/obj/item/device/pda/pda = perp:wear_id
					perpname = pda.owner
			if(E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						threatcount = 4
						break

	return threatcount

/obj/machinery/bot/secbot/Bump(M as mob|obj) //Leave no door unopened!
	if((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
		var/obj/machinery/door/D = M
		if(!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard))
			D.open()
			src.frustration = 0
	else if((istype(M, /mob/living/)) && (!src.anchored))
		src.loc = M:loc
		src.frustration = 0
	return

/* terrible
/obj/machinery/bot/secbot/Bumped(atom/movable/M as mob|obj)
	spawn(0)
		if(M)
			var/turf/T = get_turf(src)
			M:loc = T
*/

/obj/machinery/bot/secbot/proc/speak(var/message)
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)
	return


/obj/machinery/bot/secbot/explode()

	walk_to(src,0)
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/secbot_assembly/Sa = new /obj/item/weapon/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = src.name
	new /obj/item/device/assembly/prox_sensor(Tsec)

	var/obj/item/weapon/melee/baton/B = new /obj/item/weapon/melee/baton(Tsec)
	B.charges = 0

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(src.loc)
	del(src)

/obj/machinery/bot/secbot/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		src.target = user
		src.mode = SECBOT_HUNT

/obj/machinery/bot/secbot/emp_act(severity)
	if(cam)
		cam.emp_act(severity)
	..()

//Secbot Construction

/obj/item/clothing/head/helmet/attackby(var/obj/item/device/assembly/signaler/S, mob/user as mob)
	..()
	if(!issignaler(S))
		..()
		return

	if(src.type != /obj/item/clothing/head/helmet) //Eh, but we don't want people making secbots out of space helmets.
		return

	if(S.secured)
		del(S)
		var/obj/item/weapon/secbot_assembly/A = new /obj/item/weapon/secbot_assembly
		user.put_in_hands(A)
		user << "You add the signaler to the helmet."
		user.drop_from_inventory(src)
		del(src)
	else
		return

/obj/item/weapon/secbot_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if((istype(W, /obj/item/weapon/weldingtool)) && (!src.build_step))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			src.build_step++
			src.overlays += image('icons/obj/aibots.dmi', "hs_hole")
			user << "You weld a hole in [src]!"

	else if(isprox(W) && (src.build_step == 1))
		user.drop_item()
		src.build_step++
		user << "You add the prox sensor to [src]!"
		src.overlays += image('icons/obj/aibots.dmi', "hs_eye")
		src.name = "helmet/signaler/prox sensor assembly"
		del(W)

	else if(((istype(W, /obj/item/robot_parts/l_arm)) || (istype(W, /obj/item/robot_parts/r_arm))) && (src.build_step == 2))
		user.drop_item()
		src.build_step++
		user << "You add the robot arm to [src]!"
		src.name = "helmet/signaler/prox sensor/robot arm assembly"
		src.overlays += image('icons/obj/aibots.dmi', "hs_arm")
		del(W)

	else if((istype(W, /obj/item/weapon/melee/baton)) && (src.build_step >= 3))
		user.drop_item()
		src.build_step++
		user << "You complete the Securitron! Beep boop."
		var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot
		S.loc = get_turf(src)
		S.name = src.created_name
		del(W)
		del(src)

	else if(istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t
