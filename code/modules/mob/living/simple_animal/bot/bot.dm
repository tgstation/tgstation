//Defines for bots are now found in code\__DEFINES\bots.dm

// AI (i.e. game AI, not the AI player) controlled bots
/mob/living/simple_animal/bot
	icon = 'icons/mob/aibots.dmi'
	layer = MOB_LAYER
	gender = NEUTER
	luminosity = 3
	stop_automated_movement = 1
	wander = 0
	healable = 0
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	maxbodytemp = INFINITY
	minbodytemp = 0
	has_unlimited_silicon_privilege = 1
	sentience_type = SENTIENCE_ARTIFICIAL
	status_flags = NONE //no default canpush
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"

	faction = list("neutral", "silicon" , "turret")

	var/obj/machinery/bot_core/bot_core = null
	var/bot_core_type = /obj/machinery/bot_core
	var/list/users = list() //for dialog updates
	var/window_id = "bot_control"
	var/window_name = "Protobot 1.0" //Popup title
	var/window_width = 0 //0 for default size
	var/window_height = 0
	var/obj/item/device/paicard/paicard // Inserted pai card.
	var/allow_pai = 1 // Are we even allowed to insert a pai card.
	var/bot_name

	var/list/player_access = list() //Additonal access the bots gets when player controlled
	var/emagged = 0
	var/list/prev_access = list()
	var/on = 1
	var/open = 0//Maint panel
	var/locked = 1
	var/hacked = 0 //Used to differentiate between being hacked by silicons and emagged by humans.
	var/text_hack = ""		//Custom text returned to a silicon upon hacking a bot.
	var/text_dehack = "" 	//Text shown when resetting a bots hacked status to normal.
	var/text_dehack_fail = "" //Shown when a silicon tries to reset a bot emagged with the emag item, which cannot be reset.
	var/declare_message = "" //What the bot will display to the HUD user.
	var/frustration = 0 //Used by some bots for tracking failures to reach their target.
	var/base_speed = 2 //The speed at which the bot moves, or the number of times it moves per process() tick.
	var/turf/ai_waypoint //The end point of a bot's path, or the target location.
	var/list/path = list() //List of turfs through which a bot 'steps' to reach the waypoint.
	var/pathset = 0
	var/list/ignore_list = list() //List of unreachable targets for an ignore-list enabled bot to ignore.
	var/mode = BOT_IDLE //Standardizes the vars that indicate the bot is busy with its function.
	var/tries = 0 //Number of times the bot tried and failed to move.
	var/remote_disabled = 0 //If enabled, the AI cannot *Remotely* control a bot. It can still control it through cameras.
	var/mob/living/silicon/ai/calling_ai //Links a bot to the AI calling it.
	var/obj/item/device/radio/Radio //The bot's radio, for speaking to people.
	var/radio_key = null //which channels can the bot listen to
	var/radio_channel = "Common" //The bot's default radio channel
	var/auto_patrol = 0// set to make bot automatically patrol
	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/turf/summon_target	// The turf of a user summoning a bot.
	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route
	var/shuffle = FALSE		// If we should shuffle our adjacency checking

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/nearest_beacon			// the nearest beacon's tag
	var/turf/nearest_beacon_loc	// the nearest beacon's location

	var/beacon_freq = 1445		// navigation beacon frequency
	var/model = "" //The type of bot it is.
	var/bot_type = 0 //The type of bot it is, for radio control.
	var/data_hud_type = DATA_HUD_DIAGNOSTIC //The type of data HUD the bot uses. Diagnostic by default.
	var/list/mode_name = list("In Pursuit","Preparing to Arrest", "Arresting", \
	"Beginning Patrol", "Patrolling", "Summoned by PDA", \
	"Cleaning", "Repairing", "Proceeding to work site", "Healing", \
	"Proceeding to AI waypoint", "Navigating to Delivery Location", "Navigating to Home", \
	"Waiting for clear path", "Calculating navigation path", "Pinging beacon network", "Unable to reach destination")
	//This holds text for what the bot is mode doing, reported on the remote bot control interface.

	hud_possible = list(DIAG_STAT_HUD, DIAG_BOT_HUD, DIAG_HUD) //Diagnostic HUD views

/mob/living/simple_animal/bot/proc/get_mode()
	if(client) //Player bots do not have modes, thus the override. Also an easy way for PDA users/AI to know when a bot is a player.
		if(paicard)
			return "<b>pAI Controlled</b>"
		else
			return "<b>Autonomous</b>"
	else if(!on)
		return "<span class='bad'>Inactive</span>"
	else if(!mode)
		return "<span class='good'>Idle</span>"
	else
		return "<span class='average'>[mode_name[mode]]</span>"

/mob/living/simple_animal/bot/proc/turn_on()
	if(stat)
		return 0
	on = 1
	set_light(initial(light_range))
	update_icon()
	diag_hud_set_botstat()
	return 1

/mob/living/simple_animal/bot/proc/turn_off()
	on = 0
	set_light(0)
	bot_reset() //Resets an AI's call, should it exist.
	update_icon()

/mob/living/simple_animal/bot/Initialize()
	..()
	access_card = new /obj/item/weapon/card/id(src)
//This access is so bots can be immediately set to patrol and leave Robotics, instead of having to be let out first.
	access_card.access += access_robotics
	set_custom_texts()
	Radio = new/obj/item/device/radio(src)
	if(radio_key)
		Radio.keyslot = new radio_key
	Radio.subspace_transmission = 1
	Radio.canhear_range = 0 // anything greater will have the bot broadcast the channel as if it were saying it out loud.
	Radio.recalculateChannels()

	bot_core = new bot_core_type(src)

	//Adds bot to the diagnostic HUD system
	prepare_huds()
	var/datum/atom_hud/data/diagnostic/diag_hud = huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_bothealth()
	diag_hud_set_botstat()
	diag_hud_set_botmode()

	//Gives a HUD view to player bots that use a HUD.
	activate_data_hud()


/mob/living/simple_animal/bot/update_canmove()
	. = ..()
	if(!on)
		. = 0
	canmove = .

/mob/living/simple_animal/bot/Destroy()
	if(paicard)
		ejectpai()
	qdel(Radio)
	qdel(access_card)
	qdel(bot_core)
	return ..()

/mob/living/simple_animal/bot/bee_friendly()
	return 1

/mob/living/simple_animal/bot/death(gibbed)
	explode()
	..()

/mob/living/simple_animal/bot/proc/explode()
	qdel(src)

/mob/living/simple_animal/bot/emag_act(mob/user)
	if(locked) //First emag application unlocks the bot's interface. Apply a screwdriver to use the emag again.
		locked = 0
		emagged = 1
		to_chat(user, "<span class='notice'>You bypass [src]'s controls.</span>")
		return
	if(!locked && open) //Bot panel is unlocked by ID or emag, and the panel is screwed open. Ready for emagging.
		emagged = 2
		remote_disabled = 1 //Manually emagging the bot locks out the AI built in panel.
		locked = 1 //Access denied forever!
		bot_reset()
		turn_on() //The bot automatically turns on when emagged, unless recently hit with EMP.
		to_chat(src, "<span class='userdanger'>(#$*#$^^( OVERRIDE DETECTED</span>")
		add_logs(user, src, "emagged")
		return
	else //Bot is unlocked, but the maint panel has not been opened with a screwdriver yet.
		to_chat(user, "<span class='warning'>You need to open maintenance panel first!</span>")

/mob/living/simple_animal/bot/examine(mob/user)
	..()
	if(health < maxHealth)
		if(health > maxHealth/3)
			to_chat(user, "[src]'s parts look loose.")
		else
			to_chat(user, "[src]'s parts look very loose!")
	else
		to_chat(user, "[src] is in pristine condition.")

/mob/living/simple_animal/bot/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount>0 && prob(10))
		new /obj/effect/decal/cleanable/oil(loc)
	. = ..()

/mob/living/simple_animal/bot/updatehealth()
	..()
	diag_hud_set_bothealth()

/mob/living/simple_animal/bot/med_hud_set_health()
	return //we use a different hud

/mob/living/simple_animal/bot/med_hud_set_status()
	return //we use a different hud

/mob/living/simple_animal/bot/handle_automated_action() //Master process which handles code common across most bots.
	set background = BACKGROUND_ENABLED
	diag_hud_set_botmode()

	if(!on || client)
		return

	switch(mode) //High-priority overrides are processed first. Bots can do nothing else while under direct command.
		if(BOT_RESPONDING)	//Called by the AI.
			call_mode()
			return
		if(BOT_SUMMON)		//Called by PDA
			bot_summon()
			return
	return 1 //Successful completion. Used to prevent child process() continuing if this one is ended early.


/mob/living/simple_animal/bot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HELP)
		interact(H)
	else
		return ..()

/mob/living/simple_animal/bot/attack_ai(mob/user)
	if(!topic_denied(user))
		interact(user)
	else
		to_chat(user, "<span class='warning'>[src]'s interface is not responding!</span>")

/mob/living/simple_animal/bot/interact(mob/user)
	show_controls(user)

/mob/living/simple_animal/bot/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(!locked)
			open = !open
			to_chat(user, "<span class='notice'>The maintenance panel is now [open ? "opened" : "closed"].</span>")
		else
			to_chat(user, "<span class='warning'>The maintenance panel is locked.</span>")
	else if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(bot_core.allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "Controls are now [locked ? "locked." : "unlocked."]")
		else
			if(emagged)
				to_chat(user, "<span class='danger'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
	else if(istype(W, /obj/item/device/paicard))
		insertpai(user, W)
	else if(istype(W, /obj/item/weapon/hemostat) && paicard)
		if(open)
			to_chat(user, "<span class='warning'>Close the access panel before manipulating the personality slot!</span>")
		else
			to_chat(user, "<span class='notice'>You attempt to pull [paicard] free...</span>")
			if(do_after(user, 30, target = src))
				if (paicard)
					user.visible_message("<span class='notice'>[user] uses [W] to pull [paicard] out of [bot_name]!</span>","<span class='notice'>You pull [paicard] out of [bot_name] with [W].</span>")
					ejectpai(user)
	else
		user.changeNext_move(CLICK_CD_MELEE)
		if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != INTENT_HARM)
			if(health >= maxHealth)
				to_chat(user, "<span class='warning'>[src] does not need a repair!</span>")
				return
			if(!open)
				to_chat(user, "<span class='warning'>Unable to repair with the maintenance panel closed!</span>")
				return
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0, user))
				adjustHealth(-10)
				user.visible_message("[user] repairs [src]!","<span class='notice'>You repair [src].</span>")
			else
				to_chat(user, "<span class='warning'>The welder must be on for this task!</span>")
		else
			if(W.force) //if force is non-zero
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(5, 1, src)
				s.start()
			..()

/mob/living/simple_animal/bot/bullet_act(obj/item/projectile/Proj)
	if(Proj && (Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		if(prob(75) && Proj.damage > 0)
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, src)
			s.start()
	return ..()

/mob/living/simple_animal/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	new /obj/effect/overlay/temp/emp(loc)
	if(paicard)
		paicard.emp_act(severity)
		src.visible_message("[paicard] is flies out of [bot_name]!","<span class='warning'>You are forcefully ejected from [bot_name]!</span>")
		ejectpai(0)
	if(on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if(was_on)
			turn_on()

/mob/living/simple_animal/bot/proc/set_custom_texts() //Superclass for setting hack texts. Appears only if a set is not given to a bot locally.
	text_hack = "You hack [name]."
	text_dehack = "You reset [name]."
	text_dehack_fail = "You fail to reset [name]."

/mob/living/simple_animal/bot/proc/speak(message,channel) //Pass a message to have the bot say() it. Pass a frequency to say it on the radio.
	if((!on) || (!message))
		return
	if(channel && Radio.channels[channel])// Use radio if we have channel key
		Radio.talk_into(src, message, channel, get_spans())
	else
		say(message)
	return

/mob/living/simple_animal/bot/get_spans()
	return ..() | SPAN_ROBOT

/mob/living/simple_animal/bot/radio(message, message_mode, list/spans)
	. = ..()
	if(. != 0)
		return .

	switch(message_mode)
		if(MODE_HEADSET)
			Radio.talk_into(src, message, , spans)
			return REDUCE_RANGE

		if(MODE_DEPARTMENT)
			Radio.talk_into(src, message, message_mode, spans)
			return REDUCE_RANGE

	if(message_mode in radiochannels)
		Radio.talk_into(src, message, message_mode, spans)
		return REDUCE_RANGE
	return 0

//Generalized behavior code, override where needed!

/*
scan() will search for a given type (such as turfs, human mobs, or objects) in the bot's view range, and return a single result.
Arguments: The object type to be searched (such as "/mob/living/carbon/human"), the old scan result to be ignored, if one exists,
and the view range, which defaults to 7 (full screen) if an override is not passed.
If the bot maintains an ignore list, it is also checked here.

Example usage: patient = scan(/mob/living/carbon/human, oldpatient, 1)
The proc would return a human next to the bot to be set to the patient var.
Pass the desired type path itself, declaring a temporary var beforehand is not required.
*/
/mob/living/simple_animal/bot/proc/scan(scan_type, old_target, scan_range = DEFAULT_SCAN_RANGE)
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/list/adjacent = T.GetAtmosAdjacentTurfs(1)
	if(shuffle)	//If we were on the same tile as another bot, let's randomize our choices so we dont both go the same way
		adjacent = shuffle(adjacent)
		shuffle = FALSE
	for(var/scan in adjacent)//Let's see if there's something right next to us first!
		if(check_bot(scan))	//Is there another bot there? Then let's just skip it
			continue
		if(isturf(scan_type))	//If we're lookeing for a turf we can just run the checks directly!
			var/final_result = checkscan(scan,scan_type,old_target)
			if(final_result)
				return final_result
		else
			var/turf/turfy = scan
			for(var/deepscan in turfy.contents)//Check the contents since adjacent is turfs
				var/final_result = checkscan(deepscan,scan_type,old_target)
				if(final_result)
					return final_result
	for (var/scan in shuffle(view(scan_range, src))-adjacent) //Search for something in range!
		var/final_result = checkscan(scan,scan_type,old_target)
		if(final_result)
			return final_result

/mob/living/simple_animal/bot/proc/checkscan(scan, scan_type, old_target)
	if(!istype(scan, scan_type)) //Check that the thing we found is the type we want!
		return 0 //If not, keep searching!
	if( (scan in ignore_list) || (scan == old_target) ) //Filter for blacklisted elements, usually unreachable or previously processed oness
		return 0

	var/scan_result = process_scan(scan) //Some bots may require additional processing when a result is selected.
	if(scan_result)
		return scan_result
	else
		return 0 //The current element failed assessment, move on to the next.
	return

/mob/living/simple_animal/bot/proc/check_bot(targ)
	var/turf/T = get_turf(targ)
	if(T)
		for(var/C in T.contents)
			if(istype(C,type) && (C != src))	//Is there another bot there already? If so, let's skip it so we dont all atack on top of eachother.
				return 1	//Let's abort if we find a bot so we dont have to keep rechecking

//When the scan finds a target, run bot specific processing to select it for the next step. Empty by default.
/mob/living/simple_animal/bot/proc/process_scan(scan_target)
	return scan_target


/mob/living/simple_animal/bot/proc/add_to_ignore(subject)
	if(ignore_list.len < 50) //This will help keep track of them, so the bot is always trying to reach a blocked spot.
		ignore_list |= subject
	else if(ignore_list.len >= subject) //If the list is full, insert newest, delete oldest.
		ignore_list -= ignore_list[1]
		ignore_list |= subject

/*
Movement proc for stepping a bot through a path generated through A-star.
Pass a positive integer as an argument to override a bot's default speed.
*/
/mob/living/simple_animal/bot/proc/bot_move(dest, move_speed)

	if(!dest || !path || path.len == 0) //A-star failed or a path/destination was not set.
		path = list()
		return 0
	dest = get_turf(dest) //We must always compare turfs, so get the turf of the dest var if dest was originally something else.
	var/turf/last_node = get_turf(path[path.len]) //This is the turf at the end of the path, it should be equal to dest.
	if(get_turf(src) == dest) //We have arrived, no need to move again.
		return 1
	else if(dest != last_node) //The path should lead us to our given destination. If this is not true, we must stop.
		path = list()
		return 0
	var/step_count = move_speed ? move_speed : base_speed //If a value is passed into move_speed, use that instead of the default speed var.

	if(step_count >= 1 && tries < BOT_STEP_MAX_RETRIES)
		for(var/step_number = 0, step_number < step_count,step_number++)
			spawn(BOT_STEP_DELAY*step_number)
				bot_step(dest)
	else
		return 0
	return 1


/mob/living/simple_animal/bot/proc/bot_step(dest) //Step,increase tries if failed
	if(!path)
		return 0
	if(path.len > 1)
		step_towards(src, path[1])
		if(get_turf(src) == path[1]) //Successful move
			path -= path[1]
			tries = 0
		else
			tries++
			return 0
	else if(path.len == 1)
		step_to(src, dest)
		path = list()
	return 1


/mob/living/simple_animal/bot/proc/check_bot_access()
	if(mode != BOT_SUMMON && mode != BOT_RESPONDING)
		access_card.access = prev_access

/mob/living/simple_animal/bot/proc/call_bot(caller, turf/waypoint, message=TRUE)
	bot_reset() //Reset a bot before setting it to call mode.
	var/area/end_area = get_area(waypoint)

	if(client) //Player bots instead get a location command from the AI
		to_chat(src, "<span class='noticebig'>Priority waypoint set by \icon[caller] <b>[caller]</b>. Proceed to <b>[end_area.name]<\b>.")

	//For giving the bot temporary all-access.
	var/obj/item/weapon/card/id/all_access = new /obj/item/weapon/card/id
	var/datum/job/captain/All = new/datum/job/captain
	all_access.access = All.get_access()

	path = get_path_to(src, waypoint, /turf/proc/Distance_cardinal, 0, 200, id=all_access)
	calling_ai = caller //Link the AI to the bot!
	ai_waypoint = waypoint

	if(path && path.len) //Ensures that a valid path is calculated!
		if(!on)
			turn_on() //Saves the AI the hassle of having to activate a bot manually.
		access_card = all_access //Give the bot all-access while under the AI's command.
		if(message)
			to_chat(calling_ai, "<span class='notice'>\icon[src] [name] called to [end_area.name]. [path.len-1] meters to destination.</span>")
		pathset = 1
		mode = BOT_RESPONDING
		tries = 0
	else
		if(message)
			to_chat(calling_ai, "<span class='danger'>Failed to calculate a valid route. Ensure destination is clear of obstructions and within range.</span>")
		calling_ai = null
		path = list()

/mob/living/simple_animal/bot/proc/call_mode() //Handles preparing a bot for a call, as well as calling the move proc.
//Handles the bot's movement during a call.
	var/success = bot_move(ai_waypoint, 3)
	if(!success)
		if(calling_ai)
			to_chat(calling_ai, "\icon[src] [get_turf(src) == ai_waypoint ? "<span class='notice'>[src] successfully arrived to waypoint.</span>" : "<span class='danger'>[src] failed to reach waypoint.</span>"]")
			calling_ai = null
		bot_reset()

/mob/living/simple_animal/bot/proc/bot_reset()
	if(calling_ai) //Simple notification to the AI if it called a bot. It will not know the cause or identity of the bot.
		to_chat(calling_ai, "<span class='danger'>Call command to a bot has been reset.</span>")
		calling_ai = null
	path = list()
	summon_target = null
	pathset = 0
	access_card.access = prev_access
	tries = 0
	mode = BOT_IDLE
	diag_hud_set_botstat()
	diag_hud_set_botmode()




//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Patrol and summon code!
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/mob/living/simple_animal/bot/proc/bot_patrol()
	patrol_step()
	spawn(5)
		if(mode == BOT_PATROL)
			patrol_step()
	return

/mob/living/simple_animal/bot/proc/start_patrol()

	if(tries >= BOT_STEP_MAX_RETRIES) //Bot is trapped, so stop trying to patrol.
		auto_patrol = 0
		tries = 0
		speak("Unable to start patrol.")

		return

	if(!auto_patrol) //A bot not set to patrol should not be patrolling.
		mode = BOT_IDLE
		return

	if(patrol_target)		// has patrol target
		spawn(0)
			calc_path()		// Find a route to it
			if(path.len == 0)
				patrol_target = null
				return
			mode = BOT_PATROL
	else					// no patrol target, so need a new one
		speak("Engaging patrol mode.")
		find_patrol_target()
		tries++
	return

// perform a single patrol step

/mob/living/simple_animal/bot/proc/patrol_step()

	if(client)		// In use by player, don't actually move.
		return

	if(loc == patrol_target)		// reached target
		//Find the next beacon matching the target.
		if(!get_next_patrol_target())
			find_patrol_target() //If it fails, look for the nearest one instead.
		return

	else if(path.len > 0 && patrol_target)		// valid path
		var/turf/next = path[1]
		if(next == loc)
			path -= next
			return


		var/moved = bot_move(patrol_target)//step_towards(src, next)	// attempt to move
		if(!moved) //Couldn't proceed the next step of the path BOT_STEP_MAX_RETRIES times
			spawn(2)
				calc_path()
				if(path.len == 0)
					find_patrol_target()
				tries = 0

	else	// no path, so calculate new one
		mode = BOT_START_PATROL

// finds the nearest beacon to self
/mob/living/simple_animal/bot/proc/find_patrol_target()
	nearest_beacon = null
	new_destination = null
	find_nearest_beacon()
	if(nearest_beacon)
		patrol_target = nearest_beacon_loc
		destination = next_destination
	else
		auto_patrol = 0
		mode = BOT_IDLE
		speak("Disengaging patrol mode.")

/mob/living/simple_animal/bot/proc/get_next_patrol_target()
	// search the beacon list for the next target in the list.
	for(var/obj/machinery/navbeacon/NB in navbeacons["[z]"])
		if(NB.location == next_destination) //Does the Beacon location text match the destination?
			destination = new_destination //We now know the name of where we want to go.
			patrol_target = NB.loc //Get its location and set it as the target.
			next_destination = NB.codes["next_patrol"] //Also get the name of the next beacon in line.
			return 1

/mob/living/simple_animal/bot/proc/find_nearest_beacon()
	for(var/obj/machinery/navbeacon/NB in navbeacons["[z]"])
		var/dist = get_dist(src, NB)
		if(nearest_beacon) //Loop though the beacon net to find the true closest beacon.
			//Ignore the beacon if were are located on it.
			if(dist>1 && dist<get_dist(src,nearest_beacon_loc))
				nearest_beacon = NB.location
				nearest_beacon_loc = NB.loc
				next_destination = NB.codes["next_patrol"]
			else
				continue
		else if(dist > 1) //Begin the search, save this one for comparison on the next loop.
			nearest_beacon = NB.location
			nearest_beacon_loc = NB.loc
	patrol_target = nearest_beacon_loc
	destination = nearest_beacon

//PDA control. Some bots, especially MULEs, may have more parameters.
/mob/living/simple_animal/bot/proc/bot_control(command, mob/user, turf/user_turf, list/user_access = list())
	if(!on || emagged == 2 || remote_disabled) //Emagged bots do not respect anyone's authority! Bots with their remote controls off cannot get commands.
		return 1 //ACCESS DENIED
	if(client)
		bot_control_message(command,user,user_turf,user_access)
	// process control input
	switch(command)
		if("patroloff")
			bot_reset() //HOLD IT!!
			auto_patrol = 0

		if("patrolon")
			auto_patrol = 1

		if("summon")
			bot_reset()
			summon_target = user_turf
			if(user_access.len != 0)
				access_card.access = user_access + prev_access //Adds the user's access, if any.
			mode = BOT_SUMMON
			speak("Responding.", radio_channel)
			calc_summon_path()

		if("ejectpai")
			ejectpairemote(user)
	return

//
/mob/living/simple_animal/bot/proc/bot_control_message(command,user,user_turf,user_access)
	switch(command)
		if("patroloff")
			to_chat(src, "<span class='warning big'>STOP PATROL</span>")
		if("patrolon")
			to_chat(src, "<span class='warning big'>START PATROL</span>")
		if("summon")
			var/area/a = get_area(user_turf)
			to_chat(src, "<span class='warning big'>PRIORITY ALERT:[user] in [a.name]!</span>")
		if("stop")
			to_chat(src, "<span class='warning big'>STOP!</span>")

		if("go")
			to_chat(src, "<span class='warning big'>GO!</span>")

		if("home")
			to_chat(src, "<span class='warning big'>RETURN HOME!</span>")
		if("ejectpai")
			return
		else
			to_chat(src, "<span class='warning'>Unidentified control sequence recieved:[command]</span>")

/mob/living/simple_animal/bot/proc/bot_summon() // summoned to PDA
	summon_step()

// calculates a path to the current destination
// given an optional turf to avoid
/mob/living/simple_animal/bot/proc/calc_path(turf/avoid)
	check_bot_access()
	path = get_path_to(src, patrol_target, /turf/proc/Distance_cardinal, 0, 120, id=access_card, exclude=avoid)

/mob/living/simple_animal/bot/proc/calc_summon_path(turf/avoid)
	check_bot_access()
	spawn()
		path = get_path_to(src, summon_target, /turf/proc/Distance_cardinal, 0, 150, id=access_card, exclude=avoid)
		if(!path.len) //Cannot reach target. Give up and announce the issue.
			speak("Summon command failed, destination unreachable.",radio_channel)
			bot_reset()

/mob/living/simple_animal/bot/proc/summon_step()

	if(client)		// In use by player, don't actually move.
		return

	if(loc == summon_target)		// Arrived to summon location.
		bot_reset()
		return

	else if(path.len > 0 && summon_target)		//Proper path acquired!
		var/turf/next = path[1]
		if(next == loc)
			path -= next
			return

		var/moved = bot_move(summon_target, 3)	// Move attempt
		if(!moved)
			spawn(2)
				calc_summon_path()
				tries = 0

	else	// no path, so calculate new one
		calc_summon_path()

/mob/living/simple_animal/bot/Bump(M as mob|obj) //Leave no door unopened!
	. = ..()
	if((istype(M, /obj/machinery/door/airlock) ||  istype(M, /obj/machinery/door/window)) && (!isnull(access_card)))
		var/obj/machinery/door/D = M
		if(D.check_access(access_card))
			D.open()
			frustration = 0

/mob/living/simple_animal/bot/proc/show_controls(mob/M)
	users |= M
	var/dat = ""
	dat = get_controls(M)
	var/datum/browser/popup = new(M,window_id,window_name,350,600)
	popup.set_content(dat)
	popup.open(use_onclose = 0)
	onclose(M,window_id,ref=src)
	return

/mob/living/simple_animal/bot/proc/update_controls()
	for(var/mob/M in users)
		show_controls(M)

/mob/living/simple_animal/bot/proc/get_controls(mob/M)
	return "PROTOBOT - NOT FOR USE"

/mob/living/simple_animal/bot/Topic(href, href_list)
	//No ..() to prevent strip panel showing up - Todo: make that saner
	if(href_list["close"])// HUE HUE
		if(usr in users)
			users.Remove(usr)
		return 1

	if(topic_denied(usr))
		to_chat(usr, "<span class='warning'>[src]'s interface is not responding!</span>")
		return 1
	add_fingerprint(usr)

	if((href_list["power"]) && (bot_core.allowed(usr) || !locked))
		if(on)
			turn_off()
		else
			turn_on()

	switch(href_list["operation"])
		if("patrol")
			auto_patrol = !auto_patrol
			bot_reset()
		if("remote")
			remote_disabled = !remote_disabled
		if("hack")
			if(emagged != 2)
				emagged = 2
				hacked = 1
				locked = 1
				to_chat(usr, "<span class='warning'>[text_hack]</span>")
				bot_reset()
			else if(!hacked)
				to_chat(usr, "<span class='boldannounce'>[text_dehack_fail]</span>")
			else
				emagged = 0
				hacked = 0
				to_chat(usr, "<span class='notice'>[text_dehack]</span>")
				bot_reset()
		if("ejectpai")
			if(paicard && (!locked || issilicon(usr) || IsAdminGhost(usr)))
				to_chat(usr, "<span class='notice'>You eject [paicard] from [bot_name]</span>")
				ejectpai(usr)
	update_controls()

/mob/living/simple_animal/bot/proc/update_icon()
	icon_state = "[initial(icon_state)][on]"

// Machinery to simplify topic and access calls
/obj/machinery/bot_core
	use_power = 0
	var/mob/living/simple_animal/bot/owner = null

/obj/machinery/bot_core/Initialize()
	..()
	owner = loc
	if(!istype(owner))
		qdel(src)

/mob/living/simple_animal/bot/proc/topic_denied(mob/user) //Access check proc for bot topics! Remember to place in a bot's individual Topic if desired.
	if(!user.canUseTopic(src))
		return 1
	// 0 for access, 1 for denied.
	if(emagged == 2) //An emagged bot cannot be controlled by humans, silicons can if one hacked it.
		if(!hacked) //Manually emagged by a human - access denied to all.
			return 1
		else if(!issilicon(user) && !IsAdminGhost(user)) //Bot is hacked, so only silicons and admins are allowed access.
			return 1
	return 0

/mob/living/simple_animal/bot/proc/hack(mob/user)
	var/hack
	if(issilicon(user) || IsAdminGhost(user)) //Allows silicons or admins to toggle the emag status of a bot.
		hack += "[emagged == 2 ? "Software compromised! Unit may exhibit dangerous or erratic behavior." : "Unit operating normally. Release safety lock?"]<BR>"
		hack += "Harm Prevention Safety System: <A href='?src=\ref[src];operation=hack'>[emagged ? "<span class='bad'>DANGER</span>" : "Engaged"]</A><BR>"
	else if(!locked) //Humans with access can use this option to hide a bot from the AI's remote control panel and PDA control.
		hack += "Remote network control radio: <A href='?src=\ref[src];operation=remote'>[remote_disabled ? "Disconnected" : "Connected"]</A><BR>"
	return hack

/mob/living/simple_animal/bot/proc/showpai(mob/user)
	var/eject = ""
	if((!locked || issilicon(usr) || IsAdminGhost(usr)))
		if(paicard || allow_pai)
			eject += "Personality card status: "
			if(paicard)
				if(client)
					eject += "<A href='?src=\ref[src];operation=ejectpai'>Active</A>"
				else
					eject += "<A href='?src=\ref[src];operation=ejectpai'>Inactive</A>"
			else if(!allow_pai || key)
				eject += "Unavailable"
			else
				eject += "Not inserted"
			eject += "<BR>"
		eject += "<BR>"
	return eject

/mob/living/simple_animal/bot/proc/insertpai(mob/user, obj/item/device/paicard/card)
	if(paicard)
		to_chat(user, "<span class='warning'>A [paicard] is already inserted!</span>")
	else if(allow_pai && !key)
		if(!locked && !open)
			if(card.pai && card.pai.mind)
				if(!user.drop_item())
					return
				card.forceMove(src)
				paicard = card
				user.visible_message("[user] inserts [card] into [src]!","<span class='notice'>You insert [card] into [src].</span>")
				paicard.pai.mind.transfer_to(src)
				to_chat(src, "<span class='notice'>You sense your form change as you are uploaded into [src].</span>")
				bot_name = name
				name = paicard.pai.name
				faction = user.faction.Copy()
				add_logs(user, paicard.pai, "uploaded to [bot_name],")
				return 1
			else
				to_chat(user, "<span class='warning'>[card] is inactive.</span>")
		else
			to_chat(user, "<span class='warning'>The personality slot is locked.</span>")
	else
		to_chat(user, "<span class='warning'>[src] is not compatible with [card]</span>")

/mob/living/simple_animal/bot/proc/ejectpai(mob/user = null, announce = 1)
	if(paicard)
		if(mind && paicard.pai)
			mind.transfer_to(paicard.pai)
		else if(paicard.pai)
			paicard.pai.key = key
		else
			ghostize(0) // The pAI card that just got ejected was dead.
		key = null
		paicard.forceMove(loc)
		if(user)
			add_logs(user, paicard.pai, "ejected from [src.bot_name],")
		else
			add_logs(src, paicard.pai, "ejected")
		if(announce)
			to_chat(paicard.pai, "<span class='notice'>You feel your control fade as [paicard] ejects from [bot_name].</span>")
		paicard = null
		name = bot_name
		faction = initial(faction)

/mob/living/simple_animal/bot/proc/ejectpairemote(mob/user)
	if(bot_core.allowed(user) && paicard)
		speak("Ejecting personality chip.", radio_channel)
		ejectpai(user)

/mob/living/simple_animal/bot/Login()
	. = ..()
	access_card.access += player_access
	diag_hud_set_botmode()
	activate_data_hud()

/mob/living/simple_animal/bot/Logout()
	. = ..()
	bot_reset()

/mob/living/simple_animal/bot/revive(full_heal = 0, admin_revive = 0)
	if(..())
		update_icon()
		. = 1

/mob/living/simple_animal/bot/ghost()
	if(stat != DEAD) // Only ghost if we're doing this while alive, the pAI probably isn't dead yet.
		..()
	if(paicard && (!client || stat == DEAD))
		ejectpai(0)

/mob/living/simple_animal/bot/sentience_act()
	faction -= "silicon"

/mob/living/simple_animal/bot/proc/activate_data_hud()
//If a bot has its own HUD (for player bots), provide it.
	if(!data_hud_type)
		return
	var/datum/atom_hud/datahud = huds[data_hud_type]
	datahud.add_hud_to(src)
