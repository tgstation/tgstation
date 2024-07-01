GLOBAL_VAR(dj_broadcast)
GLOBAL_VAR(dj_booth)


/obj/item/clothing/ears
	//can we be used to listen to radio?
	var/radio_compat = FALSE

/obj/machinery/cassette/dj_station
	name = "Cassette Player"
	desc = "Plays Space Music Board approved cassettes for anyone in the station to listen to "

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "cassette_player"

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION

	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = TRUE
	var/broadcasting = FALSE
	var/obj/item/device/cassette_tape/inserted_tape
	var/time_left = 0
	var/current_song_duration = 0
	var/list/people_with_signals = list()
	var/list/active_listeners = list()
	var/waiting_for_yield = FALSE

	//tape stuff goes here
	var/pl_index = 0
	var/list/current_playlist = list()
	var/list/current_namelist = list()

	COOLDOWN_DECLARE(next_song_timer)

/obj/machinery/cassette/dj_station/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	GLOB.dj_booth = src
	register_context()

/obj/machinery/cassette/dj_station/Destroy()
	. = ..()
	GLOB.dj_booth = null
	STOP_PROCESSING(SSprocessing, src)

/obj/machinery/cassette/dj_station/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(inserted_tape)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject Tape"
		if(!broadcasting)
			context[SCREENTIP_CONTEXT_LMB] = "Play Tape"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/cassette/dj_station/examine(mob/user)
	. = ..()
	if(time_left > 0 || next_song_timer)
		. += span_notice("It seems to be cooling down, you estimate it will take about [time_left ? DisplayTimeText(((time_left * 10) + 6000)) : DisplayTimeText(COOLDOWN_TIMELEFT(src, next_song_timer))].")

/obj/machinery/cassette/dj_station/process(seconds_per_tick)
	if(waiting_for_yield)
		return
	time_left -= round(seconds_per_tick)
	if(time_left <= 0)
		time_left = 0
		if(COOLDOWN_FINISHED(src, next_song_timer) && broadcasting)
			COOLDOWN_START(src, next_song_timer, 10 MINUTES)
		broadcasting = FALSE

/obj/machinery/cassette/dj_station/attack_hand(mob/user)
	. = ..()
	if(!inserted_tape)
		return
	if((!COOLDOWN_FINISHED(src, next_song_timer)) && !broadcasting)
		to_chat(user, span_notice("The [src] feels hot to the touch and needs time to cooldown."))
		to_chat(user, span_info("You estimate it will take about [time_left ? DisplayTimeText(((time_left * 10) + 6000)) : DisplayTimeText(COOLDOWN_TIMELEFT(src, next_song_timer))] to cool down."))
		return
	message_admins("[src] started broadcasting [inserted_tape] interacted with by [user]")
	logger.Log(LOG_CATEGORY_MUSIC, "[src] started broadcasting [inserted_tape]")
	start_broadcast()

/obj/machinery/cassette/dj_station/AltClick(mob/user)
	. = ..()
	if(!isliving(user) || !user.Adjacent(src))
		return
	if(!inserted_tape)
		return
	if(broadcasting)
		next_song()

/obj/machinery/cassette/dj_station/CtrlClick(mob/user)
	. = ..()
	if(!inserted_tape || broadcasting)
		return
	if(Adjacent(user) && !issiliconoradminghost(user))
		if(!user.put_in_hands(inserted_tape))
			inserted_tape.forceMove(drop_location())
	else
		inserted_tape.forceMove(drop_location())
	inserted_tape = null
	time_left = 0
	current_song_duration = 0
	pl_index = 0
	current_playlist = list()
	current_namelist = list()
	stop_broadcast(TRUE)

/obj/machinery/cassette/dj_station/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/device/cassette_tape))
		return
	var/obj/item/device/cassette_tape/attacked = weapon
	if(!attacked.approved_tape)
		to_chat(user, span_warning("The [src] smartly rejects the bootleg cassette tape"))
		return
	if(!inserted_tape)
		insert_tape(attacked)
	else
		if(!broadcasting)
			if(Adjacent(user) && !issiliconoradminghost(user))
				if(!user.put_in_hands(inserted_tape))
					inserted_tape.forceMove(drop_location())
			else
				inserted_tape.forceMove(drop_location())
			inserted_tape = null
			time_left = 0
			current_song_duration = 0
			pl_index = 0
			current_playlist = list()
			current_namelist = list()
			insert_tape(attacked)
			if(broadcasting)
				stop_broadcast(TRUE)

/obj/machinery/cassette/dj_station/proc/insert_tape(obj/item/device/cassette_tape/CTape)
	if(inserted_tape || !istype(CTape))
		return

	inserted_tape = CTape
	CTape.forceMove(src)

	update_appearance()
	pl_index = 1
	if(inserted_tape.songs["side1"] && inserted_tape.songs["side2"])
		var/list/list = inserted_tape.songs["[inserted_tape.flipped ? "side2" : "side1"]"]
		for(var/song in list)
			current_playlist += song

		var/list/name_list = inserted_tape.song_names["[inserted_tape.flipped ? "side2" : "side1"]"]
		for(var/song in name_list)
			current_namelist += song

/obj/machinery/cassette/dj_station/proc/stop_broadcast(soft = FALSE)
	STOP_PROCESSING(SSprocessing, src)
	GLOB.dj_broadcast = FALSE
	broadcasting = FALSE
	message_admins("[src] has stopped broadcasting [inserted_tape].")
	logger.Log(LOG_CATEGORY_MUSIC, "[src] has stopped broadcasting [inserted_tape]")
	for(var/client/anything as anything in active_listeners)
		if(!istype(anything))
			continue
		anything.tgui_panel?.stop_music()
		GLOB.youtube_exempt["dj-station"] -= anything
	active_listeners = list()

	if(!soft)
		for(var/mob/living/carbon/anything as anything in people_with_signals)
			if(!istype(anything))
				continue
			UnregisterSignal(anything, COMSIG_CARBON_UNEQUIP_EARS)
			UnregisterSignal(anything, COMSIG_CARBON_EQUIP_EARS)
			UnregisterSignal(anything, COMSIG_MOVABLE_Z_CHANGED)
		people_with_signals = list()

/obj/machinery/cassette/dj_station/proc/start_broadcast()
	var/choice = tgui_input_list(usr, "Choose which song to play.", "[src]", current_namelist)
	if(!choice)
		return
	var/list_index = current_namelist.Find(choice)
	if(!list_index)
		return
	GLOB.dj_broadcast = TRUE
	pl_index = list_index

	var/list/viable_z = SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING, ZTRAIT_CENTCOM, ZTRAIT_RESERVED))
	for(var/mob/person as anything in GLOB.player_list)
		if(issilicon(person) || isobserver(person) || isaicamera(person) || isbot(person))
			active_listeners |=	person.client
			continue
		if(iscarbon(person))
			var/mob/living/carbon/anything = person
			if(!(anything in people_with_signals))
				if(!istype(anything))
					continue

				RegisterSignal(anything, COMSIG_CARBON_UNEQUIP_EARS, PROC_REF(stop_solo_broadcast))
				RegisterSignal(anything, COMSIG_CARBON_EQUIP_EARS, PROC_REF(check_solo_broadcast))
				RegisterSignal(anything, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(check_solo_broadcast))
				people_with_signals |= anything

			if(!(anything.client in active_listeners))
				if(!(anything.z in viable_z))
					continue

				if(!anything.client)
					continue

				if(anything.client in GLOB.youtube_exempt["walkman"])
					continue

				var/obj/item/ear_slot = anything.get_item_by_slot(ITEM_SLOT_EARS)
				if(istype(ear_slot, /obj/item/clothing/ears))
					var/obj/item/clothing/ears/worn
					if(!worn || !worn?.radio_compat)
						continue
				else if(!istype(ear_slot, /obj/item/radio/headset))
					continue

				if(!anything.client.prefs?.read_preference(/datum/preference/toggle/hear_music))
					continue

				active_listeners |=	anything.client

	if(!length(active_listeners))
		return

	start_playing(active_listeners)
	START_PROCESSING(SSprocessing, src)


/obj/machinery/cassette/dj_station/proc/check_solo_broadcast(mob/living/carbon/source, obj/item/clothing/ears/ear_item)
	SIGNAL_HANDLER

	if(!istype(source))
		return

	if(istype(ear_item, /obj/item/clothing/ears))
		var/obj/item/clothing/ears/worn
		if(!worn || !worn?.radio_compat)
			return
	else if(!istype(ear_item, /obj/item/radio/headset))
		return

	var/list/viable_z = SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING, ZTRAIT_CENTCOM))
	if(!(source.z in viable_z) || !source.client)
		return

	if(!source.client.prefs?.read_preference(/datum/preference/toggle/hear_music))
		return

	active_listeners |= source.client
	GLOB.youtube_exempt["dj-station"] |= source.client
	INVOKE_ASYNC(src, PROC_REF(start_playing),list(source.client))

/obj/machinery/cassette/dj_station/proc/stop_solo_broadcast(mob/living/carbon/source)
	SIGNAL_HANDLER

	if(!source.client || !(source.client in active_listeners))
		return

	active_listeners -= source.client
	GLOB.youtube_exempt["dj-station"] -= source.client
	source.client.tgui_panel?.stop_music()

/obj/machinery/cassette/dj_station/proc/start_playing(list/clients)
	if(!inserted_tape)
		if(broadcasting)
			stop_broadcast(TRUE)
		return

	waiting_for_yield = TRUE
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

		for(var/client/anything as anything in clients)
			if(!istype(anything))
				continue
			anything.tgui_panel?.play_music(web_sound_url, music_extra_data)
			GLOB.youtube_exempt["dj-station"] |= anything
		broadcasting = TRUE
	waiting_for_yield = FALSE

/obj/machinery/cassette/dj_station/proc/add_new_player(mob/living/carbon/new_player)
	if(!(new_player in people_with_signals))
		RegisterSignal(new_player, COMSIG_CARBON_UNEQUIP_EARS, PROC_REF(stop_solo_broadcast))
		RegisterSignal(new_player, COMSIG_CARBON_EQUIP_EARS, PROC_REF(check_solo_broadcast))
		RegisterSignal(new_player, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(check_solo_broadcast))
		people_with_signals |= new_player

	if(!broadcasting)
		return

	var/obj/item/ear_slot = new_player.get_item_by_slot(ITEM_SLOT_EARS)
	if(istype(ear_slot, /obj/item/clothing/ears))
		var/obj/item/clothing/ears/worn
		if(!worn || !worn?.radio_compat)
			return
	else if(!istype(ear_slot, /obj/item/radio/headset))
		return
	var/list/viable_z = SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING, ZTRAIT_CENTCOM))
	if(!(new_player.z in viable_z))
		return

	if(!(new_player.client in active_listeners))
		active_listeners |= new_player.client
		start_playing(list(new_player.client))

/obj/machinery/cassette/dj_station/proc/next_song()
	waiting_for_yield = TRUE
	var/choice = tgui_input_number(usr, "Choose which song number to play.", "[src]", 1, length(current_playlist), 1)
	if(!choice)
		waiting_for_yield = FALSE
		stop_broadcast()
		return
	GLOB.dj_broadcast = TRUE
	pl_index = choice

	pl_index++
	start_playing(active_listeners)
