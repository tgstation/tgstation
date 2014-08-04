/*******************************
 * Modified Jukebox code for DJing.
 *
 * By N3X15
 *******************************/

#define JUKEMODE_SHUFFLE     1 // Default
#define JUKEMODE_REPEAT_SONG 2
#define JUKEMODE_PLAY_ONCE   3 // Play, then stop.


/obj/machinery/media/tapedeck
	name = "Tape Deck"
	desc = "What the fuck is \"tape\", anyway?"

	icon = 'icons/obj/jukebox.dmi'
	icon_state = "tapedeck"

	density = 1
	anchored = 1

	playing=0

	var/loop_mode = JUKEMODE_SHUFFLE

	// Server-side playlist IDs this jukebox can play.
	var/list/playlists=list() // ID = Label

	var/list/current_playlist=list()

	// Playlist to load at startup.
	var/playlist_id = ""

	var/list/playlist
	var/current_song  = 0 // 0, or whatever song is currently playing.
	var/next_song     = 0 // 0, or a song someone has purchased.  Played after current song completes.
	var/selected_song = 0 // 0 or the song someone has selected for purchase
	var/autoplay      = 0 // Start playing after spawn?
	var/last_reload   = 0 // Reload cooldown.
	var/last_song     = 0 // Doubleplay prevention

	// Eventually...
	var/cycletype      = TAPEDECK_CYCLE_MUSIC
	var/adcyc_duration = 2 MINUTES
	var/last_ad_cyc    = 0 // Last world.time of an ad cycle
	var/list/ad_queue  = 0 // Ads queued to play

	var/state_base = "tapedeck"

/obj/machinery/media/tapedeck/attack_ai(var/mob/user)
	attack_hand(user)

/obj/machinery/media/tapedeck/attack_paw()
	return

/obj/machinery/media/tapedeck/power_change()
	..()
	//if(emagged && !(stat & (NOPOWER|BROKEN)))
	//	playing = 1
	update_icon()

/obj/machinery/media/tapedeck/update_icon()
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

/obj/machinery/media/tapedeck/proc/check_reload()
	return world.time > last_reload + JUKEBOX_RELOAD_COOLDOWN

/obj/machinery/media/tapedeck/attack_hand(var/mob/user)
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

	var/t = "<div class=\"navbar\">"
	t += "<a href=\"?src=\ref[src];screen=[JUKEBOX_SCREEN_MAIN]\">Main</a>"
	//if(allowed(user))
	//	t += " | <a href=\"?src=\ref[src];screen=[JUKEBOX_SCREEN_SETTINGS]\">Settings</a>"
	t += "</div>"
	switch(screen)
		if(JUKEBOX_SCREEN_MAIN)     t += ScreenMain(user)
		//if(JUKEBOX_SCREEN_SETTINGS) t += ScreenSettings(user)

	user.set_machine(src)
	var/datum/browser/popup = new (user,"tapedeck",name,420,700)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/media/jukebox/proc/ScreenMain(var/mob/user)
	var/t = "<h1>[src] Interface</h1>"
	t += "<b>Power:</b> <a href='?src=\ref[src];power=1'>[playing?"On":"Off"]</a><br />"
	t += "<b>Play Mode:</b> <a href='?src=\ref[src];mode=1'>[loopModeNames[loop_mode]]</a><br />"
	if(playlist == null)
		t += "\[DOWNLOADING PLAYLIST, PLEASE WAIT\]"
	else
		if(req_access.len == 0 || allowed(user))
			if(check_reload())
				t += "<b>Playlist:</b> "
				for(var/plid in playlists)
					t += "<a href='?src=\ref[src];playlist=[plid]'>[playlists[plid]]</a>"
			else
				t += "<i>Please wait before changing playlists.</i>"
		else
			t += "<i>You cannot change the playlist.</i>"
		t += "<br />"

		////////////////////////////
		// Now here's the cool shit
		t += {"
		<b>Playlist Tools:</b>
			<a href='?src=\ref[src];reload=1'>Reload</a>
			<a href='?src=\ref[src];add=1'>Add Song</a>
			<a href='?src=\ref[src];clear=1'>Clear</a>
		<br />"}
		//
		////////////////////////////

		if(current_song)
			var/datum/song_info/song=playlist[current_song]
			t += "<b>Current song:</b> [song.artist] - [song.title]<br />"
		if(next_song)
			var/datum/song_info/song=playlist[next_song]
			t += "<b>Up next:</b> [song.artist] - [song.title]<br />"
		t += "<table class='prettytable'><tr><th colspan='2'>Artist - Title</th><th>Album</th><th>Controls</th></tr>"
		var/i
		var/can_change=1

		for(i = 1,i <= playlist.len,i++)
			var/datum/song_info/song=playlist[i]
			t += {"
			<tr>
				<th>#[i]</th>
				<td>
					<A href='?src=\ref[src];song=[i]' class='nobg'>[song.displaytitle()]</A>
				</td>
				<td>[song.album]</td>
				<td>
					<A href='?src=\ref[src];queue=[i]'>Q</A>
					<A href='?src=\ref[src];remove=[i]'>X</A>
				</td>
			</tr>"}
		t += "</table>"
	return t

/obj/machinery/media/jukebox/proc/ScreenSettings(var/mob/user)
	var/dat={"<h1>Settings</h1>
		<form action="?src=\ref[src]" method="get">
		<input type="hidden" name="src" value="\ref[src]" />
		<fieldset>
			<legend>Access</legend>
			<p>Permissions required to change song:</p>
			<div>
				<input type="radio" name="lock" id="lock_none" value=""[change_access == list() ? " checked='selected'":""] /> <label for="lock_none">None</label>
			</div>
			<div>
				<input type="radio" name="lock" id="lock_bar" value="[access_bar]"[change_access == list(access_bar) ? " checked='selected'":""] /> <label for="lock_bar">Bar</label>
			</div>
			<div>
				<input type="radio" name="lock" id="lock_head" value="[access_heads]"[change_access == list(access_heads) ? " checked='selected'":""] /> <label for="lock_head">Any Head</label>
			</div>
			<div>
				<input type="radio" name="lock" id="lock_cap" value="[access_captain]"[change_access == list(access_captain) ? " checked='selected'":""] /> <label for="lock_cap">Captain</label>
			</div>
		</fieldset>
		<input type="submit" name="act" value="Save Settings" />
		</form>"}
	return dat



/obj/machinery/media/jukebox/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)
		return 1
	if(istype(W, /obj/item/weapon/card/emag))
		current_song = 0
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

	if (href_list["power"])
		playing=!playing
		update_music()
		update_icon()

	if("screen" in href_list)
		screen=text2num(href_list["screen"])

	if("act" in href_list)
		switch(href_list["act"])
			if("Save Settings")
				var/datum/money_account/new_linked_account = get_money_account(text2num(href_list["payableto"]),z)
				if(!new_linked_account)
					usr << "\red Unable to link new account. Aborting."
					return

				change_cost = max(0,text2num(href_list["set_change_cost"]))
				linked_account = new_linked_account
				if("lock" in href_list && href_list["lock"] != "")
					change_access = list(text2num(href_list["lock"]))
				else
					change_access = list()

				screen=POS_SCREEN_SETTINGS
	if (href_list["reload"])
		href_list["playlist"]=playlist_id // Hax

	if (href_list["playlist"])
		if(!check_reload())
			usr << "\red You must wait 60 seconds between playlist reloads."
			return
		playlist_id=href_list["playlist"]
		last_reload=world.time
		playlist=null
		current_song = 0
		next_song = 0
		selected_song = 0
		update_music()
		update_icon()

	if (href_list["song"])
		selected_song=Clamp(text2num(href_list["song"]),1,playlist.len)
		next_song = selected_song
		selected_song = 0
		if(!current_song)
			update_music()
			update_icon()

	if (href_list["add_song"])
		var/song_uri=input(

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
			if(autoplay)
				playing=1
				autoplay=0
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
			if(next_song)
				current_song = next_song
				next_song = 0
			else
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
	department = "Civilian"
	req_access = list(access_bar)

	playlist_id="bar"
	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"jazz" = "Jazz",
		"rock" = "Rock"
	)

// Relaxing elevator music~
/obj/machinery/media/jukebox/dj

	playlist_id="muzak"
	autoplay = 1

	id_tag="DJ Satellite" // For autolink

	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"jazz" = "Jazz",
		"rock" = "Rock",
		"muzak" = "Muzak"
	)

// So I don't have to do all this shit manually every time someone sacrifices pun-pun.
// Also for debugging.
/obj/machinery/media/jukebox/superjuke
	name = "Super Juke"
	desc = "The ultimate jukebox. Your brain begins to liquify from simply looking at it."

	state_base = "superjuke"
	change_cost = 0

	playlist_id="bar"
	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"jazz" = "Jazz",
		"rock" = "Rock",
		"muzak" = "Muzak",

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
