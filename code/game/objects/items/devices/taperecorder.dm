/obj/item/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_empty"
	inhand_icon_state = "analyzer"
	worn_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = HEAR_1
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=60, /datum/material/glass=30)
	force = 2
	throwforce = 0
	var/recording = FALSE
	var/playing = FALSE
	var/playsleepseconds = 0
	var/obj/item/tape/mytape
	var/starting_tape_type = /obj/item/tape/random
	var/open_panel = FALSE
	var/canprint = TRUE
	var/list/icons_available = list()
	var/icon_directory = 'icons/effects/icons.dmi'


/obj/item/taperecorder/Initialize(mapload)
	. = ..()
	if(starting_tape_type)
		mytape = new starting_tape_type(src)
	update_icon()


/obj/item/taperecorder/examine(mob/user)
	. = ..()
	. += "The wire panel is [open_panel ? "opened" : "closed"]."

/obj/item/taperecorder/AltClick(mob/user)
	. = ..()
	play()

/obj/item/taperecorder/proc/update_available_icons()
	icons_available = list()

	if(recording)
		icons_available += list("Stop Recording" = image(icon = icon_directory, icon_state = "record_stop"))
	else
		if(!playing)
			icons_available += list("Record" = image(icon = icon_directory, icon_state = "record"))

	if(playing)
		icons_available += list("Pause" = image(icon = icon_directory, icon_state = "pause"))
	else
		if(!recording)
			icons_available += list("Play" = image(icon = icon_directory, icon_state = "play"))

	if(canprint && !recording && !playing)
		icons_available += list("Print Transcript" = image(icon = icon_directory, icon_state = "print"))
	if(mytape)
		icons_available += list("Eject" = image(icon = icon_directory, icon_state = "eject"))

/obj/item/taperecorder/attackby(obj/item/I, mob/user, params)
	if(!mytape && istype(I, /obj/item/tape))
		if(!user.transferItemToLoc(I,src))
			return
		mytape = I
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
		update_icon()


/obj/item/taperecorder/proc/eject(mob/user)
	if(mytape)
		playsound(src, 'sound/items/taperecorder/taperecorder_open.ogg', 50, FALSE)
		to_chat(user, "<span class='notice'>You remove [mytape] from [src].</span>")
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon()

/obj/item/taperecorder/fire_act(exposed_temperature, exposed_volume)
	mytape.ruin() //Fires destroy the tape
	..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/taperecorder/attack_hand(mob/user)
	if(loc != user || !mytape || !user.is_holding(src))
		return ..()
	eject(user)

/obj/item/taperecorder/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return TRUE
	return FALSE


/obj/item/taperecorder/verb/ejectverb()
	set name = "Eject Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return

	eject(usr)


/obj/item/taperecorder/update_icon_state()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"


/obj/item/taperecorder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list())
	. = ..()
	if(mytape && recording)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] [message]"

/obj/item/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	if(mytape.used_capacity < mytape.max_capacity)
		to_chat(usr, "<span class='notice'>Recording started.</span>")
		playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
		recording = 1
		update_icon()
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording started."
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		while(recording && used < max)
			mytape.used_capacity++
			used++
			sleep(10)
		recording = FALSE
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The tape is full.</span>")


/obj/item/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(!can_use(usr))
		return

	if(recording)
		recording = FALSE
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity * 10,"mm:ss")]\] Recording stopped."
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		to_chat(usr, "<span class='notice'>Recording stopped.</span>")
		return
	else if(playing)
		playing = FALSE
		var/turf/T = get_turf(src)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>")
	update_icon()


/obj/item/taperecorder/verb/play()
	set name = "Play Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	playing = 1
	update_icon()
	to_chat(usr, "<span class='notice'>Playing started.</span>")
	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used <= max, sleep(10 * playsleepseconds))
		if(!mytape)
			break
		if(playing == FALSE)
			break
		if(mytape.storedinfo.len < i)
			break
		say(mytape.storedinfo[i])
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(10)
			say("End of recording.")
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			say("Skipping [playsleepseconds] seconds of silence")
			playsleepseconds = 1
		i++

	playing = FALSE
	update_icon()


/obj/item/taperecorder/attack_self(mob/user)
	if(!mytape)
		to_chat(user, "<span class='notice'>The [src] does not have a tape inside.</span>")
		return
	if(mytape.ruined)
		to_chat(user, "<span class='notice'>The tape inside the [src] appears to be broken.</span>")
		return

	update_available_icons()
	if(icons_available)
		var/selection = show_radial_menu(user, src, icons_available, radius = 38, require_near = TRUE, tooltips = TRUE)
		if(!selection)
			return
		switch(selection)
			if("Pause")
				stop()
			if("Stop Recording")  // yes we actually need 2 seperate stops for the same proc- Hopek
				stop()
			if("Record")
				record()
			if("Play")
				play()
			if("Print Transcript")
				print_transcript()
			if("Eject")
				eject(user)

/obj/item/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return
	if(!canprint)
		to_chat(usr, "<span class='notice'>The recorder can't print that fast!</span>")
		return
	if(recording || playing)
		return

	to_chat(usr, "<span class='notice'>Transcript printed.</span>")
	playsound(src, 'sound/items/taperecorder/taperecorder_print.ogg', 50, FALSE)
	var/obj/item/paper/P = new /obj/item/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i = 1, mytape.storedinfo.len >= i, i++)
		t1 += "[mytape.storedinfo[i]]<BR>"
	P.info = t1
	P.name = "paper- 'Transcript'"
	P.update_icon_state()
	usr.put_in_hands(P)
	canprint = FALSE
	addtimer(VARSET_CALLBACK(src, canprint, TRUE), 30 SECONDS)


//empty tape recorders
/obj/item/taperecorder/empty
	starting_tape_type = null


/obj/item/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon_state = "tape_white"
	icon = 'icons/obj/device.dmi'
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=20, /datum/material/glass=5)
	force = 1
	throwforce = 0
	var/max_capacity = 600
	var/used_capacity = 0
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/ruined = FALSE

/obj/item/tape/fire_act(exposed_temperature, exposed_volume)
	ruin()
	..()

/obj/item/tape/attack_self(mob/user)
	if(!ruined)
		to_chat(user, "<span class='notice'>You pull out all the tape!</span>")
		ruin()


/obj/item/tape/proc/ruin()
	//Lets not add infinite amounts of overlays when our fireact is called
	//repeatedly
	if(!ruined)
		add_overlay("ribbonoverlay")
	ruined = TRUE


/obj/item/tape/proc/fix()
	cut_overlay("ribbonoverlay")
	ruined = FALSE


/obj/item/tape/attackby(obj/item/I, mob/user, params)
	if(ruined && (I.tool_behaviour == TOOL_SCREWDRIVER || istype(I, /obj/item/pen)))
		to_chat(user, "<span class='notice'>You start winding the tape back in...</span>")
		if(I.use_tool(src, user, 120))
			to_chat(user, "<span class='notice'>You wound the tape back in.</span>")
			fix()

//Random colour tapes
/obj/item/tape/random
	icon_state = "random_tape"

/obj/item/tape/random/Initialize()
	. = ..()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"
