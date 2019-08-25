//Few global vars to track the infections
GLOBAL_LIST_EMPTY(infections) //complete list of all infections made.
GLOBAL_LIST_EMPTY(infection_nodes)
GLOBAL_VAR(infection_core)
GLOBAL_VAR(infection_commander)

/*
	The actual commander of the infection that places down all of the structures and commands every creature
*/

/mob/camera/commander
	name = "Infection Commander"
	real_name = "Infection Commander"
	desc = "The commander. It controls the infection."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	color = "#00a7ff"

	pass_flags = PASSBLOB
	faction = list(ROLE_INFECTION)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	hud_type = /datum/hud/infection_commander
	// The infection commanders physical core
	var/obj/structure/infection/core/infection_core = null
	// The amount of points that can be spent on structures and powers
	var/infection_points = 0
	// The maximum amount of points that can be attained
	var/max_infection_points = 100
	// Upgrade points used to buy evolutions in the evolution shop
	var/upgrade_points = 1
	// List of all the infection mobs this commander controls
	var/list/infection_mobs = list()
	// List of all the resource infection this commander controls
	var/list/resource_infection = list()
	// If the infection requires nodes to place down some structures
	var/nodes_required = FALSE
	// If the core has been placed or not
	var/placed = FALSE
	// Are we placing the core of the infection? Used to prevent premature end of gamemode
	var/placing = FALSE
	// If this commander can move his camera wherever he wants with no limitations
	var/freecam = TRUE
	// Points generated every life tick from the core
	var/base_point_rate = 2
	// The amount of time it takes for the core to be placed after this mob has been spawned
	var/autoplace_time = CORE_AUTOPLACE_TIME
	// If we're winning and don't want to lose after this moment
	var/victory_in_progress = FALSE
	// Color that all of the infection are tinted
	var/infection_color = "#ffffff"
	// The medical hud display for the commander
	var/datum/atom_hud/medical_hud

	// Actions that the infection commander starts with
	var/list/default_actions = list(/datum/action/cooldown/infection/creator/shield,
									/datum/action/cooldown/infection/creator/resource,
									/datum/action/cooldown/infection/creator/node,
									/datum/action/cooldown/infection/creator/factory,
									/datum/action/cooldown/infection/coregrab,
									/datum/action/cooldown/infection/targetlocation)

	// Actions that the infection commander can spend upgrade points to unlock
	var/list/unlockable_actions = list()

	// Menu handler for the evolution menu
	var/datum/infection_menu/menu_handler

/mob/camera/commander/Initialize(mapload, starting_points = max_infection_points)
	if(GLOB.infection_commander)
		return INITIALIZE_HINT_QDEL // there can be only one
	. = ..()
	GLOB.infection_commander = src
	infection_points = starting_points
	autoplace_time += world.time
	if(infection_core)
		infection_core.update_icon()
	SSshuttle.registerHostileEnvironment(src)
	addtimer(CALLBACK(src, .proc/generate_announcement), CORE_AUTOPLACE_TIME * 0.1)
	addtimer(CALLBACK(src, .proc/place_beacons), CORE_AUTOPLACE_TIME * 0.3)
	addtimer(CALLBACK(src, .proc/info_announcement), CORE_AUTOPLACE_TIME * 0.5)

	for(var/type_action in default_actions)
		var/datum/action/cooldown/infection/add_action = new type_action()
		add_action.Grant(src)
	generate_unlockables()
	SSmobs.clients_by_zlevel[z] += src
	menu_handler = new /datum/infection_menu(src)
	START_PROCESSING(SSobj, src)

/*
	Adds unlockables to the unlockable upgrades list so you don't have to manually
*/
/mob/camera/commander/proc/generate_unlockables()
	for(var/upgrade_type in subtypesof(/datum/infection_upgrade/overmind))
		unlockable_actions += new upgrade_type()

/*
	First info announcement when the infection has just been spotted
*/
/mob/camera/commander/proc/generate_announcement()
	priority_announce("[station_name()]: A self replicating and all consuming entity has been detected on a collision course with your station. \n\
					   Our calculations estimate the substance will impact in [(autoplace_time - world.time)/600] minutes.\n\n\
					   We will be deploying beacons that will defend the majority of your station, prepare to go to war to protect them. \n\
					   There will also be a gravity generator near your arrivals shuttle, we recommend that you power it unless you want to fight while floating around.",
					  "CentCom Biohazard Division", 'sound/misc/notice1.ogg')

/*
	Extra info announcement to hopefully avoid people running in and dying to an unkillable enemy
*/
/mob/camera/commander/proc/info_announcement()
	priority_announce("[station_name()]: The entity appears to have a core that is virtually indestructible, normal destructive methods will not affect it in any way. \n\n\
					   The core is also heavily defended, so we recommend that you don't rush in blindly unless you want to feed the infection. \n\n\
					   On that note, the infection appears to be able to assimilate sentient creatures into its own army, top priority should be saving those killed by the infection.",
					  "CentCom Biohazard Division", 'sound/misc/notice1.ogg')

/*
	Players win, infection is defeated
*/
/mob/camera/commander/proc/defeated_announcement()
	priority_announce("Our scanners detect no trace of any sentient infectious substance, threat neutralized.",
					  "CentCom Biohazard Division", 'sound/misc/notice2.ogg')

/*
	Places the beacons down at all of the landmarks in the map files, slightly delayed to make it look cool
*/
/mob/camera/commander/proc/place_beacons()
	for(var/obj/effect/landmark/beacon_start/B in GLOB.beacon_spawns)
		var/turf/T = get_turf(B)
		var/obj/structure/beacon_generator/G = new /obj/structure/beacon_generator(T.loc)
		G.forceMove(T)
		G.setDir(B.dir)
		INVOKE_ASYNC(G, /obj/structure/beacon_generator.proc/generateWalls)
		sleep(100 / GLOB.beacon_spawns.len)
	var/turf/T = pick(GLOB.infection_gravity_spawns)
	if(T)
		new /obj/machinery/gravity_generator/main/station(T)
	else
		message_admins("Could not find extra gravity generator spawn location for infection gamemode, consider spawning in a gravity generator behind all of the beacons.")

/mob/camera/commander/process()
	if(!infection_core)
		if(!placed && !placing)
			if(autoplace_time && world.time >= autoplace_time)
				place_infection_core()
		else if(placed)
			qdel(src)
	else if(!victory_in_progress && !GLOB.infection_beacons.len)
		victory_in_progress = TRUE
		priority_announce("The infection is replicating at an unstoppable rate, total station takeover estimated at T-minus 25 seconds.", "CentCom Biohazard Division")
		set_security_level("delta")
		max_infection_points = INFINITY
		infection_points = INFINITY
		addtimer(CALLBACK(src, .proc/victory), 250)

/*
	Called when all of the beacons have been destroyed and the infection has won
*/
/mob/camera/commander/proc/victory()
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(100)
	for(var/i in GLOB.mob_living_list - src)
		var/mob/living/L = i
		var/turf/T = get_turf(L)
		if(!T || !is_station_level(T.z))
			continue

		if(L in GLOB.overminds || (L.pass_flags & PASSBLOB))
			continue

		var/area/Ablob = get_area(T)

		if(!Ablob.blob_allowed)
			continue

		if(!(ROLE_INFECTION in L.faction))
			playsound(L, 'sound/effects/splat.ogg', 50, 1)
			L.death()
			new/mob/living/simple_animal/hostile/infection/infectionspore(T)
		else
			L.fully_heal()

		for(var/area/A in GLOB.sortedAreas)
			if(!(A.type in GLOB.the_station_areas))
				continue
			if(!A.blob_allowed)
				continue
			A.name = "normal infection"
			A.icon = 'icons/mob/infection/infection.dmi'
			A.icon_state = "normal"
			A.layer = BELOW_MOB_LAYER
			A.invisibility = 0
			A.blend_mode = 0
	var/datum/antagonist/infection/I = mind.has_antag_datum(/datum/antagonist/infection)
	if(I)
		var/datum/objective/infection_takeover/main_objective = locate() in I.objectives
		if(main_objective)
			main_objective.completed = TRUE
	to_chat(world, "<B>[real_name] consumed the station in an unstoppable tide!</B>")
	SSticker.news_report = BLOB_WIN
	SSticker.force_ending = TRUE

/mob/camera/commander/Destroy()
	GLOB.infection_commander = null
	for(var/IN in GLOB.infections)
		var/obj/structure/infection/I = IN
		if(I && I.overmind == src)
			I.overmind = null
			I.update_icon() //reset anything that was ours
	for(var/IB in infection_mobs)
		var/mob/living/simple_animal/hostile/infection/I = IB
		if(I)
			I.overmind = null
			I.update_icons()
	STOP_PROCESSING(SSobj, src)

	SSshuttle.clearHostileEnvironment(src)

	SSmobs.clients_by_zlevel[z] -= src

	addtimer(CALLBACK(src, .proc/defeated_announcement), 40)

	return ..()

/mob/camera/commander/Login()
	. = ..()
	to_chat(src, "<span class='notice'>You are the infection!</span>")
	infection_help()
	update_health_hud()
	add_points(0)

/mob/camera/commander/examine(mob/user)
	. = ..()
	to_chat(user, "<font color=[infection_color]>The commander of the infection.</font>")

/mob/camera/commander/update_health_hud()
	if(infection_core)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(infection_core.obj_integrity)]</font></div>"

/*
	Adds points to the infection commander, but not over or under the maximum or minimum
*/
/mob/camera/commander/proc/add_points(points)
	infection_points = CLAMP(infection_points + points, 0, max_infection_points)
	hud_used.infectionpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(infection_points)]</font></div>"

/mob/camera/commander/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	infection_talk(message)

/*
	Tries to talk to other fellow infectious creature with the message sent
*/
/mob/camera/commander/proc/infection_talk(message)

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	src.log_talk(message, LOG_SAY)

	var/rendered = "<span class='big'><font color=\"#EE4000\"><b>(<font color=\"[color]\">[src.name]</font>)</b> [message]</font></span>"

	for(var/mob/M in GLOB.mob_list)
		if(iscommander(M) || isinfectionmonster(M))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/mob/camera/commander/blob_act(obj/structure/infection/I)
	return

/*
	Toggles the medical heads up display
*/
/mob/camera/commander/proc/toggle_medical_hud()
	if(medical_hud)
		medical_hud.remove_hud_from(src)
		medical_hud = null
	else
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		hud.add_hud_to(src)
		medical_hud = hud

/mob/camera/commander/Stat()
	. = ..()
	if(statpanel("Status"))
		if(infection_core)
			stat(null, "Core Health: [infection_core.obj_integrity]")
			stat(null, "Power Stored: [infection_points]/[max_infection_points]")
			stat(null, "Upgrade Points: [upgrade_points]")
			stat(null, "Beacons Remaining: [GLOB.infection_beacons.len]")
		if(!placed)
			stat(null, "Time Before Automatic Placement: [max(round((autoplace_time - world.time)*0.1, 0.1), 0)]")

/mob/camera/commander/Move(NewLoc, Dir = 0)
	if(freecam || !placed)
		forceMove(NewLoc)
		return TRUE
	if(placed)
		var/obj/structure/infection/I = locate() in range("3x3", NewLoc)
		if(I)
			forceMove(NewLoc)
			return TRUE
		else
			return FALSE
	return TRUE
