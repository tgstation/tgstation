/obj/machinery/jukebox
	name = "jukebox"
	desc = "A classic music player."
	icon = 'icons/obj/machines/music.dmi'
	icon_state = "jukebox"
	base_icon_state = "jukebox"
	verb_say = "states"
	density = TRUE
	req_access = list(ACCESS_BAR)
	processing_flags = START_PROCESSING_MANUALLY
	/// Cooldown between "Error" sound effects being played
	COOLDOWN_DECLARE(jukebox_error_cd)
	/// Cooldown between being allowed to play another song
	COOLDOWN_DECLARE(jukebox_song_cd)
	/// TimerID to when the current song ends
	var/song_timerid
	/// The actual music player datum that handles the music
	var/datum/jukebox/music_player

/obj/machinery/jukebox/Initialize(mapload)
	. = ..()
	music_player = new(src)

/obj/machinery/jukebox/Destroy()
	stop_music()
	QDEL_NULL(music_player)
	return ..()

/obj/machinery/jukebox/examine(mob/user)
	. = ..()
	if(music_player.active_song_sound)
		. += "Now playing: [music_player.selection.song_name]"

/obj/machinery/jukebox/no_access
	req_access = null

/obj/machinery/jukebox/wrench_act(mob/living/user, obj/item/tool)
	if(!isnull(music_player.active_song_sound))
		return NONE

	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_BLOCKING

/obj/machinery/jukebox/update_icon_state()
	icon_state = "[base_icon_state][music_player.active_song_sound ? "-active" : null]"
	return ..()

/obj/machinery/jukebox/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return ..()
	if(!anchored)
		to_chat(user,span_warning("This device must be anchored by a wrench!"))
		return UI_CLOSE
	if(!allowed(user))
		to_chat(user,span_warning("Error: Access Denied."))
		user.playsound_local(src, 'sound/machines/compiler/compiler-failure.ogg', 25, TRUE)
		return UI_CLOSE
	if(!length(music_player.songs))
		to_chat(user,span_warning("Error: No music tracks have been authorized for your station. Petition Central Command to resolve this issue."))
		user.playsound_local(src, 'sound/machines/compiler/compiler-failure.ogg', 25, TRUE)
		return UI_CLOSE
	return ..()

/obj/machinery/jukebox/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Jukebox", name)
		ui.open()

/obj/machinery/jukebox/ui_data(mob/user)
	return music_player.get_ui_data()

/obj/machinery/jukebox/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			if(isnull(music_player.active_song_sound))
				if(!COOLDOWN_FINISHED(src, jukebox_song_cd))
					to_chat(usr, span_warning("Error: The device is still resetting from the last activation, \
						it will be ready again in [DisplayTimeText(COOLDOWN_TIMELEFT(src, jukebox_song_cd))]."))
					if(COOLDOWN_FINISHED(src, jukebox_error_cd))
						playsound(src, 'sound/machines/compiler/compiler-failure.ogg', 33, TRUE)
						COOLDOWN_START(src, jukebox_error_cd, 15 SECONDS)
					return TRUE

				activate_music()
			else
				stop_music()

			return TRUE

		if("select_track")
			if(!isnull(music_player.active_song_sound))
				to_chat(usr, span_warning("Error: You cannot change the song until the current one is over."))
				return TRUE

			var/datum/track/new_song = music_player.songs[params["track"]]
			if(QDELETED(src) || !istype(new_song, /datum/track))
				return TRUE

			music_player.selection = new_song
			return TRUE

		if("set_volume")
			var/new_volume = params["volume"]
			if(new_volume == "reset" || new_volume == "max")
				music_player.set_volume_to_max()
			else if(new_volume == "min")
				music_player.set_new_volume(0)
			else if(isnum(text2num(new_volume)))
				music_player.set_new_volume(text2num(new_volume))
			return TRUE

		if("loop")
			music_player.sound_loops = !!params["looping"]
			return TRUE

/obj/machinery/jukebox/proc/activate_music()
	if(!isnull(music_player.active_song_sound))
		return FALSE

	music_player.start_music()
	update_use_power(ACTIVE_POWER_USE)
	update_appearance(UPDATE_ICON_STATE)
	if(!music_player.sound_loops)
		song_timerid = addtimer(CALLBACK(src, PROC_REF(stop_music)), music_player.selection.song_length, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)
	return TRUE

/obj/machinery/jukebox/proc/stop_music()
	if(!isnull(song_timerid))
		deltimer(song_timerid)

	music_player.unlisten_all()

	if(!QDELING(src))
		COOLDOWN_START(src, jukebox_song_cd, 10 SECONDS)
		playsound(src,'sound/machines/terminal/terminal_off.ogg',50,TRUE)
		update_use_power(IDLE_POWER_USE)
		update_appearance(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/jukebox/on_set_is_operational(old_value)
	if(!is_operational)
		stop_music()

/obj/machinery/jukebox/disco
	name = "radiant dance machine mark IV"
	desc = "The first three prototypes were discontinued after mass casualty incidents."
	icon_state = "disco"
	base_icon_state = "disco"
	req_access = list(ACCESS_ENGINEERING)
	anchored = FALSE

	/// Spotlight effects being played
	VAR_PRIVATE/list/obj/item/flashlight/spotlight/spotlights = list()
	/// Sparkle effects being played
	VAR_PRIVATE/list/obj/effect/overlay/sparkles/sparkles = list()

/obj/machinery/jukebox/disco/indestructible
	name = "radiant dance machine mark V"
	desc = "Now redesigned with data gathered from the extensive disco and plasma research."
	req_access = null
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/jukebox/disco/activate_music()
	. = ..()
	if(!.)
		return
	dance_setup()
	lights_spin()
	begin_processing()

/obj/machinery/jukebox/disco/stop_music()
	. = ..()
	if(!.)
		return
	QDEL_LIST(spotlights)
	QDEL_LIST(sparkles)
	end_processing()

/obj/machinery/jukebox/disco/process()
	var/dance_num = rand(1, 4) //all will do the same dance
	for(var/mob/living/dancer in music_player.get_active_listeners())
		if(!(dancer.mobility_flags & MOBILITY_MOVE))
			continue
		if(HAS_TRAIT(dancer, TRAIT_DISCO_DANCER))
			continue
		dance(dancer, dance_num)

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
		if(QDELETED(src) || isnull(music_player.active_song_sound))
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
	while(!isnull(music_player.active_song_sound))
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
		sleep(music_player.selection.song_beat)
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
