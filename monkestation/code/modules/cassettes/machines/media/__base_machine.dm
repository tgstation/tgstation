/proc/mobs_in_area(var/area/A)
	var/list/mobs = list()
	for(var/M in GLOB.mob_list)
		if(get_area(M) == A)
			mobs += M
	return mobs

// Machinery serving as a media source.
/obj/machinery/media
	var/playing = 0				// Am I playing right now?
	var/media_url = ""			// URL of media I am playing
	var/media_start_time = 0	// world.time when it started playing
	var/volume = 1				// 0 - 1 for ease of coding.

	// ~Leshana - Transmitters unimplemented

// Notify everyone in the area of new music.
// YOU MUST SET MEDIA_URL AND MEDIA_START_TIME YOURSELF!
/obj/machinery/media/proc/update_music()
	update_media_source()
	// Send update to clients.
	for(var/mob/M in range(15))
		if(M && M.client)
			M.update_music()

/obj/machinery/media/proc/update_media_source()
	// Check if there's a media source already.
	for(var/area/A in get_areas_in_range(15, src))
		if(A.media_source && A.media_source != src) // If it does, the new media source replaces it. basically, the last media source arrived gets played on top.
			A.media_source.disconnect_media_source() // You can turn a media source off and on for it to come back on top.
			A.media_source = src
			return
		else
			A.media_source = src

/obj/machinery/media/proc/disconnect_media_source()
	for(var/area/A in get_areas_in_range(15, src))
		// Update Media Source.
		A.media_source = null

	// Clients
	for(var/mob/M as anything in range(15))
		M.update_music()

/obj/machinery/media/Move()
	disconnect_media_source()
	. = ..()
	if(anchored)
		update_music()

/obj/machinery/media/forceMove(var/atom/destination)
	disconnect_media_source()
	. = ..()
	if(anchored)
		update_music()

/obj/machinery/media/Initialize()
	. = ..()
	update_media_source()

/obj/machinery/media/Destroy()
	disconnect_media_source()
	. = ..()
