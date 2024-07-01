/obj/machinery/cassette/adv_cassette_deck
	name = "Advanced Cassette Deck"
	desc = "A more advanced less portable Cassette Deck. Useful for recording songs from our generation, or customizing the style of your cassettes."
	icon ='monkestation/code/modules/cassettes/icons/adv_cassette_deck.dmi'
	icon_state = "cassette_deck"
	density = TRUE
	pass_flags = PASSTABLE
	///cassette tape used in adding songs or customizing
	var/obj/item/device/cassette_tape/tape
	///Selection used to remove songs
	var/selection

/obj/machinery/cassette/adv_cassette_deck/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)

/obj/machinery/cassette/adv_cassette_deck/wrench_act(mob/living/user, obj/item/wrench)
	..()
	default_unfasten_wrench(user, wrench, 15)
	return TRUE

/obj/machinery/cassette/adv_cassette_deck/attackby(obj/item/cassette, mob/user)
	if(!istype(cassette, /obj/item/device/cassette_tape))
		return ..()
	if(!tape)
		insert_tape(cassette)
		playsound(src,'sound/weapons/handcuffs.ogg',20,1)
		to_chat(user,"You insert \the [cassette] into \the [src]")
	else
		to_chat(user,"Remove a tape first!")

/obj/machinery/cassette/adv_cassette_deck/proc/insert_tape(obj/item/device/cassette_tape/CTape)
	if(tape || !istype(CTape))
		return
	tape = CTape
	CTape.forceMove(src)

/obj/machinery/cassette/adv_cassette_deck/proc/eject_tape(mob/user)
	if(!tape)
		return
	user.put_in_hands(tape)
	tape = null

/obj/machinery/cassette/adv_cassette_deck/ui_status(mob/user)
	if(!anchored)
		to_chat(user,"<span class='warning'>This device must be anchored by a wrench!</span>")
		return UI_CLOSE
	if(!allowed(user) && !isobserver(user))
		to_chat(user,"<span class='warning'>Error: Access Denied.</span>")
		user.playsound_local(src, 'sound/misc/compiler-failure.ogg', 25, TRUE)
		return UI_CLOSE
	return ..()

/obj/machinery/cassette/adv_cassette_deck/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteDeck", name)
		ui.open()

/obj/machinery/cassette/adv_cassette_deck/ui_data(mob/user)
	///all data for the tgui
	var/list/data = list()
	data["songs"] = list()
	if(tape)
		var/text = "[tape.flipped ? "side2" : "side1"]"
		for(var/song_name in tape.song_names["[text]"])
			data["songs"] += song_name
	data["track_selected"] = null
	if(selection)
		data["track_selected"] = selection
	return data

/obj/machinery/cassette/adv_cassette_deck/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("remove")
			if(!tape)
				return
			var/text = "[tape.flipped ? "side2" : "side1"]"
			var/list/found_list = tape.song_names["[text]"]
			var/number = found_list.Find(selection)
			tape.song_names["[text]"] -= tape.song_names["[text]"][number]
			tape.songs["[text]"] -= tape.songs["[text]"][number]

		if("select_track")
			selection = params["track"]
			return TRUE
		if("eject")
			if(!tape)
				to_chat(usr,"Error: No Cassette Inserted Please Insert a Cassette!")
				return
			eject_tape(usr)
			return
		if("url")
			///the input of the videos ID
			var/url = stripped_input(usr, "Insert the ID of the video in question (characters after the =):", no_trim = TRUE)
			var/list/data
			///the REGEX used for determining if its a valid ID or not
			var/static/regex/link_check = regex(@"^[a-zA-Z0-9_.-]{11}$")
			if(!link_check.Find(url))
				to_chat(usr, "Error: Bad ID!")
				return
			///The Finished url to add to the song list
			var/url_stuck = "https://www.youtube.com/watch?v=[url]"
			///invoking youtube-dl
			var/ytdl = CONFIG_GET(string/invoke_youtubedl)
			/// all the extra data youtube-dl gives us we are only interested in the title however
			var/list/music_extra_data = list()
			///trimming the url to prevent any missed errors
			var/url2 = trim(url_stuck)
			if(!(url2 in GLOB.parsed_audio))
				///scrub the url before passing it through a shell
				var/shell_scrubbed_input = shell_url_scrub(url2)
				///the command being sent to the shell after being scrubbed
				var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height <= 360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
				///any errors
				var/errorlevel = output[SHELLEO_ERRORLEVEL]
				///the standard output
				var/stdout = output[SHELLEO_STDOUT]
				if(!errorlevel)
					try
						data = json_decode(stdout)
					catch(var/exception/error) /// any errors are caught here
						CRASH("<span class='warning'>[error]: [stdout]</span>")
					if (data["url"])
						music_extra_data["title"] = data["title"]
					GLOB.parsed_audio["[url2]"] = data
			else
				data = GLOB.parsed_audio["[url2]"]

			if(tape.flipped == FALSE)
				if(length(tape.songs["side1"]) >= 7)
					return
				tape.songs["side1"] += url_stuck
				tape.song_names["side1"] += data["title"]
			else
				if(length(tape.songs["side2"]) >= 7)
					return
				tape.songs["side2"] += url_stuck
				tape.song_names["side2"] += data["title"]
			to_chat(usr, span_notice("The [src] makes a clicking noise as the song is added to the cassette."))
			tape.approved_tape = FALSE
			if(ishuman(usr))
				var/mob/living/carbon/human/user = usr
				tape.author_name = user.real_name
				tape.ckey_author = user.client?.ckey
			tape.update_appearance()

			playsound(src,'sound/weapons/handcuffs.ogg',20,1)

		if("design")
			if(!tape)
				to_chat(usr,"Error: No Cassette Inserted Please Insert a Cassette!")
				return
			///design paths for the designer used to add a sticker to cassettes
			var/list/design_path = list("cassette_flip",\
								"cassette_blue",\
								"cassette_gray",\
								"cassette_green",\
								"cassette_orange",\
								"cassette_pink_stripe",\
								"cassette_purple",\
								"cassette_rainbow",\
								"cassette_red_black",\
								"cassette_red_stripe",\
								"cassette_camo",\
								"cassette_rising_sun",\
								"cassette_ocean",\
								"cassette_aesthetic",)
			///design names for the tgui so its not ugly
			var/list/design_names = list("Blank Cassette",
							"Blue Sticker",\
							"Gray Sticker",\
							"Green Sticker",\
							"Orange Sticker",\
							"Pink Stripped Sticker",\
							"Purple Sticker",\
							"Rainbow Sticker",\
							"Red and Black Sticker",\
							"Red Stripped Sticker",\
							"Camo Sticker",\
							"Rising Sun Sticker",\
							"Ocean Sticker",\
							"Aesthetic Sticker")
			///the input list to choose which sticker to add to the cassette
			var/selection = tgui_input_list(usr, "Choose Your Sticker", "Advanced Cassette Deck", design_names)
			if(tape.flipped == FALSE)
				tape.icon_state = design_path[design_names.Find(selection)]
				tape.side1_icon = design_path[design_names.Find(selection)]
			else
				tape.icon_state = design_path[design_names.Find(selection)]
				tape.side2_icon = design_path[design_names.Find(selection)]
