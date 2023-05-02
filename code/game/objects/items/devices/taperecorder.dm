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
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=60, /datum/material/glass=30)
	force = 2
	throwforce = 2
	speech_span = SPAN_TAPE_RECORDER
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	var/recording = FALSE
	var/playing = FALSE
	var/playsleepseconds = 0
	var/obj/item/tape/mytape
	var/starting_tape_type = /obj/item/tape/random
	var/open_panel = FALSE
	var/canprint = TRUE
	var/list/icons_available = list()
	var/radial_icon_file = 'icons/hud/radial_taperecorder.dmi'
	///Whether we've warned during this recording session that the tape is almost up.
	var/time_warned = FALSE
	///Seconds under which to warn that the tape is almost up.
	var/time_left_warning = 60 SECONDS
	///Sound loop that plays when recording or playing back.
	var/datum/looping_sound/tape_recorder_hiss/soundloop

/obj/item/taperecorder/Initialize(mapload)
	. = ..()
	if(starting_tape_type)
		mytape = new starting_tape_type(src)
	soundloop = new(src)
	update_appearance()
	become_hearing_sensitive()

/obj/item/taperecorder/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(mytape)
	return ..()

/obj/item/taperecorder/proc/readout()
	if(mytape)
		if(playing)
			return span_notice("<b>PLAYING</b>")
		else
			var/time = mytape.used_capacity / 10 //deciseconds / 10 = seconds
			var/mins = round(time / 60)
			var/secs = time - mins * 60
			return span_notice("<b>[mins]</b>m <b>[secs]</b>s")
	return span_notice("<b>NO TAPE INSERTED</b>")

/obj/item/taperecorder/examine(mob/user)
	. = ..()
	if(in_range(src, user) || isobserver(user))
		. += span_notice("The wire panel is [open_panel ? "opened" : "closed"]. The display reads:")
		. += "[readout()]"

/obj/item/taperecorder/AltClick(mob/user)
	. = ..()
	play()

/obj/item/taperecorder/proc/update_available_icons()
	icons_available = list()

	if(!playing && !recording)
		icons_available += list("Record" = image(radial_icon_file,"record"))
		icons_available += list("Play" = image(radial_icon_file,"play"))
		if(canprint && mytape?.storedinfo.len)
			icons_available += list("Print Transcript" = image(radial_icon_file,"print"))

	if(playing || recording)
		icons_available += list("Stop" = image(radial_icon_file,"stop"))

	if(mytape)
		icons_available += list("Eject" = image(radial_icon_file,"eject"))

/obj/item/taperecorder/proc/update_sound()
	if(!playing && !recording)
		soundloop.stop()
	else
		soundloop.start()

/obj/item/taperecorder/attackby(obj/item/I, mob/user, params)
	if(!mytape && istype(I, /obj/item/tape))
		if(!user.transferItemToLoc(I,src))
			return
		mytape = I
		balloon_alert(user, "inserted [mytape]")
		playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
		update_appearance()


/obj/item/taperecorder/proc/eject(mob/user)
	if(!mytape)
		balloon_alert(user, "no tape!")
		return
	if(playing)
		balloon_alert(user, "stop the tape first!")
		return
	playsound(src, 'sound/items/taperecorder/taperecorder_open.ogg', 50, FALSE)
	balloon_alert(user, "ejected [mytape]")
	stop()
	user.put_in_hands(mytape)
	mytape = null
	update_appearance()

/obj/item/taperecorder/fire_act(exposed_temperature, exposed_volume)
	mytape.unspool() //Fires unspool the tape, which makes sense if you don't think about it
	..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/taperecorder/attack_hand(mob/user, list/modifiers)
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
		balloon_alert(usr, "can't use!")
		return
	if(!mytape)
		balloon_alert(usr, "no tape!")
		return

	eject(usr)


/obj/item/taperecorder/update_icon_state()
	if(!mytape)
		icon_state = "taperecorder_empty"
		return ..()
	if(recording)
		icon_state = "taperecorder_recording"
		return ..()
	if(playing)
		icon_state = "taperecorder_playing"
		return ..()
	icon_state = "taperecorder_idle"
	return ..()


/obj/item/taperecorder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list(), message_range)
	. = ..()
	if(mytape && recording)
		mytape.timestamp += mytape.used_capacity
		mytape.storedinfo += "\[[time2text(mytape.used_capacity,"mm:ss")]\] [raw_message]"


/obj/item/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(!can_use(usr))
		balloon_alert(usr, "can't use!")
		return
	if(!mytape || mytape.unspooled)
		balloon_alert(usr, "no spooled tape!")
		return
	if(recording)
		balloon_alert(usr, "stop recording first!")
		return
	if(playing)
		balloon_alert(usr, "already playing!")
		return

	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)

	if(mytape.used_capacity < mytape.max_capacity)
		recording = TRUE
		balloon_alert(usr, "started recording")
		update_sound()
		update_appearance()
		var/used = mytape.used_capacity //to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		while(recording && used < max)
			mytape.used_capacity += 1 SECONDS
			used += 1 SECONDS
			if(max - used < time_left_warning && !time_warned)
				time_warned = TRUE
				balloon_alert(usr, "[(max - used) / 10] second\s left")
			sleep(1 SECONDS)
		if(used >= max)
			balloon_alert(usr, "tape full!")
			sleep(1 SECONDS) //prevent balloon alerts layering over the top of each other
		stop()
	else
		balloon_alert(usr, "tape full!")
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)


/obj/item/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(!can_use(usr))
		balloon_alert(usr, "can't use!")
		return

	if(recording)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		balloon_alert(usr, "stopped recording")
		recording = FALSE
	else if(playing)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		balloon_alert(usr, "stopped playing")
		playing = FALSE
	time_warned = FALSE
	update_appearance()
	update_sound()

/obj/item/taperecorder/verb/play()
	set name = "Play Tape"
	set category = "Object"

	if(!can_use(usr))
		balloon_alert(usr, "can't use!")
		return
	if(!mytape || mytape.unspooled)
		balloon_alert(usr, "no spooled tape!")
		return
	if(recording)
		balloon_alert(usr, "stop recording first!")
		return
	if(playing)
		balloon_alert(usr, "already playing!")
		return
	if(mytape.storedinfo?.len <= 0)
		balloon_alert(usr, "[mytape] is empty!")
		return

	playing = TRUE
	update_appearance()
	update_sound()
	balloon_alert(usr, "started playing")
	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
	var/used = mytape.used_capacity //to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used <= max, sleep(playsleepseconds))
		if(!mytape)
			break
		if(playing == FALSE)
			break
		if(mytape.storedinfo.len < i)
			balloon_alert(usr, "recording ended")
			stoplag(1 SECONDS) //prevents multiple balloon alerts covering each other
			break
		say("[mytape.storedinfo[i]]", sanitize=FALSE)//We want to display this properly, don't double encode
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(1 SECONDS)
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14 SECONDS)
			sleep(1 SECONDS)
			say("Skipping [playsleepseconds/10] seconds of silence.")
			playsleepseconds = 1 SECONDS
		i++

	stop()


/obj/item/taperecorder/attack_self(mob/user)
	if(!mytape)
		balloon_alert(user, "it's empty!")
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

	var/list/transcribed_info = mytape.storedinfo
	if(!length(transcribed_info))
		balloon_alert(usr, "tape is empty!")
		return
	if(!canprint)
		balloon_alert(usr, "can't print that fast!")
		return
	if(!can_use(usr))
		balloon_alert(usr, "can't use!")
		return
	if(!mytape || mytape.unspooled)
		balloon_alert(usr, "no spooled tape!")
		return
	if(recording)
		balloon_alert(usr, "stop recording first!")
		return
	if(playing)
		balloon_alert(usr, "already playing!")
		return

	var/transcribed_text = "<b>Transcript:</b><br><br>"
	var/page_count = 1

	var/tape_name = mytape.name
	var/initial_tape_name = initial(mytape.name)
	var/paper_name = "paper- '[tape_name == initial_tape_name ? "Tape" : "[tape_name]"] Transcript'"

	for(var/transcript_excerpt in transcribed_info)
		var/excerpt_length = length(transcript_excerpt)

		// Very unexpected. Better abort non-gracefully.
		if(excerpt_length > MAX_PAPER_LENGTH)
			balloon_alert(usr, "data corrupted, can't print!")
			CRASH("Transcript entry has more than [MAX_PAPER_LENGTH] chars: [excerpt_length] chars")

		// If we're going to overflow the paper's length, print the current transcribed text out first and reset to prevent us
		// going over the paper char count.
		if((length(transcribed_text) + excerpt_length) > MAX_PAPER_LENGTH)
			var/obj/item/paper/transcript_paper = new /obj/item/paper(get_turf(src))
			transcript_paper.add_raw_text(transcribed_text)
			transcript_paper.name = "[paper_name] page [page_count]"
			transcript_paper.update_appearance()
			transcribed_text = ""
			page_count++

		transcribed_text += "[transcript_excerpt]<br>"

	var/obj/item/paper/transcript_paper = new /obj/item/paper(get_turf(src))
	transcript_paper.add_raw_text(transcribed_text)
	transcript_paper.name = "[paper_name] page [page_count]"
	transcript_paper.update_appearance()

	balloon_alert(usr, "transcript printed\n[page_count] page\s")
	playsound(src, 'sound/items/taperecorder/taperecorder_print.ogg', 50, FALSE)

	// Can't put the entire stack into their hands if there's multple pages, but hey we can at least put one page in.
	usr.put_in_hands(transcript_paper)
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
	///Because we can't expect God to do all the work.
	var/initial_icon_state
	var/max_capacity = 10 MINUTES
	var/used_capacity = 0 SECONDS
	///Numbered list of chat messages the recorder has heard with spans and prepended timestamps. Used for playback and transcription.
	var/list/storedinfo = list()
	///Numbered list of seconds the messages in the previous list appear at on the tape. Used by playback to get the timing right.
	var/list/timestamp = list()
	var/used_capacity_otherside = 0 SECONDS //Separate my side
	var/list/storedinfo_otherside = list()
	var/list/timestamp_otherside = list()
	var/unspooled = FALSE
	var/list/icons_available = list()
	var/radial_icon_file = 'icons/hud/radial_tape.dmi'

/obj/item/tape/Initialize(mapload)
	. = ..()
	initial_icon_state = icon_state //random tapes will set this after choosing their icon

	var/mycolor = random_short_color()
	name += " ([mycolor])" //multiple tapes can get confusing fast
	if(icon_state == "tape_greyscale")
		add_atom_colour("#[mycolor]", FIXED_COLOUR_PRIORITY)

	if(prob(50))
		tapeflip()

/obj/item/tape/examine(mob/user)
	. = ..()
	if(unspooled)
		. += span_notice("It looks like the tape is unspooled. A screwdriver might fix this.")

/obj/item/tape/fire_act(exposed_temperature, exposed_volume)
	unspool()
	..()

/obj/item/tape/proc/update_available_icons()
	icons_available = list()

	if(!unspooled)
		icons_available += list("Unwind tape" = image(radial_icon_file,"tape_unwind"))
	icons_available += list("Flip tape" = image(radial_icon_file,"tape_flip"))

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
				tapeflip()
				balloon_alert(user, "flipped tape")
				playsound(src, 'sound/items/taperecorder/tape_flip.ogg', 70, FALSE)
			if("Unwind tape")
				if(loc != user)
					return
				unspool()
				balloon_alert(user, "unspooled tape")

/obj/item/tape/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(prob(50))
		tapeflip()
	. = ..()

/obj/item/tape/proc/unspool()
	//Let's not add infinite amounts of overlays when our fire_act is called repeatedly
	if(!unspooled)
		add_overlay("ribbonoverlay")
	unspooled = TRUE

/obj/item/tape/proc/respool()
	cut_overlay("ribbonoverlay")
	unspooled = FALSE

/obj/item/tape/proc/tapeflip()
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

	if(icon_state == initial_icon_state)
		icon_state = "[initial_icon_state]_reverse"
	else if(icon_state == "[initial_icon_state]_reverse") //so flipping doesn't overwrite an unexpected icon_state (e.g. an admin's)
		icon_state = initial_icon_state

/obj/item/tape/screwdriver_act(mob/living/user, obj/item/tool)
	if(!unspooled)
		return FALSE
	balloon_alert(user, "respooling tape...")
	if(!tool.use_tool(src, user, 12 SECONDS))
		balloon_alert(user, "respooling failed!")
		return FALSE
	balloon_alert(user, "tape respooled")
	respool()

//Random colour tapes
/obj/item/tape/random
	icon_state = "random_tape"

/obj/item/tape/random/Initialize(mapload)
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple", "greyscale")]"
	. = ..()

/obj/item/tape/dyed
	icon_state = "tape_greyscale"
