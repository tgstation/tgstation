// Machinery serving as a media source.
/obj/machinery/media
	var/playing=0
	var/media_url=""
	var/media_start_time=0

// Notify everyone in the area of new music.
// YOU MUST SET MEDIA_URL AND MEDIA_START_TIME YOURSELF!
/obj/machinery/media/proc/update_music()
	var/area/A = get_area(src)
	if(A.master)
		A=A.master
	for(var/mob/M in A)
		if(M && M.client)
			M.update_music()