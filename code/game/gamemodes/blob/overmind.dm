/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	desc = "The overmind. It controls the blob."
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"
	mouse_opacity = 1
	move_on_shuttle = 1
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER

	pass_flags = PASSBLOB
	faction = list("blob")
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
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

/mob/camera/blob/Initialize(mapload, pre_placed = 0, mode_made = 0, starting_points = 60)
	blob_points = starting_points
	if(pre_placed) //we already have a core!
		manualplace_min_time = 0
		autoplace_max_time = 0
		placed = 1
	else
		if(mode_made)
			manualplace_min_time = world.time + BLOB_NO_PLACE_TIME
		else
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

	..()

/mob/camera/blob/Life()
	if(!blob_core)
		if(!placed)
			if(manualplace_min_time && world.time >= manualplace_min_time)
				to_chat(src, "<b><span class='big'><font color=\"#EE4000\">You may now place your blob core.</font></span></b>")
				to_chat(src, "<span class='big'><font color=\"#EE4000\">You will automatically place your blob core in [round((autoplace_max_time - world.time)/600, 0.5)] minutes.</font></span>")
				manualplace_min_time = 0
			if(autoplace_max_time && world.time >= autoplace_max_time)
				place_blob_core(base_point_rate, 1)
		else
			qdel(src)
	..()

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

	return ..()

/mob/camera/blob/Login()
	..()
	sync_mind()
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
	blob_points = Clamp(blob_points + points, 0, max_blob_points)
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
	log_say("[key_name(src)] : [message]")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	var/message_a = say_quote(message, get_spans())
	var/rendered = "<span class='big'><font color=\"#EE4000\"><b>\[Blob Telepathy\] [name](<font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</font>)</b> [message_a]</font></span>"

	for(var/mob/M in GLOB.mob_list)
		if(isovermind(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/mob/camera/blob/emote(act,m_type=1,message = null)
	return

/mob/camera/blob/blob_act(obj/structure/blob/B)
	return

/mob/camera/blob/Stat()
	..()
	if(statpanel("Status"))
		if(blob_core)
			stat(null, "Core Health: [blob_core.obj_integrity]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")
		if(SSticker && istype(SSticker.mode, /datum/game_mode/blob))
			var/datum/game_mode/blob/B = SSticker.mode
			stat(null, "Blobs to Win: [GLOB.blobs_legit.len]/[B.blobwincount]")
		else
			stat(null, "Total Blobs: [GLOB.blobs.len]")
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
			loc = NewLoc
		else
			return 0
	else
		var/area/A = get_area(NewLoc)
		if(isspaceturf(NewLoc) || istype(A, /area/shuttle)) //if unplaced, can't go on shuttles or space tiles
			return 0
		loc = NewLoc
		return 1
