// Lure bobbing
#define WAIT_PHASE 1
// Click now to start tgui part
#define BITING_PHASE 2
// UI minigame phase
#define MINIGAME_PHASE 3

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

	/// Fishing line visual
	var/datum/beam/fishing_line

	var/experience_multiplier = 1

/datum/fishing_challenge/New(datum/component/fishing_spot/comp, reward_path, obj/item/fishing_rod/rod, mob/user)
	src.user = user
	src.reward_path = reward_path
	src.used_rod = rod
	var/atom/spot = comp.parent
	lure = new(get_turf(spot), spot)
	RegisterSignal(spot, COMSIG_QDELETING, PROC_REF(on_spot_gone))
	RegisterSignal(comp.fish_source, COMSIG_FISHING_SOURCE_INTERRUPT_CHALLENGE, PROC_REF(interrupt_challenge))
	comp.fish_source.RegisterSignal(src, COMSIG_FISHING_CHALLENGE_COMPLETED, TYPE_PROC_REF(/datum/fish_source, on_challenge_completed))
	background = comp.fish_source.background
	/// Fish minigame properties
	if(ispath(reward_path,/obj/item/fish))
		var/obj/item/fish/fish = reward_path
		fish_ai = initial(fish.fish_ai_type)
		// Apply fish trait modifiers
		var/list/fish_list_properties = collect_fish_properties()
		var/list/fish_traits = fish_list_properties[fish][NAMEOF(fish, fish_traits)]
		for(var/fish_trait in fish_traits)
			var/datum/fish_trait/trait = GLOB.fish_traits[fish_trait]
			special_effects += trait.minigame_mod(rod, user)
	/// Enable special parameters
	if(rod.line)
		if(rod.line.fishing_line_traits & FISHING_LINE_BOUNCY)
			special_effects |= FISHING_MINIGAME_RULE_LIMIT_LOSS
	if(rod.hook)
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_WEIGHTED)
			special_effects |= FISHING_MINIGAME_RULE_WEIGHTED_BAIT
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_BIDIRECTIONAL)
			special_effects |= FISHING_MINIGAME_RULE_BIDIRECTIONAL
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_NO_ESCAPE)
			special_effects |= FISHING_MINIGAME_RULE_NO_ESCAPE
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_ENSNARE)
			special_effects |= FISHING_MINIGAME_RULE_LIMIT_LOSS
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_KILL)
			special_effects |= FISHING_MINIGAME_RULE_KILL

	if((FISHING_MINIGAME_RULE_KILL in special_effects) && ispath(reward_path,/obj/item/fish))
		RegisterSignal(user, COMSIG_MOB_FISHING_REWARD_DISPENSED, PROC_REF(hurt_fish))

	difficulty += comp.fish_source.calculate_difficulty(reward_path, rod, user, src)

/datum/fishing_challenge/Destroy(force, ...)
	if(!completed)
		complete(win = FALSE)
	if(fishing_line)
		QDEL_NULL(fishing_line)
	if(lure)
		QDEL_NULL(lure)
	user = null
	used_rod = null
	return ..()

/datum/fishing_challenge/proc/send_alert(message)
	var/turf/lure_turf = get_turf(lure)
	lure_turf?.balloon_alert(user, message)

/datum/fishing_challenge/proc/on_spot_gone(datum/source)
	send_alert("fishing spot gone!")
	interrupt(balloon_alert = FALSE)

/datum/fishing_challenge/proc/interrupt_challenge(datum/source, reason)
	if(reason)
		send_alert(reason)
	interrupt(balloon_alert = FALSE)

/datum/fishing_challenge/proc/start(mob/living/user)
	/// Create fishing line visuals
	fishing_line = used_rod.create_fishing_line(lure, target_py = 5)
	// If fishing line breaks los / rod gets dropped / deleted
	RegisterSignal(fishing_line, COMSIG_FISHING_LINE_SNAPPED, PROC_REF(interrupt))
	RegisterSignal(used_rod, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	ADD_TRAIT(user, TRAIT_GONE_FISHING, REF(src))
	user.add_mood_event("fishing", /datum/mood_event/fishing)
	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(handle_click))
	start_baiting_phase()
	to_chat(user, span_notice("You start fishing..."))
	playsound(lure, 'sound/effects/splash.ogg', 100)

/datum/fishing_challenge/proc/handle_click(mob/source, atom/target, modifiers)
	SIGNAL_HANDLER
	//You need to be holding the rod to use it.
	if(!source.get_active_held_item(used_rod) || LAZYACCESS(modifiers, SHIFT_CLICK))
		return
	if(phase == WAIT_PHASE) //Reset wait
		send_alert("miss!")
		start_baiting_phase()
	else if(phase == BITING_PHASE)
		INVOKE_ASYNC(src, PROC_REF(start_minigame_phase))
	return COMSIG_MOB_CANCEL_CLICKON

/// Challenge interrupted by something external
/datum/fishing_challenge/proc/interrupt(datum/source, balloon_alert = TRUE)
	SIGNAL_HANDLER
	if(!completed)
		experience_multiplier *= 0.5
		if(balloon_alert)
			send_alert(user.is_holding(used_rod) ? "line snapped" : "tool dropped")
		complete(FALSE)

/datum/fishing_challenge/proc/on_attack_self(obj/item/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(stop_fishing), source, user)

/datum/fishing_challenge/proc/stop_fishing(obj/item/rod, mob/user)
	if((phase != MINIGAME_PHASE || do_after(user, 3 SECONDS, rod)) && !QDELETED(src) && !completed)
		experience_multiplier *= 0.5
		send_alert("stopped fishing")
		complete(FALSE)

/datum/fishing_challenge/proc/complete(win = FALSE, perfect_win = FALSE)
	deltimer(next_phase_timer)
	completed = TRUE
	if(user)
		REMOVE_TRAIT(user, TRAIT_GONE_FISHING, REF(src))
		if(start_time)
			var/seconds_spent = (world.time - start_time)/10
			if(!(FISHING_MINIGAME_RULE_NO_EXP in special_effects))
				user.mind?.adjust_experience(/datum/skill/fishing, min(round(seconds_spent * FISHING_SKILL_EXP_PER_SECOND * experience_multiplier), FISHING_SKILL_EXP_CAP_PER_GAME))
				if(win && user.mind?.get_skill_level(/datum/skill/fishing) >= SKILL_LEVEL_LEGENDARY)
					user.client?.give_award(/datum/award/achievement/skill/legendary_fisher, user)
	if(win)
		if(reward_path != FISHING_DUD)
			playsound(lure, 'sound/effects/bigsplash.ogg', 100)
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
	next_phase_timer = addtimer(CALLBACK(src, PROC_REF(start_biting_phase)), wait_time, TIMER_STOPPABLE)

/datum/fishing_challenge/proc/start_biting_phase()
	phase = BITING_PHASE
	// Trashing animation
	playsound(lure, 'sound/effects/fish_splash.ogg', 100)
	send_alert("!!!")
	animate(lure, pixel_y = 3, time = 5, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -3, time = 5, flags = ANIMATION_RELATIVE)
	// Setup next phase
	var/wait_time = rand(3 SECONDS, 6 SECONDS)
	next_phase_timer = addtimer(CALLBACK(src, PROC_REF(start_baiting_phase)), wait_time, TIMER_STOPPABLE)

///The damage dealt per second to the fish when FISHING_MINIGAME_RULE_KILL is active.
#define FISH_DAMAGE_PER_SECOND 2

/datum/fishing_challenge/proc/start_minigame_phase()
	phase = MINIGAME_PHASE
	deltimer(next_phase_timer)
	if((FISHING_MINIGAME_RULE_KILL in special_effects) && ispath(reward_path,/obj/item/fish))
		var/obj/item/fish/fish = reward_path
		var/wait_time = (initial(fish.health) / FISH_DAMAGE_PER_SECOND) SECONDS
		addtimer(CALLBACK(src, PROC_REF(win_anyway)), wait_time)
	start_time = world.time
	experience_multiplier += difficulty * FISHING_SKILL_DIFFIULTY_EXP_MULT
	ui_interact(user)

/datum/fishing_challenge/proc/win_anyway()
	if(!completed)
		//winning by timeout or idling around shouldn't give as much experience.
		experience_multiplier *= 0.5
		complete(TRUE)

/datum/fishing_challenge/proc/hurt_fish(datum/source, obj/item/fish/reward)
	SIGNAL_HANDLER
	if(istype(reward))
		var/damage = CEILING((world.time - start_time)/10 * FISH_DAMAGE_PER_SECOND, 1)
		reward.adjust_health(reward.health - damage)

#undef FISH_DAMAGE_PER_SECOND

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
		send_alert("stopped fishing")
		complete(FALSE)

/datum/fishing_challenge/ui_static_data(mob/user)
	. = ..()
	.["difficulty"] = clamp(difficulty, 1, 100)
	.["fish_ai"] = fish_ai
	.["special_effects"] = special_effects
	.["background_image"] = background

/datum/fishing_challenge/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/fishing_minigame)) //preset screens

/datum/fishing_challenge/ui_status(mob/user, datum/ui_state/state)
	return min(
		get_dist(user, lure) > 5 ? UI_CLOSE : UI_INTERACTIVE,
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
			send_alert("it got away")
			complete(win = FALSE)

/// The visual that appears over the fishing spot
/obj/effect/fishing_lure
	icon = 'icons/obj/fishing.dmi'
	icon_state = "lure_idle"

/obj/effect/fishing_lure/Initialize(mapload, atom/spot)
	. = ..()
	if(ismovable(spot)) // we want the lure and therefore the fishing line to stay connected with the fishing spot.
		RegisterSignal(spot, COMSIG_MOVABLE_MOVED, PROC_REF(follow_movable))

/obj/effect/fishing_lure/proc/follow_movable(atom/movable/source)
	set_glide_size(source.glide_size)
	forceMove(source.loc)

#undef WAIT_PHASE
#undef BITING_PHASE
#undef MINIGAME_PHASE
