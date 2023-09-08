GLOBAL_LIST_INIT(parsed_audio, list())

GLOBAL_LIST_INIT(youtube_exempt, list(
	"walkman" = list(),
	"dj-station" = list()
))

#define sound_to(target, sound) target << (sound)
#define NEXT_SONG_USE_TIMER (5 SECONDS)
/obj/item/device/walkman
	name = "walkman"
	desc = "A cassette player that first hit the market over 200 years ago. Crazy how these never went out of style. Alt-click removes the Cassette. Ctrl-click changes to the next song"
	icon = 'monkestation/code/modules/cassettes/icons/walkman.dmi'
	icon_state = "walkman"
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/walkman/play_pause,/datum/action/item_action/walkman/next_song,/datum/action/item_action/walkman/restart_song)
	///the cassette tape object
	var/obj/item/device/cassette_tape/tape
	///if the walkman is paused or not
	var/paused = TRUE
	///songs inside the current playlist
	var/list/current_playlist = list()
	///names of the songs inside the current playlist
	var/list/current_songnames = list()
	///Current song being played
	var/sound/current_song
	///Who's using the walkman
	var/mob/current_listener
	///Client of the listener
	var/client/listener
	///where in the playlist you are
	var/pl_index = 1
	///volume the walkman starts at
	var/volume = 25
	/// What kind of walkman design style to use
	var/design = 1
	///Is the current song a link? We handle those different
	var/link_play = FALSE
	///time left in current link song, used for a variety of things. One it lets us sync the next song up, two it lets us find out where to resume
	var/time_left = 0
	///current_song_duration
	var/current_song_duration = 0
	///cooldown used by the next song to stop overlapping sounds between url based songs and normal ones
	COOLDOWN_DECLARE(next_song_use)

/obj/item/device/walkman/Initialize()
	. = ..()
	design = rand(1, 5)
	update_icon()

/obj/item/device/walkman/Destroy()
	QDEL_NULL(tape)
	break_sound()
	current_song = null
	current_listener = null
	listener = null
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/device/walkman/attackby(obj/item/cassette, mob/user)
	if(!istype(cassette, /obj/item/device/cassette_tape))
		return
	if(!tape)
		insert_tape(cassette)
		playsound(src,'sound/weapons/handcuffs.ogg',20,1)
		to_chat(user,("You insert \the [cassette] into \the [src]"))
	else
		to_chat(user,("Remove the other tape first!"))

/obj/item/device/walkman/attack_self(mob/user)
	..()

	if(!current_listener)
		current_listener = user
		listener = current_listener.client
	if(istype(tape))
		if(paused)
			play()
			to_chat(user,("You press [src]'s 'play' button"))
		else
			pause()
			to_chat(user,("You pause [src]"))
		update_icon()
	else
		to_chat(user,("There's no tape to play"))
	playsound(src,'sound/machines/click.ogg',20,1)

/obj/item/device/walkman/AltClick(mob/user)
	if(tape)
		eject_tape(user)
	else
		..()

/obj/item/device/walkman/CtrlClick(mob/user)
	if(tape)
		next_song(user)
	else
		return ..()

///This is called when sound needs to be broken ie you die or lose access to it
/obj/item/device/walkman/proc/break_sound()
	if(link_play)
		listener.tgui_panel?.stop_music()
		GLOB.youtube_exempt["walkman"] -= listener
		if(GLOB.dj_booth && GLOB.dj_broadcast)
			var/obj/machinery/cassette/dj_station/dj = GLOB.dj_booth
			if(iscarbon(current_listener))
				dj.check_solo_broadcast(current_listener)
		return
	var/sound/break_sound = sound(null, 0, 0, CHANNEL_WALKMAN)
	break_sound.priority = 255
	update_song(break_sound, current_listener, 0)


/*Called when songs are updated ie volume change
 *Arguments: mob/user -> the current user of the walkman
 * sound/noise -> the sound that is being directed to the user
 */
/obj/item/device/walkman/proc/update_song(sound/noise, mob/user, flags = SOUND_UPDATE)
	if(!istype(user) || !istype(noise)) return
	if(HAS_TRAIT(user, TRAIT_DEAF))
		flags |= SOUND_MUTE
	noise.status = flags
	noise.volume = src.volume
	noise.channel = CHANNEL_WALKMAN
	sound_to(user,noise)

/*Called when music is paused by the user
 *Arguments: mob/user -> the current user of the walkman
 */
/obj/item/device/walkman/proc/pause(mob/user)
	if(!current_song && !link_play)
		return
	paused = TRUE
	STOP_PROCESSING(SSprocessing, src)
	if(!link_play)
		update_song(current_song,current_listener, SOUND_PAUSED | SOUND_UPDATE)
	else
		listener.tgui_panel?.stop_music()

///Handles the actual playing of the sound to the current_listener
/obj/item/device/walkman/proc/play()
	if(!current_song)
		if(current_playlist.len > 0)
			if(findtext(current_playlist[pl_index], GLOB.is_http_protocol))
				///invoking youtube-dl
				var/ytdl = CONFIG_GET(string/invoke_youtubedl)
				///the input for ytdl handled by the song list
				var/web_sound_input
				///the url for youtube-dl
				var/web_sound_url = ""
				///all extra data from the youtube-dl really want the name
				var/list/music_extra_data = list()
				web_sound_input = trim(current_playlist[pl_index])
				if(!(web_sound_input in GLOB.parsed_audio))
					///scrubbing the input before putting it in the shell
					var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
					///putting it in the shell
					var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height <= 360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
					///any errors
					var/errorlevel = output[SHELLEO_ERRORLEVEL]
					///the standard output
					var/stdout = output[SHELLEO_STDOUT]
					if(!errorlevel)
						///list for all the output data to go to
						var/list/data
						try
							data = json_decode(stdout)
						catch(var/exception/error) ///catch errors here
							to_chat(src, "<span class='boldwarning'>Youtube-dl JSON parsing FAILED:</span>", confidential = TRUE)
							to_chat(src, "<span class='warning'>[error]: [stdout]</span>", confidential = TRUE)
							return

						if (data["url"])
							web_sound_url = data["url"]
							music_extra_data["start"] = data["start_time"]
							music_extra_data["end"] = data["end_time"]
							music_extra_data["link"] = data["webpage_url"]
							music_extra_data["title"] = data["title"]
							if(music_extra_data["start"])
								time_left = data["duration"] - music_extra_data["start"]
							else
								time_left = data["duration"]

							current_song_duration = data["duration"]

						GLOB.parsed_audio["[web_sound_input]"] = data
					GLOB.youtube_exempt["walkman"] |= listener
					listener.tgui_panel?.play_music(web_sound_url, music_extra_data)
					START_PROCESSING(SSprocessing, src)
					link_play = TRUE
					paused = FALSE
					return
				else
					var/list/data = GLOB.parsed_audio["[web_sound_input]"]
					web_sound_url = data["url"]
					music_extra_data["start"] = data["start_time"]
					music_extra_data["end"] = data["end_time"]
					music_extra_data["link"] = data["webpage_url"]
					music_extra_data["title"] = data["title"]
					if(time_left <= 0)
						if(music_extra_data["start"])
							time_left = data["duration"] - music_extra_data["start"]
						else
							time_left = data["duration"]

					current_song_duration = data["duration"]
					music_extra_data["duration"] = data["duration"]

					if(time_left > 0)
						music_extra_data["start"] = music_extra_data["duration"] - time_left

					GLOB.youtube_exempt["walkman"] |= listener
					listener.tgui_panel?.play_music(web_sound_url, music_extra_data)
					START_PROCESSING(SSprocessing, src)
					link_play = TRUE
					paused = FALSE
					return

			else
				current_song = sound(current_playlist[pl_index], 0, 0, CHANNEL_WALKMAN, volume)
				current_song.status = SOUND_STREAM
		else
			return
	paused = FALSE
	if(current_song.status & SOUND_PAUSED)
		update_song(current_song,current_listener)
	else
		update_song(current_song,current_listener,0)

	update_song(current_song,current_listener)


/*Called when
 *Arguments: obj/item/device/cassette_tape/CT -> the cassette in question that you are inserting into the walkman
 */
/obj/item/device/walkman/proc/insert_tape(obj/item/device/cassette_tape/CTape)
	if(tape || !istype(CTape))
		return

	tape = CTape
	CTape.forceMove(src)

	update_icon()
	paused = TRUE
	pl_index = 1
	if(tape.songs["side1"] && tape.songs["side2"])
		var/list/list = tape.songs["[tape.flipped ? "side2" : "side1"]"]
		for(var/song in list)
			current_playlist += song
			current_songnames += list[song]

/*Called when you eject a tape
 *Arguments: mob/user -> the current user of the walkman
 */
/obj/item/device/walkman/proc/eject_tape(mob/user)
	if(!tape)
		return

	break_sound()

	current_song = null
	current_playlist.Cut()
	current_songnames.Cut()
	user.put_in_hands(tape)
	pause()
	tape = null
	time_left = 0
	current_song_duration = 0
	update_icon()
	STOP_PROCESSING(SSprocessing, src)
	playsound(src,'sound/weapons/handcuffs.ogg',20,1)

/*Called when you need to go to next song either when it naturally ends or when user changes song manually
 *Arguments: mob/user -> the current user of the walkman
 */
/obj/item/device/walkman/proc/next_song(mob/user)
	if(current_playlist.len == 0 || !COOLDOWN_FINISHED(src, next_song_use))
		return
	COOLDOWN_START(src, next_song_use, NEXT_SONG_USE_TIMER)

	time_left = 0
	current_song_duration = 0

	break_sound()

	pl_index = pl_index + 1 <= current_playlist.len ? (pl_index += 1) : 1
	link_play = findtext(current_playlist[pl_index], GLOB.is_http_protocol) ? TRUE : FALSE


	if(!link_play)
		current_song = sound(current_playlist[pl_index], 0, 0, CHANNEL_WALKMAN, volume)
		current_song.status = SOUND_STREAM
	else
		current_song = null
	play()



/obj/item/device/walkman/update_icon()
	..()
	overlays.Cut()
	if(design)
		overlays += "+[design]"
	if(tape)
		if(!paused)
			overlays += "+playing"
	else
		overlays += "+empty"

	if(ishuman(loc))
		///current human used to get location
		var/mob/living/carbon/human/player = loc
		player.regenerate_icons()

/obj/item/device/walkman/process(seconds_per_tick)
	time_left--
	if(time_left <= 0)
		next_song(current_listener)

	if(!(src in current_listener.get_all_contents()) || current_listener.stat & DEAD)
		if(current_song)
			current_song = null
		break_sound()
		paused = TRUE
		current_listener = null
		listener = null
		update_icon()
		STOP_PROCESSING(SSprocessing, src)
		return

	if(HAS_TRAIT(current_listener, TRAIT_DEAF) && current_song && !(current_song.status & SOUND_MUTE))
		update_song(current_song, current_listener)
	if(!HAS_TRAIT(current_listener, TRAIT_DEAF) && current_song && current_song.status & SOUND_MUTE)
		update_song(current_song, current_listener)

/obj/item/device/walkman/verb/change_volume()
	set name = "Change Walkman volume"
	set category = "Object"
	set src in usr

	if(!current_song) return

	var/tmp = input(usr,"Change the volume (0 - 100)","Volume") as num|null
	if(tmp == null)
		return
	if(tmp > 100)
		tmp = 100
	if(tmp < 0)
		tmp = 0
	volume = tmp
	update_song(current_song, current_listener)

/* Called when you need to restart a song
 * Arguments: mob/user -> the user that has triggered the reset
 */
/obj/item/device/walkman/proc/restart_song(mob/user)
	if(!current_song)
		return

	update_song(current_song, current_listener, 0)

/*
	ACTION BUTTONS
*/

/datum/action/item_action/walkman
	button_icon = 'monkestation/code/modules/cassettes/icons/walkman.dmi'
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/walkman/New()
	.=..()

/datum/action/item_action/walkman/play_pause
	button_icon_state = "walkman_playpause"

/datum/action/item_action/walkman/play_pause/New()
	..()
	name = "Play/Pause"

/datum/action/item_action/walkman/play_pause/Trigger(trigger_flags)
	if(target)
		var/obj/item/device/walkman/WM = target
		WM.attack_self(owner)

/datum/action/item_action/walkman/next_song
	button_icon_state = "walkman_next"

/datum/action/item_action/walkman/next_song/New()
	..()
	name = "Next song"

/datum/action/item_action/walkman/next_song/Trigger(trigger_flags)
	if(target)
		var/obj/item/device/walkman/walkM = target
		walkM.next_song(owner)

/datum/action/item_action/walkman/restart_song
	button_icon_state = "walkman_restart"

/datum/action/item_action/walkman/restart_song/New()
	..()
	name = "Restart song"

/datum/action/item_action/walkman/restart_song/Trigger(trigger_flags)
	if(target)
		var/obj/item/device/walkman/walkM = target
		walkM.restart_song(owner)

#undef sound_to
#undef NEXT_SONG_USE_TIMER
