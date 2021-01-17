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
	var/icon_directory = 'icons/hud/radial_taperecorder.dmi'
	///Whether we've warned during this recording session that the tape is almost up.
	var/time_warned = FALSE
	///Seconds under which to warn that the tape is almost up.
	var/time_left_warning = 60 SECONDS
	///What color we talk in.
	var/say_color = COLOR_MAROON


/obj/item/taperecorder/Initialize(mapload)
	. = ..()
	if(starting_tape_type)
		mytape = new starting_tape_type(src)
	update_icon()

/obj/item/taperecorder/proc/readout()
	if(mytape)
		if(playing)
			return "<span class='notice'><b>PLAYING</b></span>"
		else
			var/time = mytape.used_capacity / 10 //deciseconds / 10 = seconds
			var/mins = round(time / 60)
			var/secs = time - mins * 60
			return "<span class='notice'><b>[mins]</b>m <b>[secs]</b>s</span>"
	return "<span class='notice'><b>NO TAPE INSERTED</b></span>"

/obj/item/taperecorder/examine(mob/user)
	. = ..()
	if(in_range(src, user) || isobserver(user))
		. += "<span class='notice'>The wire panel is [open_panel ? "opened" : "closed"]. The display reads:</span>"
		. += "[readout()]"

/obj/item/taperecorder/AltClick(mob/user)
	. = ..()
	play()

/obj/item/taperecorder/proc/update_available_icons()
	icons_available = list()

	if(!playing && !recording)
		icons_available += list("Record" = image(icon = icon_directory, icon_state = "record"))
		icons_available += list("Play" = image(icon = icon_directory, icon_state = "play"))
		if(canprint && mytape?.storedinfo.len)
			icons_available += list("Print Transcript" = image(icon = icon_directory, icon_state = "print"))

	if(playing || recording)
		icons_available += list("Stop" = image(icon = icon_directory, icon_state = "stop"))

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
		mytape.storedinfo += "\[[time2text(mytape.used_capacity,"mm:ss")]\] [message]"


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

	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)

	if(mytape.used_capacity < mytape.max_capacity)
		recording = TRUE
		say("<font color='[say_color]'>Recording started.</font>")
		update_icon()
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		while(recording && used < max)
			mytape.used_capacity += 1 SECONDS
			used += 1 SECONDS
			if(max - used < time_left_warning && !time_warned)
				time_warned = TRUE
				say("<font color='[say_color]'>[(max - used) / 10] seconds left!</font>") //deciseconds / 10 = seconds
			sleep(1 SECONDS)
		if(used >= max)
			say("<font color='[say_color]'>Tape full.</font>")
		stop()
	else
		say("<font color='[say_color]'>The tape is full!</font>")
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)


/obj/item/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(!can_use(usr))
		return

	if(recording)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		recording = FALSE
		say("<font color='[say_color]'>Recording stopped.</font>")
	else if(playing)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		playing = FALSE
		say("<font color='[say_color]'>Playback stopped.</font>")
	time_warned = FALSE
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

	playing = TRUE
	update_icon()
	say("<font color='[say_color]'>Playback started.</font>")
	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used <= max, sleep(playsleepseconds))
		if(!mytape)
			break
		if(playing == FALSE)
			break
		if(mytape.storedinfo.len < i)
			say("<font color='[say_color]'>End of recording.</font>")
			break
		say("[mytape.storedinfo[i]]")
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(1 SECONDS)
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14 SECONDS)
			sleep(1 SECONDS)
			say("<font color='[say_color]'>Skipping [playsleepseconds] seconds of silence.</font>")
			playsleepseconds = 1 SECONDS
		i++

	stop()


/obj/item/taperecorder/attack_self(mob/user)
	if(!mytape)
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")
		return
	if(mytape.ruined)
		to_chat(user, "<span class='warning'>\The tape inside \the [src] is broken!</span>")
		return

	update_available_icons()
	if(icons_available)
		var/selection = show_radial_menu(user, src, icons_available, radius = 38, require_near = TRUE, tooltips = TRUE)
		if(!selection)
			return
		switch(selection)
			if("Stop")
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

	if(!mytape.storedinfo.len)
		return
	if(!can_use(usr))
		return
	if(!mytape)
		return
	if(!canprint)
		to_chat(usr, "<span class='warning'>The recorder can't print that fast!</span>")
		return
	if(recording || playing)
		return

	say("<font color='[say_color]'>Transcript printed.</font>")
	playsound(src, 'sound/items/taperecorder/taperecorder_print.ogg', 50, FALSE)
	var/obj/item/paper/P = new /obj/item/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i = 1, mytape.storedinfo.len >= i, i++)
		t1 += "[mytape.storedinfo[i]]<BR>"
	P.info = t1
	var/tapename = mytape.name
	var/prototapename = initial(mytape.name)
	P.name = "paper- '[tapename == prototapename ? "Tape" : "[tapename]"] Transcript'"
	P.update_icon_state()
	usr.put_in_hands(P)
	canprint = FALSE
	addtimer(VARSET_CALLBACK(src, canprint, TRUE), 30 SECONDS)


//empty tape recorders
/obj/item/taperecorder/empty
	starting_tape_type = null


/obj/item/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content on either side."
	icon_state = "tape_white"
	icon = 'icons/obj/device.dmi'
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=20, /datum/material/glass=5)
	force = 1
	throwforce = 0
	obj_flags = UNIQUE_RENAME //my mixtape
	drop_sound = 'sound/items/handling/tape_drop.ogg'
	pickup_sound = 'sound/items/handling/tape_pickup.ogg'
	var/max_capacity = 10 MINUTES
	var/used_capacity = 0 SECONDS
	///Numbered list of chat messages the recorder has heard with spans and prepended timestamps. Used for playback and transcription.
	var/list/storedinfo = list()
	///Numbered list of seconds the messages in the previous list appear at on the tape. Used by playback to get the timing right.
	var/list/timestamp = list()
	var/used_capacity_otherside = 0 SECONDS //Separate my side
	var/list/storedinfo_otherside = list()
	var/list/timestamp_otherside = list()
	var/ruined = FALSE
	var/list/icons_available = list()
	var/icon_file = 'icons/effects/tape_radial.dmi'

/obj/item/tape/fire_act(exposed_temperature, exposed_volume)
	ruin()
	..()

/obj/item/tape/proc/update_available_icons()
	icons_available = list()

	if(!ruined)
		icons_available += list("Unwind tape" = image(icon_file, "tape_unwind"))
	icons_available += list("Flip tape" = image(icon_file, "tape_flip"))

/obj/item/tape/attack_self(mob/user)
	update_available_icons()
	if(icons_available)
		var/selection = show_radial_menu(user, src, icons_available, radius = 38, require_near = TRUE, tooltips = TRUE)
		if(!selection)
			return
		switch(selection)
			if("Flip tape")
				if(loc != user)
					return
				flip()
				to_chat(user, "<span class='notice'>You turn \the [src] over.</span>")
				playsound(src, 'sound/items/taperecorder/tape_flip.ogg', 70, FALSE)
			if("Unwind tape")
				if(loc != user)
					return
				ruin()
				to_chat(user, "<span class='warning'>You pull out all the tape!</span>")

/obj/item/tape/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(prob(50))
		flip()
	. = ..()

/obj/item/tape/proc/ruin()
	//Lets not add infinite amounts of overlays when our fireact is called
	//repeatedly
	if(!ruined)
		add_overlay("ribbonoverlay")
	ruined = TRUE

/obj/item/tape/proc/fix()
	cut_overlay("ribbonoverlay")
	ruined = FALSE

/obj/item/tape/proc/flip()
	//first we save a copy of our current side
	var/list/storedinfo_currentside = storedinfo.Copy()
	var/list/timestamp_currentside = timestamp.Copy()
	var/used_capacity_currentside = used_capacity
	//then we overwite our current side with our other side
	storedinfo = storedinfo_otherside.Copy()
	timestamp = timestamp_otherside.Copy()
	used_capacity = used_capacity_otherside
	//then we overwrite our other side with the saved side
	storedinfo_otherside = storedinfo_currentside.Copy()
	timestamp_otherside = timestamp_currentside.Copy()
	used_capacity_otherside = used_capacity_currentside

/obj/item/tape/attackby(obj/item/I, mob/user, params)
	if(ruined && (I.tool_behaviour == TOOL_SCREWDRIVER))
		to_chat(user, "<span class='notice'>You start winding the tape back in...</span>")
		if(I.use_tool(src, user, 120))
			to_chat(user, "<span class='notice'>You wind the tape back in.</span>")
			fix()

//Random colour tapes
/obj/item/tape/random
	icon_state = "random_tape"

/obj/item/tape/random/Initialize()
	. = ..()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"
