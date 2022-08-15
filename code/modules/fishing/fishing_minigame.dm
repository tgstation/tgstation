// Lure bobbing
#define WAIT_PHASE 1
// Click now to start tgui part
#define BITING_PHASE 2
// UI minigame phase
#define MINIGAME_PHASE 3
// Shortest time the minigame can be won
#define MINIMUM_MINIGAME_DURATION 140

/datum/fishing_challenge
	/// When the ui minigame phase started
	var/start_time
	/// Is it finished (either by win/lose or window closing)
	var/completed = FALSE
	/// Fish AI type to use
	var/fish_ai = FISH_AI_DUMB
	/// Rule modifiers (eg weighted bait)
	var/list/special_effects = list()
	/// Did the game get past the baiting phase, used to track if bait should be consumed afterwards
	var/bait_taken = FALSE
	/// Result path
	var/reward_path = FISHING_DUD
	/// Minigame difficulty
	var/difficulty = FISHING_DEFAULT_DIFFICULTY
	// Current phase
	var/phase = WAIT_PHASE
	// Timer for the next phase
	var/next_phase_timer
	/// Fishing mob
	var/mob/user
	/// Rod that is used for the challenge
	var/obj/item/fishing_rod/used_rod
	/// Lure visual
	var/obj/effect/fishing_lure/lure
	/// Background image from /datum/asset/simple/fishing_minigame
	var/background = "default"

	/// Max distance we can move from the spot
	var/max_distance = 5

	/// Fishing line visual
	var/datum/beam/fishing_line

/datum/fishing_challenge/New(atom/spot, reward_path, obj/item/fishing_rod/rod, mob/user)
	src.user = user
	src.reward_path = reward_path
	src.used_rod = rod
	lure = new(get_turf(spot))
	/// Fish minigame properties
	if(ispath(reward_path,/obj/item/fish))
		var/obj/item/fish/fish = reward_path
		fish_ai = initial(fish.fish_ai_type)
		// Apply fishing trait modifiers
		var/list/fish_list_properties = collect_fish_properties()
		var/list/fish_traits = fish_list_properties[fish][NAMEOF(fish, fishing_traits)]
		for(var/fish_trait in fish_traits)
			var/datum/fishing_trait/trait = new fish_trait
			special_effects += trait.minigame_mod(rod, user)
	/// Enable special parameters
	if(rod.line)
		if(rod.line.fishing_line_traits & FISHING_LINE_BOUNCY)
			special_effects += FISHING_MINIGAME_RULE_LIMIT_LOSS
	if(rod.hook)
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_WEIGHTED)
			special_effects += FISHING_MINIGAME_RULE_WEIGHTED_BAIT

/datum/fishing_challenge/Destroy(force, ...)
	if(!completed)
		complete(win = FALSE)
	if(fishing_line)
		QDEL_NULL(fishing_line)
	if(lure)
		QDEL_NULL(lure)
	. = ..()

/datum/fishing_challenge/proc/start(mob/user)
	/// Create fishing line visuals
	fishing_line = used_rod.create_fishing_line(lure, target_py = 5)
	// If fishing line breaks los / rod gets dropped / deleted
	RegisterSignal(fishing_line, COMSIG_FISHING_LINE_SNAPPED, .proc/interrupt)
	ADD_TRAIT(user, TRAIT_GONE_FISHING, REF(src))
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "fishing", /datum/mood_event/fishing)
	RegisterSignal(user, COMSIG_MOB_CLICKON, .proc/handle_click)
	start_baiting_phase()
	to_chat(user, span_notice("You start fishing..."))
	playsound(lure, 'sound/effects/splash.ogg', 100)

/datum/fishing_challenge/proc/handle_click()
	if(phase == WAIT_PHASE) //Reset wait
		lure.balloon_alert(user, "miss!")
		start_baiting_phase()
	else if(phase == BITING_PHASE)
		start_minigame_phase()
	return COMSIG_MOB_CANCEL_CLICKON

/datum/fishing_challenge/proc/check_distance()
	SIGNAL_HANDLER
	if(get_dist(user,lure) > max_distance)
		interrupt()

/// Challenge interrupted by something external
/datum/fishing_challenge/proc/interrupt()
	SIGNAL_HANDLER
	if(!completed)
		complete(FALSE)

/datum/fishing_challenge/proc/complete(win = FALSE, perfect_win = FALSE)
	deltimer(next_phase_timer)
	completed = TRUE
	if(user)
		UnregisterSignal(user, list(COMSIG_MOB_CLICKON, COMSIG_MOVABLE_MOVED))
		REMOVE_TRAIT(user, TRAIT_GONE_FISHING, REF(src))
	if(used_rod)
		UnregisterSignal(used_rod, COMSIG_ITEM_DROPPED)
		if(phase == MINIGAME_PHASE)
			used_rod.consume_bait()
	if(win)
		// validate timings to have at least basic abuse prevention, though it's kinda impossible task here
		// 140 from minimum completion bar fill time
		var/minimum_time = start_time + MINIMUM_MINIGAME_DURATION
		if(world.time < minimum_time)
			win = FALSE
			stack_trace("Fishing minimum time check failed")
	if(win)
		if(reward_path != FISHING_DUD)
			playsound(lure, 'sound/effects/bigsplash.ogg', 100)
	else
		user.balloon_alert(user, "it got away")
	SEND_SIGNAL(src, COMSIG_FISHING_CHALLENGE_COMPLETED, user, win, perfect_win)
	qdel(src)

/datum/fishing_challenge/proc/start_baiting_phase()
	deltimer(next_phase_timer)
	phase = WAIT_PHASE
	//Bobbing animation
	animate(lure, pixel_y = 1, time = 1 SECONDS, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -1, time = 1 SECONDS, flags = ANIMATION_RELATIVE)
	//Setup next phase
	var/wait_time = rand(1 SECONDS, 30 SECONDS)
	next_phase_timer = addtimer(CALLBACK(src, .proc/start_biting_phase), wait_time, TIMER_STOPPABLE)

/datum/fishing_challenge/proc/start_biting_phase()
	phase = BITING_PHASE
	// Trashing animation
	playsound(lure, 'sound/effects/fish_splash.ogg', 100)
	lure.balloon_alert(user, "!!!")
	animate(lure, pixel_y = 3, time = 5, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -3, time = 5, flags = ANIMATION_RELATIVE)
	// Setup next phase
	var/wait_time = rand(3 SECONDS, 6 SECONDS)
	next_phase_timer = addtimer(CALLBACK(src, .proc/start_baiting_phase), wait_time, TIMER_STOPPABLE)

/datum/fishing_challenge/proc/start_minigame_phase()
	phase = MINIGAME_PHASE
	deltimer(next_phase_timer)
	start_time = world.time
	ui_interact(user)

/datum/fishing_challenge/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fishing")
		ui.set_autoupdate(FALSE)
		ui.set_mouse_hook(TRUE)
		ui.open()

/datum/fishing_challenge/ui_host(mob/user)
	return lure //Could be the target really

// Manually closing the ui is treated as lose
/datum/fishing_challenge/ui_close(mob/user)
	. = ..()
	if(!completed)
		complete(FALSE)

/datum/fishing_challenge/ui_static_data(mob/user)
	. = ..()
	.["difficulty"] = max(1,min(difficulty,100))
	.["fish_ai"] = fish_ai
	.["special_effects"] = special_effects
	.["background_image"] = background

/datum/fishing_challenge/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/fishing_minigame)) //preset screens

/datum/fishing_challenge/ui_status(mob/user, datum/ui_state/state)
	return min(
		get_dist(user, lure) > max_distance ? UI_CLOSE : UI_INTERACTIVE,
		ui_status_user_has_free_hands(user),
		ui_status_user_is_abled(user, lure),
	)

/datum/fishing_challenge/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(phase != MINIGAME_PHASE)
		return

	switch(action)
		if("win")
			complete(win = TRUE, perfect_win = params["perfect"])
		if("lose")
			complete(win = FALSE)

/// The visual that appears over the fishing spot
/obj/effect/fishing_lure
	icon = 'icons/obj/fishing.dmi'
	icon_state = "lure_idle"

#undef WAIT_PHASE
#undef BITING_PHASE
#undef MINIGAME_PHASE
#undef MINIMUM_MINIGAME_DURATION
