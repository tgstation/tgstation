SUBSYSTEM_DEF(jukeboxes)
	name = "Jukeboxes"
	wait = 5
	var/list/songs = list()
	var/list/activejukeboxes = list()

/datum/track
	var/song_name = "generic"
	var/song_path = null
	var/song_length = 0
	var/song_beat = 0
	var/song_associated_id = null

/datum/track/New(name, path, length, beat, assocID)
	song_name = name
	song_path = path
	song_length = length
	song_beat = beat
	song_associated_id = assocID

/datum/controller/subsystem/jukeboxes/proc/addjukebox(obj/jukebox, datum/track/T, jukefalloff = 1)
	if(!istype(T))
		CRASH("[src] tried to play a song with a nonexistant track")
	var/channeltoreserve = CHANNEL_JUKEBOX_START + activejukeboxes.len - 1
	if(channeltoreserve > CHANNEL_JUKEBOX)
		return FALSE
	activejukeboxes.len++
	activejukeboxes[activejukeboxes.len] = list(T, channeltoreserve, jukebox, jukefalloff)
	return activejukeboxes.len

/datum/controller/subsystem/jukeboxes/proc/removejukebox(IDtoremove)
	if(islist(activejukeboxes[IDtoremove]))
		for(var/mob/M in GLOB.player_list)
			if(!M.client)
				continue
			M.stop_sound_channel(activejukeboxes[IDtoremove][2])
		activejukeboxes.Cut(IDtoremove, IDtoremove+1)
		return TRUE
	else
		to_chat(world, "<span class='warning'>If you see this, screenshot it and send it to a dev. Tried to remove jukebox with invalid ID</span>")

/datum/controller/subsystem/jukeboxes/proc/findjukeboxindex(obj/jukebox)
	if(activejukeboxes.len)
		for(var/list/jukeinfo in activejukeboxes)
			if(jukebox in jukeinfo)
				return activejukeboxes.Find(jukeinfo)
	return FALSE

/datum/controller/subsystem/jukeboxes/Initialize()
	var/list/tracks = flist("config/jukebox_music/sounds/")
	for(var/S in tracks)
		var/datum/track/T = new()
		T.song_path = file("config/jukebox_music/sounds/[S]")
		var/list/L = splittext(S,"+")
		T.song_name = L[1]
		T.song_length = text2num(L[2])
		T.song_beat = text2num(L[3])
		T.song_associated_id = L[4]
		songs |= T
	return ..()

/datum/controller/subsystem/jukeboxes/fire()
	if(!activejukeboxes.len)
		return
	for(var/list/jukeinfo in activejukeboxes)
		if(!jukeinfo.len)
			to_chat(world, "<span class='warning'>If you see this, screenshot it and send it to a dev. Active jukebox without any associated metadata</span>")
		var/datum/track/juketrack = jukeinfo[1]
		if(!istype(juketrack))
			to_chat(world, "<span class='warning'>If you see this, screenshot it and send it to a dev. After jukebox track grabbing</span>")
			continue
		var/obj/jukebox = jukeinfo[3]
		if(!istype(jukebox))
			to_chat(world, "<span class='warning'>If you see this, screenshot it and send it to a dev. Nonexistant or invalid jukebox in active jukebox list")
			continue
		var/sound/song_played = sound(juketrack.song_path)
		var/area/currentarea = get_area(jukebox)
		var/turf/currentturf = get_turf(jukebox)
		var/list/hearerscache = hearers(7, jukebox)

		song_played.falloff = jukeinfo[4]

		for(var/mob/M in GLOB.player_list)
			if(!M.client)
				continue
			if(!(M.client.prefs.toggles & SOUND_INSTRUMENTS))
				M.stop_sound_channel(jukeinfo[2])
				continue

			var/inrange = FALSE
			if(jukebox.z == M.z)	//todo - expand this to work with mining planet z-levels when robust jukebox audio gets merged to master
				song_played.status = SOUND_UPDATE
				if(get_area(M) == currentarea)
					inrange = TRUE
				else if(M in hearerscache)
					inrange = TRUE
			else
				song_played.status = SOUND_MUTE | SOUND_UPDATE	//Setting volume = 0 doesn't let the sound properties update at all, which is lame.

			M.playsound_local(currentturf, null, 100, channel = jukeinfo[2], S = song_played, envwet = (inrange ? -250 : 0), envdry = (inrange ? 0 : -10000))
			CHECK_TICK
	return
