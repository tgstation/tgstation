//Few global vars to track the infections
GLOBAL_LIST_EMPTY(infections) //complete list of all infections made.
GLOBAL_LIST_EMPTY(infection_nodes)
GLOBAL_VAR(infection_core)
GLOBAL_VAR(infection_commander)

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
	var/obj/structure/infection/core/infection_core = null // The infection commanders's core
	var/infection_points = 0
	var/max_infection_points = 100
	var/upgrade_points = 1 // obtained by destroying beacons
	var/last_attack = 0
	var/list/infection_mobs = list()
	var/list/resource_infection = list()
	var/nodes_required = FALSE //if the infection needs nodes to place resource and factory blobs
	var/placed = FALSE
	var/placing = FALSE
	var/freecam = FALSE
	var/base_point_rate = 2 //for core placement
	var/autoplace_time = CORE_AUTOPLACE_TIME // 5 minutes
	var/victory_in_progress = FALSE
	var/infection_color = "#ffffff"
	var/datum/atom_hud/medical_hud

	var/list/default_actions = list(/datum/action/cooldown/infection/creator/shield,
									/datum/action/cooldown/infection/creator/resource,
									/datum/action/cooldown/infection/creator/node,
									/datum/action/cooldown/infection/creator/factory,
									/datum/action/cooldown/infection/coregrab)

	var/list/unlockable_actions = list()

	var/datum/infection_menu/menu_handler

/mob/camera/commander/Initialize(mapload, starting_points = max_infection_points)
	if(GLOB.infection_commander)
		return INITIALIZE_HINT_QDEL // there can be only one
	. = ..()
	GLOB.infection_commander = src
	infection_points = starting_points
	autoplace_time += world.time
	last_attack = world.time
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

/mob/camera/commander/proc/generate_unlockables()
	for(var/upgrade_type in subtypesof(/datum/infection_upgrade/overmind))
		unlockable_actions += new upgrade_type()

/mob/camera/commander/proc/generate_announcement()
	priority_announce("[station_name()]: An abnormal and biological meteor has been detected on a collision course with your station. \n\n\
					   This substance appears to be self replicating, and will stop at nothing to consume all matter around it.\n\n\
					   Our calculations estimate the meteor will impact in [(autoplace_time - world.time)/600] minutes.\n\n\
					   We will be deploying beacons that will defend the majority of your station, provided that they are not destroyed.\n\n\
					   Further updates will be given as we analyze the substance.",
					  "CentCom Biohazard Division", 'sound/misc/notice1.ogg')

/mob/camera/commander/proc/info_announcement()
	priority_announce("[station_name()]: We have updated information regarding the biohazardous substance. \n\n\
					   It appears to have a core that is virtually indestructible, we have been unable to affect it in any way, even with something as powerful as a singularity.\n\n\
					   We advise that you do not attempt to attack the core, unless you find something that you think may damage it.\n\n\
					   The meteor also appears to be heavily defended by many structures, that attack seemingly anything that gets close to it.\n\n\
					   However some of these structures do not seem to naturally regenerate, and if they do, are not as strong as they once were.\n\n\
					   Try to use this information to your advantage, we will report back again once the core has landed.",
					  "CentCom Biohazard Division", 'sound/misc/notice1.ogg')


/mob/camera/commander/proc/defeated_announcement()
	priority_announce("Our scanners detect no trace of any sentient infectious substance, threat neutralized.",
					  "CentCom Biohazard Division", 'sound/misc/notice2.ogg')

/mob/camera/commander/proc/place_beacons()
	for(var/obj/effect/landmark/beacon_start/B in GLOB.beacon_spawns)
		var/turf/T = get_turf(B)
		var/obj/structure/beacon_generator/G = new /obj/structure/beacon_generator(T.loc)
		G.forceMove(T)
		G.setDir(B.dir)
		INVOKE_ASYNC(G, /obj/structure/beacon_generator.proc/generateWalls)
		sleep(100 / GLOB.beacon_spawns.len)

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
			A.name = "eye mass"
			A.icon = 'icons/mob/infection/infection.dmi'
			A.icon_state = "eyemass"
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
