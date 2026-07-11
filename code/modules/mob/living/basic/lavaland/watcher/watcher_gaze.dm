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
	/// Image displayed for to-be-blinded victims
	var/image/danger_overlay
	/// Timer until we go to the next stage
	var/stage_timer
	/// Proximity monitor we use to keep track of possible targets
	var/datum/proximity_monitor/watcher_gaze/proximity_monitor
	/// List of textrefs to mobs in range we're currently displaying warnings to -> are they currently under threat or not
	var/list/tracked_mobs = list()

/datum/action/cooldown/mob_cooldown/watcher_gaze/Activate(mob/living/target)
	proximity_monitor = new(owner, effect_radius, ability = src)
	// Start tracking all potential victims in range as proxmon won't trigger on them
	for (var/mob/living/victim in viewers(effect_radius, owner))
		on_entered(victim)
	show_indicator_overlay("eye_open")
	stage_timer = addtimer(CALLBACK(src, PROC_REF(show_indicator_overlay), "eye_pulse"), animation_time, TIMER_STOPPABLE)
	StartCooldown(360 SECONDS, 360 SECONDS)
	owner.visible_message(span_warning("[owner]'s eye glows ominously!"))
	if (do_after(owner, delay = wait_delay, target = owner, hidden = TRUE))
		trigger_effect()
	else
		deltimer(stage_timer)
		clear_current_overlay()
	StartCooldown()
	tracked_mobs.Cut()
	QDEL_NULL(proximity_monitor)
	return TRUE

/datum/action/cooldown/mob_cooldown/watcher_gaze/Destroy()
	tracked_mobs.Cut()
	QDEL_NULL(proximity_monitor)
	deltimer(stage_timer)
	clear_current_overlay()
	return ..()

/datum/action/cooldown/mob_cooldown/watcher_gaze/Remove(mob/removed_from)
	tracked_mobs.Cut()
	QDEL_NULL(proximity_monitor)
	deltimer(stage_timer)
	clear_current_overlay()
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
	current_overlay = image(icon = 'icons/effects/eldritch.dmi', loc = owner, icon_state = "[overlay_state]_y", layer = ABOVE_ALL_MOB_LAYER)
	current_overlay.pixel_w = -owner.pixel_x
	current_overlay.pixel_z = 28
	SET_PLANE_EXPLICIT(current_overlay, ABOVE_LIGHTING_PLANE, owner)
	// This will cause turning to reset the animation *but* this is the best option
	// as modifying alpha requires readding the image to client.images for it to actually update
	danger_overlay = image(icon = 'icons/effects/eldritch.dmi', loc = owner, icon_state = overlay_state, layer = ABOVE_ALL_MOB_LAYER)
	danger_overlay.pixel_w = -owner.pixel_x
	danger_overlay.pixel_z = 28
	SET_PLANE_EXPLICIT(danger_overlay, ABOVE_LIGHTING_PLANE, owner)

	for(var/client/add_to in GLOB.clients)
		var/mob/living/victim = add_to.mob
		if (istype(victim) && tracked_mobs[REF(victim)])
			add_to.images += danger_overlay
		else
			add_to.images += current_overlay

/// Hide whatever overlay we are showing
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/clear_current_overlay()
	if (!isnull(current_overlay))
		remove_image_from_clients(current_overlay, GLOB.clients)
		remove_image_from_clients(danger_overlay, GLOB.clients)
	current_overlay = null
	danger_overlay = null

/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/on_entered(mob/living/arrived)
	if (arrived == owner)
		return
	// Already tracked
	if (isnull(tracked_mobs[REF(arrived)]))
		RegisterSignals(arrived, list(COMSIG_ATOM_POST_DIR_CHANGE, COMSIG_MOB_STATCHANGE), PROC_REF(update_state))
	update_state(arrived)

/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/on_exited(mob/living/exited)
	if (exited == owner)
		return
	UnregisterSignal(exited, list(COMSIG_ATOM_POST_DIR_CHANGE, COMSIG_MOB_STATCHANGE))
	tracked_mobs -= REF(exited)
	if (current_overlay && exited.client)
		exited.client.images += current_overlay
		exited.client.images -= danger_overlay

/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/update_state(mob/living/target)
	SIGNAL_HANDLER
	// Don't do viewers(), too costly and only applies for thermals anyways
	if (valid_target(target))
		if (!tracked_mobs[REF(target)])
			tracked_mobs[REF(target)] = TRUE
			if (current_overlay && target.client)
				target.client.images -= current_overlay
				target.client.images += danger_overlay
	else if (tracked_mobs[REF(target)] != FALSE) // Can be null
		tracked_mobs[REF(target)] = FALSE
		if (current_overlay && target.client)
			target.client.images += current_overlay
			target.client.images -= danger_overlay

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
