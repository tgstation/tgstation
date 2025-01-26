/// Repeatedly throw up until there's nothing left inside, regrettably sufficiently complex that it requires its own file
/datum/action/cooldown/mob_cooldown/goose_vomit
	name = "Vomit"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	button_icon_state = "vomit"
	button_icon = 'icons/mob/simple/animal.dmi'
	cooldown_time = INFINITY // We reset the cooldown when we are done throwing up
	text_cooldown = FALSE
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE
	/// Extra time to spend chundering
	var/extra_duration = 0 SECONDS

/datum/action/cooldown/mob_cooldown/goose_vomit/Grant(mob/granted_to)
	. = ..()
	if(!owner)
		return
	RegisterSignals(owner, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/goose_vomit/Remove(mob/removed_from)
	UnregisterSignal(owner, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	return ..()

/datum/action/cooldown/mob_cooldown/goose_vomit/IsAvailable(feedback)
	. = ..()
	if (!.)
		return FALSE
	if (!length(owner.contents))
		if (feedback)
			owner.balloon_alert(owner, "stomach empty!")
		return FALSE
	if (!isliving(owner))
		if (feedback)
			owner.balloon_alert(owner, "you're not alive!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/goose_vomit/Activate(atom/target)
	StartCooldown(INFINITY)
	if (istype(owner, /mob/living/basic/goose))
		owner.icon_state = "vomit"
		flick("vomit_start", owner)
		owner.ai_controller?.set_blackboard_key(BB_GOOSE_VOMIT_CHANCE, 0)
		addtimer(CALLBACK(src, PROC_REF(start_vomiting)), 13) // 13 frame long animation
	else
		start_vomiting()

/// Start the performance
/datum/action/cooldown/mob_cooldown/goose_vomit/proc/start_vomiting()
	var/mob/living/living_owner = owner
	living_owner.apply_status_effect(/datum/status_effect/goose_vomit, extra_duration)
	extra_duration = 0

/// Handles iteratively emptying our stomach
/datum/status_effect/goose_vomit
	id = "goose_vomit"
	alert_type = null
	tick_interval = 1 SECONDS
	/// How long do we vomit for?
	var/vomit_duration = 2.5 SECONDS
	/// How long have we spent vomiting?
	var/elapsed_time = 0 SECONDS
	/// Chance to step in a random direction
	var/move_chance = 80
	/// Chance to produce an item per tick
	var/vomit_item_chance = 50

/datum/status_effect/goose_vomit/on_creation(mob/living/new_owner, extra_duration = 0)
	vomit_duration += extra_duration
	return ..()

/datum/status_effect/goose_vomit/on_apply()
	owner.set_jitter_if_lower(vomit_duration)
	owner.ai_controller?.set_blackboard_key(BB_GOOSE_PANICKED, TRUE)
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_owner_died))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	return TRUE

/datum/status_effect/goose_vomit/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED))
	owner.ai_controller?.set_blackboard_key(BB_GOOSE_PANICKED, FALSE)
	if (istype(owner, /mob/living/basic/goose) && owner.stat != DEAD)
		var/mob/living/basic/goose_mob = owner
		flick("vomit_end", owner)
		goose_mob.icon_state = goose_mob.icon_living

	var/datum/action/cooldown/mob_cooldown/goose_vomit/vomit_action = locate() in owner.actions
	vomit_action?.StartCooldown(0 SECONDS)

/// Don't keep vomiting from beyond the grave
/datum/status_effect/goose_vomit/proc/on_owner_died()
	SIGNAL_HANDLER
	qdel(src)

/// For good measure we'll spit up every time we take a step too
/datum/status_effect/goose_vomit/proc/on_owner_moved()
	SIGNAL_HANDLER
	vomit_iteratively(can_move = FALSE)

/datum/status_effect/goose_vomit/tick(seconds_between_ticks)
	elapsed_time += seconds_between_ticks

	if (!length(owner.contents))
		qdel(src)
		return

	if (elapsed_time <= vomit_duration)
		vomit_iteratively()
	else
		vomit_finale()

/// One to come up
/datum/status_effect/goose_vomit/proc/vomit_iteratively(can_move = TRUE)
	if (prob(vomit_item_chance))
		hurl_item()
	else
		make_mess(owner.drop_location())

	if (can_move && prob(move_chance))
		var/move_dir = pick(GLOB.alldirs)
		var/turf/destination_turf = get_step(owner, move_dir)
		owner.Move(destination_turf, move_dir)

/// Stop fucking around and get the rest of it out
/datum/status_effect/goose_vomit/proc/vomit_finale()
	tick_interval = 0.1 SECONDS
	owner.set_jitter_if_lower(1 SECONDS)
	hurl_item(vomit_strongly = TRUE)

/// Produce an item from our inventory
/datum/status_effect/goose_vomit/proc/hurl_item(vomit_strongly = FALSE)
	if (!length(owner.contents))
		return
	var/obj/item/thing = pick_n_take(owner.contents)
	if (!ismovable(thing) || HAS_TRAIT(thing, TRAIT_NOT_BARFABLE))
		qdel(src) // Someone is fucking around with this goose, let's not get stuck in this forever
		return
	var/drop_location = owner.drop_location()

	thing.forceMove(drop_location)
	if (isopenturf(drop_location))
		make_mess(drop_location)
		var/destination = get_edge_target_turf(drop_location, pick(GLOB.alldirs))
		var/throwRange = vomit_strongly ? rand(2, 8) : 1
		thing.safe_throw_at(destination, throwRange, 2)

/// Make a mess
/datum/status_effect/goose_vomit/proc/make_mess(turf/open/drop_turf)
	if (!istype(drop_turf))
		return
	playsound(drop_turf, 'sound/effects/splat.ogg', 50, TRUE)
	drop_turf.add_vomit_floor(owner)


/// Wheeze until we die
/datum/status_effect/goose_choking
	id = "goose_choking"
	alert_type = null
	duration = 30 SECONDS
	tick_interval = 2 SECONDS
	/// Chance per second to emote
	var/emote_prob = 18
	/// What things do we do while dying
	var/static/list/emotes = list("chokes.", "coughs.", "gasps.", "tries urgently to breathe.", "shudders violently.", "wheezes.")

/datum/status_effect/goose_choking/tick(seconds_between_ticks)
	if (SPT_PROB(emote_prob, seconds_between_ticks))
		owner.manual_emote(pick(emotes))

/datum/status_effect/goose_choking/on_apply()
	owner.set_jitter_if_lower(duration)
	owner.ai_controller?.set_blackboard_key(BB_GOOSE_PANICKED, TRUE)
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_owner_died))
	return TRUE

/datum/status_effect/goose_choking/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	if (duration >= world.time)
		return // Saved by something, although probably by dying early
	owner.death_message = "lets out one final oxygen-deprived honk before [owner.p_they()] go[owner.p_es()] limp and lifeless.."
	owner.death()

/// Don't keep dying if we died
/datum/status_effect/goose_choking/proc/on_owner_died()
	SIGNAL_HANDLER
	qdel(src)
