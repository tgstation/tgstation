
/datum/anvil_challenge
	/// When the ui minigame phase started
	var/start_time
	/// Is it finished (either by win/lose or window closing)
	var/completed = FALSE
	///the smithing mob
	var/mob/user
	/// Background icon state from anvil_game.dmi
	var/background = "background_default"
	/// list of the clicks needed aswell as the world timings
	var/list/anvil_presses = list()
	/// A secondary list of our notes with how many pixels they have moved
	var/list/note_pixels_moved = list()
	///The background as shown in the minigame, and the holder of the other visual overlays
	var/atom/movable/screen/anvil_hud/anvil_hud
	///the output portion of the anvil
	var/datum/anvil_recipe/selected_recipe
	///our anvil object
	var/obj/structure/anvil/host_anvil
	///the difficulty of the recipe
	var/difficulty = 1
	///overall success
	var/success = 100
	///our total off time
	var/off_time = 0
	///our notes left to make
	var/notes_left = 0
	///our total notes
	var/total_notes = 0
	///failed notes
	var/failed_notes = 0
	///do we debug?
	var/debug = FALSE
	///our clients average ping
	var/average_ping = 0

/datum/anvil_challenge/New(obj/structure/anvil/anvil, datum/anvil_recipe/end_product_recipe, mob/user, difficulty_modifier)
	host_anvil = anvil
	src.user = user
	selected_recipe = end_product_recipe

	//RegisterSignal(host_anvil, COMSIG_QDELETING, PROC_REF(on_anvil_deletion))

	notes_left = end_product_recipe.total_notes
	total_notes = end_product_recipe.total_notes

	difficulty = round(selected_recipe.difficulty + difficulty_modifier)

	generate_anvil_beats(TRUE)

	if(!user.client || user.incapacitated())
		return FALSE
	. = TRUE
	anvil_hud = new
	anvil_hud.prepare_minigame(src, anvil_presses)
	RegisterSignal(user.client, COMSIG_CLIENT_CLICK_DIRTY, PROC_REF(check_click))

	START_PROCESSING(SSfishing, src)

/datum/anvil_challenge/proc/generate_anvil_beats(init = FALSE)
	var/list/new_notes = list()

	var/last_note_time = REALTIMEOFDAY + 1 SECONDS
	for(var/i = 1 to min(rand(1,5), notes_left))
		notes_left--
		var/atom/movable/screen/hud_note/hud_note = new(null, null, src)
		var/time = rand(5, 10)
		if(difficulty >= 6)
			time /= round((difficulty - 4) * 0.5)
		hud_note.generate_click_type(difficulty)
		hud_note.pixel_x += 138 // we start 40 units back and move towards the end
		anvil_presses += hud_note
		anvil_presses[hud_note] = last_note_time + time

		if(debug)
			hud_note.maptext = "[last_note_time + time] - 170"
		last_note_time += time

		animate(hud_note, last_note_time - REALTIMEOFDAY, pixel_x = hud_note.pixel_x - 170)
		animate(alpha=0, time = 0.4 SECONDS)

		note_pixels_moved += hud_note
		note_pixels_moved[hud_note] = 0
		new_notes |= hud_note

	if(!init)
		anvil_hud.add_notes(new_notes)

/datum/anvil_challenge/proc/check_click(datum/source, atom/target, atom/location, control, params, mob/user)
	var/atom/movable/screen/hud_note/choice = anvil_presses[1]
	if(user.client)
		average_ping = user.client.avgping * 0.01


	var/upper_range = anvil_presses[choice] + 0.2 SECONDS + average_ping
	var/lower_range = anvil_presses[choice] - 0.2 SECONDS - average_ping

	var/list/modifiers = params2list(params)

	//oh yea we making it out of the shitcode with this one.
	var/list/click_list = list()
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		click_list |= RIGHT_CLICK
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		click_list |= LEFT_CLICK
	if(LAZYACCESS(modifiers, ALT_CLICK))
		click_list |= ALT_CLICK
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		click_list |= CTRL_CLICK


	var/good_hit = TRUE
	if(!choice.check_click(click_list))
		failed_notes++
		good_hit = FALSE
	else
		if((REALTIMEOFDAY > lower_range) && (REALTIMEOFDAY < upper_range))
			anvil_presses -= anvil_presses[choice]
			user.balloon_alert(user, "Great Hit!")
			playsound(host_anvil, 'monkestation/code/modules/smithing/sounds/forge.ogg', 25, TRUE, mixer_channel = CHANNEL_SOUND_EFFECTS)

		else
			if(REALTIMEOFDAY > anvil_presses[choice] + 0.2 SECONDS + average_ping)
				off_time += REALTIMEOFDAY - (anvil_presses[choice] + 0.2 SECONDS + average_ping)
				failed_notes++
				good_hit = FALSE
			else if(REALTIMEOFDAY < anvil_presses[choice] - 0.2 SECONDS - average_ping)
				off_time += (anvil_presses[choice] + 0.2 SECONDS + average_ping) - REALTIMEOFDAY
				failed_notes++
				good_hit = FALSE

	anvil_presses -= choice
	note_pixels_moved -= choice
	anvil_hud.pop_note(choice, good_hit)
	if(!length(anvil_presses))
		if(!notes_left)
			end_minigame()
		else
			generate_anvil_beats()
	return FALSE

/datum/anvil_challenge/process(seconds_per_tick)
	for(var/note in anvil_presses)
		if(anvil_presses[note] + 0.6 SECONDS > REALTIMEOFDAY)
			continue
		anvil_presses -= note
		anvil_hud.delete_note(note)
		if(!length(anvil_presses))
			if(!notes_left)
				end_minigame()
			else
				generate_anvil_beats()

/datum/anvil_challenge/proc/end_minigame()
	success = max(0, round(success - ((100 * (failed_notes / total_notes)) + 1 * (off_time * 2))))
	UnregisterSignal(user.client, COMSIG_CLIENT_CLICK_DIRTY)
	STOP_PROCESSING(SSfishing, src)
	anvil_presses = null
	note_pixels_moved = null
	anvil_hud.end_minigame()
	QDEL_NULL(anvil_hud)
	host_anvil.smithing = FALSE
	host_anvil.generate_item(success)
	host_anvil = null

///The screen object which bait, fish, and completion bar are visually attached to.
/atom/movable/screen/anvil_hud
	icon = 'monkestation/code/modules/smithing/icons/anvil_hud.dmi'
	screen_loc = "CENTER:8,CENTER+2:2"
	name = "anvil minigame"
	appearance_flags = APPEARANCE_UI|KEEP_TOGETHER
	alpha = 230
	var/list/cached_notes = list()

///Initialize stuff
/atom/movable/screen/anvil_hud/proc/prepare_minigame(datum/anvil_challenge/challenge, list/notes)
	icon_state = challenge.background
	add_overlay("frame")
	add_notes(notes)
	challenge.user.client.screen += src

/atom/movable/screen/anvil_hud/proc/end_minigame()
	QDEL_LIST(cached_notes)

/atom/movable/screen/anvil_hud/proc/add_notes(list/notes)
	for(var/atom/movable/screen/hud_note/note as anything in notes)
		cached_notes += note
		vis_contents += note

/atom/movable/screen/anvil_hud/proc/pop_note(atom/movable/screen/hud_note/note, good_hit)
	addtimer(CALLBACK(src, PROC_REF(delete_note), note), 0.4 SECONDS)
	if(good_hit)
		flick("hit_state", note)
		note.alpha = 255
	animate(note, alpha = 0, time = 0.4 SECONDS)

/atom/movable/screen/anvil_hud/proc/delete_note(atom/movable/screen/hud_note/note)
	vis_contents -= note
	cached_notes -= note
	qdel(note)

/atom/movable/screen/hud_note
	icon = 'monkestation/code/modules/smithing/icons/anvil_hud.dmi'
	icon_state = "note"
	vis_flags = VIS_INHERIT_ID
	var/list/click_requirements = list()
	var/timer

/atom/movable/screen/hud_note/proc/generate_click_type(difficulty)
	difficulty = min(6, difficulty)

	switch(rand(1,difficulty))
		if(1)
			click_requirements = list(LEFT_CLICK)
			icon_state = "note"
		if(2)
			click_requirements = list(RIGHT_CLICK)
			icon_state = "note-right"
		if(3)
			click_requirements = list(LEFT_CLICK, ALT_CLICK)
			icon_state = "note-alt"
		if(4)
			click_requirements = list(RIGHT_CLICK, ALT_CLICK)
			icon_state = "note-right-alt"
		if(5)
			click_requirements = list(LEFT_CLICK, CTRL_CLICK)
			icon_state = "note-ctrl"
		if(6)
			click_requirements = list(RIGHT_CLICK, CTRL_CLICK)
			icon_state = "note-right-ctrl"

/atom/movable/screen/hud_note/proc/check_click(list/click_modifiers)
	var/list/copied_checks = click_requirements
	if(length(click_modifiers) != length(copied_checks))
		return FALSE
	for(var/item in copied_checks)
		if(item in click_modifiers)
			copied_checks -= item
		if(!length(copied_checks))
			return TRUE
	return FALSE
