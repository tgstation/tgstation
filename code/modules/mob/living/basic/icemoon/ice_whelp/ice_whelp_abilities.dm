/// Breathe "fire" in a line (it's freezing cold)
/datum/action/cooldown/mob_cooldown/fire_breath/ice
	name = "Ice Breath"
	desc = "Fire a cold line of fire towards the enemy!"
	button_icon = 'icons/effects/magic.dmi'
	button_icon_state = "fireball"
	cooldown_time = 6 SECONDS
	fire_range = 7
	fire_damage = 10
	fire_delay = 0.75 DECISECONDS
	/// Time to warn people about what we are doing
	var/forecast_delay = 0.5 SECONDS
	/// What turf are we aiming at?
	var/turf/target_turf
	/// Overlay we show when we're about to fire
	var/image/forecast_overlay
	/// Icon state used for overlay
	var/forecast_overlay_state = "ice_whelp_telegraph_dir"

/datum/action/cooldown/mob_cooldown/fire_breath/ice/New(Target, original)
	. = ..()
	forecast_overlay = image('icons/mob/simple/icemoon/icemoon_monsters.dmi', forecast_overlay_state)

/// Apply our specific fire breathing shape, in proc form so we can override it in subtypes
/datum/action/cooldown/mob_cooldown/fire_breath/ice/attack_sequence(atom/target)
	target_turf = get_turf(target)
	INVOKE_ASYNC(src, PROC_REF(attack_forecast))

/// Charge up before we breathe fire
/datum/action/cooldown/mob_cooldown/fire_breath/ice/proc/attack_forecast()
	owner.face_atom(target_turf)
	owner.Shake(pixelshiftx = 1, pixelshifty = 0, duration = forecast_delay)
	forecast_overlay.setDir(get_dir(owner, target_turf))
	owner.add_overlay(forecast_overlay)
	var/succeeded = do_after(owner, delay = forecast_delay, target = owner, hidden = TRUE)
	owner.cut_overlay(forecast_overlay)
	if (succeeded)
		playsound(owner.loc, fire_sound, 200, TRUE)
		breath_attack()

/// Actually breathe fire
/datum/action/cooldown/mob_cooldown/fire_breath/ice/proc/breath_attack()
	owner.face_atom(target_turf)
	fire_line(target_turf)
	target_turf = null

/datum/action/cooldown/mob_cooldown/fire_breath/ice/burn_turf(turf/fire_turf, list/hit_list, atom/source)
	var/obj/effect/hotspot/fire_hotspot = ..()
	fire_hotspot.add_atom_colour(COLOR_BLUE_LIGHT, FIXED_COLOUR_PRIORITY) // You're blue now, that's my attack
	return fire_hotspot

/datum/action/cooldown/mob_cooldown/fire_breath/ice/on_burn_mob(mob/living/barbecued, mob/living/source)
	barbecued.apply_status_effect(/datum/status_effect/ice_block_talisman, 2 SECONDS)
	to_chat(barbecued, span_userdanger("You're frozen solid by [source]'s icy breath!"))
	barbecued.adjustFireLoss(fire_damage)

/// Breathe really cold fire in a plus shape, like bomberman
/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption
	name = "Ice Eruption"
	desc = "Unleash cold fire in all directions"
	button_icon = 'icons/effects/fire.dmi'
	button_icon_state = "light"
	cooldown_time = 6 SECONDS
	click_to_activate = FALSE
	fire_range = 3
	forecast_delay = 1 SECONDS
	fire_delay = 1.5 DECISECONDS
	forecast_overlay_state = "ice_whelp_telegraph_all"

/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption/breath_attack()
	target_turf = null

	var/list/hit_list = list(owner)
	var/list/nearby_turfs = list()
	for (var/turf/open/target_turf in circle_range(owner, fire_range))
		if (target_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		var/turf_dist = get_dist(owner, target_turf)
		if (turf_dist == 0)
			continue
		LAZYADDASSOCLIST(nearby_turfs, "[turf_dist]", target_turf)

	for (var/i in 1 to fire_range)
		for (var/turf/open/kindling as anything in nearby_turfs["[i]"])
			burn_turf(kindling, hit_list, owner)
		sleep(fire_delay)
