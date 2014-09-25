// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	luminosity = 3
	use_power = 0
	var/obj/item/weapon/card/id/botcard			// the ID card that the bot "holds"
	var/list/prev_access = list()
	var/on = 1
	var/health = 0 //do not forget to set health for your bot!
	var/maxhealth = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0//Maint panel
	var/locked = 1
	var/hacked = 0 //Used to differentiate between being hacked by silicons and emagged by humans.
	var/text_hack = ""		//Custom text returned to a silicon upon hacking a bot.
	var/text_dehack = "" 	//Text shown when resetting a bots hacked status to normal.
	var/text_dehack_fail = "" //Shown when a silicon tries to reset a bot emagged with the emag item, which cannot be reset.
	var/declare_message = "" //What the bot will display to the HUD user.
	var/frustration = 0 //Used by some bots for tracking failures to reach their target.
	var/list/call_path = list() //Path calculated by the AI and given to the bot to follow.
	var/list/path = new() //Every bot has this, so it is best to put it here.
	var/list/patrol_path = list() //The path a bot has while on patrol.
	var/list/summon_path = list() //Path bot has while summoned.
	var/pathset = 0
	var/mode = 0 //Standardizes the vars that indicate the bot is busy with its function.
	var/tries = 0 //Number of times the bot tried and failed to move.
	var/remote_disabled = 0 //If enabled, the AI cannot *Remotely* control a bot. It can still control it through cameras.
	var/mob/living/silicon/ai/calling_ai //Links a bot to the AI calling it.
	var/obj/item/device/radio/Radio //The bot's radio, for speaking to people.
	var/radio_frequency = 1459 //The bot's default radio speaking freqency. Recommended to be on a department frequency.
	//var/emagged = 0 //Urist: Moving that var to the general /bot tree as it's used by most bots
	var/auto_patrol = 0// set to make bot automatically patrol
	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/turf/summon_target	// The turf of a user summoning a bot.
	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/nearest_beacon			// the nearest beacon's tag
	var/turf/nearest_beacon_loc	// the nearest beacon's location

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = 1447		// bot control frequency

	var/bot_filter 				// The radio filter the bot uses to identify itself on the network.

	var/bot_type = 0 //The type of bot it is, for radio control.
	#define SEC_BOT				1	// Secutritrons (Beepsky) and ED-209s
	#define MULE_BOT			2	// MULEbots
	#define FLOOR_BOT			3	// Floorbots
	#define CLEAN_BOT			4	// Cleanbots
	#define MED_BOT				5	// Medibots

	//Mode defines
	#define BOT_IDLE 			0	// idle
	#define BOT_HUNT 			1	// found target, hunting
	#define BOT_PREP_ARREST 	2	// at target, preparing to arrest
	#define BOT_ARREST			3	// arresting target
	#define BOT_START_PATROL	4	// start patrol
	#define BOT_PATROL			5	// patrolling
	#define BOT_SUMMON			6	// summoned by PDA
	#define BOT_CLEANING 		7	// cleaning (cleanbots)
	#define BOT_REPAIRING		8	// repairing hull breaches (floorbots)
	#define BOT_MOVING			9	// for clean/floor bots, when moving.
	#define BOT_HEALING			10	// healing people (medbots)
	#define BOT_RESPONDING		11	// responding to a call from the AI
	#define BOT_LOADING			12	// loading/unloading
	#define BOT_DELIVER			13	// moving to deliver
	#define BOT_GO_HOME			14	// returning to home
	#define BOT_BLOCKED			15	// blocked
	#define BOT_NAV				16	// computing navigation
	#define BOT_WAIT_FOR_NAV	17	// waiting for nav computation
	#define BOT_NO_ROUTE		18	// no destination beacon found (or no route)
	var/list/mode_name = list("In Pursuit","Preparing to Arrest","Arresting","Beginning Patrol","Patrolling","Summoned by PDA", \
	"Cleaning", "Repairing", "Proceeding to work site","Healing","Responding","Loading/Unloading","Navigating to Delivery Location","Navigating to Home", \
	"Waiting for clear path","Calculating navigation path","Pinging beacon network","Unable to reach destination")
	//This holds text for what the bot is mode doing, reported on the AI's bot control interface.


/obj/machinery/bot/proc/turn_on()
	if(stat)	return 0
	on = 1
	SetLuminosity(initial(luminosity))
	return 1

/obj/machinery/bot/proc/turn_off()
	on = 0
	SetLuminosity(0)
	bot_reset() //Resets an AI's call, should it exist.

/obj/machinery/bot/New()
	..()
	botcard = new /obj/item/weapon/card/id(src)
	set_custom_texts()
	Radio = new /obj/item/device/radio(src)
	Radio.listening = 0 //Makes bot radios transmit only so no one hears things while adjacent to one.

/obj/machinery/bot/proc/add_to_beacons(bot_filter) //Master filter control for bots. Must be placed in the bot's local New() to support map spawned bots.
	if(radio_controller)
		radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)
		if(bot_filter)
			radio_controller.add_object(src, control_freq, filter = bot_filter)



/obj/machinery/bot/proc/explode()
	qdel(src)

/obj/machinery/bot/proc/healthcheck()
	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/proc/Emag(mob/user as mob) //Master Emag proc. Ensure this is called in your bot before setting unique functions.
	if(locked) //First emag application unlocks the bot's interface. Apply a screwdriver to use the emag again.
		locked = 0
		emagged = 1
		user << "<span class='warning'>You bypass [src]'s controls.</span>"
	if(!locked && open) //Bot panel is unlocked by ID or emag, and the panel is screwed open. Ready for emagging.
		emagged = 2
		remote_disabled = 1 //Manually emagging the bot locks out the AI built in panel.
		locked = 1 //Access denied forever!
		bot_reset()
		turn_on() //The bot automatically turns on when emagged, unless recently hit with EMP.
	else //Bot is unlocked, but the maint panel has not been opened with a screwdriver yet.
		user << "<span class='notice'>You need to open maintenance panel first.</span>"

/obj/machinery/bot/examine()
	set src in view()
	..()
	if (src.health < maxhealth)
		if (src.health > maxhealth/3)
			usr << "<span class='warning'>[src]'s parts look loose.</span>"
		else
			usr << "<span class='danger'>[src]'s parts look very loose!</span>"
	return

/obj/machinery/bot/attack_alien(var/mob/living/carbon/alien/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	src.health -= rand(15,30)*brute_dam_coeff
	src.visible_message("<span class='userdanger'>[user] has slashed [src]!</span>")
	playsound(src.loc, 'sound/weapons/slice.ogg', 25, 1, -1)
	if(prob(10))
		new /obj/effect/decal/cleanable/oil(src.loc)
	healthcheck()


/obj/machinery/bot/attack_animal(var/mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		return
	M.changeNext_move(CLICK_CD_MELEE)
	src.health -= M.melee_damage_upper
	src.visible_message("<span class='userdanger'>[M] has [M.attacktext] [src]!</span>")
	add_logs(M, src, "attacked", admin=0)
	if(prob(10))
		new /obj/effect/decal/cleanable/oil(src.loc)
	healthcheck()

/obj/machinery/bot/Topic(href, href_list) //Master Topic to handle common functions.
	if(..())
		return

	if(topic_denied())
		usr << "<span class='warning'>[src]'s interface is not responding!</span>"
		href_list = list()
		return

	usr.set_machine(src)
	add_fingerprint(usr)
	if((href_list["power"]) && (allowed(usr) || !locked))
		if (on)
			turn_off()
		else
			turn_on()

	switch(href_list["operation"])
		if("patrol")
			auto_patrol = !auto_patrol
			mode = BOT_IDLE
		if("remote")
			remote_disabled = !remote_disabled
		if("hack")
			if(emagged != 2)
				emagged = 2
				hacked = 1
				remote_disabled = 0
				locked = 1
				usr << "<span class='warning'>[text_hack]</span>"
				bot_reset()
			else if(!hacked)
				usr << "<span class='userdanger'>[text_dehack_fail]</span>"
			else
				emagged = 0
				hacked = 0
				usr << "<span class='notice'>[text_dehack]</span>"
				bot_reset()
	updateUsrDialog()

/obj/machinery/bot/proc/topic_denied() //Access check proc for bot topics! Remember to place in a bot's individual Topic if desired.
	// 0 for access, 1 for denied.
	if(emagged == 2) //An emagged bot cannot be controlled by humans, silicons can if one hacked it.
		if(!hacked) //Manually emagged by a human - access denied to all.
			return 1
		else if(!issilicon(usr)) //Bot is hacked, so only silicons are allowed access.
			return 1
	else
		return 0


/obj/machinery/bot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(!locked)
			open = !open
			user << "<span class='notice'>Maintenance panel is now [src.open ? "opened" : "closed"].</span>"
	else if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != "harm")
		if(health < maxhealth)
			if(open)
				health = min(maxhealth, health+10)
				user.visible_message("<span class='danger'>[user] repairs [src]!</span>","<span class='notice'>You repair [src]!</span>")
			else
				user << "<span class='notice'>Unable to repair with the maintenance panel closed.</span>"
		else
			user << "<span class='notice'>[src] does not need a repair.</span>"
	else if (istype(W, /obj/item/weapon/card/emag) && emagged < 2)
		Emag(user)
	else
		if(hasvar(W,"force") && hasvar(W,"damtype"))
			user.changeNext_move(CLICK_CD_MELEE)
			switch(W.damtype)
				if("fire")
					src.health -= W.force * fire_dam_coeff
				if("brute")
					src.health -= W.force * brute_dam_coeff
			..()
			healthcheck()
		else
			..()

/obj/machinery/bot/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
		..()
		healthcheck()
	return

/obj/machinery/bot/blob_act()
	src.health -= rand(20,40)*fire_dam_coeff
	healthcheck()
	return

/obj/machinery/bot/ex_act(severity)
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
			src.health -= rand(5,10)*fire_dam_coeff
			src.health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				src.health -= rand(1,5)*fire_dam_coeff
				src.health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/machinery/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = 1
	pulse2.dir = pick(cardinal)

	spawn(10)
		pulse2.delete()
	if (on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if (was_on)
			turn_on()

/obj/machinery/bot/proc/hack(mob/user)
	var/hack
	if(issilicon(user)) //Allows silicons to toggle the emag status of a bot.
		hack += "[emagged == 2 ? "Software compromised! Unit may exhibit dangerous or erratic behavior." : "Unit operating normally. Release safety lock?"]<BR>"
		hack += "Harm Prevention Safety System: <A href='?src=\ref[src];operation=hack'>[emagged ? "<span class='bad'>DANGER</span>" : "Engaged"]</A><BR>"
	else if(!locked) //Humans with access can use this option to hide a bot from the AI's remote control panel.
		hack += "AI remote control network port: <A href='?src=\ref[src];operation=remote'>[remote_disabled ? "Closed" : "Open"]</A><BR><BR>"
	return hack

/obj/machinery/bot/proc/set_custom_texts() //Superclass for setting hack texts. Appears only if a set is not given to a bot locally.
	text_hack = "You hack [name]."
	text_dehack = "You reset [name]."
	text_dehack_fail = "You fail to reset [name]."

/obj/machinery/bot/attack_ai(mob/user as mob)
	src.attack_hand(user)

/obj/machinery/bot/proc/speak(var/message, freq) //Pass a message to have the bot say() it. Pass a frequency to say it on the radio.
	if((!src.on) || (!message))
		return
	if(freq)
		Radio.set_frequency(radio_frequency)
		Radio.talk_into(src, message, radio_frequency)
	else
		say(message)
	return


/obj/machinery/bot/proc/check_bot_access()
	if(mode != BOT_SUMMON && mode != BOT_RESPONDING)
		botcard.access = prev_access

/obj/machinery/bot/proc/call_bot(var/caller, var/turf/waypoint)
	bot_reset() //Reset a bot becore setting it to call mode.
	var/area/end_area = get_area(waypoint)

	//For giving the bot temporary all-access.
	var/obj/item/weapon/card/id/all_access = new /obj/item/weapon/card/id
	var/datum/job/captain/All = new/datum/job/captain
	all_access.access = All.get_access()

	call_path = AStar(src, waypoint, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 200, id=all_access)
	calling_ai = caller //Link the AI to the bot!

	if(call_path && call_path.len) //Ensures that a valid path is calculated!
		if(!on)
			turn_on() //Saves the AI the hassle of having to activate a bot manually.
		botcard = all_access //Give the bot all-access while under the AI's command.
		calling_ai << "<span class='notice'>\icon[src] [name] called to [end_area.name]. [call_path.len-1] meters to destination.</span>"
		pathset = 1
		mode = BOT_RESPONDING
		tries = 0
	else
		calling_ai << "<span class='danger'>Failed to calculate a valid route. Ensure destination is clear of obstructions and within range.</span>"
		calling_ai = null

/obj/machinery/bot/proc/call_mode() //Handles preparing a bot for a call, as well as calling the move proc.
//Handles the bot's movement during a call.
		move_to_call()
		sleep(5)
		move_to_call() //Called twice so that the bot moves faster.
		return

/obj/machinery/bot/proc/move_to_call()
	if(call_path && call_path.len && tries < 6)
		step_towards(src, call_path[1])

		if(loc == call_path[1])//Remove turfs from the path list if the bot moved there.
			tries = 0
			call_path -= call_path[1]
		else //Could not move because of an obstruction.
			tries++
	else
		if(calling_ai)
			calling_ai << "\icon[src] [tries ? "<span class='danger'>[src] failed to reach waypoint.</span>" : "<span class='notice'>[src] successfully arrived to waypoint.</span>"]"
			calling_ai = null
		bot_reset()

obj/machinery/bot/proc/bot_reset()
	if(calling_ai) //Simple notification to the AI if it called a bot. It will not know the cause or identity of the bot.
		calling_ai << "<span class='danger'>Call command to a bot has been reset.</span>"
		calling_ai = null
	call_path = null
	path = new()
	patrol_path = list()
	summon_path = list()
	summon_target = null
	pathset = 0
	botcard.access = prev_access
	tries = 0
	mode = BOT_IDLE


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Patrol and summon code!
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/obj/machinery/bot/proc/bot_patrol()
	patrol_step()
	spawn(5)
		if(mode == BOT_PATROL)
			patrol_step()
	return

obj/machinery/bot/proc/start_patrol()

	if(tries >= 4) //Bot is trapped, so stop trying to patrol.
		auto_patrol = 0
		tries = 0
		speak("Unable to start patrol.")

		return

	if(!auto_patrol) //A bot not set to patrol should not be patrolling.
		mode = BOT_IDLE
		return

	if(patrol_path && patrol_path.len > 0 && patrol_target)	// have a valid path, so just resume
		mode = BOT_PATROL
		return

	else if(patrol_target)		// has patrol target already
		spawn(0)
			calc_path()		// so just find a route to it
			if(patrol_path.len == 0)
				patrol_target = 0
				return
			mode = BOT_PATROL
	else					// no patrol target, so need a new one
		find_patrol_target()
		speak("Engaging patrol mode.")
		tries++
	return

// perform a single patrol step

/obj/machinery/bot/proc/patrol_step()

	if(loc == patrol_target)		// reached target


		at_patrol_target()
		return

	else if(patrol_path.len > 0 && patrol_target)		// valid path
		var/turf/next = patrol_path[1]
		if(next == loc)
			patrol_path -= next
			return


		if(istype( next, /turf/simulated))

			var/moved = step_towards(src, next)	// attempt to move
			if(moved)	// successful move
				blockcount = 0
				patrol_path -= loc

			else		// failed to move
				blockcount++

				if(blockcount > 5)	// attempt 5 times before recomputing
					// find new path excluding blocked turf

					spawn(2)
						calc_path(next)
						if(patrol_path.len == 0)
							find_patrol_target()
						else
							blockcount = 0
							tries = 0

					return

				return

		else	// not a valid turf
			mode = BOT_IDLE
			return

	else	// no path, so calculate new one
		mode = BOT_START_PATROL

	return

// finds a new patrol target
/obj/machinery/bot/proc/find_patrol_target()
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
/obj/machinery/bot/proc/find_nearest_beacon()
	nearest_beacon = null
	new_destination = "__nearest__"
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1
	spawn(10)
		awaiting_beacon = 0
		if(nearest_beacon)
			set_destination(nearest_beacon)
			tries = 0
		else
			auto_patrol = 0
			mode = BOT_IDLE
			speak("Disengaging patrol mode.")
			send_status()


/obj/machinery/bot/proc/at_patrol_target()

	find_patrol_target()
	return


// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/proc/set_destination(var/new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1


// receive a radio signal
// used for beacon reception

/obj/machinery/bot/receive_signal(datum/signal/signal)
	//log_admin("DEBUG \[[// world.timeofday]\]: /obj/machinery/bot/receive_signal([signal.debug_print()])")
	if(!on)
		return
/*
	if(!signal.data["beacon"])

		for(var/x in signal.data)
			world << "* [x] = [signal.data[x]]"
	*/

	var/recv = signal.data["command"]
	// process all-bot input

	if(recv=="bot_status")
		send_status()

	// check to see if we are the commanded bot
	if(signal.data["active"] == src)
		if(emagged == 2) //Emagged bots do not respect anyone's authority!
			return
	// process control input
		switch(recv)
			if("stop")
				bot_reset() //HOLD IT!!
				auto_patrol = 0
				return

			if("go")
				auto_patrol = 1
				return

			if("summon")
				bot_reset()
				var/list/user_access = signal.data["useraccess"]
				summon_target = signal.data["target"]	//Location of the user
				if(user_access.len != 0)
					botcard.access = user_access + prev_access //Adds the user's access, if any.
				mode = BOT_SUMMON
				calc_summon_path()
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
/obj/machinery/bot/proc/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/proc/post_signal_multiple(var/freq, var/list/keyval)
	if(!z || z != 1) //Bot control will only work on station.
		return
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency) return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
//	for(var/key in keyval)
//		signal.data[key] = keyval[key]
	signal.data = keyval
//	world << "sent [key],[keyval[key]] on [freq]"
	if(signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if(signal.data["type"] == bot_type)
		frequency.post_signal(src, signal, filter = bot_filter)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/proc/send_status()
	var/list/kv = list(
	"type" = bot_type,
	"name" = name,
	"loca" = get_area(src),	// area
	"mode" = mode
	)
	post_signal_multiple(control_freq, kv)


obj/machinery/bot/proc/bot_summon()
		// summoned to PDA
	summon_step()
	spawn(4)
		if(mode == BOT_SUMMON)
			summon_step()
			sleep(4)
			summon_step()
	return

// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/proc/calc_path(var/turf/avoid = null)
	check_bot_access()
	patrol_path = AStar(loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 120, id=botcard, exclude=avoid)
	if(!patrol_path)
		patrol_path = list()

/obj/machinery/bot/proc/calc_summon_path(var/turf/avoid = null)
	check_bot_access()
	summon_path = AStar(loc, summon_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 150, id=botcard, exclude=avoid)
	if(!summon_path || tries >= 5)
		bot_reset()

/obj/machinery/bot/proc/summon_step()

	if(loc == summon_target)		// Arrived to summon location.
		bot_reset()
		return

	else if(summon_path.len > 0 && summon_target)		//Proper path acquired!
		var/turf/next = summon_path[1]
		if(next == loc)
			summon_path -= next
			return


		if(istype( next, /turf/simulated))

			var/moved = step_towards(src, next)	// Move attempt
			if(moved)
				blockcount = 0
				summon_path -= loc

			else		// failed to move
				blockcount++

				if(blockcount > 5)	// attempt 5 times before recomputing
					// find new path excluding blocked turf
					spawn(2)
						calc_summon_path(next)
						tries++
						return

				return

		else	// not a valid turf
			bot_reset()
			return

	else	// no path, so calculate new one
		calc_summon_path()

	return


/obj/machinery/bot/Bump(M as mob|obj) //Leave no door unopened!
	if((istype(M, /obj/machinery/door/airlock) ||  istype(M, /obj/machinery/door/window)) && (!isnull(botcard)))
		var/obj/machinery/door/D = M
		if(D.check_access(botcard))
			D.open()
			frustration = 0
	else if((istype(M, /mob/living/)) && (!anchored))
		var/mob/living/Mb = M
		loc = Mb.loc
		frustration = 0
	return
