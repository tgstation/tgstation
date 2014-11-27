/*******************************
 * Largely a rewrite of the Jukebox from D2K5
 *
 * By N3X15
 *******************************/

#define JUKEMODE_SHUFFLE     1 // Default
#define JUKEMODE_REPEAT_SONG 2
#define JUKEMODE_PLAY_ONCE   3 // Play, then stop.
#define JUKEMODE_COUNT       3

#define JUKEBOX_SCREEN_MAIN     1 // Default
#define JUKEBOX_SCREEN_PAYMENT  2
#define JUKEBOX_SCREEN_SETTINGS 3

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
			str += artist+" - "
		if(title!="")
			str += "\"[title]\""
		else
			str += "Untitled"
		// Only show album if we have to.
		if(album!="" && artist == "")
			str += " ([album])"
		return str


var/global/loopModeNames=list(
	JUKEMODE_SHUFFLE     = "Shuffle",
	JUKEMODE_REPEAT_SONG = "Single",
	JUKEMODE_PLAY_ONCE   = "Once",
)
/obj/machinery/media/jukebox
	name = "Jukebox"
	desc = "A bastion of goodwill, peace, and hope."
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox2"
	density = 1

	anchored = 1
	luminosity = 4 // Why was this 16

	custom_aghost_alerts=1 // We handle our own logging.

	playing=0

	var/loop_mode = JUKEMODE_SHUFFLE

	// Server-side playlist IDs this jukebox can play.
	var/list/playlists=list() // ID = Label

	// Playlist to load at startup.
	var/playlist_id = ""

	var/list/playlist
	var/current_song  = 0 // 0, or whatever song is currently playing.
	var/next_song     = 0 // 0, or a song someone has purchased.  Played after current song completes.
	var/selected_song = 0 // 0 or the song someone has selected for purchase
	var/autoplay      = 0 // Start playing after spawn?
	var/last_reload   = 0 // Reload cooldown.
	var/last_song     = 0 // ID of previous song (used in shuffle to prevent double-plays)

	var/screen = JUKEBOX_SCREEN_MAIN

	var/credits_held   = 0 // Cash currently held
	var/credits_needed = 0 // Credits needed to complete purchase.
	var/change_cost    = 10 // Current cost to change songs.
	var/list/change_access  = list() // Access required to change songs
	var/datum/money_account/linked_account
	var/department // Department that gets the money

	var/state_base = "jukebox2"

	machine_flags = WRENCHMOVE | FIXED2WORK | EMAGGABLE
	mech_flags = MECH_SCAN_FAIL
	emag_cost = 0 // because fun/unlimited uses.

/obj/machinery/media/jukebox/New(loc)
	..(loc)
	if(department)
		linked_account = department_accounts[department]
	else
		linked_account = station_account

/obj/machinery/media/jukebox/attack_ai(var/mob/user)
	attack_hand(user)

/obj/machinery/media/jukebox/attack_paw()
	return

/obj/machinery/media/jukebox/power_change()
	..()
	if(emagged && !(stat & (NOPOWER|BROKEN)))
		playing = 1
		if(current_song)
			update_music()
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

	var/t = "<div class=\"navbar\">"
	t += "<a href=\"?src=\ref[src];screen=[JUKEBOX_SCREEN_MAIN]\">Main</a>"
	if(allowed(user))
		t += " | <a href=\"?src=\ref[src];screen=[JUKEBOX_SCREEN_SETTINGS]\">Settings</a>"
	t += "</div>"
	switch(screen)
		if(JUKEBOX_SCREEN_MAIN)     t += ScreenMain(user)
		if(JUKEBOX_SCREEN_PAYMENT)  t += ScreenPayment(user)
		if(JUKEBOX_SCREEN_SETTINGS) t += ScreenSettings(user)

	user.set_machine(src)
	var/datum/browser/popup = new (user,"jukebox",name,420,700)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/media/jukebox/proc/ScreenMain(var/mob/user)
	var/t = "<h1>Jukebox Interface</h1>"
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
		if(current_song)
			var/datum/song_info/song=playlist[current_song]
			t += "<b>Current song:</b> [song.artist] - [song.title]<br />"
		if(next_song)
			var/datum/song_info/song=playlist[next_song]
			t += "<b>Up next:</b> [song.artist] - [song.title]<br />"
		t += "<table class='prettytable'><tr><th colspan='2'>Artist - Title</th><th>Album</th></tr>"
		var/i
		var/can_change=!next_song
		if(change_access.len > 0) // Permissions
			if(can_access(user.GetAccess(),req_access=change_access))
				can_change = 1

		for(i = 1,i <= playlist.len,i++)
			var/datum/song_info/song=playlist[i]
			t += "<tr><th>#[i]</th><td>"
			if(can_change) t += "<A href='?src=\ref[src];song=[i]' class='nobg'>"
			t += song.displaytitle()
			if(can_change) t += "</A>"
			t += "</td><td>[song.album]</td></tr>"
		t += "</table>"
	return t

/obj/machinery/media/jukebox/proc/ScreenPayment(var/mob/user)
	var/t = "<h1>Pay for Song</h1>"
	var/datum/song_info/song=playlist[selected_song]
	t += {"
	<center>
		<p>You've selected <b>[song.displaytitle()]</b>.</p>
		<p><b>Swipe ID card</b> or <b>insert cash</b> to play this song next! ($[num2septext(change_cost)])</p>
		\[ <a href='?src=\ref[src];cancelbuy=1'>Cancel</a> \]
	</center>"}
	return t

/obj/machinery/media/jukebox/proc/ScreenSettings(var/mob/user)
	var/dat={"<h1>Settings</h1>
		<form action="?src=\ref[src]" method="get">
		<input type="hidden" name="src" value="\ref[src]" />
		<fieldset>
			<legend>Banking</legend>
			<div>
				<b>Payable Account:</b> <input type="textbox" name="payableto" value="[linked_account.account_number]" />
			</div>
		</fieldset>
		<fieldset>
			<legend>Pricing</legend>
			<div>
				<b>Change Song:</b> $<input type="textbox" name="set_change_cost" value="[change_cost]" />
			</div>
		</fieldset>
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
	..()
	if(istype(W,/obj/item/weapon/card/id))
		if(!selected_song || screen!=JUKEBOX_SCREEN_PAYMENT)
			visible_message("\blue The machine buzzes.","\red You hear a buzz.")
			return
		var/obj/item/weapon/card/id/I = W
		if(!linked_account)
			visible_message("\red The machine buzzes, and flashes \"NO LINKED ACCOUNT\" on the screen.","You hear a buzz.")
			return
		var/datum/money_account/acct = get_card_account(I)
		if(!acct)
			visible_message("\red The machine buzzes, and flashes \"NO ACCOUNT\" on the screen.","You hear a buzz.")
			return
		if(credits_needed > acct.money)
			visible_message("\red The machine buzzes, and flashes \"NOT ENOUGH FUNDS\" on the screen.","You hear a buzz.")
			return
		visible_message("\blue The machine beeps happily.","You hear a beep.")
		acct.charge(credits_needed,linked_account,"Song selection at [areaMaster.name]'s [name].")
		credits_needed = 0

		successful_purchase()

		attack_hand(user)
	else if(istype(W,/obj/item/weapon/spacecash))
		if(!selected_song || screen!=JUKEBOX_SCREEN_PAYMENT)
			visible_message("\blue The machine buzzes.","\red You hear a buzz.")
			return
		if(!linked_account)
			visible_message("\red The machine buzzes, and flashes \"NO LINKED ACCOUNT\" on the screen.","You hear a buzz.")
			return
		var/obj/item/weapon/spacecash/C=W
		credits_held += C.worth*C.amount
		if(credits_held >= credits_needed)
			visible_message("\blue The machine beeps happily.","You hear a beep.")
			credits_held -= credits_needed
			credits_needed=0
			screen=JUKEBOX_SCREEN_MAIN
			if(credits_held)
				var/obj/item/weapon/storage/box/B = new(loc)
				dispense_cash(credits_held,B)
				B.name="change"
				B.desc="A box of change."
			credits_held=0

			successful_purchase()
		attack_hand(user)

/obj/machinery/media/jukebox/emag(mob/user)
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
		return 1
	return

/obj/machinery/media/jukebox/wrenchAnchor(mob/user)
	if(..())
		playing = emagged
		update_music()
		update_icon()

/obj/machinery/media/jukebox/proc/successful_purchase()
		next_song = selected_song
		selected_song = 0
		screen = JUKEBOX_SCREEN_MAIN

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

	if("screen" in href_list)
		if(isobserver(usr) && !canGhostWrite(usr,src,""))
			usr << "\red You can't do that."
			return
		screen=text2num(href_list["screen"])

	if("act" in href_list)
		switch(href_list["act"])
			if("Save Settings")
				if(isobserver(usr) && !canGhostWrite(usr,src,"saved settings for"))
					usr << "\red You can't do that."
					return
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

	if (href_list["playlist"])
		if(isobserver(usr) && !canGhostWrite(usr,src,""))
			usr << "\red You can't do that."
			return
		if(!check_reload())
			usr << "\red You must wait 60 seconds between playlist reloads."
			return
		playlist_id=href_list["playlist"]
		if(isAdminGhost(usr))
			message_admins("[key_name_admin(usr)] changed [src] playlist to [playlist_id] at [formatJumpTo(src)]")
		last_reload=world.time
		playlist=null
		current_song = 0
		next_song = 0
		selected_song = 0
		update_music()
		update_icon()

	if (href_list["song"])
		if(isobserver(usr) && !canGhostWrite(usr,src,""))
			usr << "\red You can't do that."
			return
		selected_song=Clamp(text2num(href_list["song"]),1,playlist.len)
		if(isAdminGhost(usr))
			var/datum/song_info/song=playlist[selected_song]
			log_adminghost("[key_name_admin(usr)] changed [src] next song to #[selected_song] ([song.display()]) at [formatJumpTo(src)]")
		if(!change_cost || isAdminGhost(usr))
			next_song = selected_song
			selected_song = 0
			if(!current_song)
				update_music()
				update_icon()
		else
			usr << "\red Swipe card or insert $[num2septext(change_cost)] to set this song."
			screen = JUKEBOX_SCREEN_PAYMENT
			credits_needed=change_cost

	if (href_list["cancelbuy"])
		selected_song=0
		screen = JUKEBOX_SCREEN_MAIN

	if (href_list["mode"])
		loop_mode = (loop_mode % JUKEMODE_COUNT) + 1

	return attack_hand(usr)

/obj/machinery/media/jukebox/process()
	if(!playlist)
		var/url="[config.media_base_url]/index.php?playlist=[playlist_id]"
		testing("[src] - Updating playlist from [url]...")

		//  Media Server 2 requires a secret key in order to tell the jukebox
		// where the music files are. It's set in config with MEDIA_SECRET_KEY
		// and MUST be the same as the media server's.
		//
		//  Do NOT log this, it's like a password.
		if(config.media_secret_key!="")
			url += "&key=[config.media_secret_key]"

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
						while(1)
							current_song=rand(1,playlist.len)
							if(current_song!=last_song || playlist.len<4)
								break
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
		last_song = current_song
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
	change_cost = 0

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
	icon_state = "superjuke"

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
		"endgame" = "Apocalypse",
	)

/obj/machinery/media/jukebox/superjuke/attackby(obj/item/W, mob/user)
	// NO FUN ALLOWED.  Emag list is included, anyway.
	if(istype(W, /obj/item/weapon/card/emag))
		user << "\red Your [W] refuses to touch \the [src]!"
		return
	..()

/obj/machinery/media/jukebox/superjuke/shuttle
	playlist_id="shuttle"
	id_tag="Shuttle" // For autolink


/obj/machinery/media/jukebox/superjuke/thematic
	playlist_id="endgame"

/obj/machinery/media/jukebox/superjuke/thematic/update_music()
	if(current_song && playing)
		var/datum/song_info/song = playlist[current_song]
		media_url = song.url
		last_song = current_song
		media_start_time = world.time
		visible_message("<span class='notice'>\icon[src] \The [src] begins to play [song.display()].</span>","<em>You hear music.</em>")
		//visible_message("<span class='notice'>\icon[src] \The [src] warbles: [song.length/10]s @ [song.url]</notice>")
	else
		media_url=""
		media_start_time = 0

	// Send update to clients.
	for(var/mob/M in mob_list)
		if(M && M.client)
			M.force_music(media_url,media_start_time,volume)

/obj/machinery/media/jukebox/superjuke/adminbus
	name = "adminbus-mounted Jukebox"
	desc = "It really doesn't get any better."
	icon = 'icons/obj/bus.dmi'
	icon_state = ""
	l_color = "#000066"
	luminosity = 0
	layer = FLY_LAYER+1
	pixel_x = -32
	pixel_y = -32

	var/datum/browser/popup = null
	req_access = list()
	playlist_id="endgame"

/obj/machinery/media/jukebox/superjuke/adminbus/attack_hand(var/mob/user)
	var/t = "<div class=\"navbar\">"
	t += "<a href=\"?src=\ref[src];screen=[JUKEBOX_SCREEN_MAIN]\">Main</a>"
	t += "</div>"
	t += ScreenMain(user)

	user.set_machine(src)
	popup = new (user,"jukebox",name,420,700)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

	if(icon_state != "jukebox")
		deploy()

/obj/machinery/media/jukebox/superjuke/adminbus/proc/deploy()
	update_media_source()
	icon_state = "jukebox"
	SetLuminosity(4)
	flick("deploying",src)

/obj/machinery/media/jukebox/superjuke/adminbus/proc/repack()
	if(playing)
		for(var/mob/M in range (src,1))
			M << "<span class='notice'>The jukebox turns itself off to protect itself from any cahot induced damage.</span>"
	if(popup)
		popup.close()
	playing = 0
	SetLuminosity(0)
	icon_state = ""
	flick("repacking",src)
	update_music()
	disconnect_media_source()
	update_icon()

/obj/machinery/media/jukebox/superjuke/adminbus/update_icon()
	if(playing)
		overlays += "beats"
	else
		overlays = 0
	return

/obj/machinery/media/jukebox/superjuke/adminbus/ex_act(severity)
	return

/obj/machinery/media/jukebox/superjuke/adminbus/cultify()
	return

/obj/machinery/media/jukebox/superjuke/adminbus/singuloCanEat()
	return 0
