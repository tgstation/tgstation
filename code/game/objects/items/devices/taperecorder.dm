/obj/item/device/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon_state = "taperecorder_empty"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = HEAR
	slot_flags = SLOT_BELT
	languages_spoken = ALL //this is a translator, after all.
	languages_understood = ALL //this is a translator, after all.
	materials = list(MAT_METAL=60, MAT_GLASS=30)
	force = 2
	throwforce = 0
	var/recording = FALSE
	var/playing = 0
	var/playsleepseconds = 0
	var/loop = FALSE
	var/obj/item/device/tape/mytape
	var/open_panel = 0
	var/canprint = 1
	var/canRecordComms = FALSE // Record what comes out of the radio
	var/announce = TRUE // Announce if the tape is playing or not playing


/obj/item/device/taperecorder/New()
	mytape = new /obj/item/device/tape/random(src)
	update_icon()
	..()


/obj/item/device/taperecorder/examine(mob/user)
	..()
	user << "The wire panel is [open_panel ? "opened" : "closed"]."


/obj/item/device/taperecorder/attackby(obj/item/I, mob/user, params)
	if(!mytape && istype(I, /obj/item/device/tape))
		if(!user.transferItemToLoc(I,src))
			return
		mytape = I
		user << "<span class='notice'>You insert [I] into [src].</span>"
		update_icon()


/obj/item/device/taperecorder/proc/eject(mob/user)
	if(mytape)
		user << "<span class='notice'>You remove [mytape] from [src].</span>"
		stop()
		user.put_in_hands(mytape)
		mytape = null
		update_icon()

/obj/item/device/taperecorder/fire_act(exposed_temperature, exposed_volume)
	mytape.ruin() //Fires destroy the tape
	..()

/obj/item/device/taperecorder/attack_hand(mob/user)
	if(loc == user)
		if(mytape)
			if(!user.is_holding(src))
				..()
				return
			eject(user)
			return
	..()


/obj/item/device/taperecorder/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return 1
	return 0


/obj/item/device/taperecorder/verb/ejectverb()
	set name = "Eject Tape"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return

	eject(usr)


/obj/item/device/taperecorder/update_icon()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"

/obj/item/device/taperecorder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans)
	if(mytape && recording)
		if ((canRecordComms && radio_freq) || !radio_freq)
			mytape.timestamp += mytape.used_capacity
			mytape.addinfo(message, speaker, message_langs, raw_message, radio_freq, spans, FALSE)

/obj/item/device/taperecorder/verb/toggleRecordComms()
	set name = "Toggle radio record"
	set category = "Object"
	if (canRecordComms)
		usr << "<span class='notice'>The [name] is set to <B>not record</B> the radio.</span>"
		canRecordComms = FALSE
	else
		usr << "<span class='notice'>The [name] is set to <B>record</B> the radio.</span>"
		canRecordComms = TRUE

/obj/item/device/taperecorder/verb/toggleLoop()
	set name = "Toggle loop"
	set category = "Object"
	if (loop)
		usr << "<span class='notice'>The [name] is set to <B>not loop</B> any longer.</span>"
		loop = FALSE
	else
		usr << "<span class='notice'>The [name] is set to <B>loop</B>.</span>"
		loop = TRUE

/obj/item/device/taperecorder/verb/toggleAnnounce()
	set name = "Toggle announcements"
	set category = "Object"
	if (announce)
		usr << "<span class='notice'>The [name] is set to <B>not announce</B> the tape playing.</span>"
		announce = FALSE
	else
		usr << "<span class='notice'>The [name] is set to <B>announce</B> the tape playing.</span>"
		announce = TRUE

/obj/item/device/taperecorder/verb/record()
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
		usr << "<span class='notice'>Recording started.</span>"
		recording = 1
		update_icon()
		mytape.timestamp += mytape.used_capacity
		mytape.addinfo("Recording started.", , , , , , TRUE)
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		for(used, used < max)
			if(recording == 0)
				break
			mytape.used_capacity++
			used++
			sleep(10)
		recording = 0
		update_icon()
	else
		usr << "<span class='notice'>The tape is full.</span>"


/obj/item/device/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(!can_use(usr))
		return

	if(recording)
		recording = 0
		mytape.timestamp += mytape.used_capacity
		mytape.addinfo("Recording stopped.", , , , , , TRUE)
		usr << "<span class='notice'>Recording stopped.</span>"
		return
	else if(playing)
		playing = 0
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>")
	update_icon()


/obj/item/device/taperecorder/verb/play()
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

	if (announce) say("Playing started.")
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used < max, sleep(10 * playsleepseconds))
		if(!mytape || playing == 0 || mytape.storedinfo.len < i)
			break
		var/x = mytape.storedinfo[i]
		// Burrowed code from send_speech
		if (!x[8])
			for(var/atom/movable/AM in get_hearers_in_view(7, src))
				AM.Hear(x[1], src, x[3], x[4], x[5], x[6])
		if(mytape.storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(10)
			if (loop)
				i = 0 // since i++ at end
		else
			playsleepseconds = mytape.timestamp[i + 1] - mytape.timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			say("Skipping [playsleepseconds] seconds of silence")
			playsleepseconds = 1
		i++
	if (announce) say("End of recording.")

	playing = 0
	update_icon()


/obj/item/device/taperecorder/attack_self(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		stop()
	else
		record()

/obj/item/device/taperecorder/AltClick(mob/living/user)
	attack_self(user)

/obj/item/device/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(!can_use(usr))
		return
	if(!mytape)
		return
	if(!canprint)
		usr << "<span class='notice'>The recorder can't print that fast!</span>"
		return
	if(recording || playing)
		return

	usr << "<span class='notice'>Transcript printed.</span>"
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i = 1, mytape.storedinfo.len >= i, i++)
		if (mytape.storedinfo[i][8])
			t1 += "** \[[mytape.storedinfo[i][7]]\] [mytape.storedinfo[i][1]]<BR>"
		else t1 += "\[[mytape.storedinfo[i][7]]\] [mytape.storedinfo[i][1]]<BR>"
	P.info = t1
	P.name = "paper- 'Transcript'"
	usr.put_in_hands(P)
	canprint = 0
	sleep(300)
	canprint = 1


//empty tape recorders
/obj/item/device/taperecorder/empty/New()
	return


/obj/item/device/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon_state = "tape_white"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL=20, MAT_GLASS=5)
	force = 1
	throwforce = 0
	var/max_capacity = 600
	var/used_capacity = 0
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/ruined = 0

/obj/item/device/tape/fire_act(exposed_temperature, exposed_volume)
	ruin()
	..()

/obj/item/device/tape/attack_self(mob/user)
	if(!ruined)
		user << "<span class='notice'>You pull out all the tape!</span>"
		ruin()


/obj/item/device/tape/proc/ruin()
	//Lets not add infinite amounts of overlays when our fireact is called
	//repeatedly
	if(!ruined)
		add_overlay("ribbonoverlay")
	ruined = 1


/obj/item/device/tape/proc/fix()
	cut_overlay("ribbonoverlay")
	ruined = 0

/obj/item/device/tape/proc/addinfo(message, speaker, message_langs, raw_message, radio_freq, spans, announcement)
	storedinfo[++storedinfo.len] = list(message, speaker, message_langs, raw_message, radio_freq, spans, time2text(used_capacity * 10,"mm:ss"), announcement)


/obj/item/device/tape/attackby(obj/item/I, mob/user, params)
	if(ruined)
		var/delay = -1
		if (istype(I, /obj/item/weapon/screwdriver))
			delay = 120*I.toolspeed
		else if(istype(I, /obj/item/weapon/pen))
			delay = 120*1.5
		if (delay != -1)
			user << "<span class='notice'>You start winding the tape back in...</span>"
			if(do_after(user, delay, target = src))
				user << "<span class='notice'>You wound the tape back in.</span>"
				fix()

//Random colour tapes
/obj/item/device/tape/random/New()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"
	..()