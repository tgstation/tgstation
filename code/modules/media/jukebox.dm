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

	var/emagged = 0

	New(var/list/json)
		title  = json["title"]
		artist = json["artist"]
		album  = json["album"]

		url    = json["url"]

		length = text2num(json["length"])

	proc/display()
		var/str="\"[title]\""
		if(artist!="")
			str += ", by [artist]"
		if(album!="")
			str += ", from '[album]'"
		return str

	proc/displaytitle()
		if(artist==""&&title=="")
			return "\[NO TAGS\]"
		var/str=""
		if(artist!="")
			str += "[artist] - "
		if(title!="")
			str += "\"[title]\""
		else
			str += "Untitled"
		return str


var/global/loopModeNames=list(
	JUKEMODE_SHUFFLE = "Shuffle",
	JUKEMODE_REPEAT_SONG = "Single",
	JUKEMODE_PLAY_ONCE= "Once",
)
/obj/machinery/media/jukebox
	name = "Jukebox"
	desc = "A jukebox used for parties and shit."
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox2"
	density = 1

	anchored = 1
	luminosity = 4 // Why was this 16

	playing=0

	var/loop_mode = JUKEMODE_SHUFFLE

	// Server-side playlist IDs this jukebox can play.
	var/list/playlists=list() // ID = Label

	// Playlist to load at startup.
	var/playlist_id = ""

	var/list/playlist
	var/current_song  = 0
	var/autoplay      = 0
	var/last_reload   = 0

	var/state_base = "jukebox2"

/obj/machinery/media/jukebox/attack_ai(var/mob/user)
	attack_hand(user)

/obj/machinery/media/jukebox/attack_paw()
	return

/obj/machinery/media/jukebox/power_change()
	..()
	if(emagged && !(stat & (NOPOWER|BROKEN)))
		playing = 1
	update_icon()

/obj/machinery/media/jukebox/update_icon()
	overlays = 0
	if(stat & (NOPOWER|BROKEN) || !anchored)
		if(stat & BROKEN)
			icon_state = "[state_base]-broken"
		else
			icon_state = "[state_base]-nopower"
		stop_playing()
		return
	icon_state = state_base
	if(playing)
		if(emagged)
			overlays += "[state_base]-emagged"
		else
			overlays += "[state_base]-running"

/obj/machinery/media/jukebox/proc/check_reload()
	return world.time > last_reload + JUKEBOX_RELOAD_COOLDOWN

/obj/machinery/media/jukebox/attack_hand(var/mob/user)
	if(stat & NOPOWER)
		usr << "\red You don't see anything to mess with."
		return
	if(stat & BROKEN && playlist!=null)
		user.visible_message("\red <b>[user.name] smacks the side of \the [src.name].</b>","\red You hammer the side of \the [src.name].")
		stat &= ~BROKEN
		playlist=null
		playing=emagged
		update_icon()
		return
	var/t = "<h1>Jukebox Interface</h1>"
	t += "<b>Power:</b> <a href='?src=\ref[src];power=1'>[playing?"On":"Off"]</a><br />"
	t += "<b>Play Mode:</b> <a href='?src=\ref[src];mode=1'>[loopModeNames[loop_mode]]</a><br />"
	if(playlist == null)
		t += "\[DOWNLOADING PLAYLIST, PLEASE WAIT\]"
	else
		if(check_reload())
			t += "<b>Playlist:</b> "
			for(var/plid in playlists)
				t += "<a href='?src=\ref[src];playlist=[plid]'>[playlists[plid]]</a>"
		else
			t += "<i>Please wait before changing playlists.</i>"
		t += "<br />"
		if(current_song)
			var/datum/song_info/song=playlist[current_song]
			t += "<b>Current song:</b> [song.artist] - [song.title]<br />"
		t += "<table class='prettytable'><tr><th colspan='2'>Artist - Title</th><th>Album</th></tr>"
		var/i
		for(i = 1,i <= playlist.len,i++)
			var/datum/song_info/song=playlist[i]
			t += "<tr><th>#[i]</th><td><A href='?src=\ref[src];song=[i]' class='nobg'>[song.displaytitle()]</A></td><td>[song.album]</td></tr>"
		t += "</table>"
	user.set_machine(src)
	var/datum/browser/popup = new (user,"jukebox",name,420,700)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()


/obj/machinery/media/jukebox/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/card/emag))
		current_song=0
		if(!emagged)
			playlist_id = "emagged"
			last_reload=world.time
			playlist=null
			loop_mode = JUKEMODE_SHUFFLE
			emagged = 1
			playing = 1
			user.visible_message("\red [user.name] slides something into the [src.name]'s card-reader.","\red You short out the [src.name].")
			update_icon()
			update_music()
	else if(istype(W,/obj/item/weapon/wrench))
		var/un = !anchored ? "" : "un"
		user.visible_message("\blue [user.name] begins [un]locking \the [src.name]'s casters.","\blue You begin [un]locking \the [src.name]'s casters.")
		if(do_after(user,30))
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
			anchored = !anchored
			user.visible_message("\blue [user.name] [un]locks \the [src.name]'s casters.","\red You [un]lock \the [src.name]'s casters.")
			playing = emagged
			update_music()
			update_icon()

/obj/machinery/media/jukebox/Topic(href, href_list)
	if(isobserver(usr) && !isAdminGhost(usr))
		usr << "\red You can't push buttons when your fingers go right through them, dummy."
		return
	..()
	if(emagged)
		usr << "\red You touch the bluescreened menu. Nothing happens. You feel dumber."
		return

	if (href_list["power"])
		playing=!playing
		update_music()
		update_icon()

	if (href_list["playlist"])
		if(!check_reload())
			usr << "\red You must wait 60 seconds between playlist reloads."
			return
		playlist_id=href_list["playlist"]
		last_reload=world.time
		playlist=null
		current_song=0
		update_music()
		update_icon()

	if (href_list["song"])
		current_song=Clamp(text2num(href_list["song"]),1,playlist.len)
		update_music()
		update_icon()

	if (href_list["mode"])
		loop_mode = (loop_mode % JUKEMODE_COUNT) + 1

	return attack_hand(usr)

/obj/machinery/media/jukebox/process()
	if(!playlist)
		var/url="[config.media_base_url]/index.php?playlist=[playlist_id]"
		testing("[src] - Updating playlist from [url]...")
		var/response = world.Export(url)
		playlist=list()
		if(response)
			var/json = file2text(response["CONTENT"])
			if("/>" in json)
				visible_message("<span class='warning'>\icon[src] \The [src] buzzes, unable to update its playlist.</span>","<em>You hear a buzz.</em>")
				stat &= BROKEN
				update_icon()
				return
			var/json_reader/reader = new()
			reader.tokens = reader.ScanJson(json)
			reader.i = 1
			var/songdata = reader.read_value()
			for(var/list/record in songdata)
				playlist += new /datum/song_info(record)
			if(playlist.len==0)
				visible_message("<span class='warning'>\icon[src] \The [src] buzzes, unable to update its playlist.</span>","<em>You hear a buzz.</em>")
				stat &= BROKEN
				update_icon()
				return
			visible_message("<span class='notice'>\icon[src] \The [src] beeps, and the menu on its front fills with [playlist.len] items.</span>","<em>You hear a beep.</em>")
		else
			testing("[src] failed to update playlist: Response null.")
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
					update_icon()
					return
			update_music()

/obj/machinery/media/jukebox/update_music()
	if(current_song && playing)
		var/datum/song_info/song = playlist[current_song]
		media_url = song.url
		media_start_time = world.time
		visible_message("<span class='notice'>\icon[src] \The [src] begins to play [song.display()].</span>","<em>You hear music.</em>")
		//visible_message("<span class='notice'>\icon[src] \The [src] warbles: [song.length/10]s @ [song.url]</notice>")
	else
		media_url=""
		media_start_time = 0
	..()

/obj/machinery/media/jukebox/proc/stop_playing()
	//current_song=0
	playing=0
	update_music()
	return

/obj/machinery/media/jukebox/bar
	playlist_id="bar"
	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"jazz" = "Jazz",
		"rock" = "Rock"
	)

// So I don't have to do all this shit manually every time someone sacrifices pun-pun.
// Also for debugging.
/obj/machinery/media/jukebox/superjuke
	name = "Super Juke"
	desc = "A jukebox used for parties at Mount Olympus and shit."

	state_base = "superjuke"

	playlist_id="bar"
	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"jazz" = "Jazz",
		"rock" = "Rock",

		"emagged" = "Syndie Mix",
		"shuttle" = "Shuttle",
		"endgame" = "Apocalypse"
	)

/obj/machinery/media/jukebox/superjuke/attackby(obj/item/W, mob/user)
	// NO FUN ALLOWED.  Emag list is included, anyway.
	if(istype(W, /obj/item/weapon/card/emag))
		user << "\red Your [W] refuses to touch \the [src]!"
		return
	..()

/obj/machinery/media/jukebox/shuttle
	playlist_id="shuttle"
	// Must be defined on your server.
	playlists=list(
		"shuttle"  = "Shuttle Mix"
	)
	invisibility=101 // FAK U NO SONG 4 U