// Machinery serving as a media source.
/obj/machinery/media
	var/playing=0
	var/media_url=""
	var/media_start_time=0

	var/area/master_area

	var/list/obj/machinery/media/transmitter/hooked = list()
	var/exclusive_hook=null // Disables output to the room

	// Media system autolink.
	var/id_tag = "???"

/obj/machinery/media/proc/hookMediaOutput(var/obj/machinery/media/transmitter/T, exclusive=0)
	if(exclusive)
		exclusive_hook=T
	hooked.Add(T)
	return 1

/obj/machinery/media/proc/unhookMediaOutput(var/obj/machinery/media/transmitter/T)
	if(exclusive_hook==T)
		exclusive_hook=null
	hooked.Remove(T)
	return 1

// Notify everyone in the area of new music.
// YOU MUST SET MEDIA_URL AND MEDIA_START_TIME YOURSELF!
/obj/machinery/media/proc/update_music()
	// Broadcasting shit
	for(var/obj/machinery/media/transmitter/T in hooked)
		testing("[src] Writing media to [T].")
		T.broadcast(media_url,media_start_time)

	if(exclusive_hook)
		disconnect_media_source() // Just to be sure.
		return

	update_media_source()

	// Bail if we lost connection to master.
	if(!master_area)
		return

	// Send update to clients.
	for(var/mob/M in mobs_in_area(master_area))
		if(M && M.client)
			M.update_music()

/obj/machinery/media/proc/update_media_source()
	var/area/A = get_area_master(src)

	// Check if there's a media source already.
	if(A.media_source && A.media_source!=src)
		master_area=null
		return

	// Update Media Source.
	if(!A.media_source)
		A.media_source=src

	master_area=A

/obj/machinery/media/proc/disconnect_media_source()
	var/area/A = get_area_master(src)

	// Sanity
	if(!A)
		master_area=null
		return

	// Check if there's a media source already.
	if(A && A.media_source && A.media_source!=src)
		master_area=null
		return

	// Update Media Source.
	A.media_source=null

	// Clients
	for(var/mob/M in mobs_in_area(A))
		if(M && M.client)
			M.update_music()

	master_area=null

/obj/machinery/media/Move()
	..()
	if(anchored)
		update_music()

/obj/machinery/media/setLoc(var/turf/T, var/teleported=0)
	disconnect_media_source()
	..(T)
	if(anchored)
		update_music()

/obj/machinery/media/New()
	..()
	update_media_source()

/obj/machinery/media/Destroy()
	disconnect_media_source()
	..()