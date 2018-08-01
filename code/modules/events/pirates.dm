#define LOOT_LOCATOR_COOLDOWN 150

/datum/round_event_control/pirates
	name = "Space Pirates"
	typepath = /datum/round_event/pirates
	weight = 8
	max_occurrences = 1
	min_players = 10
	earliest_start = 30 MINUTES
	gamemode_blacklist = list("nuclear")

/datum/round_event_control/pirates/preRunEvent()
	if (!SSmapping.empty_space)
		return EVENT_CANT_RUN

	return ..()

/datum/round_event/pirates
	startWhen = 60 //2 minutes to answer
	var/datum/comm_message/threat
	var/payoff = 0
	var/paid_off = FALSE
	var/ship_name = "Space Privateers Association"
	var/shuttle_spawned = FALSE

/datum/round_event/pirates/setup()
	ship_name = pick(strings(PIRATE_NAMES_FILE, "ship_names"))

/datum/round_event/pirates/announce()
	priority_announce("Incoming subspace communication. Secure channel opened at all communication consoles.", "Incoming Message", 'sound/ai/commandreport.ogg')

	if(!control) //Means this is false alarm, todo : explicit checks instead of using announceWhen
		return
	threat = new
	payoff = round(SSshuttle.points * 0.80)
	threat.title = "Business proposition"
	threat.content = "This is [ship_name]. Pay up [payoff] credits or you'll walk the plank."
	threat.possible_answers = list("We'll pay.","No way.")
	threat.answer_callback = CALLBACK(src,.proc/answered)
	SScommunications.send_message(threat,unique = TRUE)

/datum/round_event/pirates/proc/answered()
	if(threat && threat.answered == 1)
		if(SSshuttle.points >= payoff)
			SSshuttle.points -= payoff
			priority_announce("Thanks for the credits, landlubbers.",sender_override = ship_name)
			paid_off = TRUE
			return
		else
			priority_announce("Trying to cheat us? You'll regret this!",sender_override = ship_name)
	if(!shuttle_spawned)
		spawn_shuttle()



/datum/round_event/pirates/start()
	if(!paid_off && !shuttle_spawned)
		spawn_shuttle()

/datum/round_event/pirates/proc/spawn_shuttle()
	shuttle_spawned = TRUE

	var/list/candidates = pollGhostCandidates("Do you wish to be considered for pirate crew?", ROLE_TRAITOR)
	shuffle_inplace(candidates)

	var/datum/map_template/shuttle/pirate/default/ship = new
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("Pirate event found no turf to load in")

	if(!ship.load(T))
		CRASH("Loading pirate ship failed!")
	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/pirate/spawner in A)
			if(candidates.len > 0)
				var/mob/M = candidates[1]
				spawner.create(M.ckey)
				candidates -= M
			else
				notify_ghosts("Space pirates are waking up!", source = spawner, action=NOTIFY_ATTACK, flashwindow = FALSE)

	priority_announce("Unidentified armed ship detected near the station.")

//Shuttle equipment

/obj/machinery/shuttle_scrambler
	name = "Data Siphon"
	desc = "This heap of machinery steals credits and data from unprotected systems and locks down cargo shuttles."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = TRUE
	var/active = FALSE
	var/obj/item/gps/gps
	var/credits_stored = 0
	var/siphon_per_tick = 5

/obj/machinery/shuttle_scrambler/Initialize(mapload)
	. = ..()
	gps = new/obj/item/gps/internal/pirate(src)
	gps.tracking = FALSE
	update_icon()

/obj/machinery/shuttle_scrambler/process()
	if(active)
		if(is_station_level(z))
			var/siphoned = min(SSshuttle.points,siphon_per_tick)
			SSshuttle.points -= siphoned
			credits_stored += siphoned
			interrupt_research()
		else
			return
	else
		STOP_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/proc/toggle_on(mob/user)
	SSshuttle.registerTradeBlockade(src)
	gps.tracking = TRUE
	active = TRUE
	to_chat(user,"<span class='notice'>You toggle [src] [active ? "on":"off"].</span>")
	to_chat(user,"<span class='warning'>The scrambling signal can be now tracked by GPS.</span>")
	START_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/interact(mob/user)
	if(!active)
		if(alert(user, "Turning the scrambler on will make the shuttle trackable by GPS. Are you sure you want to do it?", "Scrambler", "Yes", "Cancel") == "Cancel")
			return
		if(active || !user.canUseTopic(src))
			return
		toggle_on(user)
		update_icon()
		send_notification()
	else
		dump_loot(user)

//interrupt_research
/obj/machinery/shuttle_scrambler/proc/interrupt_research()
	for(var/obj/machinery/rnd/server/S in GLOB.machines)
		if(S.stat & (NOPOWER|BROKEN))
			continue
		S.emp_act(1)
		new /obj/effect/temp_visual/emp(get_turf(S))

/obj/machinery/shuttle_scrambler/proc/dump_loot(mob/user)
	if(credits_stored < 200)
		to_chat(user,"<span class='notice'>Not enough credits to retrieve.</span>")
		return
	while(credits_stored >= 200)
		new /obj/item/stack/spacecash/c200(drop_location())
		credits_stored -= 200
	to_chat(user,"<span class='notice'>You retrieve the siphoned credits!</span>")


/obj/machinery/shuttle_scrambler/proc/send_notification()
	priority_announce("Data theft signal detected, source registered on local gps units.")

/obj/machinery/shuttle_scrambler/proc/toggle_off(mob/user)
	SSshuttle.clearTradeBlockade(src)
	gps.tracking = FALSE
	active = FALSE
	STOP_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/update_icon()
	if(active)
		icon_state = "dominator-blue"
	else
		icon_state = "dominator"

/obj/machinery/shuttle_scrambler/Destroy()
	toggle_off()
	QDEL_NULL(gps)
	return ..()

/obj/item/gps/internal/pirate
	gpstag = "Nautical Signal"
	desc = "You can hear shanties over the static."

/obj/machinery/computer/shuttle/pirate
	name = "pirate shuttle console"
	shuttleId = "pirateship"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	possible_destinations = "pirateship_away;pirateship_home;pirateship_custom"

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/pirate
	name = "pirate shuttle navigation computer"
	desc = "Used to designate a precise transit location for the pirate shuttle."
	shuttleId = "pirateship"
	lock_override = CAMERA_LOCK_STATION
	shuttlePortId = "pirateship_custom"
	shuttlePortName = "custom location"
	x_offset = 9
	y_offset = 0
	see_hidden = FALSE

/obj/docking_port/mobile/pirate
	name = "pirate shuttle"
	id = "pirateship"
	var/engines_cooling = FALSE
	var/engine_cooldown = 3 MINUTES

/obj/docking_port/mobile/pirate/getStatusText()
	. = ..()
	if(engines_cooling)
		return "[.] - Engines cooling."

/obj/docking_port/mobile/pirate/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	. = ..()
	if(. == DOCKING_SUCCESS && !is_reserved_level(new_dock.z))
		engines_cooling = TRUE
		addtimer(CALLBACK(src,.proc/reset_cooldown),engine_cooldown,TIMER_UNIQUE)

/obj/docking_port/mobile/pirate/proc/reset_cooldown()
	engines_cooling = FALSE

/obj/docking_port/mobile/pirate/canMove()
	if(engines_cooling)
		return FALSE
	return ..()

/obj/machinery/suit_storage_unit/pirate
	suit_type = /obj/item/clothing/suit/space
	helmet_type = /obj/item/clothing/head/helmet/space
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/oxygen

/obj/machinery/loot_locator
	name = "Booty Locator"
	desc = "This sophisticated machine scans the nearby space for items of value."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	var/cooldown = 0
	var/result_count = 3 //Show X results.

/obj/machinery/proc/display_current_value()
	var/area/current = get_area(src)
	var/value = 0
	for(var/turf/T in current.contents)
		value += export_item_and_contents(T,TRUE, TRUE, dry_run = TRUE)
	say("Current vault value : [value] credits.")

/obj/machinery/loot_locator/interact(mob/user)
	if(world.time <= cooldown)
		to_chat(user,"<span class='warning'>[src] is recharging.</span>")
		return
	cooldown = world.time + LOOT_LOCATOR_COOLDOWN
	display_current_value()
	var/list/results = list()
	for(var/atom/movable/AM in world)
		if(is_type_in_typecache(AM,GLOB.pirate_loot_cache))
			if(is_station_level(AM.z))
				if(get_area(AM) == get_area(src)) //Should this be variable ?
					continue
				results += AM
		CHECK_TICK
	if(!results.len)
		say("No valuables located. Try again later.")
	else
		for(var/i in 1 to result_count)
			if(!results.len)
				return
			var/atom/movable/AM = pick_n_take(results)
			say("Located: [AM.name] at [get_area_name(AM)]")

#undef LOOT_LOCATOR_COOLDOWN