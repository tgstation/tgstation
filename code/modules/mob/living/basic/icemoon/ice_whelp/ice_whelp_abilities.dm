/// Breathe "fire" in a line (it's freezing cold)
/datum/action/cooldown/mob_cooldown/fire_breath/ice
	name = "Ice Breath"
	desc = "Fire a cold line of fire towards the enemy!"
	button_icon = 'icons/effects/magic.dmi'
	button_icon_state = "fireball"
	cooldown_time = 3 SECONDS
	melee_cooldown_time = 0 SECONDS
	fire_range = 4
	fire_damage = 10

/datum/action/cooldown/mob_cooldown/fire_breath/ice/burn_turf(turf/fire_turf, list/hit_list, atom/source)
	var/obj/effect/hotspot/fire_hotspot = ..()
	fire_hotspot.add_atom_colour(COLOR_BLUE_LIGHT, FIXED_COLOUR_PRIORITY) // You're blue now, that's my attack
	return fire_hotspot

/datum/action/cooldown/mob_cooldown/fire_breath/ice/on_burn_mob(mob/living/barbecued, mob/living/source)
	barbecued.apply_status_effect(/datum/status_effect/ice_block_talisman, 2 SECONDS)
	to_chat(barbecued, span_userdanger("You're frozen solid by [source]'s icy breath!"))
	barbecued.adjustFireLoss(fire_damage)

/// Breathe really cold fire in a plus shape, like bomberman
/datum/action/cooldown/mob_cooldown/fire_breath/ice/cross
	name = "Fire all directions"
	desc = "Unleash lines of cold fire in all directions"
	button_icon = 'icons/effects/fire.dmi'
	button_icon_state = "1"
	cooldown_time = 4 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	fire_range = 6

/datum/action/cooldown/mob_cooldown/fire_breath/ice/cross/attack_sequence(atom/target)
	playsound(owner.loc, fire_sound, 200, TRUE)
	for(var/direction in GLOB.cardinals)
		var/turf/target_fire_turf = get_ranged_target_turf(owner, direction, fire_range)
		fire_line(target_fire_turf)
