//Few global vars to track the blob
GLOBAL_LIST_EMPTY(infections) //complete list of all infections made.
GLOBAL_LIST_EMPTY(infection_cores)
GLOBAL_LIST_EMPTY(infection_nodes)
GLOBAL_LIST_EMPTY(infection_beacons)


/mob/camera/commander
	name = "Infection Commander"
	real_name = "Infection Commander"
	desc = "The commander. It controls the infection."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = 1
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	color = "#00a7ff"

	pass_flags = PASSBLOB
	faction = list(ROLE_INFECTION)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	call_life = TRUE
	hud_type = /datum/hud/infection_commander
	var/obj/structure/infection/core/infection_core = null // The infection commanders's core
	var/obj/effect/meteor/infection/meteor = null // The infection's incoming meteor
	var/infection_points = 0
	var/max_infection_points = 100000
	var/last_attack = 0
	var/list/infection_mobs = list()
	var/list/resource_infection = list()
	var/nodes_required = 1 //if the blob needs nodes to place resource and factory blobs
	var/placed = 0
	var/base_point_rate = 2 //for blob core placement
	var/autoplace_time = 100 // a few seconds, just so it isnt sudden at game start
	var/victory_in_progress = FALSE
	var/infection_color = "#ff5800"

/mob/camera/commander/Initialize(mapload, starting_points = max_infection_points)
	infection_points = starting_points
	autoplace_time += world.time
	last_attack = world.time
	if(infection_core)
		infection_core.update_icon()
	SSshuttle.registerHostileEnvironment(src)
	.= ..()

/mob/camera/commander/Life()
	if(!infection_core && !meteor)
		if(!placed)
			if(autoplace_time && world.time >= autoplace_time)
				place_infection_core()
		else
			qdel(src)
	else if(!victory_in_progress && !GLOB.infection_beacons.len && !meteor)
		victory_in_progress = TRUE
		priority_announce("Security beacons have been destroyed. Station loss is imminent.", "Infection Alert")
		set_security_level("delta")
		max_infection_points = INFINITY
		infection_points = INFINITY
		addtimer(CALLBACK(src, .proc/victory), 450)
	..()


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
			A.color = infection_color
			A.name = "infection"
			A.icon = 'icons/mob/blob.dmi'
			A.icon_state = "blob_shield"
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
	SSticker.force_ending = 1

/mob/camera/commander/Destroy()
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

	SSshuttle.clearHostileEnvironment(src)

	return ..()

/mob/camera/commander/Login()
	..()
	to_chat(src, "<span class='notice'>You are the infection!</span>")
	infection_help()
	update_health_hud()
	add_points(0)

/mob/camera/commander/examine(mob/user)
	..()
	to_chat(user, "<font color=[infection_color]>The commander of the infection.</font>")

/mob/camera/commander/update_health_hud()
	if(infection_core)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(infection_core.obj_integrity)]</font></div>"
		for(var/mob/living/simple_animal/hostile/infection/infesternaut/I in infection_mobs)
			if(I.hud_used && I.hud_used.infectionpwrdisplay)
				I.hud_used.infectionpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(infection_core.obj_integrity)]</font></div>"

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

	var/message_a = say_quote(message, get_spans())
	var/rendered = "<span class='big'><font color=\"#EE4000\"><b>(<font color=\"[infection_color]\">[src.name]</font>)</b> [message_a]</font></span>"

	for(var/mob/M in GLOB.mob_list)
		if(iscommander(M) || isovermind(M) || istype(M, /mob/living/simple_animal/hostile/infection))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/mob/camera/commander/blob_act(obj/structure/infection/I)
	return

/mob/camera/commander/Stat()
	..()
	if(statpanel("Status"))
		if(infection_core)
			stat(null, "Core Health: [infection_core.obj_integrity]")
			stat(null, "Power Stored: [infection_points]/[max_infection_points]")
			stat(null, "Beacons to Win: [GLOB.infection_beacons.len]")
		if(!placed)
			stat(null, "Time Before Automatic Placement: [max(round((autoplace_time - world.time)*0.1, 0.1), 0)]")

/mob/camera/commander/Move(NewLoc, Dir = 0)
	if(meteor)
		return 0
	forceMove(NewLoc)
	return 1

/mob/camera/commander/mind_initialize()
	. = ..()
	var/datum/antagonist/infection/I = mind.has_antag_datum(/datum/antagonist/infection)
	if(!I)
		mind.add_antag_datum(/datum/antagonist/infection)
