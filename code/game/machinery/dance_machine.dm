/// Helper macro to check if the passed mob has jukebox sound preference enabled
#define HAS_JUKEBOX_PREF(mob) (!QDELETED(mob) && !isnull(mob.client) && mob.client.prefs.read_preference(/datum/preference/toggle/sound_jukebox))

/obj/machinery/jukebox
	name = "jukebox"
	desc = "A classic music player."
	icon = 'icons/obj/machines/music.dmi'
	icon_state = "jukebox"
	verb_say = "states"
	density = TRUE
	req_access = list(ACCESS_BAR)
	/// Whether we're actively playing music
	VAR_PRIVATE/active = FALSE
	// /// List of weakrefs to mobs listening to the current song
	// var/list/datum/weakref/rangers = list()
	/// World.time when the current song will stop playing, but also a cooldown between activations
	VAR_PRIVATE/stop = 0
	/// List of /datum/tracks we can play
	/// Inited from config every time a jukebox is instantiated
	var/list/songs = list()
	/// Current song selected
	VAR_PRIVATE/datum/track/selection = null
	/// Volume of the songs played
	var/volume = 50
	/// Cooldown between "Error" sound effects being played
	COOLDOWN_DECLARE(jukebox_error_cd)

	var/dance = TRUE

/obj/machinery/jukebox/disco
	name = "radiant dance machine mark IV"
	desc = "The first three prototypes were discontinued after mass casualty incidents."
	icon_state = "disco"
	req_access = list(ACCESS_ENGINEERING)
	anchored = FALSE

	var/list/spotlights = list()
	var/list/sparkles = list()

/obj/machinery/jukebox/disco/indestructible
	name = "radiant dance machine mark V"
	desc = "Now redesigned with data gathered from the extensive disco and plasma research."
	req_access = null
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	obj_flags = /obj::obj_flags | NO_DECONSTRUCTION

/datum/track
	var/song_name = "generic"
	var/song_path = null
	var/song_length = 0
	var/song_beat = 0

/datum/track/default
	song_path = 'sound/ambience/title3.ogg'
	song_name = "Tintin on the Moon"
	song_length = 3 MINUTES + 52 SECONDS
	song_beat = 1 SECONDS

/obj/machinery/jukebox/Initialize(mapload)
	. = ..()
	songs = load_songs_from_config()
	if(length(songs))
		selection = pick(songs)

/// Loads the config sounds once, and returns a copy of them.
/obj/machinery/jukebox/proc/load_songs_from_config()
	var/static/list/config_songs
	if(isnull(config_songs))
		config_songs = list()
		var/list/tracks = flist("[global.config.directory]/jukebox_music/sounds/")
		for(var/track_file in tracks)
			var/datum/track/new_track = new()
			new_track.song_path = file("[global.config.directory]/jukebox_music/sounds/[track_file]")
			var/list/track_data = splittext(track_file, "+")
			if(length(track_data) != 3)
				continue
			new_track.song_name = track_data[1]
			new_track.song_length = text2num(track_data[2])
			new_track.song_beat = text2num(track_data[3])
			config_songs += new_track

		if(!length(config_songs))
			// Includes title3 as a default for testing / "no config" support, also because it's a banger
			config_songs += new /datum/track/default()

	// returns a copy so it can mutate if desired.
	return config_songs.Copy()

/obj/machinery/jukebox/Destroy()
	dance_over()
	selection = null
	songs.Cut()
	return ..()

/obj/machinery/jukebox/attackby(obj/item/O, mob/user, params)
	if(!active && !(obj_flags & NO_DECONSTRUCTION))
		if(O.tool_behaviour == TOOL_WRENCH)
			if(!anchored && !isinspace())
				to_chat(user,span_notice("You secure [src] to the floor."))
				set_anchored(TRUE)
			else if(anchored)
				to_chat(user,span_notice("You unsecure and disconnect [src]."))
				set_anchored(FALSE)
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			return
	return ..()

/obj/machinery/jukebox/update_icon_state()
	icon_state = "[initial(icon_state)][active ? "-active" : null]"
	return ..()

/obj/machinery/jukebox/ui_status(mob/user)
	if(!anchored)
		to_chat(user,span_warning("This device must be anchored by a wrench!"))
		return UI_CLOSE
	if(!allowed(user) && !isobserver(user))
		to_chat(user,span_warning("Error: Access Denied."))
		user.playsound_local(src, 'sound/misc/compiler-failure.ogg', 25, TRUE)
		return UI_CLOSE
	if(!songs.len && !isobserver(user))
		to_chat(user,span_warning("Error: No music tracks have been authorized for your station. Petition Central Command to resolve this issue."))
		user.playsound_local(src, 'sound/misc/compiler-failure.ogg', 25, TRUE)
		return UI_CLOSE
	return ..()

/obj/machinery/jukebox/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Jukebox", name)
		ui.open()

/obj/machinery/jukebox/ui_data(mob/user)
	var/list/data = list()
	data["active"] = active
	data["songs"] = list()
	for(var/datum/track/S in songs)
		var/list/track_data = list(
			name = S.song_name
		)
		data["songs"] += list(track_data)
	data["track_selected"] = selection ? selection.song_name : null
	data["track_length"] = selection ? DisplayTimeText(selection.song_length) : null
	data["track_beat"] = selection ? selection.song_beat : null
	data["volume"] = volume
	return data

/obj/machinery/jukebox/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			if(QDELETED(src))
				return
			if(!active)
				if(stop > world.time)
					to_chat(usr, span_warning("Error: The device is still resetting from the last activation, it will be ready again in [DisplayTimeText(stop-world.time)]."))
					if(!COOLDOWN_FINISHED(src, jukebox_error_cd))
						return
					playsound(src, 'sound/misc/compiler-failure.ogg', 50, TRUE)
					COOLDOWN_START(src, jukebox_error_cd, 15 SECONDS)
					return
				activate_music()
				START_PROCESSING(SSobj, src)
				return TRUE
			else
				stop = 0
				return TRUE

		if("select_track")
			if(active)
				to_chat(usr, span_warning("Error: You cannot change the song until the current one is over."))
				return
			var/list/available = list()
			for(var/datum/track/S in songs)
				available[S.song_name] = S
			var/selected = params["track"]
			if(QDELETED(src) || !selected || !istype(available[selected], /datum/track))
				return
			selection = available[selected]
			return TRUE

		if("set_volume")
			var/new_volume = params["volume"]
			if(new_volume == "reset")
				set_new_volume(initial(volume))
				return TRUE
			else if(new_volume == "min")
				set_new_volume(0)
				return TRUE
			else if(new_volume == "max")
				set_new_volume(initial(volume))
				return TRUE
			else if(isnum(text2num(new_volume)))
				set_new_volume(text2num(new_volume))
				return TRUE

/obj/machinery/jukebox/proc/set_new_volume(new_vol)
	new_vol = clamp(new_vol, 0, 50)
	if(volume == new_vol)
		return
	volume = new_vol
	if(!active || !active_song_sound)
		return
	active_song_sound = volume
	for(var/mob/listening as anything in listeners)
		update_listener(listening)

/obj/machinery/jukebox/proc/proc/set_new_environment(new_env)
	if(!active || !active_song_sound || active_song_sound.environment == new_env)
		return
	active_song_sound.environment = new_env
	for(var/mob/listening as anything in listeners)
		update_listener(listening)

/obj/machinery/jukebox/proc/activate_music()
	active = TRUE
	update_use_power(ACTIVE_POWER_USE)
	update_appearance(UPDATE_ICON_STATE)
	START_PROCESSING(SSobj, src)
	stop = world.time + selection.song_length
	for(var/mob/nearby in hearers(world.view, src))
		register_listener(nearby)


/obj/machinery/jukebox/disco/activate_music()
	..()
	dance_setup()
	lights_spin()

/obj/machinery/jukebox/disco/proc/dance_setup()
	var/turf/cen = get_turf(src)
	FOR_DVIEW(var/turf/t, 3, get_turf(src),INVISIBILITY_LIGHTING)
		if(t.x == cen.x && t.y > cen.y)
			spotlights += new /obj/item/flashlight/spotlight(t, 1 + get_dist(src, t), 30 - (get_dist(src, t) * 8), COLOR_SOFT_RED)
			continue
		if(t.x == cen.x && t.y < cen.y)
			spotlights += new /obj/item/flashlight/spotlight(t, 1 + get_dist(src, t), 30 - (get_dist(src, t) * 8), LIGHT_COLOR_PURPLE)
			continue
		if(t.x > cen.x && t.y == cen.y)
			spotlights += new /obj/item/flashlight/spotlight(t, 1 + get_dist(src, t), 30 - (get_dist(src, t) * 8), LIGHT_COLOR_DIM_YELLOW)
			continue
		if(t.x < cen.x && t.y == cen.y)
			spotlights += new /obj/item/flashlight/spotlight(t, 1 + get_dist(src, t), 30 - (get_dist(src, t) * 8), LIGHT_COLOR_GREEN)
			continue
		if((t.x+1 == cen.x && t.y+1 == cen.y) || (t.x+2 == cen.x && t.y+2 == cen.y))
			spotlights += new /obj/item/flashlight/spotlight(t, 1.4 + get_dist(src, t), 30 - (get_dist(src, t) * 8), LIGHT_COLOR_ORANGE)
			continue
		if((t.x-1 == cen.x && t.y-1 == cen.y) || (t.x-2 == cen.x && t.y-2 == cen.y))
			spotlights += new /obj/item/flashlight/spotlight(t, 1.4 + get_dist(src, t), 30 - (get_dist(src, t) * 8), LIGHT_COLOR_CYAN)
			continue
		if((t.x-1 == cen.x && t.y+1 == cen.y) || (t.x-2 == cen.x && t.y+2 == cen.y))
			spotlights += new /obj/item/flashlight/spotlight(t, 1.4 + get_dist(src, t), 30 - (get_dist(src, t) * 8), LIGHT_COLOR_BLUEGREEN)
			continue
		if((t.x+1 == cen.x && t.y-1 == cen.y) || (t.x+2 == cen.x && t.y-2 == cen.y))
			spotlights += new /obj/item/flashlight/spotlight(t, 1.4 + get_dist(src, t), 30 - (get_dist(src, t) * 8), LIGHT_COLOR_BLUE)
			continue
		continue
	FOR_DVIEW_END

/obj/machinery/jukebox/disco/proc/hierofunk()
	for(var/i in 1 to 10)
		spawn_atom_to_turf(/obj/effect/temp_visual/hierophant/telegraph/edge, src, 1, FALSE)
		sleep(0.5 SECONDS)

#define DISCO_INFENO_RANGE (rand(85, 115)*0.01)

/obj/machinery/jukebox/disco/proc/lights_spin()
	for(var/i in 1 to 25)
		if(QDELETED(src) || !active)
			return
		var/obj/effect/overlay/sparkles/S = new /obj/effect/overlay/sparkles(src)
		S.alpha = 0
		sparkles += S
		switch(i)
			if(1 to 8)
				S.orbit(src, 30, TRUE, 60, 36, TRUE)
			if(9 to 16)
				S.orbit(src, 62, TRUE, 60, 36, TRUE)
			if(17 to 24)
				S.orbit(src, 95, TRUE, 60, 36, TRUE)
			if(25)
				S.pixel_y = 7
				S.forceMove(get_turf(src))
		sleep(0.7 SECONDS)
	for(var/s in sparkles)
		var/obj/effect/overlay/sparkles/reveal = s
		reveal.alpha = 255
	while(active)
		for(var/g in spotlights) // The multiples reflects custom adjustments to each colors after dozens of tests
			var/obj/item/flashlight/spotlight/glow = g
			if(QDELETED(glow))
				stack_trace("[glow?.gc_destroyed ? "Qdeleting glow" : "null entry"] found in [src].[gc_destroyed ? " Source qdeleting at the time." : ""]")
				return
			switch(glow.light_color)
				if(COLOR_SOFT_RED)
					if(glow.even_cycle)
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_BLUE)
					else
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 1.48, LIGHT_COLOR_BLUE)
						glow.set_light_on(TRUE)
				if(LIGHT_COLOR_BLUE)
					if(glow.even_cycle)
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 2, LIGHT_COLOR_GREEN)
						glow.set_light_on(TRUE)
					else
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_GREEN)
				if(LIGHT_COLOR_GREEN)
					if(glow.even_cycle)
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_ORANGE)
					else
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 0.5, LIGHT_COLOR_ORANGE)
						glow.set_light_on(TRUE)
				if(LIGHT_COLOR_ORANGE)
					if(glow.even_cycle)
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 2.27, LIGHT_COLOR_PURPLE)
						glow.set_light_on(TRUE)
					else
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_PURPLE)
				if(LIGHT_COLOR_PURPLE)
					if(glow.even_cycle)
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_BLUEGREEN)
					else
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 0.44, LIGHT_COLOR_BLUEGREEN)
						glow.set_light_on(TRUE)
				if(LIGHT_COLOR_BLUEGREEN)
					if(glow.even_cycle)
						glow.set_light_range(glow.base_light_range * DISCO_INFENO_RANGE)
						glow.set_light_color(LIGHT_COLOR_DIM_YELLOW)
						glow.set_light_on(TRUE)
					else
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_DIM_YELLOW)
				if(LIGHT_COLOR_DIM_YELLOW)
					if(glow.even_cycle)
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_CYAN)
					else
						glow.set_light_range(glow.base_light_range * DISCO_INFENO_RANGE)
						glow.set_light_color(LIGHT_COLOR_CYAN)
						glow.set_light_on(TRUE)
				if(LIGHT_COLOR_CYAN)
					if(glow.even_cycle)
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 0.68, COLOR_SOFT_RED)
						glow.set_light_on(TRUE)
					else
						glow.set_light_on(FALSE)
						glow.set_light_color(COLOR_SOFT_RED)
					glow.even_cycle = !glow.even_cycle
		if(prob(2))  // Unique effects for the dance floor that show up randomly to mix things up
			INVOKE_ASYNC(src, PROC_REF(hierofunk))
		sleep(selection.song_beat)
		if(QDELETED(src))
			return

#undef DISCO_INFENO_RANGE

/obj/machinery/jukebox/disco/proc/dance(mob/living/dancer, dance_num) //Show your moves
	ADD_TRAIT(dancer, TRAIT_DISCO_DANCER, REF(src))
	switch(dance_num)
		if(1)
			dance1(dancer)
		if(2)
			dance2(dancer)
		if(3)
			start_dance3(dancer)
		if(4)
			dance4(dancer)

/mob/proc/dance_flip()
	if(dir == WEST)
		emote("flip")

/obj/machinery/jukebox/disco/proc/dance1(mob/living/dancer)
	addtimer(TRAIT_CALLBACK_REMOVE(dancer, TRAIT_DISCO_DANCER, REF(src)), 6.5 SECONDS, TIMER_CLIENT_TIME)
	for(var/i in 0 to (6 SECONDS) step (1.5 SECONDS))
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dance_rotate), dancer, CALLBACK(dancer, TYPE_PROC_REF(/mob, dance_flip))), i, TIMER_CLIENT_TIME)

/obj/machinery/jukebox/disco/proc/dance2(mob/living/dancer, dance_length = 2.5 SECONDS)
	var/matrix/initial_matrix = matrix(dancer.transform)
	var/list/transforms = list(
		"[NORTH]" = matrix(dancer.transform).Translate(0, 3),
		"[EAST]" = matrix(dancer.transform).Translate(3, 0),
		"[SOUTH]" = matrix(dancer.transform).Translate(0, -3),
		"[WEST]" = matrix(dancer.transform).Translate(-1, -1),
	)
	addtimer(VARSET_CALLBACK(dancer, transform, initial_matrix), dance_length + 0.5 SECONDS, TIMER_CLIENT_TIME)
	addtimer(TRAIT_CALLBACK_REMOVE(dancer, TRAIT_DISCO_DANCER, REF(src)), dance_length + 0.5 SECONDS)
	for (var/i in 1 to dance_length)
		addtimer(CALLBACK(src, PROC_REF(animate_dance2), dancer, transforms, initial_matrix), i, TIMER_CLIENT_TIME)

/obj/machinery/jukebox/disco/proc/animate_dance2(mob/living/dancer, list/transforms, matrix/initial_matrix)
	dancer.setDir(turn(dancer.dir, 90))
	animate(dancer, transform = transforms[num2text(dancer.dir)], time = 1, loop = 0)
	animate(transform = initial_matrix, time = 2, loop = 0)

/obj/machinery/jukebox/disco/proc/start_dance3(mob/living/dancer, dance_length = 3 SECONDS)
	var/initially_resting = dancer.resting
	var/direction_index = 1 //this should allow everyone to dance in the same direction
	addtimer(TRAIT_CALLBACK_REMOVE(dancer, TRAIT_DISCO_DANCER, REF(src)), dance_length + 0.2 SECONDS)
	addtimer(CALLBACK(dancer, TYPE_PROC_REF(/mob/living, set_resting), initially_resting, TRUE, TRUE), dance_length + 0.2 SECONDS, TIMER_CLIENT_TIME)
	for (var/i in 1 to dance_length step 2) // 1 = 0.1 seconds
		addtimer(CALLBACK(src, PROC_REF(dance3), dancer, GLOB.cardinals[direction_index]), i, TIMER_CLIENT_TIME)
		direction_index++
		if(direction_index > GLOB.cardinals.len)
			direction_index = 1

/obj/machinery/jukebox/disco/proc/dance3(mob/living/dancer, dir)
	dancer.setDir(dir)
	dancer.set_resting(!dancer.resting, silent = TRUE, instant = TRUE)

/obj/machinery/jukebox/disco/proc/dance4(mob/living/dancer, dance_length = 1.5 SECONDS)
	var/matrix/initial_matrix = matrix(dancer.transform)
	animate(dancer, transform = matrix(dancer.transform).Turn(180), time = 2, loop = 0)
	dancer.emote("spin")
	addtimer(CALLBACK(src, PROC_REF(dance4_revert), dancer, initial_matrix), dance_length, TIMER_CLIENT_TIME)

/obj/machinery/jukebox/disco/proc/dance4_revert(mob/living/dancer, matrix/starting_matrix)
	animate(dancer, transform = starting_matrix, time = 5, loop = 0)
	REMOVE_TRAIT(dancer, TRAIT_DISCO_DANCER, REF(src))

/obj/machinery/jukebox/proc/dance_over()
	for(var/mob/listening as anything in listeners)
		deregister_listener(listening)
	active_song_sound = null

/obj/machinery/jukebox/disco/dance_over()
	..()
	QDEL_LIST(spotlights)
	QDEL_LIST(sparkles)

/obj/machinery/jukebox/process()
	if(world.time >= stop && active)
		active = FALSE
		update_use_power(IDLE_POWER_USE)
		dance_over()
		playsound(src,'sound/machines/terminal_off.ogg',50,TRUE)
		update_appearance(UPDATE_ICON_STATE)
		stop = world.time + 100
		return PROCESS_KILL

	if(!active)
		return PROCESS_KILL

	for(var/mob/nearby in hearers(world.view, src) - listeners)
		register_listener(nearby)

/obj/machinery/jukebox/disco/process()
	. = ..()
	if(!active || !dance)
		return

	// var/dance_num = rand(1,4) //all will do the same dance
	// for(var/datum/weakref/weak_dancer as anything in rangers)
	// 	var/mob/living/to_dance = weak_dancer.resolve()
	// 	if(!istype(to_dance) || !(to_dance.mobility_flags & MOBILITY_MOVE))
	// 		continue
	// 	if(!HAS_TRAIT(to_dance, TRAIT_DISCO_DANCER))
	// 		dance(to_dance, dance_num)

#undef HAS_JUKEBOX_PREF

/obj/machinery/jukebox
	VAR_PRIVATE/list/mob/listeners = list()
	VAR_PRIVATE/sound/active_song_sound
	VAR_PRIVATE/x_cutoff
	VAR_PRIVATE/z_cutoff

/obj/machinery/jukebox/Initialize(mapload)
	. = ..()
	var/list/worldviewsize = getviewsize(world.view)
	x_cutoff = ceil(worldviewsize[1] / 2)
	z_cutoff = ceil(worldviewsize[2] / 2)

/obj/machinery/jukebox/Destroy()
	for(var/mob/leftover as anything in listeners)
		deregister_listener(leftover)
	return ..()

/obj/machinery/jukebox/proc/register_listener(mob/new_listener)
	listeners[new_listener] = NONE

	RegisterSignal(new_listener, COMSIG_QDELETING, PROC_REF(listener_deleted))
	RegisterSignal(new_listener, COMSIG_MOVABLE_MOVED, PROC_REF(listener_moved))

	if(isnull(new_listener.client))
		RegisterSignal(new_listener, COMSIG_MOB_LOGIN, PROC_REF(listener_login))

	else
		update_listener(new_listener)
		// if you have a sound with status SOUND_UPDATE,
		// and try to play it to a client who is not listening to the sound already,
		// it will not work.
		// so we only add this status AFTER the first update, which plays the first sound.
		// and after that it's fine to keep it on the sound so it updates as the x/z does.
		listeners[new_listener] |= SOUND_UPDATE

/obj/machinery/jukebox/proc/listener_deleted(mob/source)
	SIGNAL_HANDLER
	deregister_listener(source)

/obj/machinery/jukebox/proc/listener_moved(mob/source)
	SIGNAL_HANDLER
	update_listener(source)

/obj/machinery/jukebox/proc/listener_login(mob/source)
	SIGNAL_HANDLER
	register_listener(source)

/obj/machinery/jukebox/proc/deregister_listener(mob/no_longer_listening)
	listeners -= no_longer_listening
	no_longer_listening.stop_sound_channel(CHANNEL_JUKEBOX)
	UnregisterSignal(no_longer_listening, list(COMSIG_MOB_LOGIN, COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))

/obj/machinery/jukebox/proc/update_listener(mob/listener)
	if(isnull(active_song_sound))
		var/area/juke_area = get_area(src)
		active_song_sound = sound(selection.song_path)
		active_song_sound.channel = CHANNEL_JUKEBOX
		active_song_sound.priority = 255
		active_song_sound.falloff = 2
		active_song_sound.volume = volume
		active_song_sound.y = 1
		active_song_sound.environment = juke_area.sound_environment || SOUND_ENVIRONMENT_NONE

	active_song_sound.status = listeners[listener] || NONE

	var/new_x = src.x - listener.x
	var/new_z = src.y - listener.y

	if(abs(new_x) > x_cutoff || abs(new_z) > z_cutoff)
		deregister_listener(listener)
		return

	// if(!listerner.can_hear() || !listener.client.prefs.read_preference(/datum/preference/toggle/sound_jukebox))
	// 	active_song_sound.status |= SOUND_MUTE
	// else
	// 	active_song_sound.status &= ~SOUND_MUTE

	// keep in mind sound XYZ is different to world XYZ. sound +-z = world +-y
	active_song_sound.x = new_x
	active_song_sound.z = new_z

	SEND_SOUND(listener, active_song_sound)

/obj/machinery/jukebox/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!active)
		return
	for(var/mob/listening as anything in listeners)
		update_listener(listening)

/obj/machinery/jukebox/on_enter_area(datum/source, area/area_to_register)
	. = ..()
	set_new_environment(area_to_register.sound_environment || SOUND_ENVIRONMENT_NONE)
