// Lure bobbing
#define WAIT_PHASE 1
// Click now to start tgui part
#define BITING_PHASE 2
// UI minigame phase
#define MINIGAME_PHASE 3

/// The height of the minigame slider. Not in pixels, but minigame units.
#define FISHING_MINIGAME_AREA 1000
/// Any lower than this, and the target position of the fish is considered null
#define FISH_TARGET_MIN_DISTANCE 6
/// The friction applied to fish jumps, so that it decelerates over time
#define FISH_FRICTION_MULT 0.9
/// Used to decide whether the fish can jump in a certain direction
#define FISH_SHORT_JUMP_MIN_DISTANCE 100
/// The maximum distance for a short jump
#define FISH_SHORT_JUMP_MAX_DISTANCE 200
// Acceleration mod when bait is over fish
#define FISH_ON_BAIT_ACCELERATION_MULT 0.6
/// The minimum velocity required for the bait to bounce
#define BAIT_MIN_VELOCITY_BOUNCE 150
/// The extra deceleration of velocity that happens when the bait switches direction
#define BAIT_DECELERATION_MULT 1.8

/// Reduce initial completion rate depending on difficulty
#define MAX_FISH_COMPLETION_MALUS 15
/// The window of time between biting phase and back to baiting phase
#define BITING_TIME_WINDOW 4 SECONDS

/// The multiplier of how much the difficulty negatively impacts the bait height
#define BAIT_HEIGHT_DIFFICULTY_MALUS 1.3

///Defines to know how the bait is moving on the minigame slider.
#define REELING_STATE_IDLE 0
#define REELING_STATE_UP 1
#define REELING_STATE_DOWN 2

///The pixel height of the minigame bar
#define MINIGAME_SLIDER_HEIGHT 76
///The standard pixel height of the bait
#define MINIGAME_BAIT_HEIGHT 27
///The standard pixel height of the fish (minus a pixel on each direction for the sake of a better looking sprite)
#define MINIGAME_FISH_HEIGHT 4

/datum/fishing_challenge
	/// When the ui minigame phase started
	var/start_time
	/// Is it finished (either by win/lose or window closing)
	var/completed = FALSE
	/// Fish AI type to use
	var/fish_ai = FISH_AI_DUMB
	/// Rule modifiers (eg weighted bait)
	var/special_effects = NONE
	/// A list of possible active minigame effects. If not empty, one will be picked from time to time.
	var/list/active_effects
	/// The cooldown between switching active effects
	COOLDOWN_DECLARE(active_effect_cd)
	/// The current active effect
	var/current_active_effect
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
	/// Background icon state from fishing_hud.dmi
	var/background = "background_default"
	/// Fish icon state from fishing_hud.dmi
	var/fish_icon = "fish"

	/// Fishing line visual
	var/datum/beam/fishing_line

	var/experience_multiplier = 1

	/// How much space the fish takes on the minigame slider
	var/fish_height = 50
	/// How much space the bait takes on the minigame slider
	var/bait_height = 360
	/// The height in pixels of the bait bar
	var/bait_pixel_height = MINIGAME_BAIT_HEIGHT
	/// The height in pixels of the fish
	var/fish_pixel_height = MINIGAME_FISH_HEIGHT
	/// The position of the fish on the minigame slider
	var/fish_position = 0
	/// The position of the bait on the minigame slider
	var/bait_position = 0
	/// The current speed the fish is moving at
	var/fish_velocity = 0
	/// The current speed the bait is moving at
	var/bait_velocity = 0

	/// The completion score. If it reaches 100, it's a win. If it reaches 0, it's a loss.
	var/completion = 30
	/// How much completion is lost per second when the bait area is not intersecting with the fish's
	var/completion_loss = 6
	/// How much completion is gained per second when the bait area is intersecting with the fish's
	var/completion_gain = 5

	/// How likely the fish is to perform a standard jump, then multiplied by difficulty
	var/short_jump_chance = 2.25
	/// How likely the fish is to perform a long jump, then multiplied by difficulty
	var/long_jump_chance = 0.0625
	/// The speed limit for the short jump
	var/short_jump_velocity_limit = 400
	/// The speed limit for the long jump
	var/long_jump_velocity_limit = 200
	/// The current speed limit used
	var/current_velocity_limit = 200
	/// The base velocity of the fish, which may affect jump distances and falling speed.
	var/fish_idle_velocity = 0
	/// A position on the slider the fish wants to get to
	var/target_position
	/// If true, the fish can jump while a target position is set, thus overriding it
	var/can_interrupt_move = TRUE

	/// Whether the bait is idle or reeling up or down (left and right click)
	var/reeling_state = REELING_STATE_IDLE
	/// The acceleration of the bait while not reeling
	var/gravity_velocity = -800
	/// The acceleration of the bait while reeling
	var/reeling_velocity = 1200
	/// By how much the bait recoils back when hitting the bounds of the slider while idle
	var/bait_bounce_mult = 0.6

	///The background as shown in the minigame, and the holder of the other visual overlays
	var/atom/movable/screen/fishing_hud/fishing_hud

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
		switch(fish_ai)
			if(FISH_AI_ZIPPY) // Keeps on jumping
				short_jump_chance *= 3
			if(FISH_AI_SLOW) // Only does long jump, and doesn't change direction until it gets there
				short_jump_chance = 0
				long_jump_chance = 1.5
				long_jump_velocity_limit = 150
				long_jump_velocity_limit = FALSE
		// Apply fish trait modifiers
		var/list/fish_list_properties = collect_fish_properties()
		var/list/fish_traits = fish_list_properties[fish][NAMEOF(fish, fish_traits)]
		for(var/fish_trait in fish_traits)
			var/datum/fish_trait/trait = GLOB.fish_traits[fish_trait]
			trait.minigame_mod(rod, user, src)
	/// Enable special parameters
	if(rod.line)
		completion_gain += 1 // Any fishing line will provide a small boost by default
		if(rod.line.fishing_line_traits & FISHING_LINE_BOUNCY)
			completion_loss -= 2
		if(rod.line.fishing_line_traits & FISHING_LINE_STIFF)
			completion_loss += 1
			completion_gain -= 1
		if(rod.line.fishing_line_traits & FISHING_LINE_AUTOREEL)
			special_effects |= FISHING_MINIGAME_AUTOREEL
	if(rod.hook)
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_WEIGHTED)
			bait_bounce_mult = 0.1
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_BIDIRECTIONAL)
			special_effects |= FISHING_MINIGAME_RULE_BIDIRECTIONAL
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_NO_ESCAPE)
			special_effects |= FISHING_MINIGAME_RULE_NO_ESCAPE
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_ENSNARE)
			completion_loss -= 2
		if(rod.hook.fishing_hook_traits & FISHING_HOOK_KILL)
			special_effects |= FISHING_MINIGAME_RULE_KILL

	completion_loss += user.mind?.get_skill_modifier(/datum/skill/fishing, SKILL_VALUE_MODIFIER)/5

	if(special_effects & FISHING_MINIGAME_RULE_KILL && ispath(reward_path,/obj/item/fish))
		RegisterSignal(comp.fish_source, COMSIG_FISH_SOURCE_REWARD_DISPENSED, PROC_REF(hurt_fish))

	difficulty += comp.fish_source.calculate_difficulty(reward_path, rod, user, src)
	difficulty = clamp(round(difficulty), FISHING_EASY_DIFFICULTY - 5, 100)

	if(difficulty > FISHING_EASY_DIFFICULTY)
		completion -= MAX_FISH_COMPLETION_MALUS * (difficulty * 0.01)

	if(HAS_MIND_TRAIT(user, TRAIT_REVEAL_FISH))
		fish_icon = GLOB.specific_fish_icons[reward_path] || "fish"

	/**
	 * If the chances are higher than 1% (100% at maximum difficulty), they'll scale
	 * less than proportionally (exponent less than 1) instead.
	 * This way we ensure fish with high jump chances won't get TOO jumpy until
	 * they near the maximum difficulty, at which they hit 100%
	 */
	var/square_angle_rad = TORADIANS(90)
	var/zero_one_difficulty = difficulty/100
	if(short_jump_chance > 1)
		short_jump_chance = (zero_one_difficulty**(square_angle_rad-TORADIANS(arctan(short_jump_chance * 1/square_angle_rad))))*100
	else
		short_jump_chance *= difficulty
	if(long_jump_chance > 1)
		long_jump_chance = (zero_one_difficulty**(square_angle_rad-TORADIANS(arctan(long_jump_chance * 1/square_angle_rad))))*100
	else
		long_jump_chance *= difficulty

	bait_height -= round(difficulty * BAIT_HEIGHT_DIFFICULTY_MALUS)
	bait_pixel_height = round(MINIGAME_BAIT_HEIGHT * (bait_height/initial(bait_height)), 1)

/datum/fishing_challenge/Destroy(force)
	if(!completed)
		complete(win = FALSE)
	if(fishing_line)
		//Stops the line snapped message from appearing everytime the minigame is over.
		UnregisterSignal(fishing_line, COMSIG_QDELETING)
		QDEL_NULL(fishing_line)
	if(lure)
		QDEL_NULL(lure)
	SStgui.close_uis(src)
	user = null
	used_rod = null
	return ..()

/datum/fishing_challenge/proc/send_alert(message)
	var/turf/lure_turf = get_turf(lure)
	lure_turf?.balloon_alert(user, message)

/datum/fishing_challenge/proc/on_spot_gone(datum/source)
	SIGNAL_HANDLER
	send_alert("fishing spot gone!")
	interrupt()

/datum/fishing_challenge/proc/interrupt_challenge(datum/source, reason)
	if(reason)
		send_alert(reason)
	interrupt()

/datum/fishing_challenge/proc/start(mob/living/user)
	/// Create fishing line visuals
	if(used_rod.display_fishing_line)
		fishing_line = used_rod.create_fishing_line(lure, target_py = 5)
		RegisterSignal(fishing_line, COMSIG_QDELETING, PROC_REF(on_line_deleted))
	else //if the rod doesnt have a fishing line, then it ends when they move away
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_move))
	active_effects = bitfield_to_list(special_effects & FISHING_MINIGAME_ACTIVE_EFFECTS)
	// If fishing line breaks los / rod gets dropped / deleted
	RegisterSignal(used_rod, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	ADD_TRAIT(user, TRAIT_GONE_FISHING, REF(src))
	user.add_mood_event("fishing", /datum/mood_event/fishing)
	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(handle_click))
	start_baiting_phase()
	to_chat(user, span_notice("You start fishing..."))
	playsound(lure, 'sound/effects/splash.ogg', 100)

/datum/fishing_challenge/proc/on_line_deleted(datum/source)
	SIGNAL_HANDLER
	fishing_line = null
	///The lure may be out of sight if the user has moed around a corner, so the message should be displayed over him instead.
	user.balloon_alert(user, user.is_holding(used_rod) ? "line snapped" : "rod dropped")
	interrupt()

/datum/fishing_challenge/proc/on_user_move(datum/source)
	SIGNAL_HANDLER

	user.balloon_alert(user, "too far!")
	interrupt()

/datum/fishing_challenge/proc/handle_click(mob/source, atom/target, modifiers)
	SIGNAL_HANDLER
	//You need to be holding the rod to use it.
	if(LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || LAZYACCESS(modifiers, ALT_CLICK))
		return
	if(!HAS_TRAIT(source, TRAIT_PROFOUND_FISHER) && source.get_active_held_item() != used_rod)
		return
	if(phase == WAIT_PHASE)
		send_alert("miss!")
		start_baiting_phase(TRUE) //Add in another 3 to 5 seconds for that blunder.
	else if(phase == BITING_PHASE)
		start_minigame_phase()
	return COMSIG_MOB_CANCEL_CLICKON

/// Challenge interrupted by something external
/datum/fishing_challenge/proc/interrupt()
	if(!completed)
		experience_multiplier *= 0.5
		complete(FALSE)

/datum/fishing_challenge/proc/on_attack_self(obj/item/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(stop_fishing), source, user)

/datum/fishing_challenge/proc/stop_fishing(obj/item/rod, mob/user)
	if((phase != MINIGAME_PHASE || do_after(user, 3 SECONDS, rod)) && !QDELETED(src) && !completed)
		experience_multiplier *= 0.5
		send_alert("stopped fishing")
		complete(FALSE)

/datum/fishing_challenge/proc/complete(win = FALSE)
	if(completed)
		return
	deltimer(next_phase_timer)
	completed = TRUE
	if(phase == MINIGAME_PHASE)
		remove_minigame_hud()
	if(user)
		REMOVE_TRAIT(user, TRAIT_GONE_FISHING, REF(src))
		if(start_time)
			var/seconds_spent = (world.time - start_time) * 0.1
			if(!(special_effects & FISHING_MINIGAME_RULE_NO_EXP))
				user.mind?.adjust_experience(/datum/skill/fishing, round(seconds_spent * FISHING_SKILL_EXP_PER_SECOND * experience_multiplier))
				if(user.mind?.get_skill_level(/datum/skill/fishing) >= SKILL_LEVEL_LEGENDARY)
					user.client?.give_award(/datum/award/achievement/skill/legendary_fisher, user)
	if(win)
		if(reward_path != FISHING_DUD)
			playsound(lure, 'sound/effects/bigsplash.ogg', 100)
	SEND_SIGNAL(src, COMSIG_FISHING_CHALLENGE_COMPLETED, user, win)
	if(!QDELETED(src))
		qdel(src)

/datum/fishing_challenge/proc/start_baiting_phase(penalty = FALSE)
	var/wait_time
	if(penalty)
		wait_time = min(timeleft(next_phase_timer) + rand(3 SECONDS, 5 SECONDS), 30 SECONDS)
	else
		wait_time = rand(3 SECONDS, 25 SECONDS)
		if(special_effects & FISHING_MINIGAME_AUTOREEL && wait_time >= 15 SECONDS)
			wait_time = max(wait_time - 7.5 SECONDS, 15 SECONDS)
	deltimer(next_phase_timer)
	phase = WAIT_PHASE
	//Bobbing animation
	animate(lure, pixel_y = 1, time = 1 SECONDS, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -1, time = 1 SECONDS, flags = ANIMATION_RELATIVE)
	next_phase_timer = addtimer(CALLBACK(src, PROC_REF(start_biting_phase)), wait_time, TIMER_STOPPABLE)

/datum/fishing_challenge/proc/start_biting_phase()
	phase = BITING_PHASE
	// Trashing animation
	playsound(lure, 'sound/effects/fish_splash.ogg', 100)
	if(HAS_MIND_TRAIT(user, TRAIT_REVEAL_FISH))
		switch(fish_icon)
			if(FISH_ICON_DEF)
				send_alert("fish!!!")
			if(FISH_ICON_HOSTILE)
				send_alert("hostile!!!")
			if(FISH_ICON_STAR)
				send_alert("starfish!!!")
			if(FISH_ICON_CHUNKY)
				send_alert("round fish!!!")
			if(FISH_ICON_JELLYFISH)
				send_alert("jellyfish!!!")
			if(FISH_ICON_SLIME)
				send_alert("slime!!!")
			if(FISH_ICON_COIN)
				send_alert("valuable!!!")
			if(FISH_ICON_GEM)
				send_alert("ore!!!")
			if(FISH_ICON_CRAB)
				send_alert("crustacean!!!")
			if(FISH_ICON_BONE)
				send_alert("bones!!!")
	else
		send_alert("!!!")
	animate(lure, pixel_y = 3, time = 5, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -3, time = 5, flags = ANIMATION_RELATIVE)
	if(special_effects & FISHING_MINIGAME_AUTOREEL)
		start_minigame_phase(auto_reel = TRUE)
		return
	// Setup next phase
	next_phase_timer = addtimer(CALLBACK(src, PROC_REF(start_baiting_phase)), BITING_TIME_WINDOW, TIMER_STOPPABLE)

///The damage dealt per second to the fish when FISHING_MINIGAME_RULE_KILL is active.
#define FISH_DAMAGE_PER_SECOND 2

///The player is no longer around to play the minigame, so we interrupt it.
/datum/fishing_challenge/proc/on_user_logout(datum/source)
	SIGNAL_HANDLER
	interrupt()

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

/datum/fishing_challenge/proc/start_minigame_phase(auto_reel = FALSE)
	if(auto_reel)
		completion *= 1.3
	else
		var/time_left = timeleft(next_phase_timer)
		switch(time_left)
			if(0 to BITING_TIME_WINDOW - 3 SECONDS)
				completion *= 0.65
			if(BITING_TIME_WINDOW - 3 SECONDS to BITING_TIME_WINDOW - 2 SECONDS)
				completion *= 0.82
			if(BITING_TIME_WINDOW - 1 SECONDS to BITING_TIME_WINDOW - 0.5 SECONDS)
				completion *= 1.2
			if(BITING_TIME_WINDOW - 0.5 SECONDS to BITING_TIME_WINDOW)
				completion *= 1.4
	if(!prepare_minigame_hud())
		return
	phase = MINIGAME_PHASE
	deltimer(next_phase_timer)
	if((FISHING_MINIGAME_RULE_KILL in special_effects) && ispath(reward_path,/obj/item/fish))
		var/obj/item/fish/fish = reward_path
		var/wait_time = (initial(fish.health) / FISH_DAMAGE_PER_SECOND) SECONDS
		addtimer(CALLBACK(src, PROC_REF(win_anyway)), wait_time)
	start_time = world.time
	experience_multiplier += difficulty * FISHING_SKILL_DIFFIULTY_EXP_MULT

#undef FISH_DAMAGE_PER_SECOND

///Initialize the minigame hud and register some signals to make it work.
/datum/fishing_challenge/proc/prepare_minigame_hud()
	if(!user.client || user.incapacitated())
		return FALSE
	. = TRUE
	fishing_hud = new
	fishing_hud.prepare_minigame(src)
	RegisterSignal(user.client, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(start_reeling))
	RegisterSignal(user.client, COMSIG_CLIENT_MOUSEUP, PROC_REF(stop_reeling))
	RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(on_user_logout))
	if(length(active_effects))
		// Give the player a moment to prepare for active minigame effects
		COOLDOWN_START(src, active_effect_cd, rand(5, 9) SECONDS)
	START_PROCESSING(SSfishing, src)

///Stop processing and remove references to the minigame hud
/datum/fishing_challenge/proc/remove_minigame_hud()
	STOP_PROCESSING(SSfishing, src)
	QDEL_NULL(fishing_hud)

///While the mouse button is held down, the bait will be reeling up (or down on r-click if the bidirectional rule is enabled)
/datum/fishing_challenge/proc/start_reeling(client/source, datum/object, location, control, params)
	SIGNAL_HANDLER
	var/bidirectional = special_effects & FISHING_MINIGAME_RULE_BIDIRECTIONAL
	var/list/modifiers = params2list(params)
	if(bidirectional && LAZYACCESS(modifiers, RIGHT_CLICK))
		reeling_state = REELING_STATE_DOWN
	else
		reeling_state = REELING_STATE_UP

///Reset the reeling state to idle once the mouse button is released
/datum/fishing_challenge/proc/stop_reeling(client/source, datum/object, location, control, params)
	SIGNAL_HANDLER
	reeling_state = REELING_STATE_IDLE

///Update the state of the fish, the bait and the hud
/datum/fishing_challenge/process(seconds_per_tick)
	if(length(active_effects) && COOLDOWN_FINISHED(src, active_effect_cd))
		select_active_effect()
	move_fish(seconds_per_tick)
	move_bait(seconds_per_tick)
	if(!QDELETED(fishing_hud))
		update_visuals()

///The proc that handles fancy effects like flipping the hud or skewing movement
/datum/fishing_challenge/proc/select_active_effect()
	///bring forth an active effect
	if(isnull(current_active_effect))
		current_active_effect = pick(active_effects)
		switch(current_active_effect)
			if(FISHING_MINIGAME_RULE_ANTIGRAV)
				fishing_hud.icon_state = "background_antigrav"
				SEND_SOUND(user, sound('sound/effects/arcade_jump.ogg', volume = 50))
				COOLDOWN_START(src, active_effect_cd, rand(6, 9) SECONDS)
			if(FISHING_MINIGAME_RULE_FLIP)
				fishing_hud.icon_state = "background_flip"
				fishing_hud.transform = fishing_hud.transform.Scale(1, -1)
				SEND_SOUND(user, sound('sound/effects/boing.ogg'))
				COOLDOWN_START(src, active_effect_cd, rand(5, 6) SECONDS)
		return

	///go back to normal
	switch(current_active_effect)
		if(FISHING_MINIGAME_RULE_ANTIGRAV)
			var/sound/inverted_sound = sound('sound/effects/arcade_jump.ogg', volume = 50)
			inverted_sound.frequency = -1
			SEND_SOUND(user, inverted_sound)
			COOLDOWN_START(src, active_effect_cd, rand(10, 13) SECONDS)
		if(FISHING_MINIGAME_RULE_FLIP)
			fishing_hud.transform = fishing_hud.transform.Scale(1, -1)
			COOLDOWN_START(src, active_effect_cd, rand(8, 12) SECONDS)

	fishing_hud.icon_state = background
	current_active_effect = null

///The proc that moves the fish around, just like in the old TGUI, mostly.
/datum/fishing_challenge/proc/move_fish(seconds_per_tick)
	var/long_chance = long_jump_chance * seconds_per_tick * 10
	var/short_chance = short_jump_chance * seconds_per_tick * 10

	// If we have the target but we're close enough, mark as target reached
	if(abs(target_position - fish_position) < FISH_TARGET_MIN_DISTANCE)
		target_position = null

	// Switching to new long jump target can interrupt any other
	if((can_interrupt_move || isnull(target_position)) && prob(long_chance))
		/**
		 * Move at least 0.75 to full of the availible bar in given direction,
		 * and more likely to move in the direction where there's more space
		 */
		var/distance_from_top = FISHING_MINIGAME_AREA - fish_position - fish_height
		var/distance_from_bottom = fish_position
		var/top_chance
		if(distance_from_top < FISH_SHORT_JUMP_MIN_DISTANCE)
			top_chance = 0
		else
			top_chance = (distance_from_top/max(distance_from_bottom, 1)) * 100
		var/new_target = fish_position
		if(prob(top_chance))
			new_target += distance_from_top * rand(75, 100)/100
		else
			new_target -= distance_from_bottom * rand(75, 100)/100
		target_position = round(new_target)
		current_velocity_limit = long_jump_velocity_limit

	// Move towards target
	if(!isnull(target_position))
		var/distance = target_position - fish_position
		// about 5 at diff 15 , 10 at diff 30, 30 at diff 100
		var/acceleration_mult = 0.3 * difficulty + 0.5
		var/target_acceleration = distance * acceleration_mult * seconds_per_tick

		fish_velocity = fish_velocity * FISH_FRICTION_MULT + target_acceleration
	else if(prob(short_chance))
		var/distance_from_top = FISHING_MINIGAME_AREA - fish_position - fish_height
		var/distance_from_bottom = fish_position
		var/jump_length
		if(distance_from_top >= FISH_SHORT_JUMP_MIN_DISTANCE)
			jump_length = rand(FISH_SHORT_JUMP_MIN_DISTANCE, FISH_SHORT_JUMP_MAX_DISTANCE)
		if(distance_from_bottom >= FISH_SHORT_JUMP_MIN_DISTANCE && (!jump_length || prob(50)))
			jump_length = -rand(FISH_SHORT_JUMP_MIN_DISTANCE, FISH_SHORT_JUMP_MAX_DISTANCE)
		target_position = clamp(fish_position + jump_length, 0, FISHING_MINIGAME_AREA - fish_height)
		current_velocity_limit = short_jump_velocity_limit

	fish_velocity = clamp(fish_velocity + fish_idle_velocity, -current_velocity_limit, current_velocity_limit)
	fish_position = clamp(fish_position + fish_velocity * seconds_per_tick, 0, FISHING_MINIGAME_AREA - fish_height)

///The proc that moves the bait around, just like in the old TGUI, mostly.
/datum/fishing_challenge/proc/move_bait(seconds_per_tick)
	var/should_bounce = abs(bait_velocity) > BAIT_MIN_VELOCITY_BOUNCE
	bait_position += bait_velocity * seconds_per_tick
	// Hitting the top bound
	if(bait_position > FISHING_MINIGAME_AREA - bait_height)
		bait_position = FISHING_MINIGAME_AREA - bait_height
		if(reeling_state == REELING_STATE_UP || !should_bounce)
			bait_velocity = 0
		else
			bait_velocity = -bait_velocity * bait_bounce_mult
	// Hitting rock bottom
	else if(bait_position < 0)
		bait_position = 0
		if(reeling_state == REELING_STATE_DOWN || !should_bounce)
			bait_velocity = 0
		else
			bait_velocity = -bait_velocity * bait_bounce_mult

	var/fish_on_bait = (fish_position + fish_height >= bait_position) && (bait_position + bait_height >= fish_position)

	var/bidirectional = special_effects & FISHING_MINIGAME_RULE_BIDIRECTIONAL

	var/velocity_change
	switch(reeling_state)
		if(REELING_STATE_UP)
			velocity_change = reeling_velocity
		if(REELING_STATE_DOWN)
			velocity_change = -reeling_velocity
		if(REELING_STATE_IDLE)
			if(!bidirectional || bait_velocity > 0)
				velocity_change = gravity_velocity
			else
				velocity_change = -gravity_velocity
	velocity_change *= (fish_on_bait ? FISH_ON_BAIT_ACCELERATION_MULT : 1) * seconds_per_tick

	velocity_change = round(velocity_change)

	if(current_active_effect == FISHING_MINIGAME_RULE_ANTIGRAV)
		velocity_change = -velocity_change

	/**
	 * Pull the brake on the velocity if the current velocity and the acceleration
	 * have different directions, making the bait less slippery, thus easier to control
	 */
	if(bait_velocity > 0 && velocity_change < 0)
		bait_velocity += max(-bait_velocity, velocity_change * BAIT_DECELERATION_MULT)
	else if(bait_velocity < 0 && velocity_change > 0)
		bait_velocity += min(-bait_velocity, velocity_change * BAIT_DECELERATION_MULT)

	///bidirectional baits stay bouyant while idle
	if(bidirectional && reeling_state == REELING_STATE_IDLE)
		if(velocity_change < 0)
			bait_velocity = max(bait_velocity + velocity_change, 0)
		else if(velocity_change > 0)
			bait_velocity = min(bait_velocity + velocity_change, 0)
	else
		bait_velocity += velocity_change

	//check that the fish area is still intersecting the bait now that it has moved
	fish_on_bait = (fish_position + fish_height >= bait_position) && (bait_position + bait_height >= fish_position)

	if(fish_on_bait)
		completion += completion_gain * seconds_per_tick
		if(completion >= 100)
			complete(TRUE)
	else
		completion -= completion_loss * seconds_per_tick
		if(completion <= 0 && !(special_effects & FISHING_MINIGAME_RULE_NO_ESCAPE))
			user.balloon_alert(user, "it got away!")
			complete(FALSE)

	completion = clamp(completion, 0, 100)

///update the vertical pixel position of both fish and bait, and the icon state of the completion bar
/datum/fishing_challenge/proc/update_visuals()
	var/bait_offset_mult = bait_position/FISHING_MINIGAME_AREA
	fishing_hud.hud_bait.pixel_y = round(MINIGAME_SLIDER_HEIGHT * bait_offset_mult, 1)
	var/fish_offset_mult = fish_position/FISHING_MINIGAME_AREA
	fishing_hud.hud_fish.pixel_y = round(MINIGAME_SLIDER_HEIGHT * fish_offset_mult, 1)
	fishing_hud.hud_completion.icon_state = "completion_[FLOOR(completion, 5)]"

///The screen object which bait, fish, and completion bar are visually attached to.
/atom/movable/screen/fishing_hud
	icon = 'icons/hud/fishing_hud.dmi'
	screen_loc = "CENTER+1:8,CENTER:2"
	name = "fishing minigame"
	appearance_flags = APPEARANCE_UI|KEEP_TOGETHER
	alpha = 230
	///The fish as shown in the minigame
	var/atom/movable/screen/hud_fish/hud_fish
	///The bait as shown in the minigame
	var/atom/movable/screen/hud_bait/hud_bait
	///The completion bar as shown in the minigame
	var/atom/movable/screen/hud_completion/hud_completion

///Initialize bait, fish and completion bar and add them to the visual appearance of this screen object.
/atom/movable/screen/fishing_hud/proc/prepare_minigame(datum/fishing_challenge/challenge)
	icon_state = challenge.background
	add_overlay("frame")
	hud_bait = new(null, null, challenge)
	hud_fish = new(null, null, challenge)
	hud_completion = new(null, null, challenge)
	vis_contents += list(hud_bait, hud_fish, hud_completion)
	challenge.user.client.screen += src
	master_ref = WEAKREF(challenge)

/atom/movable/screen/fishing_hud/Destroy()
	var/datum/fishing_challenge/challenge = master_ref?.resolve()
	if(!isnull(challenge))
		challenge.user.client.screen -= src
	QDEL_NULL(hud_fish)
	QDEL_NULL(hud_bait)
	QDEL_NULL(hud_completion)
	return ..()

/atom/movable/screen/hud_bait
	icon = 'icons/hud/fishing_hud.dmi'
	icon_state = "bait"
	vis_flags = VIS_INHERIT_ID

/atom/movable/screen/hud_bait/Initialize(mapload, datum/hud/hud_owner, datum/fishing_challenge/challenge)
	. = ..()
	if(!challenge || challenge.bait_pixel_height == MINIGAME_BAIT_HEIGHT)
		return
	var/static/icon_height
	if(!icon_height)
		var/list/icon_dimensions = get_icon_dimensions(icon)
		icon_height = icon_dimensions["height"]
	var/height_percent_diff = challenge.bait_pixel_height/MINIGAME_BAIT_HEIGHT
	transform = transform.Scale(1, height_percent_diff)
	pixel_z = -icon_height * (1 - height_percent_diff) * 0.5

/atom/movable/screen/hud_fish
	icon = 'icons/hud/fishing_hud.dmi'
	icon_state = "fish"
	vis_flags = VIS_INHERIT_ID

/atom/movable/screen/hud_fish/Initialize(mapload, datum/hud/hud_owner, datum/fishing_challenge/challenge)
	. = ..()
	if(challenge)
		icon_state = challenge.fish_icon

/atom/movable/screen/hud_completion
	icon = 'icons/hud/fishing_hud.dmi'
	icon_state = "completion_0"
	vis_flags = VIS_INHERIT_ID

/atom/movable/screen/hud_completion/Initialize(mapload, datum/hud/hud_owner, datum/fishing_challenge/challenge)
	. = ..()
	if(challenge)
		icon_state = "completion_[FLOOR(challenge.completion, 5)]"

/// The visual that appears over the fishing spot
/obj/effect/fishing_lure
	icon = 'icons/obj/fishing.dmi'
	icon_state = "lure_idle"

/obj/effect/fishing_lure/Initialize(mapload, atom/spot)
	. = ..()
	if(ismovable(spot)) // we want the lure and therefore the fishing line to stay connected with the fishing spot.
		RegisterSignal(spot, COMSIG_MOVABLE_MOVED, PROC_REF(follow_movable))

/obj/effect/fishing_lure/proc/follow_movable(atom/movable/source)
	SIGNAL_HANDLER

	set_glide_size(source.glide_size)
	forceMove(source.loc)

#undef WAIT_PHASE
#undef BITING_PHASE
#undef MINIGAME_PHASE

#undef FISHING_MINIGAME_AREA
#undef FISH_TARGET_MIN_DISTANCE
#undef FISH_FRICTION_MULT
#undef FISH_SHORT_JUMP_MIN_DISTANCE
#undef FISH_SHORT_JUMP_MAX_DISTANCE
#undef FISH_ON_BAIT_ACCELERATION_MULT
#undef BAIT_MIN_VELOCITY_BOUNCE
#undef BAIT_DECELERATION_MULT

#undef MINIGAME_SLIDER_HEIGHT
#undef MINIGAME_BAIT_HEIGHT
#undef MINIGAME_FISH_HEIGHT

#undef BAIT_HEIGHT_DIFFICULTY_MALUS

#undef REELING_STATE_IDLE
#undef REELING_STATE_UP
#undef REELING_STATE_DOWN

#undef MAX_FISH_COMPLETION_MALUS
#undef BITING_TIME_WINDOW
