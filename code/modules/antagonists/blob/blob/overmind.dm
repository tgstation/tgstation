//Few global vars to track the blob
GLOBAL_LIST_EMPTY(blobs) //complete list of all blobs made.
GLOBAL_LIST_EMPTY(blob_cores)
GLOBAL_LIST_EMPTY(overminds)
GLOBAL_LIST_EMPTY(blob_nodes)


/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	desc = "The overmind. It controls the blob."
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = 1
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER

	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	call_life = TRUE
	var/obj/structure/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/last_attack = 0
	var/datum/reagent/blob/blob_reagent_datum = new/datum/reagent/blob()
	var/list/blob_mobs = list()
	var/list/resource_blobs = list()
	var/free_chem_rerolls = 1 //one free chemical reroll
	var/nodes_required = 1 //if the blob needs nodes to place resource and factory blobs
	var/placed = 0
	var/base_point_rate = 2 //for blob core placement
	var/manualplace_min_time = 600 //in deciseconds //a minute, to get bearings
	var/autoplace_max_time = 3600 //six minutes, as long as should be needed
	var/list/blobs_legit = list()
	var/max_count = 0 //The biggest it got before death
	var/blobwincount = 400
	var/victory_in_progress = FALSE

/mob/camera/blob/Initialize(mapload, starting_points = 60)
	validate_location()
	blob_points = starting_points
	manualplace_min_time += world.time
	autoplace_max_time += world.time
	GLOB.overminds += src
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	last_attack = world.time
	var/datum/reagent/blob/BC = pick((subtypesof(/datum/reagent/blob)))
	blob_reagent_datum = new BC
	color = blob_reagent_datum.complementary_color
	if(blob_core)
		blob_core.update_icon()
	SSshuttle.registerHostileEnvironment(src)
	.= ..()

/mob/camera/blob/proc/validate_location()
	var/turf/T = get_turf(src)
	if(!is_valid_turf(T) && LAZYLEN(GLOB.blobstart))
		var/list/blobstarts = shuffle(GLOB.blobstart)
		for(var/_T in blobstarts)
			if(is_valid_turf(_T))
				T = _T
				break
	if(!T)
		CRASH("No blobspawnpoints and blob spawned in nullspace.")
	forceMove(T)

/mob/camera/blob/proc/is_valid_turf(turf/T)
	var/area/A = get_area(T)
	if((A && !A.blob_allowed) || !T || !is_station_level(T.z) || isspaceturf(T))
		return FALSE
	return TRUE

/mob/camera/blob/Life()
	if(!blob_core)
		if(!placed)
			if(manualplace_min_time && world.time >= manualplace_min_time)
				to_chat(src, "<b><span class='big'><font color=\"#EE4000\">You may now place your blob core.</font></span></b>")
				to_chat(src, "<span class='big'><font color=\"#EE4000\">You will automatically place your blob core in [DisplayTimeText(autoplace_max_time - world.time)].</font></span>")
				manualplace_min_time = 0
			if(autoplace_max_time && world.time >= autoplace_max_time)
				place_blob_core(base_point_rate, 1)
		else
			qdel(src)
	else if(!victory_in_progress && (blobs_legit.len >= blobwincount))
		victory_in_progress = TRUE
		priority_announce("Biohazard has reached critical mass. Station loss is imminent.", "Biohazard Alert")
		set_security_level("delta")
		max_blob_points = INFINITY
		blob_points = INFINITY
		addtimer(CALLBACK(src, .proc/victory), 450)

	if(!victory_in_progress && max_count < blobs_legit.len)
		max_count = blobs_legit.len
	..()


/mob/camera/blob/proc/victory()
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(100)
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/turf/T = get_turf(L)
		if(!T || !is_station_level(T.z))
			continue

		if(L in GLOB.overminds || (L.pass_flags & PASSBLOB))
			continue

		var/area/Ablob = get_area(T)

		if(!Ablob.blob_allowed)
			continue

		if(!(ROLE_BLOB in L.faction))
			playsound(L, 'sound/effects/splat.ogg', 50, 1)
			L.death()
			new/mob/living/simple_animal/hostile/blob/blobspore(T)
		else
			L.fully_heal()

		for(var/area/A in GLOB.sortedAreas)
			if(!(A.type in GLOB.the_station_areas))
				continue
			if(!A.blob_allowed)
				continue
			A.color = blob_reagent_datum.color
			A.name = "blob"
			A.icon = 'icons/mob/blob.dmi'
			A.icon_state = "blob_shield"
			A.layer = BELOW_MOB_LAYER
			A.invisibility = 0
			A.blend_mode = 0
	var/datum/antagonist/blob/B = mind.has_antag_datum(/datum/antagonist/blob)
	if(B)
		var/datum/objective/blob_takeover/main_objective = locate() in B.objectives
		if(main_objective)
			main_objective.completed = TRUE
	to_chat(world, "<B>[real_name] consumed the station in an unstoppable tide!</B>")
	SSticker.news_report = BLOB_WIN
	SSticker.force_ending = 1

/mob/camera/blob/Destroy()
	for(var/BL in GLOB.blobs)
		var/obj/structure/blob/B = BL
		if(B && B.overmind == src)
			B.overmind = null
			B.update_icon() //reset anything that was ours
	for(var/BLO in blob_mobs)
		var/mob/living/simple_animal/hostile/blob/BM = BLO
		if(BM)
			BM.overmind = null
			BM.update_icons()
	GLOB.overminds -= src

	SSshuttle.clearHostileEnvironment(src)

	return ..()

/mob/camera/blob/Login()
	..()
	to_chat(src, "<span class='notice'>You are the overmind!</span>")
	blob_help()
	update_health_hud()
	add_points(0)

/mob/camera/blob/examine(mob/user)
	..()
	if(blob_reagent_datum)
		to_chat(user, "Its chemical is <font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</font>.")

/mob/camera/blob/update_health_hud()
	if(blob_core)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(blob_core.obj_integrity)]</font></div>"
		for(var/mob/living/simple_animal/hostile/blob/blobbernaut/B in blob_mobs)
			if(B.hud_used && B.hud_used.blobpwrdisplay)
				B.hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(blob_core.obj_integrity)]</font></div>"

/mob/camera/blob/proc/add_points(points)
	blob_points = CLAMP(blob_points + points, 0, max_blob_points)
	hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(blob_points)]</font></div>"

/mob/camera/blob/say(message)
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

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_talk(src,"[key_name(src)] : [message]",LOGSAY)

	var/message_a = say_quote(message, get_spans())
	var/rendered = "<span class='big'><font color=\"#EE4000\"><b>\[Blob Telepathy\] [name](<font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</font>)</b> [message_a]</font></span>"

	for(var/mob/M in GLOB.mob_list)
		if(isovermind(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/mob/camera/blob/blob_act(obj/structure/blob/B)
	return

/mob/camera/blob/Stat()
	..()
	if(statpanel("Status"))
		if(blob_core)
			stat(null, "Core Health: [blob_core.obj_integrity]")
			stat(null, "Power Stored: [blob_points]/[max_blob_points]")
			stat(null, "Blobs to Win: [blobs_legit.len]/[blobwincount]")
		if(free_chem_rerolls)
			stat(null, "You have [free_chem_rerolls] Free Chemical Reroll\s Remaining")
		if(!placed)
			if(manualplace_min_time)
				stat(null, "Time Before Manual Placement: [max(round((manualplace_min_time - world.time)*0.1, 0.1), 0)]")
			stat(null, "Time Before Automatic Placement: [max(round((autoplace_max_time - world.time)*0.1, 0.1), 0)]")

/mob/camera/blob/Move(NewLoc, Dir = 0)
	if(placed)
		var/obj/structure/blob/B = locate() in range("3x3", NewLoc)
		if(B)
			forceMove(NewLoc)
		else
			return 0
	else
		var/area/A = get_area(NewLoc)
		if(isspaceturf(NewLoc) || istype(A, /area/shuttle)) //if unplaced, can't go on shuttles or space tiles
			return 0
		forceMove(NewLoc)
		return 1

/mob/camera/blob/mind_initialize()
	. = ..()
	var/datum/antagonist/blob/B = mind.has_antag_datum(/datum/antagonist/blob)
	if(!B)
		mind.add_antag_datum(/datum/antagonist/blob)
