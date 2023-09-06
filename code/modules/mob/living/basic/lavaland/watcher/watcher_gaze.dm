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
	cooldown_time = 30 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	click_to_activate = FALSE
	shared_cooldown = NONE
	/// At what range do we check for vision?
	var/effect_radius = 7
	/// How long does it take to play our various animation stages
	var/animation_time = 0.8 SECONDS
	/// How long after pressing the button do we give people to turn around?
	var/wait_delay = 1.6 SECONDS
	/// What are we currently displaying?
	var/image/current_overlay
	/// Timer until we go to the next stage
	var/stage_timer

/datum/action/cooldown/mob_cooldown/watcher_gaze/Activate(mob/living/target)
	show_indicator_overlay("eye_open")
	stage_timer = addtimer(CALLBACK(src, PROC_REF(show_indicator_overlay), "eye_pulse"), animation_time, TIMER_STOPPABLE)
	StartCooldown(360 SECONDS, 360 SECONDS)
	owner.visible_message(span_warning("[owner]'s eye glows ominously!"))
	if (do_after(owner, delay = wait_delay, target = owner))
		trigger_effect()
	else
		deltimer(stage_timer)
		clear_current_overlay()
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/watcher_gaze/Destroy()
	deltimer(stage_timer)
	clear_current_overlay()
	return ..()

/datum/action/cooldown/mob_cooldown/watcher_gaze/Remove(mob/removed_from)
	deltimer(stage_timer)
	clear_current_overlay()
	return ..()

/// Do some effects to whoever is looking at us
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/trigger_effect()
	deltimer(stage_timer)
	show_indicator_overlay("eye_flash")
	for (var/mob/living/viewer in viewers(effect_radius, owner))
		var/view_dir = get_dir(viewer, owner)
		if (!(viewer.dir & view_dir) || viewer.stat != CONSCIOUS)
			continue
		if (!apply_effect(viewer))
			continue
		var/image/flashed_overlay = image(
			icon = 'icons/effects/eldritch.dmi',
			loc = viewer,
			icon_state = "eye_flash",
			pixel_x = -viewer.pixel_x,
			pixel_y = -viewer.pixel_y,
		)
		flick_overlay_global(flashed_overlay, show_to = GLOB.clients, duration = animation_time)
	stage_timer = addtimer(CALLBACK(src, PROC_REF(hide_eye)), animation_time, TIMER_STOPPABLE)
	var/mob/living/living_owner = owner
	living_owner.Stun(1.5 SECONDS, ignore_canstun = TRUE)

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
	current_overlay = image(icon = 'icons/effects/eldritch.dmi', loc = owner, icon_state = overlay_state, pixel_x = -owner.pixel_x, pixel_y = 28, layer = ABOVE_ALL_MOB_LAYER)
	SET_PLANE_EXPLICIT(current_overlay, ABOVE_LIGHTING_PLANE, owner)
	for(var/client/add_to in GLOB.clients)
		add_to.images += current_overlay

/// Hide whatever overlay we are showing
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/clear_current_overlay()
	if (!isnull(current_overlay))
		remove_image_from_clients(current_overlay, GLOB.clients)
	current_overlay = null

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
	to_chat(viewer, span_warning("You are repulsed by the force of [owner]'s cold stare!"))
	viewer.apply_status_effect(/datum/status_effect/freon/watcher/extended)
	viewer.safe_throw_at(
		target = get_edge_target_turf(owner, get_dir(owner, get_step_away(viewer, owner))),
		range = max_throw,
		speed = 1,
		thrower = owner,
		force = MOVE_FORCE_EXTREMELY_STRONG,
	)
