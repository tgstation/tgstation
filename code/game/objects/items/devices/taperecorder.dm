/obj/item/device/taperecorder
	desc = "A device that can record up to an hour of dialogue and play it back. It automatically translates the content in playback."
	name = "universal recorder"
	icon_state = "taperecorderidle"
	item_state = "analyzer"
	w_class = 1.0
	starting_materials = list(MAT_IRON = 60, MAT_GLASS = 30)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	var/emagged = 0.0
	var/recording = 0.0
	var/playing = 0.0
	var/timerecorded = 0.0
	var/playsleepseconds = 0.0
	var/list/storedinfo = new/list()
	var/list/timestamp = new/list()
	var/canprint = 1
	flags = FPRINT | HEAR
	siemens_coefficient = 1
	throwforce = 2
	throw_speed = 4
	throw_range = 20

/obj/item/device/taperecorder/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(recording)
		timestamp += timerecorded
		storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] \"[html_encode(speech.message)]\""

/obj/item/device/taperecorder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/card/emag))
		if(emagged == 0)
			emagged = 1
			recording = 0
			to_chat(user, "<span class='warning'>PZZTTPFFFT</span>")
			icon_state = "taperecorderidle"
		else
			to_chat(user, "<span class='warning'>It is already emagged!</span>")

/obj/item/device/taperecorder/proc/explode()
	var/turf/T = get_turf(loc)
	if(ismob(loc))
		var/mob/M = loc
		to_chat(M, "<span class='danger'>\The [src] explodes!</span>")
	if(T)
		T.hotspot_expose(700,125,surfaces=istype(loc,/turf))
		explosion(T, -1, -1, 0, 4)
	del(src)
	return

/obj/item/device/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(usr.stat || (usr.status_flags & FAKEDEATH))
		return
	if(emagged == 1)
		to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
		return
	icon_state = "taperecorderrecording"
	if(timerecorded < 3600 && playing == 0)
		to_chat(usr, "<span class='notice'>Recording started.</span>")
		recording = 1
		timestamp+= timerecorded
		storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording started."
		for(timerecorded, timerecorded<3600)
			if(recording == 0)
				break
			timerecorded++
			sleep(10)
		recording = 0
		icon_state = "taperecorderidle"
		return
	else
		to_chat(usr, "<span class='notice'>Either your tape recorder's memory is full, or it is currently playing back its memory.</span>")


/obj/item/device/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(usr.stat || (usr.status_flags & FAKEDEATH))
		return
	if(emagged == 1)
		to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
		return
	if(recording == 1)
		recording = 0
		timestamp+= timerecorded
		storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording stopped."
		to_chat(usr, "<span class='notice'>Recording stopped.</span>")
		icon_state = "taperecorderidle"
		return
	else if(playing == 1)
		playing = 0
		recorder_message("Playback stopped.")
		icon_state = "taperecorderidle"
		return


/obj/item/device/taperecorder/verb/clear_memory()
	set name = "Clear Memory"
	set category = "Object"

	if(usr.stat || (usr.status_flags & FAKEDEATH))
		return
	if(emagged == 1)
		to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
		return
	if(recording == 1 || playing == 1)
		to_chat(usr, "<span class='notice'>You can't clear the memory while playing or recording!</span>")
		return
	else
		if(storedinfo)	storedinfo.Cut()
		if(timestamp)	timestamp.Cut()
		timerecorded = 0
		to_chat(usr, "<span class='notice'>Memory cleared.</span>")
		return


/obj/item/device/taperecorder/verb/playback_memory()
	set name = "Playback Memory"
	set category = "Object"

	if(usr.stat || (usr.status_flags & FAKEDEATH))
		return
	if(emagged == 1)
		to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
		return
	if(recording == 1)
		to_chat(usr, "<span class='notice'>You can't playback when recording!</span>")
		return
	if(playing == 1)
		to_chat(usr, "<span class='notice'>You're already playing!</span>")
		return
	playing = 1
	icon_state = "taperecorderplaying"
	to_chat(usr, "<span class='notice'>Playing started.</span>")
	for(var/i=1,timerecorded<3600,sleep(10 * (playsleepseconds) ))
		if(playing == 0)
			break
		if(storedinfo.len < i)
			break
		recorder_message("[storedinfo[i]]")
		if(storedinfo.len < i+1)
			playsleepseconds = 1
			sleep(10)
			recorder_message("End of recording.")
		else
			playsleepseconds = timestamp[i+1] - timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			recorder_message("Skipping [playsleepseconds] seconds of silence")
			playsleepseconds = 1
		i++
	icon_state = "taperecorderidle"
	playing = 0
	if(emagged == 1.0)
		recorder_message("This tape recorder will self-destruct in... Five.")
		sleep(10)
		recorder_message("Four.")
		sleep(10)
		recorder_message("Three.")
		sleep(10)
		recorder_message("Two.")
		sleep(10)
		recorder_message("One.")
		sleep(10)
		explode()


/obj/item/device/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(usr.stat || (usr.status_flags & FAKEDEATH))
		return
	if(emagged == 1)
		to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
		return
	if(!canprint)
		to_chat(usr, "<span class='notice'>The recorder can't print that fast!</span>")
		return
	if(recording == 1 || playing == 1)
		to_chat(usr, "<span class='notice'>You can't print the transcript while playing or recording!</span>")
		return
	to_chat(usr, "<span class='notice'>Transcript printed.</span>")
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i=1,storedinfo.len >= i,i++)
		t1 += "[storedinfo[i]]<BR>"
	P.info = t1
	P.name = "paper- 'Transcript'"
	canprint = 0
	sleep(300)
	canprint = 1


/obj/item/device/taperecorder/attack_self(mob/user)
	if(recording == 0 && playing == 0)
		if(usr.stat)
			return
		if(emagged == 1)
			to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
			return
		icon_state = "taperecorderrecording"
		if(timerecorded < 3600 && playing == 0)
			to_chat(usr, "<span class='notice'>Recording started.</span>")
			recording = 1
			timestamp+= timerecorded
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording started."
			for(timerecorded, timerecorded<3600)
				if(recording == 0)
					break
				timerecorded++
				sleep(10)
			recording = 0
			icon_state = "taperecorderidle"
			return
		else
			to_chat(usr, "<span class='warning'>Either your tape recorder's memory is full, or it is currently playing back its memory.</span>")
	else
		if(usr.stat)
			to_chat(usr, "Not when you're incapacitated.")
			return
		if(recording == 1)
			recording = 0
			timestamp+= timerecorded
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording stopped."
			to_chat(usr, "<span class='notice'>Recording stopped.</span>")
			icon_state = "taperecorderidle"
			return
		else if(playing == 1)
			playing = 0
			recorder_message("Playback stopped")
			icon_state = "taperecorderidle"
			return
		else
			to_chat(usr, "<span class='warning'>Stop what?</span>")
			return

/obj/item/device/taperecorder/proc/recorder_message(var/msg)
	visible_message("<font color=Maroon><B>Tape Recorder</B>: [msg]</font>")
