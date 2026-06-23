/**
 * Do something nasty to everyone nearby if they're looking at us.
 */
/datum/action/cooldown/mob_cooldown/watcher_gaze
	name = "Disorienting Gaze"
	desc = "After a delay, flash everyone looking at you."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "gaze"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	cooldown_time = 20 SECONDS
	click_to_activate = FALSE
	shared_cooldown = NONE
	/// At what range do we check for vision?
	var/effect_radius = 7
	/// How long does it take to play our various animation stages
	var/animation_time = 0.8 SECONDS
	/// How long after pressing the button do we give people to turn around?
	var/wait_delay = 1.6 SECONDS
	/// What are we currently displaying to all mobs?
	var/image/current_overlay
	/// Icon state of the current overlay
	var/current_overlay_state
	/// Timer until we go to the next stage
	var/stage_timer
	/// Proximity monitor we use to keep track of possible targets
	var/datum/proximity_monitor/watcher_gaze/proximity_monitor
	/// List of textrefs to mobs in range we're currently displaying warnings to -> if they're currently seeing the warning overlay or not
	var/list/tracked_mobs = list()
	/// List of weakrefs to mobs -> warning image they're currently seeing
	var/list/mob_images = list()

/datum/action/cooldown/mob_cooldown/watcher_gaze/Activate(mob/living/target)
	proximity_monitor = new(owner, effect_radius, ability = src)
	// Start tracking all potential victims in range as proxmon won't trigger on them
	for (var/mob/living/victim in viewers(effect_radius, owner))
		if (valid_target(victim))
			tracked_mobs[REF(victim)] = TRUE
		else
			tracked_mobs[REF(victim)] = FALSE
	show_indicator_overlay("eye_open")
	stage_timer = addtimer(CALLBACK(src, PROC_REF(show_indicator_overlay), "eye_pulse"), animation_time, TIMER_STOPPABLE)
	StartCooldown(360 SECONDS, 360 SECONDS)
	owner.visible_message(span_warning("[owner]'s eye glows ominously!"))
	if (do_after(owner, delay = wait_delay, target = owner, hidden = TRUE))
		trigger_effect()
	else
		deltimer(stage_timer)
		clear_current_overlay()
	// Don't cut images here, we may have an ongoing animation still
	tracked_mobs.Cut()
	QDEL_NULL(proximity_monitor)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/watcher_gaze/Destroy()
	QDEL_NULL(proximity_monitor)
	deltimer(stage_timer)
	clear_current_overlay()
	tracked_mobs.Cut()
	return ..()

/datum/action/cooldown/mob_cooldown/watcher_gaze/Remove(mob/removed_from)
	QDEL_NULL(proximity_monitor)
	deltimer(stage_timer)
	clear_current_overlay()
	tracked_mobs.Cut()
	return ..()

/// Do some effects to whoever is looking at us
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/trigger_effect()
	deltimer(stage_timer)
	show_indicator_overlay("eye_flash")
	for (var/mob/living/viewer in viewers(effect_radius, owner))
		if (!valid_target(viewer))
			continue
		if (!apply_effect(viewer))
			continue
		var/image/flashed_overlay = image(
			icon = 'icons/effects/eldritch.dmi',
			loc = viewer,
			icon_state = "eye_flash"
		)
		flashed_overlay.pixel_w = -viewer.pixel_x
		flashed_overlay.pixel_z = -viewer.pixel_y
		flick_overlay_global(flashed_overlay, show_to = GLOB.clients, duration = animation_time)
	stage_timer = addtimer(CALLBACK(src, PROC_REF(hide_eye)), animation_time, TIMER_STOPPABLE)
	var/mob/living/living_owner = owner
	living_owner.Stun(1.5 SECONDS, ignore_canstun = TRUE)

/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/valid_target(mob/living/viewer)
	if (!istype(viewer) || viewer.stat || viewer == owner)
		return FALSE
	if (!(viewer.dir & get_dir(viewer, owner)))
		return FALSE
	return TRUE

/// Do something bad to someone who was looking at us
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/apply_effect(mob/living/viewer)
	if (!viewer.flash_act(intensity = 4, affect_silicon = TRUE, visual = TRUE, length = 3 SECONDS))
		return FALSE
	viewer.set_confusion_if_lower(12 SECONDS)
	to_chat(viewer, span_warning("You are blinded by [owner]'s piercing gaze!"))
	return TRUE

/// Animate our effect out
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/hide_eye()
	show_indicator_overlay("eye_close")
	stage_timer = addtimer(CALLBACK(src, PROC_REF(clear_current_overlay)), animation_time, TIMER_STOPPABLE)

/// Display an animated overlay over our head to indicate what's going on
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/show_indicator_overlay(overlay_state)
	clear_current_overlay()
	current_overlay_state = overlay_state
	current_overlay = image(icon = 'icons/effects/eldritch.dmi', loc = owner, icon_state = "[overlay_state]_y", layer = ABOVE_ALL_MOB_LAYER)
	current_overlay.pixel_w = -owner.pixel_x
	current_overlay.pixel_z = 28
	SET_PLANE_EXPLICIT(current_overlay, ABOVE_LIGHTING_PLANE, owner)

	for(var/client/add_to in GLOB.clients)
		var/mob/living/victim = add_to.mob
		add_to.images += current_overlay
		if (!istype(victim) || isnull(tracked_mobs[REF(victim)]))
			continue
		var/image/danger_overlay = get_danger_overlay()
		// Need to have them always on display because animation starts from scratch when we add an image to client.images
		danger_overlay.alpha = tracked_mobs[REF(victim)] ? 255 : 0
		mob_images[WEAKREF(victim)] = danger_overlay
		add_to.images += danger_overlay

/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/get_danger_overlay()
	var/image/danger_overlay = image(icon = 'icons/effects/eldritch.dmi', loc = owner, icon_state = current_overlay_state, layer = ABOVE_ALL_MOB_LAYER + 0.01)
	danger_overlay.pixel_w = -owner.pixel_x
	danger_overlay.pixel_z = 28
	SET_PLANE_EXPLICIT(danger_overlay, ABOVE_LIGHTING_PLANE, owner)
	return danger_overlay

/// Hide whatever overlay we are showing
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/clear_current_overlay()
	if (!isnull(current_overlay))
		remove_image_from_clients(current_overlay, GLOB.clients)

	for (var/datum/weakref/mob_ref as anything in mob_images)
		var/mob/living/victim = mob_ref.resolve()
		if (!isnull(victim) && victim.client)
			victim.client.images -= mob_images[mob_ref]
		else // Orphaned overlay, needs cleanup - only happens in case of bodyswaps or logouts, and there isn't really a better way to handle this without risking harddels
			remove_image_from_clients(mob_images[mob_ref], GLOB.clients)

	current_overlay = null
	mob_images.Cut()

/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/on_entered(mob/living/arrived)
	// Already tracked
	if (isnull(tracked_mobs[REF(arrived)]))
		RegisterSignals(arrived, list(COMSIG_ATOM_POST_DIR_CHANGE, COMSIG_MOB_STATCHANGE), PROC_REF(update_state))
	update_state(arrived)

/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/on_exited(mob/living/exited)
	UnregisterSignal(exited, list(COMSIG_ATOM_POST_DIR_CHANGE, COMSIG_MOB_STATCHANGE))
	tracked_mobs -= REF(exited)
	var/image/danger_overlay = mob_images[WEAKREF(exited)]
	if (!isnull(danger_overlay))
		danger_overlay.alpha = 0

/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/update_state(mob/living/target)
	SIGNAL_HANDLER

	// Don't do viewers(), too costly and only applies for thermals anyways
	var/prev_state = tracked_mobs[REF(target)]
	if (valid_target(target))
		tracked_mobs[REF(target)] = TRUE
	else
		tracked_mobs[REF(target)] = FALSE

	var/image/danger_overlay = mob_images[WEAKREF(target)]
	if (!isnull(danger_overlay))
		if (prev_state != tracked_mobs[REF(target)])
			danger_overlay.alpha = tracked_mobs[REF(target)] ? 255 : 0
		return

	danger_overlay = get_danger_overlay()
	mob_images[WEAKREF(target)] = danger_overlay
	danger_overlay.alpha = tracked_mobs[REF(target)] ? 255 : 0
	target.client?.images += danger_overlay

// No need to refresh targets when the owner moves as the ability uses a do_after and will stop if the owner moves anyways
/datum/proximity_monitor/watcher_gaze
	/// Ability we're linked to
	var/datum/action/cooldown/mob_cooldown/watcher_gaze/gaze = null

/datum/proximity_monitor/watcher_gaze/Destroy()
	gaze = null
	return ..()

/datum/proximity_monitor/watcher_gaze/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, datum/action/cooldown/mob_cooldown/watcher_gaze/ability = null)
	. = ..()
	gaze = ability

/datum/proximity_monitor/watcher_gaze/on_entered(atom/source, atom/movable/arrived, turf/old_loc)
	if (source != host && arrived != host && isliving(arrived))
		gaze.on_entered(arrived)

/datum/proximity_monitor/watcher_gaze/on_uncrossed(atom/source, atom/movable/gone, direction)
	if (source != host && gone != host && isliving(gone))
		gaze.on_exited(gone)

/datum/proximity_monitor/watcher_gaze/on_initialized(turf/location, atom/created, init_flags)
	if (isliving(created))
		gaze.on_entered(created)

/// Magmawing glare burns you
/datum/action/cooldown/mob_cooldown/watcher_gaze/fire
	name = "Searing Glare"
	desc = "After a delay, burn and stun everyone looking at you."

/datum/action/cooldown/mob_cooldown/watcher_gaze/fire/apply_effect(mob/living/viewer)
	to_chat(viewer, span_warning("[owner]'s searing glare forces you to the ground!"))
	viewer.Paralyze(3 SECONDS)
	viewer.adjust_fire_stacks(10)
	viewer.ignite_mob()
	return TRUE

/// Icewing glare freezes you
/datum/action/cooldown/mob_cooldown/watcher_gaze/ice
	name = "Cold Stare"
	desc = "After a delay, freeze and repulse everyone looking at you."
	/// Max distance to throw people looking at us
	var/max_throw = 3

/datum/action/cooldown/mob_cooldown/watcher_gaze/ice/apply_effect(mob/living/viewer)
	if(!HAS_TRAIT(viewer, TRAIT_RESISTCOLD))
		return
	to_chat(viewer, span_warning("You are repulsed by the force of [owner]'s cold stare!"))
	viewer.apply_status_effect(/datum/status_effect/freon/watcher/extended)
	viewer.safe_throw_at(
		target = get_edge_target_turf(owner, get_dir(owner, get_step_away(viewer, owner))),
		range = max_throw,
		speed = 1,
		thrower = owner,
		force = MOVE_FORCE_EXTREMELY_STRONG,
	)
