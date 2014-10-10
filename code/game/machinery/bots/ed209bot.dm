/obj/machinery/bot/ed209
	name = "\improper ED-209 Security Robot"
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

	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/frustration = 0
//var/emagged = 0 //Emagged Secbots view everyone as a criminal
	var/declare_arrests = 1 //When making an arrest, should it notify everyone wearing sechuds?
	var/idcheck = 1 //If true, arrest people with no IDs
	var/weaponscheck = 1 //If true, arrest people for weapons if they don't have access
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	var/projectile = /obj/item/projectile/energy/electrode //Holder for projectile type
	var/shoot_sound = 'sound/weapons/Taser.ogg'

	var/mode = 0
#define SECBOT_IDLE 		0		// idle
#define SECBOT_HUNT 		1		// found target, hunting
#define SECBOT_PREP_ARREST  2		// at target, preparing to arrest
#define SECBOT_ARREST		3		// arresting target
#define SECBOT_START_PATROL	4		// start patrol
#define SECBOT_PATROL		5		// patrolling
#define SECBOT_SUMMON		6		// summoned by PDA

	var/auto_patrol = 0		// set to make bot automatically patrol

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = 1447		// bot control frequency

	//List of weapons that secbots will not arrest for
	var/safe_weapons = list(\
		/obj/item/weapon/gun/energy/laser/bluetag,\
		/obj/item/weapon/gun/energy/laser/redtag,\
		/obj/item/weapon/gun/energy/laser/practice)

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
	name = "\improper ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = ""


/obj/machinery/bot/ed209/New(loc,created_name,created_lasercolor)
	..()
	if(created_name)
		name = created_name
	if(created_lasercolor)
		lasercolor = created_lasercolor
	src.icon_state = "[lasercolor]ed209[src.on]"
	src.set_weapon() //giving it the right projectile and firing sound.
	spawn(3)
		src.botcard = new /obj/item/weapon/card/id(src)
		var/datum/job/detective/J = new/datum/job/detective
		src.botcard.access = J.get_access()

		if(radio_controller)
			radio_controller.add_object(src, control_freq, filter = RADIO_SECBOT)
			radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)
		if(lasercolor)
			shot_delay = 6//Longer shot delay because JESUS CHRIST
			check_records = 0//Don't actively target people set to arrest
			arrest_type = 1//Don't even try to cuff
			req_access = list(access_maint_tunnels, access_theatre)
			arrest_type = 1
			if((lasercolor == "b") && (name == "\improper ED-209 Security Robot"))//Picks a name if there isn't already a custome one
				name = pick("BLUE BALLER","SANIC","BLUE KILLDEATH MURDERBOT")
			if((lasercolor == "r") && (name == "\improper ED-209 Security Robot"))
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
	dat += hack(user)
	dat += text({"
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [src.open ? "opened" : "closed"]<BR>"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )

	if(!src.locked || issilicon(user))
		if(!lasercolor)
			dat += text({"<BR>
Arrest Unidentifiable Persons: []<BR>
Arrest for Unauthorized Weapons: []<BR>
Arrest for Warrant: []<BR>
<BR>
Operating Mode: []<BR>
Report Arrests[]"},

"<A href='?src=\ref[src];operation=idcheck'>[src.idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=weaponscheck'>[src.weaponscheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[src.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[src.arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=declarearrests'>[src.declare_arrests ? "Yes" : "No"]</A>" )


		dat += text({"<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )



	var/datum/browser/popup = new(user, "autosec", "Securitron v2.0.9 controls")
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/bot/ed209/Topic(href, href_list)
	if (..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(lasercolor && (istype(usr,/mob/living/carbon/human)))
		var/mob/living/carbon/human/H = usr
		if((lasercolor == "b") && (istype(H.wear_suit, /obj/item/clothing/suit/redtag)))//Opposing team cannot operate it
			return
		else if((lasercolor == "r") && (istype(H.wear_suit, /obj/item/clothing/suit/bluetag)))
			return
	if ((href_list["power"]) && (src.allowed(usr)))
		if (src.on && !src.emagged)
			turn_off()
		else
			turn_on()
		return

	switch(href_list["operation"])
		if ("idcheck")
			src.idcheck = !src.idcheck
			src.updateUsrDialog()
		if("weaponscheck")
			src.weaponscheck = !src.weaponscheck
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
		if("declarearrests")
			src.declare_arrests = !src.declare_arrests
			src.updateUsrDialog()
		if("hack")
			if(!src.emagged)
				src.emagged = 2
				src.hacked = 1
				src.set_weapon()
				usr << "<span class='warning'>You disable [src]'s combat inhibitor.</span>"
			else if(!src.hacked)
				usr << "<span class='userdanger'>[src] ignores your attempts to restrict it!</span>"
			else
				src.emagged = 0
				src.hacked = 0
				src.set_weapon()
				usr << "<span class='notice'>You restore [src]'s combat inhibitor.</span>"
			src.updateUsrDialog()

/obj/machinery/bot/ed209/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user) && !open && !emagged)
			src.locked = !src.locked
			user << "<span class='notice'>Controls are now [src.locked ? "locked" : "unlocked"].</span>"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='warning'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='notice'>Access denied.</span>"
	else
		..()
		if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != "harm") // Any intent but harm will heal, so we shouldn't get angry.
			return
		if (!istype(W, /obj/item/weapon/screwdriver) && (!src.target)) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
			if(W.force && W.damtype != STAMINA)//If force is non-zero and damage type isn't stamina.
				threatlevel = user.assess_threat(src)
				threatlevel += 6
				if(threatlevel >= 4)
					src.target = user
					if(lasercolor)//To make up for the fact that lasertag bots don't hunt
						src.shootAt(user)
					src.mode = SECBOT_HUNT

/obj/machinery/bot/ed209/Emag(mob/user as mob)
	..()
	if(open && !locked)
		if(user) user << "<span class='warning'>You short out [src]'s target assessment circuits.</span>"
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='userdanger'>[src] buzzes oddly!</span>", 1)
		src.target = null
		if(user) src.oldtarget_name = user.name
		src.last_found = world.time
		src.anchored = 0
		src.declare_arrests = 0
		src.emagged = 2
		src.on = 1
		src.icon_state = "[lasercolor]ed209[src.on]"
		src.set_weapon()
		mode = SECBOT_IDLE

/obj/machinery/bot/ed209/process()
	set background = BACKGROUND_ENABLED

	if (!src.on || src.disabled)
		return
	var/list/targets = list()
	for (var/mob/living/carbon/C in view(9,src)) //Let's find us a target
		var/threatlevel = 0
		if ((C.stat) || (C.lying))
			continue
		threatlevel = C.assess_threat(src, lasercolor)
		//src.speak(C.real_name + text(": threat: []", threatlevel))
		if (threatlevel < 4 )
			continue

		var/dst = get_dist(src, C)
		if ( dst <= 1 || dst > 12)
			continue

		targets += C
	if (targets.len>0)
		var/mob/living/carbon/t = pick(targets)
		if ((t.stat!=2) && (t.lying != 1) && (!t.handcuffed)) //we don't shoot people who are dead, cuffed or lying down.
			src.shootAt(t)
	switch(mode)

		if(SECBOT_IDLE)		// idle
			walk_to(src,0)
			if(!src.lasercolor) //lasertag bots don't want to arrest anyone
				look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = SECBOT_START_PATROL	// switch to patrol mode

		if(SECBOT_HUNT)		// hunting for perp
			// if can't reach perp for long enough, go idle
			if(src.frustration >= 8)
				walk_to(src,0)
				back_to_idle()

			if(target)		// make sure target exists
				if(src.Adjacent(target) && isturf(src.target.loc)) // if right next to perp
					playsound(src.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
					src.icon_state = "[lasercolor]ed209-c"
					spawn(2)
						src.icon_state = "[lasercolor]ed209[src.on]"
					var/mob/living/carbon/M = src.target
					if(istype(M, /mob/living/carbon/human))
						if( M.stuttering < 5 && !(HULK in M.mutations) )
							M.stuttering = 5
						M.Stun(5)
						M.Weaken(5)
					else
						M.Weaken(5)
						M.stuttering = 5
						M.Stun(5)

					if(declare_arrests)
						var/area/location = get_area(src)
						broadcast_hud_message("[src.name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] scumbag <b>[target.name]</b> in <b>[location]</b>", src)
					target.visible_message("<span class='danger'>[src.target] has been stunned by [src]!</span>",\
											"<span class='userdanger'>[src.target] has been stunned by [src]!</span></span>")

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
			else
				back_to_idle()

		if(SECBOT_PREP_ARREST)		// preparing to arrest target

			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if( !src.Adjacent(target) || !isturf(src.target.loc) ||  src.target.weakened < 2 )
				back_to_hunt()
				return

			if(iscarbon(target) && target.canBeHandcuffed())
				if(!src.arrest_type)
					if(!src.target.handcuffed)  //he's not cuffed? Try to cuff him!
						mode = SECBOT_ARREST
						playsound(src.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
						target.visible_message("<span class='danger'>[src] is trying to put handcuffs on [src.target]!</span>",\
											"<span class='userdanger'>[src] is trying to put handcuffs on [src.target]!</span>")

						spawn(60)
							if( !src.Adjacent(target) || !isturf(src.target.loc) ) //if he's in a closet or not adjacent, we cancel cuffing.
								return
							if(!src.target.handcuffed)
								target.handcuffed = new /obj/item/weapon/handcuffs(target)
								target.update_inv_handcuffed(0)	//update the handcuffs overlay
								back_to_idle()
					else
						back_to_idle()
						return
			else
				back_to_idle()
				return

		if(SECBOT_ARREST)

			if (!target)
				src.anchored = 0
				mode = SECBOT_IDLE
				src.last_found = world.time
				frustration = 0
				return

			if(src.target.handcuffed) //no target or target cuffed? back to idle.
				back_to_idle()
				return

			if( !src.Adjacent(target) || !isturf(src.target.loc) || (src.target.loc != src.target_lastloc && src.target.weakened < 2) ) //if he's changed loc and about to get up or not adjacent or got into a closet, we prep arrest again.
				back_to_hunt()
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

/obj/machinery/bot/ed209/proc/back_to_idle()
	src.anchored = 0
	mode = SECBOT_IDLE
	src.target = null
	src.last_found = world.time
	frustration = 0
	spawn(0)
		process() //ensure bot quickly responds

/obj/machinery/bot/ed209/proc/back_to_hunt()
	src.anchored = 0
	src.frustration = 0
	mode = SECBOT_HUNT
	spawn(0)
		process() //ensure bot quickly responds

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

				if(lasercolor)
					sleep(20)
				else
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
	if(auto_patrol)
		find_patrol_target()
	else
		mode = SECBOT_IDLE
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
	src.path = AStar(src.loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 120, id=botcard, exclude=avoid)
	if(!src.path)
		src.path = list()


// look for a criminal in view of the bot

/obj/machinery/bot/ed209/proc/look_for_perp()
	if(src.disabled)
		return
	src.anchored = 0
	src.threatlevel = 0
	for (var/mob/living/carbon/C in view(12,src)) //Let's find us a criminal
		if ((C.stat) || (C.handcuffed))
			continue

		if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100))
			continue

		src.threatlevel = C.assess_threat(src, lasercolor)

		if (!src.threatlevel)
			continue

		else if (src.threatlevel >= 4)
			src.target = C
			src.oldtarget_name = C.name
			src.speak("Level [src.threatlevel] infraction alert!")
			playsound(src.loc, pick('sound/voice/ed209_20sec.ogg', 'sound/voice/EDPlaceholder.ogg'), 50, 0)
			src.visible_message("<b>[src]</b> points at [C.name]!")
			mode = SECBOT_HUNT
			spawn(0)
				process()	// ensure bot quickly responds to a perp
			break
		else
			continue

/obj/machinery/bot/ed209/proc/check_for_weapons(var/obj/item/slot_item)
	if(istype(slot_item, /obj/item/weapon/gun) || istype(slot_item, /obj/item/weapon/melee))
		if(!(slot_item.type in safe_weapons))
			return 1
	return 0

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

/obj/machinery/bot/ed209/explode()
	walk_to(src,0)
	src.visible_message("<span class='userdanger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/ed209_assembly/Sa = new /obj/item/weapon/ed209_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = src.name
	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(!lasercolor)
		var/obj/item/weapon/gun/energy/taser/G = new /obj/item/weapon/gun/energy/taser(Tsec)
		G.power_supply.charge = 0
		G.update_icon()
	else if(lasercolor == "b")
		var/obj/item/weapon/gun/energy/laser/bluetag/G = new /obj/item/weapon/gun/energy/laser/bluetag(Tsec)
		G.power_supply.charge = 0
		G.update_icon()
	else if(lasercolor == "r")
		var/obj/item/weapon/gun/energy/laser/redtag/G = new /obj/item/weapon/gun/energy/laser/redtag(Tsec)
		G.power_supply.charge = 0
		G.update_icon()

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
	qdel(src)


/obj/machinery/bot/ed209/proc/set_weapon()  //used to update the projectile type and firing sound
	shoot_sound = 'sound/weapons/laser.ogg'
	if(src.emagged == 2)
		if(lasercolor)
			projectile = /obj/item/projectile/lasertag
		else
			projectile = /obj/item/projectile/beam
	else
		if(!lasercolor)
			shoot_sound = 'sound/weapons/Taser.ogg'
			projectile = /obj/item/projectile/energy/electrode
		else if(lasercolor == "b")
			projectile = /obj/item/projectile/lasertag/bluetag
		else if(lasercolor == "r")
			projectile = /obj/item/projectile/lasertag/redtag


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

	if(!projectile)
		return

	if (!( istype(U, /turf) ))
		return
	var/obj/item/projectile/A = new projectile (loc)
	playsound(src.loc, shoot_sound, 50, 1)
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
			pulse2.delete()
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
					if (prob(50) && emagged < 2)
						emagged = 2
						set_weapon()
						shootAt(toshoot)
						emagged = 0
						set_weapon()
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
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if(!t)	return
		if(!in_range(src, usr) && src.loc != usr)	return
		created_name = t
		return

	switch(build_step)
		if(0,1)
			if(istype(W, /obj/item/robot_parts/l_leg) || istype(W, /obj/item/robot_parts/r_leg))
				user.drop_item()
				qdel(W)
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
			if(istype(W, /obj/item/clothing/suit/redtag))
				lasercolor = "r"
			else if(istype(W, /obj/item/clothing/suit/bluetag))
				lasercolor = "b"
			if(lasercolor || istype(W, /obj/item/clothing/suit/armor/vest))
				user.drop_item()
				qdel(W)
				build_step++
				user << "<span class='notice'>You add the armor to [src].</span>"
				name = "vest/legs/frame assembly"
				item_state = "[lasercolor]ed209_shell"
				icon_state = "[lasercolor]ed209_shell"

		if(3)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					build_step++
					name = "shielded frame assembly"
					user << "<span class='notice'>You welded the vest to [src].</span>"
		if(4)
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/clothing/head/helmet/bluetaghelm))
						return

				if("r")
					if(!istype(W, /obj/item/clothing/head/helmet/redtaghelm))
						return

				if("")
					if(!istype(W, /obj/item/clothing/head/helmet))
						return

			user.drop_item()
			qdel(W)
			build_step++
			user << "<span class='notice'>You add the helmet to [src].</span>"
			name = "covered and shielded frame assembly"
			item_state = "[lasercolor]ed209_hat"
			icon_state = "[lasercolor]ed209_hat"

		if(5)
			if(isprox(W))
				user.drop_item()
				qdel(W)
				build_step++
				user << "<span class='notice'>You add the prox sensor to [src].</span>"
				name = "covered, shielded and sensored frame assembly"
				item_state = "[lasercolor]ed209_prox"
				icon_state = "[lasercolor]ed209_prox"

		if(6)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if (coil.get_amount() < 1)
					user << "<span class='warning'>You need one length of cable to wire the ED-209.</span>"
					return
				user << "<span class='notice'>You start to wire [src]...</span>"
				if (do_after(user, 40))
					if (coil.get_amount() >= 1 && build_step == 6)
						coil.use(1)
						build_step = 7
						user << "<span class='notice'>You wire the ED-209 assembly.</span>"
						name = "wired ED-209 assembly"

		if(7)
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/weapon/gun/energy/laser/bluetag))
						return
					name = "bluetag ED-209 assembly"
				if("r")
					if(!istype(W, /obj/item/weapon/gun/energy/laser/redtag))
						return
					name = "redtag ED-209 assembly"
				if("")
					if(!istype(W, /obj/item/weapon/gun/energy/taser))
						return
					name = "taser ED-209 assembly"
				else
					return
			build_step++
			user << "<span class='notice'>You add [W] to [src].</span>"
			src.item_state = "[lasercolor]ed209_taser"
			src.icon_state = "[lasercolor]ed209_taser"
			user.drop_item()
			qdel(W)

		if(8)
			if(istype(W, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
				var/turf/T = get_turf(user)
				user << "<span class='notice'>Now attaching the gun to the frame...</span>"
				sleep(40)
				if(get_turf(user) == T)
					build_step++
					name = "armed [name]"
					user << "<span class='notice'>Taser gun attached.</span>"

		if(9)
			if(istype(W, /obj/item/weapon/stock_parts/cell))
				build_step++
				user << "<span class='notice'>You complete the ED-209.</span>"
				var/turf/T = get_turf(src)
				new /obj/machinery/bot/ed209(T,created_name,lasercolor)
				user.drop_item()
				qdel(W)
				user.unEquip(src, 1)
				qdel(src)


/obj/machinery/bot/ed209/bullet_act(var/obj/item/projectile/Proj)
	if(!disabled)
		var/lasertag_check = 0
		if((src.lasercolor == "b"))
			if(istype(Proj, /obj/item/projectile/lasertag/redtag))
				lasertag_check++
		else if((src.lasercolor == "r"))
			if(istype(Proj, /obj/item/projectile/lasertag/bluetag))
				lasertag_check++
		if(lasertag_check)
			icon_state = "[lasercolor]ed2090"
			src.disabled = 1
			target = null
			spawn(100)
				src.disabled = 0
				icon_state = "[lasercolor]ed2091"
			return 1
		else
			..(Proj)
	else
		..(Proj)

/obj/machinery/bot/ed209/bluetag/New()//If desired, you spawn red and bluetag bots easily
	new /obj/machinery/bot/ed209(get_turf(src),null,"b")
	qdel(src)


/obj/machinery/bot/ed209/redtag/New()
	new /obj/machinery/bot/ed209(get_turf(src),null,"r")
	qdel(src)
