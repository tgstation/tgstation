/*******************************
 * Largely a rewrite of the Jukebox from D2K5
 *
 * By N3X15
 *******************************/

#define JUKEMODE_SHUFFLE     1 // Default
#define JUKEMODE_REPEAT_SONG 2
#define JUKEMODE_PLAY_ONCE   3 // Play, then stop.
#define JUKEMODE_COUNT       3

#define JUKEBOX_RELOAD_COOLDOWN 600 // 60s

// Represents a record returned.
/datum/song_info
	var/title  = ""
	var/artist = ""
	var/album  = ""

	var/url    = ""
	var/length = 0 // decaseconds

	New(var/list/json)
		title  = json["title"]
		artist = json["artist"]
		album  = json["album"]

		url    = json["url"]

		length = text2num(json["length"])


var/global/loopModeNames=list(
	JUKEMODE_SHUFFLE = "Shuffle",
	JUKEMODE_REPEAT_SONG = "Single",
	JUKEMODE_PLAY_ONCE= "Once",
)
/obj/machinery/media/jukebox
	name = "Jukebox"
	desc = "A jukebox used for parties and shit."
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox"
	density = 1

	anchored = 1
	luminosity = 4 // Why was this 16

	playing=0

	var/loop_mode = JUKEMODE_SHUFFLE
	// /datum/song_info
	var/list/playlist
	var/current_song  = 0
	var/autoplay      = 0
	var/last_reload   = 0

/obj/machinery/media/jukebox/attack_ai()
	return

/obj/machinery/media/jukebox/attack_paw()
	return
/obj/machinery/media/jukebox/proc/check_reload()
	return world.time > last_reload + JUKEBOX_RELOAD_COOLDOWN
/obj/machinery/media/jukebox/attack_hand(var/mob/user)
	var/t = "<h1>Jukebox Interface</h1>"
	t += "<b>Power:</b> <a href='?src=\ref[src];power=1'>[playing?"On":"Off"]</a><br />"
	t += "<b>Play Mode:</b> <a href='?src=\ref[src];loop=1'>[loopModeNames[loop_mode]]</a><br />"
	if(playlist == null)
		t += "\[DOWNLOADING PLAYLIST, PLEASE WAIT\]"
	else
		if(current_song)
			var/datum/song_info/song=playlist[current_song]
			t += "<b>Current song:</b> [song.artist] - [song.title]<br />"
		if(check_reload())
			t += "\[<a href='?src=\ref[src];reload=1'>Reload Playlist</a>\]"
		t += "<table class='prettytable'><tr><th colspan='2'>Artist - Title</th><th>Album</th></tr>"
		var/i
		for(i = 1,i <= playlist.len,i++)
			var/datum/song_info/song=playlist[i]
			t += "<tr><th>#[i]</th><td><A href='?src=\ref[src];song=[i]'>[song.artist] - [song.title]</A></td><td>[song.album]</td></tr>"
		t += "</table>"
	user.set_machine(src)
	var/datum/browser/popup = new (user,"jukebox",name,420,700)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()


/obj/machinery/media/jukebox/Topic(href, href_list)
	..()
	if (href_list["power"])
		playing=!playing
		update_music()

	if (href_list["reload"])
		if(!check_reload())
			usr << "\red You must wait 60 seconds between reloads."
			return
		last_reload=world.time
		playlist=null
		current_song=0
		update_music()

	if (href_list["song"])
		current_song=Clamp(text2num(href_list["song"]),1,playlist.len)
		update_music()

	if (href_list["mode"])
		// Theoretically, this should barrel shift.
		loop_mode = (loop_mode % JUKEMODE_COUNT)+1
	return attack_hand(usr)

/obj/machinery/media/jukebox/process()
	if(!playlist)
		var/url="[config.media_base_url]/index.php"
		testing("[src] - Updating playlist from [url]...")
		var/response = world.Export(url)
		playlist=list()
		if(response)
			var/json = file2text(response["CONTENT"])
			var/json_reader/reader = new()
			reader.tokens = reader.ScanJson(json)
			reader.i = 1
			var/songdata = reader.read_value()
			for(var/list/record in songdata)
				playlist += new /datum/song_info(record)
			visible_message("<span class='notice'>\icon[src] \The [src] beeps, and the menu on its front fills with [playlist.len] items.</span>","<em>You hear a beep.</em>")
		else
			//testing("Failed to update playlist: Response null.")
			stat &= BROKEN
			update_icon()
			return
	if(playing)
		var/datum/song_info/song
		if(current_song)
			song = playlist[current_song]
		if(!current_song || (song && world.time >= media_start_time + song.length))
			current_song=1
			switch(loop_mode)
				if(JUKEMODE_SHUFFLE)
					current_song=rand(1,playlist.len)
				if(JUKEMODE_REPEAT_SONG)
					current_song=current_song
				if(JUKEMODE_PLAY_ONCE)
					playing=0
					return
			if(!playing)
				return
			update_music()

/obj/machinery/media/jukebox/update_music()
	if(current_song)
		var/datum/song_info/song = playlist[current_song]
		media_url = song.url
		media_start_time = world.time
		visible_message("<span class='notice'>\icon[src] \The [src] begins to play \"[song.title]\", by [song.artist].</span>","<em>You hear music.</em>")
		//visible_message("<span class='notice'>\icon[src] \The [src] warbles: [song.length/10]s @ [song.url]</notice>")
	else
		media_url=""
		media_start_time = 0
	..()