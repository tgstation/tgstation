//
// Media Player Jukebox
// Rewritten by Leshana from existing Polaris code, merging in D2K5 and N3X15 work
//

#define JUKEMODE_NEXT        1 // Advance to next song in the track list
#define JUKEMODE_RANDOM      2 // Not shuffle, randomly picks next each time.
#define JUKEMODE_REPEAT_SONG 3 // Play the same song over and over
#define JUKEMODE_PLAY_ONCE   4 // Play, then stop.

/obj/machinery/media/jukebox
	name = "space jukebox"
	desc = "Filled with songs both past and present!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "jukebox"
	var/state_base = "jukebox"
	anchored = TRUE
	density = TRUE
	power_channel = AREA_USAGE_EQUIP
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	//circuit = /obj/item/weapon/circuitboard/jukebox

	// Vars for hacking
	var/hacked = 0 // Whether to show the hidden songs or not
	var/freq = 0 // Currently no effect, will return in phase II of mediamanager.
	//VOREStation Add
	var/loop_mode = JUKEMODE_PLAY_ONCE			// Behavior when finished playing a song
	var/list/obj/item/device/juke_remote/remotes
	//VOREStation Add End
	var/datum/media_track/current_track

/obj/machinery/media/jukebox/Initialize()
	. = ..()
	update_icon()
	if(!LAZYLEN(getTracksList()))
		machine_stat |= BROKEN

/obj/machinery/media/jukebox/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/machinery/media/jukebox/proc/getTracksList()
	return hacked ? SSmedia_tracks.all_tracks : SSmedia_tracks.jukebox_tracks

/obj/machinery/media/jukebox/process()
	if(!playing)
		return
	if(machine_stat & (NOPOWER | BROKEN))
		disconnect_media_source()
		playing = 0
		return
	// If the current track isn't finished playing, let it keep going
	if(current_track && world.time < media_start_time + current_track.duration)
		return
	// Oh... nothing in queue? Well then pick next according to our rules
	var/list/tracks = getTracksList()
	switch(loop_mode)
		if(JUKEMODE_NEXT)
			var/curTrackIndex = max(1, tracks.Find(current_track))
			var/newTrackIndex = (curTrackIndex % tracks.len) + 1  // Loop back around if past end
			current_track = tracks[newTrackIndex]
		if(JUKEMODE_RANDOM)
			var/previous_track = current_track
			do
				current_track = pick(tracks)
			while(current_track == previous_track && tracks.len > 1)
		if(JUKEMODE_REPEAT_SONG)
			current_track = current_track
		if(JUKEMODE_PLAY_ONCE)
			current_track = null
			playing = 0
			update_icon()
	updateDialog()
	start_stop_song()

// Tells the media manager to start or stop playing based on current settings.
/obj/machinery/media/jukebox/proc/start_stop_song()
	if(current_track && playing)
		media_url = current_track.url
		media_start_time = world.time
		audible_message("<span class='notice'>\The [src] begins to play [current_track.display()].</span>")
	else
		media_url = ""
		media_start_time = 0
	update_music()

/obj/machinery/media/jukebox/proc/set_hacked(var/newhacked)
	if(hacked == newhacked)
		return
	hacked = newhacked
	updateDialog()

/obj/machinery/media/jukebox/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(W))
		return
	if(W.tool_behaviour == TOOL_WRENCH)
		if(playing)
			StopPlaying()
		user.visible_message("<span class='warning'>[user] has [anchored ? "un" : ""]secured \the [src].</span>", "<span class='notice'>You [anchored ? "un" : ""]secure \the [src].</span>")
		anchored = !anchored
		playsound(src, W.usesound, 50, 1)
		power_change()
		update_icon()
		if(!anchored)
			playing = 0
			disconnect_media_source()
		else
			update_media_source()
		return
	return ..()

/obj/machinery/media/jukebox/power_change()
	. = ..()
	if(!powered(power_channel) || !anchored)
		machine_stat |= NOPOWER
	else
		machine_stat &= ~NOPOWER

	if(machine_stat & (NOPOWER|BROKEN) && playing)
		StopPlaying()
	update_icon()

/obj/machinery/media/jukebox/update_icon()
	. = ..()
	cut_overlays()
	icon_state = state_base
	if(playing)
		add_overlay("[state_base]-running")
	if (panel_open)
		add_overlay("panel_open")

/obj/machinery/media/jukebox/attack_hand(mob/user)
	if(machine_stat & (NOPOWER | BROKEN))
		to_chat(usr, "\The [src] doesn't appear to function.")
		return
	ui_interact(user)

/obj/machinery/media/jukebox/ui_status(mob/user)
	if(machine_stat & (NOPOWER | BROKEN))
		to_chat(user, "<span class='warning'>[src] doesn't appear to function.</span>")
		return UI_CLOSE
	if(!anchored)
		to_chat(user, "<span class='warning'>You must secure [src] first.</span>")
		return UI_CLOSE
	. = ..()

/obj/machinery/media/jukebox/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MediaJukebox", "RetroBox - Space Style")
		ui.open()

/obj/machinery/media/jukebox/ui_data(mob/user)
	var/list/data = ..()

	data["playing"] = playing
	data["loop_mode"] = loop_mode
	data["volume"] = volume
	data["current_track_ref"] = null
	data["current_track"] = null
	data["current_genre"] = null
	if(current_track)
		data["current_track_ref"] = "\ref[current_track]"  // Convenient shortcut
		data["current_track"] = current_track.toTguiList()
		data["current_genre"] = current_track.genre
	data["percent"] = playing ? min(100, round(world.time - media_start_time) / current_track.duration) : 0;

	var/list/tgui_tracks = list()
	for(var/datum/media_track/T in getTracksList())
		tgui_tracks.Add(list(T.toTguiList()))
	data["tracks"] = tgui_tracks

	return data

/obj/machinery/media/jukebox/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	switch(action)
		if("change_track")
			var/datum/media_track/T = locate(params["change_track"]) in getTracksList()
			if(istype(T))
				current_track = T
				StartPlaying()
			return TRUE
		if("loopmode")
			var/newval = text2num(params["loopmode"])
			loop_mode = sanitize_inlist(newval, list(JUKEMODE_NEXT, JUKEMODE_RANDOM, JUKEMODE_REPEAT_SONG, JUKEMODE_PLAY_ONCE), loop_mode)
			return TRUE
		if("volume")
			var/newval = text2num(params["val"])
			volume = clamp(newval, 0, 1)
			update_music() // To broadcast volume change without restarting song
			return TRUE
		if("stop")
			StopPlaying()
			return TRUE
		if("play")
			if(current_track == null)
				to_chat(usr, "No track selected.")
			else
				StartPlaying()
			return TRUE

/obj/machinery/media/jukebox/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/media/jukebox/attack_hand(var/mob/user as mob)
	interact(user)

/obj/machinery/media/jukebox/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(W))
		return
	if(W.tool_behaviour == TOOL_WRENCH)
		if(playing)
			StopPlaying()
		user.visible_message("<span class='warning'>[user] has [anchored ? "un" : ""]secured \the [src].</span>", "<span class='notice'>You [anchored ? "un" : ""]secure \the [src].</span>")
		anchored = !anchored
		playsound(src, W.usesound, 50, 1)
		power_change()
		update_icon()
		return
	return ..()

/obj/machinery/media/jukebox/emag_act(var/remaining_charges, var/mob/user)
	if(!(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		StopPlaying()
		visible_message("<span class='danger'>\The [src] makes a fizzling sound.</span>")
		update_icon()
		return 1

/obj/machinery/media/jukebox/proc/StopPlaying()
	playing = 0
	update_use_power(IDLE_POWER_USE)
	update_icon()
	start_stop_song()

/obj/machinery/media/jukebox/proc/StartPlaying()
	if(!current_track)
		return
	playing = 1
	update_use_power(ACTIVE_POWER_USE)
	update_icon()
	start_stop_song()
	updateDialog()

// Advance to the next track - Don't start playing it unless we were already playing
/obj/machinery/media/jukebox/proc/NextTrack()
	var/list/tracks = getTracksList()
	if(!tracks.len) return
	var/curTrackIndex = max(1, tracks.Find(current_track))
	var/newTrackIndex = (curTrackIndex % tracks.len) + 1  // Loop back around if past end
	current_track = tracks[newTrackIndex]
	if(playing)
		start_stop_song()
	updateDialog()

// Advance to the next track - Don't start playing it unless we were already playing
/obj/machinery/media/jukebox/proc/PrevTrack()
	var/list/tracks = getTracksList()
	if(!tracks.len) return
	var/curTrackIndex = max(1, tracks.Find(current_track))
	var/newTrackIndex = curTrackIndex == 1 ? tracks.len : curTrackIndex - 1
	current_track = tracks[newTrackIndex]
	if(playing)
		start_stop_song()
	updateDialog()

//Pre-hacked Jukebox, has the full sond list unlocked
/obj/machinery/media/jukebox/hacked
	name = "DRM free space jukebox"
	desc = "Filled with songs both past and present! Unlocked for your convenience!"
	hacked = 1

// Ghostly jukebox for adminbuse
/obj/machinery/media/jukebox/ghost
	name = "ghost jukebox"
	desc = "A jukebox from the nether-realms! Spooky."

	plane = GHOST_PLANE
	invisibility = INVISIBILITY_OBSERVER
	alpha = 127

	icon_state = "jukebox"

	density = FALSE
	hacked = TRUE

	use_power = 0
	circuit = null

	var/list/custom_tracks = list()

// Just junk to make it sneaky - I wish a lot more stuff was on /obj/machinery/media instead of /jukebox so I could use that.
/obj/machinery/media/jukebox/ghost/audible_message(message, deaf_message, hearing_distance = DEFAULT_MESSAGE_RANGE, self_message, audible_message_flags = NONE)
	return
/obj/machinery/media/jukebox/ghost/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, visible_message_flags = NONE)
	return
/obj/machinery/media/jukebox/ghost/attackby(obj/item/W as obj, mob/user as mob)
	return
/obj/machinery/media/jukebox/ghost/attack_ai(mob/user as mob)
	return
/obj/machinery/media/jukebox/ghost/attack_hand(var/mob/user as mob)
	return
/obj/machinery/media/jukebox/ghost/update_use_power(new_use_power)
	. = ..()
	return
/obj/machinery/media/jukebox/ghost/power_change()
	. = ..()
	return
/obj/machinery/media/jukebox/ghost/emp_act(severity)
	return
/obj/machinery/media/jukebox/ghost/emag_act(remaining_charges, mob/user)
	return
/obj/machinery/media/jukebox/ghost/update_icon()
	. = ..()
	if(playing)
		animate(src, alpha = 200, time = 5, loop = -1)
	else
		animate(src, alpha = initial(alpha), time = 10)
// End junk

/obj/machinery/media/jukebox/ghost/attack_ghost(mob/dead/observer/M)
	if(!istype(M))
		return

	if(check_rights(R_FUN|R_ADMIN, show_msg=0))
		interact(M)
	else if(current_track)
		to_chat(M, "\The [src] is playing [current_track.display()].")
	else
		to_chat(M, "\The [src] is not playing any music.")

/obj/machinery/media/jukebox/ghost/getTracksList()
	return (custom_tracks + ..())

/obj/machinery/media/jukebox/ghost/proc/manual_track_add()
	var/client/C = usr.client
	if(!check_rights(R_FUN|R_ADMIN))
		return

	// Required
	var/url = tgui_input_text(C, "REQUIRED: Provide URL for track", "Track URL")
	if(!url)
		return

	var/title = tgui_input_text(C, "REQUIRED: Provide title for track", "Track Title")
	if(!title)
		return

	var/duration = tgui_input_number(C, "REQUIRED: Provide duration for track (in deciseconds, aka seconds*10)", "Track Duration")
	if(!duration)
		return

	// Optional
	var/artist = tgui_input_text(C, "Optional: Provide artist for track", "Track Artist")
	if(isnull(artist)) // Cancel rather than empty string
		return

	// So they're obvious and grouped
	var/genre = "! Admin Loaded !"

	custom_tracks += new /datum/media_track(url, title, duration, artist, genre)

/obj/machinery/media/jukebox/ghost/proc/manual_track_remove()
	var/client/C = usr.client
	if(!check_rights(R_FUN|R_ADMIN))
		return

	var/track = tgui_input_text(C, "Input track title or URL to remove (must be exact)", "Remove Track")
	if(!track)
		return

	for(var/datum/media_track/T in custom_tracks)
		if(T.title == track || T.url == track)
			custom_tracks -= T
			qdel(T)
			return

	to_chat(C, "<span class='warning>Couldn't find a track matching the specified parameters.</span>")

/obj/machinery/media/jukebox/ghost/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION("add_track", "Add New Track")
	VV_DROPDOWN_OPTION("remove_track", "Remove Track")

/obj/machinery/media/jukebox/ghost/vv_do_topic(list/href_list)
	. = ..()
	if(href_list["add_track"] && check_rights(R_FUN))
		manual_track_add()
		href_list["datumrefresh"] = "\ref[src]"
	if(href_list["remove_track"] && check_rights(R_FUN))
		manual_track_remove()
		href_list["datumrefresh"] = "\ref[src]"
