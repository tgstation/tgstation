// Machinery serving as a media source.
/obj/machinery/media
	var/playing=0
	var/media_url=""
	var/media_start_time=0

	var/area/master_area

// Notify everyone in the area of new music.
// YOU MUST SET MEDIA_URL AND MEDIA_START_TIME YOURSELF!
/obj/machinery/media/proc/update_music()
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
	disconnect_media_source()
	if(anchored)
		update_music()

/obj/machinery/media/New()
	..()
	update_media_source()

/obj/machinery/media/Destroy()
	disconnect_media_source()
	..()