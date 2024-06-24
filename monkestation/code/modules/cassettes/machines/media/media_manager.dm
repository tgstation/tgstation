/**********************
 * AWW SHIT IT'S TIME FOR RADIO
 *
 * Concept stolen from D2K5
 * Rewritten by N3X15 for vgstation
 * Adapted by Leshana for VOREStation
 * Adapted by Dwasint for Monkestation
 ***********************/

// Uncomment to test the mediaplayer
//#define DEBUG_MEDIAPLAYER

#ifdef DEBUG_MEDIAPLAYER
#define MP_DEBUG(x) to_chat(owner,x)
#warn Please comment out #define DEBUG_MEDIAPLAYER before committing.
#else
#define MP_DEBUG(x)
#endif

// Stop media when the round ends. I guess so it doesn't play forever or something (for some reason?)
/proc/stop_all_media()
	// Stop all music.
	for(var/mob/M in GLOB.mob_list)
		if(M && M.client)
			M.stop_all_music()
	//  SHITTY HACK TO AVOID RACE CONDITION WITH SERVER REBOOT.
	sleep(10)  // TODO - Leshana - see if this is needed

// Update when moving between areas.
// TODO - While this direct override might technically be faster, probably better code to use observer or hooks ~Leshana
/area/Entered(var/mob/M)
	// Note, we cannot call ..() first, because it would update lastarea.
	if(!istype(M))
		return ..()
	if(M.client?.media && !M.client.media.forced)
		M.update_music()
	return ..()

//
// ### Media variable on /client ###
/client
	// Set on Login
	var/datum/media_manager/media = null

/client/verb/change_volume()
	set name = "Set Volume"
	set category = "OOC"
	set desc = "Set jukebox volume"
	set_new_volume(usr)

/client/proc/set_new_volume(var/mob/user)
	if(!QDELETED(src.media) || !istype(src.media))
		to_chat(user, "<span class='warning'>You have no media datum to change, if you're not in the lobby tell an admin.</span>")
		return
	var/value = input(usr, "Choose your Jukebox volume.", "Jukebox volume", media.volume)
	value = round(max(0, min(100, value)))
	media.update_volume(value)

//
// ### Media procs on mobs ###
// These are all convenience functions, simple delegations to the media datum on mob.
// But their presense and null checks make other coder's life much easier.
//

/mob/proc/update_music()
	if (client?.media && !client.media.forced)
		client.media.update_music()
		if(!client.media.signal_synced && !istype(client.mob, /mob/dead/new_player))
			client.media.RegisterSignal(client, COMSIG_MOB_CLIENT_MOVED_CLIENT_SEND, PROC_REF(recalc_volume))
			client.media.signal_synced = TRUE
		else if (!istype(client.mob, /mob/dead/new_player) && client.media.signal_synced)
			var/area/A = get_area(src)
			var/obj/machinery/media/M = A?.media_source
			if(!M || !M.playing)
				client.media.signal_synced = FALSE
				client.media.UnregisterSignal(client, COMSIG_MOB_CLIENT_MOVED_CLIENT_SEND)

/mob/proc/stop_all_music()
	client?.media.stop_music()

/mob/proc/force_music(var/url, var/start, var/volume=1)
	if (client?.media)
		if(url == "")
			client.media.forced = 0
			client.media.update_music()
		else
			client.media.forced = 1
			client.media.push_music(url, start, volume)
	return

//
// ### Define media source to areas ###
// Each area may have at most one media source that plays songs into that area.
// We keep track of that source so any mob entering the area can lookup what to play.
//
/area
	// For now, only one media source per area allowed
	// Possible Future: turn into a list, then only play the first one that's playing.
	var/obj/machinery/media/media_source = null

//
// ### Media Manager Datum
//

/datum/media_manager
	var/url = ""				// URL of currently playing media
	var/start_time = 0			// world.time when it started playing *in the source* (Not when started playing for us)
	var/source_volume = 1		// Volume as set by source. Actual volume = "volume * source_volume"
	var/rate = 1				// Playback speed.  For Fun(tm)
	var/volume = 50				// Client's volume modifier. Actual volume = "volume * source_volume"
	var/client/owner			// Client this is actually running in
	var/forced=0				// If true, current url overrides area media sources
	var/playerstyle				// Choice of which player plugin to use
	var/const/WINDOW_ID = "statwindow.mediapanel"	// Which elem in skin.dmf to use
	var/balance=0				// do you know what insanity is? Value from -100 to 100 where -100 is left and 100 is right
	var/signal_synced = 0		//used to check if we have our signal created

/datum/media_manager/New(var/client/C)
	ASSERT(istype(C))
	src.owner = C

// Actually pop open the player in the background.
/datum/media_manager/proc/open()
	playerstyle = PLAYER_WMP_HTML
	owner << browse(null, "window=[WINDOW_ID]")
	owner << browse(playerstyle, "window=[WINDOW_ID]")
	send_update()

// Tell the player to play something via JS.
/datum/media_manager/proc/send_update()
	if(!(owner.prefs))
		return
	if(owner.prefs.channel_volume["[CHANNEL_JUKEBOX]"])
		volume *= (owner.prefs.channel_volume["[CHANNEL_JUKEBOX]"] * 0.01)

	if(!owner.prefs.read_preference(/datum/preference/toggle/hear_music))
		owner << output(list2params(list("", (world.time - 0) / 10, volume * 1, 0)), "[WINDOW_ID]:SetMusic")
		return // Don't send anything other than a cancel to people with SOUND_STREAMING pref disabled

	MP_DEBUG("<span class='good'>Sending update to mediapanel ([url], [(world.time - start_time) / 10], [volume * source_volume])...</span>")
	owner << output(list2params(list(url, (world.time - start_time) / 10, volume * source_volume, balance)), "[WINDOW_ID]:SetMusic")

/datum/media_manager/proc/push_music(var/targetURL, var/targetStartTime, var/targetVolume, var/targetBalance)
	if(targetVolume != source_volume)
		push_volume_recalc(targetVolume)

	if (url != targetURL || abs(targetStartTime - start_time) > 1)
		url = targetURL
		start_time = targetStartTime
		source_volume = clamp(targetVolume, 0, 1)
		balance = targetBalance
		send_update()

/datum/media_manager/proc/stop_music()
	push_music("", 0, 1)

/datum/media_manager/proc/update_volume(var/value)
	volume = value
	send_update()

// Scan for media sources and use them.
/datum/media_manager/proc/update_music()
	var/targetURL = ""
	var/targetStartTime = 0
	var/targetVolume = 0
	var/targetBalance = 0

	if (forced || !owner || !owner.mob)
		return

	var/area/A = get_area(owner.mob)
	if(!A)
		MP_DEBUG("client=[owner], mob=[owner.mob] not in an area! loc=[owner.mob.loc].  Aborting.")
		stop_music()
		return
	var/obj/machinery/media/M = A.media_source
	if(M && M.playing)
		var/dist = get_dist(owner.mob, M)
		var/x_dist = (owner.mob.x - M.x) * 10

		targetURL = M.media_url
		targetStartTime = M.media_start_time
		targetVolume = max(0, M.volume * (1 - (dist * 0.1)))
		targetBalance = x_dist

		//MP_DEBUG("Found audio source: [M.media_url] @ [(world.time - start_time) / 10]s.")
	push_music(targetURL, targetStartTime, targetVolume, targetBalance)

/mob/proc/recalc_volume()
	if (client?.media && !client.media.forced)
		client.media.recalc_volume()

/datum/media_manager/proc/recalc_volume(datum/source, direction, turf/new_loc)
	if(!(owner.prefs))
		return

	if(!owner.prefs.read_preference(/datum/preference/toggle/hear_music))
		return // Don't send anything other than a cancel to people with SOUND_STREAMING pref disabled

	var/targetVolume = 0
	var/targetBalance = 0

	if (forced || !owner || !owner.mob)
		return

	var/area/A = get_area(owner.mob)
	if(!A)
		MP_DEBUG("client=[owner], mob=[owner.mob] not in an area! loc=[owner.mob.loc].  Aborting.")
		stop_music()
		return

	var/obj/machinery/media/M = A.media_source
	if(M && M.playing)
		var/dist = get_dist(new_loc, M)
		var/x_dist = -(new_loc.x - M.x) * 10

		targetVolume = max(0, M.volume * (1 - (dist * 0.1)))
		targetBalance = x_dist
	push_volume_recalc(targetVolume, targetBalance)

/datum/media_manager/proc/push_volume_recalc(var/targetVolume, var/targetBalance)
	source_volume = clamp(targetVolume, 0, 1)
	balance = targetBalance
	send_volume_update()

// Tell the player to play something via JS.
/datum/media_manager/proc/send_volume_update()
	if(!(owner.prefs))
		return
	/*
	if(!owner.is_preference_enabled(/datum/client_preference/play_jukebox) && url != "")
		return // Don't send anything other than a cancel to people with SOUND_STREAMING pref disabled
	*/
	MP_DEBUG("<span class='good'>Sending volume update to mediapanel ([volume * source_volume], [balance])...</span>")
	owner << output(list2params(list(volume * source_volume, balance)), "[WINDOW_ID]:SetVolume")

/datum/media_manager/proc/return_eastwest(mob/source, obj/machinery/media/target)
	if(source.x < target.x)
		return EAST
	if(source.x == target.x)
		return NONE
	return WEST
