/proc/mobs_in_area(var/area/passed_area)
	var/list/mobs = list()
	for(var/glob_mob in GLOB.mob_list)
		if(get_area(glob_mob) == passed_area)
			mobs += glob_mob
	return mobs

// Machinery serving as a media source.
/obj/machinery/media
	var/playing = FALSE			// Am I playing right now?
	var/media_url = ""			// URL of media I am playing
	var/media_start_time = 0	// world.time when it started playing
	var/volume = 1				// 0 - 1 for ease of coding.

	// ~Leshana - Transmitters unimplemented

// Notify everyone in the area of new music.
// YOU MUST SET MEDIA_URL AND MEDIA_START_TIME YOURSELF!
/obj/machinery/media/proc/update_music()
	update_media_source()
	// Send update to clients.
	for(var/mob/mob in range(15, get_turf(src))) //15 being the max volume of the radio
		if(mob && mob.client)
			mob.update_music()

/obj/machinery/media/proc/update_media_source()
	// Check if there's a media source already.
	for(var/area/area in get_areas_in_range(15, src))
		if(area.media_source && area.media_source != src) // If it does, the new media source replaces it. basically, the last media source arrived gets played on top.
			area.media_source.disconnect_media_source() // You can turn a media source off and on for it to come back on top.
			area.media_source = src
			return
		else
			area.media_source = src

/obj/machinery/media/proc/disconnect_media_source()
	for(var/area/area in get_areas_in_range(15, src))
		// Update Media Source.
		area.media_source = null

	// Clients
	for(var/mob/mob as anything in range(15))
		if(!istype(mob)) //might be possible to simply make this not be as() anything
			continue
		mob.update_music()

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
