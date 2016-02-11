/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASSBLOB
	faction = list("blob")

	var/obj/effect/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/last_attack = 0
	var/datum/reagent/blob/blob_reagent_datum = new/datum/reagent/blob()
	var/list/blob_mobs = list()
	var/ghostimage = null

/mob/camera/blob/New()
	overminds += src
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	last_attack = world.time
	var/list/possible_reagents = list()
	for(var/type in (subtypesof(/datum/reagent/blob)))
		possible_reagents.Add(new type)
	blob_reagent_datum = pick(possible_reagents)
	if(blob_core)
		blob_core.update_icon()

	ghostimage = image(src.icon,src,src.icon_state)
	ghost_darkness_images |= ghostimage //so ghosts can see the blob cursor when they disable darkness
	updateallghostimages()
	..()

/mob/camera/blob/Life()
	if(!blob_core)
		qdel(src)
	..()

/mob/camera/blob/Destroy()
	overminds -= src
	if (ghostimage)
		ghost_darkness_images -= ghostimage
		qdel(ghostimage)
		ghostimage = null;
		updateallghostimages()
	return ..()

/mob/camera/blob/Login()
	..()
	sync_mind()
	src << "<span class='notice'>You are the overmind!</span>"
	blob_help()
	update_health_hud()

/mob/camera/blob/update_health_hud()
	if(blob_core)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(blob_core.health)]</font></div>"

/mob/camera/blob/proc/add_points(points)
	if(points != 0)
		blob_points = Clamp(blob_points + points, 0, max_blob_points)
		hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(src.blob_points)]</font></div>"

/mob/camera/blob/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
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

	for(var/mob/M in mob_list)
		if(isovermind(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			M << rendered
		if(isobserver(M))
			M << "<a href='?src=\ref[M];follow=\ref[src]'>(F)</a>[rendered]"

/mob/camera/blob/emote(act,m_type=1,message = null)
	return

/mob/camera/blob/blob_act()
	return

/mob/camera/blob/Stat()
	..()
	if(statpanel("Status"))
		if(blob_core)
			stat(null, "Core Health: [blob_core.health]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")

/mob/camera/blob/Move(NewLoc, Dir = 0)
	var/obj/effect/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		loc = NewLoc
	else
		return 0

/mob/camera/blob/proc/can_attack()
	return (world.time > (last_attack + CLICK_CD_RANGE))
