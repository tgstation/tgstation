/obj/machinery/bot/ed209
	name = "ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed2090"
	layer = 5.0
	density = 1
	anchored = 0
//	weight = 1.0E7
	req_access = list(access_security)
	health = 100
	maxhealth = 100
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5

	var/lastfired = 0
	var/shot_delay = 3 //.3 seconds between shots
	var/lasercolor = ""
	var/disabled = 0//A holder for if it needs to be disabled, if true it will not seach for targets, shoot at targets, or move, currently only used for lasertag

	//var/lasers = 0

	var/locked = 1 //Behavior Controls lock
	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/frustration = 0
//var/emagged = 0 //Emagged Secbots view everyone as a criminal
	var/idcheck = 1 //If false, all station IDs are authorized for weapons.
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	var/projectile = null//Holder for projectile type, to avoid so many else if chains

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


/obj/item/weapon/ed209_assembly
	name = "ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = ""


/obj/machinery/bot/ed209/New(loc,created_name,created_lasercolor)
	..()
	if(created_name)		name = created_name
	if(created_lasercolor)	lasercolor = created_lasercolor
	src.icon_state = "[lasercolor]ed209[src.on]"
	spawn(3)
		src.botcard = new /obj/item/weapon/card/id(src)
		src.botcard.access = get_access("Detective")
		src.cam = new /obj/machinery/camera(src)
		src.cam.c_tag = src.name
		src.cam.network = "SS13"
		if(radio_controller)
			radio_controller.add_object(src, control_freq, filter = RADIO_SECBOT)
			radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)
		if(lasercolor)
			shot_delay = 6//Longer shot delay because JESUS CHRIST
			check_records = 0//Don't actively target people set to arrest
			arrest_type = 1//Don't even try to cuff
			req_access = list(access_maint_tunnels,access_clown,access_mime)
			arrest_type = 1
			if((lasercolor == "b") && (name == "ED-209 Security Robot"))//Picks a name if there isn't already a custome one
				name = pick("BLUE BALLER","SANIC","BLUE KILLDEATH MURDERBOT")
			if((lasercolor == "r") && (name == "ED-209 Security Robot"))
				name = pick("RED RAMPAGE","RED ROVER","RED KILLDEATH MURDERBOT")

/obj/machinery/bot/ed209/turn_on()
	. = ..()
	src.icon_state = "[lasercolor]ed209[src.on]"
	src.mode = SECBOT_IDLE
	src.updateUsrDialog()

/obj/machinery/bot/ed209/turn_off()
	..()
	src.target = null
	src.oldtarget_name = null
	src.anchored = 0
	src.mode = SECBOT_IDLE
	walk_to(src,0)
	src.icon_state = "[lasercolor]ed209[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/ed209/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat

	dat += text({"
<TT><B>Automatic Security Unit v2.5</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )

	if(!src.locked)
		if(!lasercolor)
			dat += text({"<BR>
Check for Weapon Authorization: []<BR>
Check Security Records: []<BR>
Operating Mode: []<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=idcheck'>[src.idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[src.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[src.arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )
		else
			dat += text({"<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )


	user << browse("<HEAD><TITLE>Securitron v2.5 controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/bot/ed209/Topic(href, href_list)
	if (..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(lasercolor && (istype(usr,/mob/living/carbon/human)))
		var/mob/living/carbon/human/H = usr
		if((lasercolor == "b") && (istype(H.wear_suit, /obj/item/clothing/suit/redtag)))//Opposing team cannot operate it
			return
		else if((lasercolor == "r") && (istype(H.wear_suit, /obj/item/clothing/suit/bluetag)))
			return
	if ((href_list["power"]) && (src.allowed(usr)))
		if (src.on)
			turn_off()
		else
			turn_on()
		return

	switch(href_list["operation"])
		if ("idcheck")
			src.idcheck = !src.idcheck
			src.updateUsrDialog()
		if ("ignorerec")
			src.check_records = !src.check_records
			src.updateUsrDialog()
		if ("switchmode")
			src.arrest_type = !src.arrest_type
			src.updateUsrDialog()
		if("patrol")
			auto_patrol = !auto_patrol
			mode = SECBOT_IDLE
			updateUsrDialog()

/obj/machinery/bot/ed209/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			user << "<span class='notice'>Controls are now [src.locked ? "locked" : "unlocked"].</span>"
		else
			user << "<span class='warning'>Access denied.</span>"
	else
		..()
		if (!istype(W, /obj/item/weapon/screwdriver) && (W.force) && (!src.target))
			src.target = user
			if(lasercolor)//To make up for the fact that lasertag bots don't hunt
				src.shootAt(user)
			src.mode = SECBOT_HUNT

/obj/machinery/bot/ed209/Emag(mob/user as mob)
	..()
	if(user) user << "<span class='warning'>You short out [src]'s target assessment circuits.</span>"
	spawn(0)
		for(var/mob/O in hearers(src, null))
			O.show_message("\red <B>[src] buzzes oddly!</B>", 1)
	src.target = null
	if(user) src.oldtarget_name = user.name
	src.last_found = world.time
	src.anchored = 0
	src.emagged = 1
	src.on = 1
	src.icon_state = "[lasercolor]ed209[src.on]"
	src.projectile = null
	mode = SECBOT_IDLE

/obj/machinery/bot/ed209/process()
	set background = 1

	if (!src.on)
		return
	var/list/targets = list()
	for (var/mob/living/carbon/C in view(12,src)) //Let's find us a target
		var/threatlevel = 0
		if ((C.stat) || (C.lying))
			continue
		if (istype(C, /mob/living/carbon/human))
			threatlevel = src.assess_perp(C)
		else if ((istype(C, /mob/living/carbon/monkey)) && (C.client) && (ticker.mode.name == "monkey"))
			threatlevel = 4
		//src.speak(C.real_name + text(": threat: []", threatlevel))
		if (threatlevel < 4 )
			continue

		var/dst = get_dist(src, C)
		if ( dst <= 1 || dst > 12)
			continue

		targets += C
	if (targets.len>0)
		var/mob/t = pick(targets)
		if (istype(t, /mob/living))
			if ((t.stat!=2) && (t.lying != 1))
				//src.speak("selected target: " + t.real_name)
				src.shootAt(t)
	switch(mode)

		if(SECBOT_IDLE)		// idle
			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = SECBOT_START_PATROL	// switch to patrol mode

		if(SECBOT_HUNT)		// hunting for perp
			if(src.lasercolor)//Lasertag bots do not tase or arrest anyone, just patrol and shoot and whatnot
				mode = SECBOT_IDLE
				return
			// if can't reach perp for long enough, go idle
			if (src.frustration >= 8)
		//		for(var/mob/O in hearers(src, null))
		//			O << "<span class='game say'><span class='name'>[src]</span> beeps, \"Backup requested! Suspect has evaded arrest.\""
				src.target = null
				src.last_found = world.time
				src.frustration = 0
				src.mode = 0
				walk_to(src,0)

			if (target)		// make sure target exists
				if (get_dist(src, src.target) <= 1)		// if right next to perp
					playsound(src.loc, 'Egloves.ogg', 50, 1, -1)
					src.icon_state = "[lasercolor]ed209-c"
					spawn(2)
						src.icon_state = "[lasercolor]ed209[src.on]"
					var/mob/living/carbon/M = src.target
					var/maxstuns = 4
					if (istype(M, /mob/living/carbon/human))
						if (M.stuttering < 10 && (!(HULK in M.mutations))  /*&& (!istype(M:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
							M.stuttering = 10
						M.Stun(10)
						M.Weaken(10)
					else
						M.Weaken(10)
						M.stuttering = 10
						M.Stun(10)
					maxstuns--
					if (maxstuns <= 0)
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
					if ((get_dist(src, src.target)) >= (olddist))
						src.frustration++
					else
						src.frustration = 0

		if(SECBOT_PREP_ARREST)		// preparing to arrest target
			if(src.lasercolor)
				mode = SECBOT_IDLE
				return
			if (!target)
				mode = SECBOT_IDLE
				src.anchored = 0
				return
			// see if he got away
			if ((get_dist(src, src.target) > 1) || ((src.target:loc != src.target_lastloc) && src.target:weakened < 2))
				src.anchored = 0
				mode = SECBOT_HUNT
				return

			if (!src.target.handcuffed && !src.arrest_type)
				playsound(src.loc, 'handcuffs.ogg', 30, 1, -2)
				mode = SECBOT_ARREST
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src] is trying to put handcuffs on [src.target]!</B>", 1)

				spawn(60)
					if (get_dist(src, src.target) <= 1)
						if (src.target.handcuffed)
							return

						if(istype(src.target,/mob/living/carbon))
							src.target.handcuffed = new /obj/item/weapon/handcuffs(src.target)
							target.update_inv_handcuffed()	//update handcuff overlays

						mode = SECBOT_IDLE
						src.target = null
						src.anchored = 0
						src.last_found = world.time
						src.frustration = 0

	//					playsound(src.loc, pick('bgod.ogg', 'biamthelaw.ogg', 'bsecureday.ogg', 'bradio.ogg', 'binsult.ogg', 'bcreep.ogg'), 50, 0)
	//					var/arrest_message = pick("Have a secure day!","I AM THE LAW.", "God made tomorrow for the crooks we don't catch today.","You can't outrun a radio.")
	//					src.speak(arrest_message)

		if(SECBOT_ARREST)		// arresting
			if(src.lasercolor)
				mode = SECBOT_IDLE
				return
			if (!target || src.target.handcuffed)
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

/obj/machinery/bot/ed209/proc/patrol_step()

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
				if(lasercolor)
					sleep(20)
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
/obj/machinery/bot/ed209/proc/find_patrol_target()
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
/obj/machinery/bot/ed209/proc/find_nearest_beacon()
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


/obj/machinery/bot/ed209/proc/at_patrol_target()
	find_patrol_target()
	return


// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/ed209/proc/set_destination(var/new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1


// receive a radio signal
// used for beacon reception

/obj/machinery/bot/ed209/receive_signal(datum/signal/signal)

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
/obj/machinery/bot/ed209/proc/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/ed209/proc/post_signal_multiple(var/freq, var/list/keyval)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency) return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	//for(var/key in keyval)
	//	signal.data[key] = keyval[key]
		//world << "sent [key],[keyval[key]] on [freq]"
	signal.data = keyval
	if (signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if (signal.data["type"] == "secbot")
		frequency.post_signal(src, signal, filter = RADIO_SECBOT)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/ed209/proc/send_status()
	var/list/kv = list(
		"type" = "secbot",
		"name" = name,
		"loca" = loc.loc,	// area
		"mode" = mode,
	)
	post_signal_multiple(control_freq, kv)



// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/ed209/proc/calc_path(var/turf/avoid = null)
	src.path = AStar(src.loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=avoid)
	src.path = reverselist(src.path)


// look for a criminal in view of the bot

/obj/machinery/bot/ed209/proc/look_for_perp()
	if(src.disabled)
		return
	src.anchored = 0
	src.threatlevel = 0
	for (var/mob/living/carbon/C in view(12,src)) //Let's find us a criminal
		if ((C.stat) || (C.handcuffed))
			continue

		if((src.lasercolor) && (C.lying))
			continue//Does not shoot at people lyind down when in lasertag mode, because it's just annoying, and they can fire once they get up.

		if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100))
			continue

		if (istype(C, /mob/living/carbon/human))
			src.threatlevel = src.assess_perp(C)
		else if ((istype(C, /mob/living/carbon/monkey)) && (C.client) && (ticker.mode.name == "monkey"))
			src.threatlevel = 4

		if (!src.threatlevel)
			continue

		else if (src.threatlevel >= 4)
			src.target = C
			src.oldtarget_name = C.name
			src.speak("Level [src.threatlevel] infraction alert!")
			if(!src.lasercolor)
				playsound(src.loc, pick('ed209_20sec.ogg', 'EDPlaceholder.ogg'), 50, 0)
			src.visible_message("<b>[src]</b> points at [C.name]!")
			mode = SECBOT_HUNT
			spawn(0)
				process()	// ensure bot quickly responds to a perp
			break
		else
			continue


//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
/obj/machinery/bot/ed209/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0

	if(src.emagged) return 10 //Everyone is a criminal!

	if((src.idcheck) || (isnull(perp:wear_id)) || (istype(perp:wear_id, /obj/item/weapon/card/id/syndicate)))

		if((istype(perp.l_hand, /obj/item/weapon/gun) && !istype(perp.l_hand, /obj/item/weapon/gun/projectile/shotgun)) || istype(perp.l_hand, /obj/item/weapon/melee/baton))
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

//Agent cards lower threatlevel when normal idchecking is off.
		if((istype(perp:wear_id, /obj/item/weapon/card/id/syndicate)) && src.idcheck)
			threatcount -= 2

	if(src.lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
		threatcount = 0//They will not, however shoot at people who have guns, because it gets really fucking annoying
		if(istype(perp.wear_suit, /obj/item/clothing/suit/redtag))
			threatcount += 4
		if((istype(perp:r_hand,/obj/item/weapon/gun/energy/laser/redtag)) || (istype(perp:l_hand,/obj/item/weapon/gun/energy/laser/redtag)))
			threatcount += 4
		if(istype(perp:belt, /obj/item/weapon/gun/energy/laser/redtag))
			threatcount += 2

	if(src.lasercolor == "r")
		threatcount = 0
		if(istype(perp.wear_suit, /obj/item/clothing/suit/bluetag))
			threatcount += 4
		if((istype(perp:r_hand,/obj/item/weapon/gun/energy/laser/bluetag)) || (istype(perp:l_hand,/obj/item/weapon/gun/energy/laser/bluetag)))
			threatcount += 4
		if(istype(perp:belt, /obj/item/weapon/gun/energy/laser/bluetag))
			threatcount += 2

	if (src.check_records)
		for (var/datum/data/record/E in data_core.general)
			var/perpname = perp.name
			if (perp:wear_id)
				var/obj/item/weapon/card/id/id = perp:wear_id
				if(istype(perp:wear_id, /obj/item/device/pda))
					var/obj/item/device/pda/pda = perp:wear_id
					id = pda.id
				if (id)
					perpname = id.registered_name
				else
					var/obj/item/device/pda/pda = perp:wear_id
					perpname = pda.owner
			if (E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if ((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						threatcount = 4
						break

	if((src.idcheck) && (src.allowed(perp)) && !(src.lasercolor))
		threatcount = 0//Corrupt cops cannot exist beep boop

	return threatcount

/obj/machinery/bot/ed209/Bump(M as mob|obj) //Leave no door unopened!
	if ((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
		var/obj/machinery/door/D = M
		if (!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard))
			D.open()
			src.frustration = 0
	else if ((istype(M, /mob/living/)) && (!src.anchored))
		src.loc = M:loc
		src.frustration = 0
	return

/* terrible
/obj/machinery/bot/ed209/Bumped(atom/movable/M as mob|obj)
	spawn(0)
		if (M)
			var/turf/T = get_turf(src)
			M:loc = T
*/

/obj/machinery/bot/ed209/proc/speak(var/message)
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)
	return

/obj/machinery/bot/ed209/explode()
	walk_to(src,0)
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/ed209_assembly/Sa = new /obj/item/weapon/ed209_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = src.name
	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(!lasercolor)
		var/obj/item/weapon/gun/energy/taser/G = new /obj/item/weapon/gun/energy/taser(Tsec)
		G.power_supply.charge = 0
	else if(lasercolor == "b")
		var/obj/item/weapon/gun/energy/laser/bluetag/G = new /obj/item/weapon/gun/energy/laser/bluetag(Tsec)
		G.power_supply.charge = 0
	else if(lasercolor == "r")
		var/obj/item/weapon/gun/energy/laser/redtag/G = new /obj/item/weapon/gun/energy/laser/redtag(Tsec)
		G.power_supply.charge = 0

	if (prob(50))
		new /obj/item/robot_parts/l_leg(Tsec)
		if (prob(25))
			new /obj/item/robot_parts/r_leg(Tsec)
	if (prob(25))//50% chance for a helmet OR vest
		if (prob(50))
			new /obj/item/clothing/head/helmet(Tsec)
		else
			if(!lasercolor)
				new /obj/item/clothing/suit/armor/vest(Tsec)
			if(lasercolor == "b")
				new /obj/item/clothing/suit/bluetag(Tsec)
			if(lasercolor == "r")
				new /obj/item/clothing/suit/redtag(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(src.loc)
	del(src)


/obj/machinery/bot/ed209/proc/shootAt(var/mob/target)
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	var/turf/T = loc
	var/atom/U = (istype(target, /atom/movable) ? target.loc : target)
	if ((!( U ) || !( T )))
		return
	while(!( istype(U, /turf) ))
		U = U.loc
	if (!( istype(T, /turf) ))
		return

	//if(lastfired && world.time - lastfired < 100)
	//	playsound(src.loc, 'ed209_shoot.ogg', 50, 0)

	if(!projectile)
		if(!lasercolor)
			if (src.emagged)
				projectile = /obj/item/projectile/beam
			else
				projectile = /obj/item/projectile/energy/electrode
		else if(lasercolor == "b")
			if (src.emagged)
				projectile = /obj/item/projectile/omnitag
			else
				projectile = /obj/item/projectile/bluetag
		else if(lasercolor == "r")
			if (src.emagged)
				projectile = /obj/item/projectile/omnitag
			else
				projectile = /obj/item/projectile/redtag

	if (!( istype(U, /turf) ))
		return
	var/obj/item/projectile/A = new projectile (loc)
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn( 0 )
		A.process()
		return
	return

/obj/machinery/bot/ed209/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if (!isalien(target))
		src.target = user
		src.mode = SECBOT_HUNT


/obj/machinery/bot/ed209/emp_act(severity)
	if (cam)
		cam.emp_act(severity)
	if(severity==2 && prob(70))
		..(severity-1)
	else
		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)
		spawn(10)
			del(pulse2)
		var/list/mob/living/carbon/targets = new
		for (var/mob/living/carbon/C in view(12,src))
			if (C.stat==2)
				continue
			targets += C
		if(targets.len)
			if(prob(50))
				var/mob/toshoot = pick(targets)
				if (toshoot)
					targets-=toshoot
					if (prob(50) && !emagged)
						emagged = 1
						shootAt(toshoot)
						emagged = 0
					else
						shootAt(toshoot)
			else if(prob(50))
				if(targets.len)
					var/mob/toarrest = pick(targets)
					if (toarrest)
						src.target = toarrest
						src.mode = SECBOT_HUNT



/obj/item/weapon/ed209_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if(istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if(!t)	return
		if(!in_range(src, usr) && src.loc != usr)	return
		created_name = t
		return

	switch(build_step)
		if(0,1)
			if( istype(W, /obj/item/robot_parts/l_leg) || istype(W, /obj/item/robot_parts/r_leg) )
				user.drop_item()
				del(W)
				build_step++
				user << "<span class='notice'>You add the robot leg to [src].</span>"
				name = "legs/frame assembly"
				if(build_step == 1)
					item_state = "ed209_leg"
					icon_state = "ed209_leg"
				else
					item_state = "ed209_legs"
					icon_state = "ed209_legs"

		if(2)
			if( istype(W, /obj/item/clothing/suit/redtag) )
				lasercolor = "r"
			else if( istype(W, /obj/item/clothing/suit/bluetag) )
				lasercolor = "b"
			if( lasercolor || istype(W, /obj/item/clothing/suit/armor/vest) )
				user.drop_item()
				del(W)
				build_step++
				user << "<span class='notice'>You add the armor to [src].</span>"
				name = "vest/legs/frame assembly"
				item_state = "[lasercolor]ed209_shell"
				icon_state = "[lasercolor]ed209_shell"

		if(3)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					build_step++
					name = "shielded frame assembly"
					user << "<span class='notice'>You welded the vest to [src].</span>"
		if(4)
			if( istype(W, /obj/item/clothing/head/helmet) )
				user.drop_item()
				del(W)
				build_step++
				user << "<span class='notice'>You add the helmet to [src].</span>"
				name = "covered and shielded frame assembly"
				item_state = "[lasercolor]ed209_hat"
				icon_state = "[lasercolor]ed209_hat"

		if(5)
			if( isprox(W) )
				user.drop_item()
				del(W)
				build_step++
				user << "<span class='notice'>You add the prox sensor to [src].</span>"
				name = "covered, shielded and sensored frame assembly"
				item_state = "[lasercolor]ed209_prox"
				icon_state = "[lasercolor]ed209_prox"

		if(6)
			if( istype(W, /obj/item/weapon/cable_coil) )
				var/obj/item/weapon/cable_coil/coil = W
				var/turf/T = get_turf(user)
				user << "<span class='notice'>You start to wire [src]...</span>"
				sleep(40)
				if(get_turf(user) == T)
					coil.use(1)
					build_step++
					user << "<span class='notice'>You wire the ED-209 assembly.</span>"
					name = "wired ED-209 assembly"

		if(7)
			switch(lasercolor)
				if("b")
					if( !istype(W, /obj/item/weapon/gun/energy/laser/bluetag) )
						return
					name = "bluetag ED-209 assembly"
				if("r")
					if( !istype(W, /obj/item/weapon/gun/energy/laser/redtag) )
						return
					name = "redtag ED-209 assembly"
				if("")
					if( !istype(W, /obj/item/weapon/gun/energy/taser) )
						return
					name = "taser ED-209 assembly"
				else
					return
			build_step++
			user << "<span class='notice'>You add [W] to [src].</span>"
			src.item_state = "[lasercolor]ed209_taser"
			src.icon_state = "[lasercolor]ed209_taser"
			user.drop_item()
			del(W)

		if(8)
			if( istype(W, /obj/item/weapon/screwdriver) )
				playsound(src.loc, 'Screwdriver.ogg', 100, 1)
				var/turf/T = get_turf(user)
				user << "<span class='notice'>Now attaching the gun to the frame...</span>"
				sleep(40)
				if(get_turf(user) == T)
					build_step++
					name = "armed [name]"
					user << "<span class='notice'>Taser gun attached.</span>"

		if(9)
			if( istype(W, /obj/item/weapon/cell) )
				build_step++
				user << "<span class='notice'>You complete the ED-209.</span>"
				var/turf/T = get_turf(src)
				new /obj/machinery/bot/ed209(T,created_name,lasercolor)
				user.drop_item()
				del(W)
				user.drop_from_inventory(src)
				del(src)


/obj/machinery/bot/ed209/bullet_act(var/obj/item/projectile/Proj)
	if((src.lasercolor == "b") && (src.disabled == 0))
		if(istype(Proj, /obj/item/projectile/redtag))
			src.disabled = 1
			del (Proj)
			sleep(100)
			src.disabled = 0
		else
			..()
	else if((src.lasercolor == "r") && (src.disabled == 0))
		if(istype(Proj, /obj/item/projectile/bluetag))
			src.disabled = 1
			del (Proj)
			sleep(100)
			src.disabled = 0
		else
			..()
	else
		..()

/obj/machinery/bot/ed209/bluetag/New()//If desired, you spawn red and bluetag bots easily
	new /obj/machinery/bot/ed209(get_turf(src),null,"b")
	del(src)


/obj/machinery/bot/ed209/redtag/New()
	new /obj/machinery/bot/ed209(get_turf(src),null,"r")
	del(src)