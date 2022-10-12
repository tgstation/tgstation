/**
 * Gives you three stacks of Brimdust Coating, when you get hit by anything it will make a short ranged explosion.
 * If this happens on the station it also sets you on fire.
 * If implanted, you can shake off a cloud of brimdust to give this buff to people around you.area
 * I you have this inside you on the station and you ever catch fire it explodes.
 */
/obj/item/organ/internal/monster_core/reusable/brimdust_sac
	name = "brimdust sac"
	desc = "A strange organ from a brimdemon. You can shake it out to coat yourself in explosive powder."
	desc_preserved = "A strange organ from a brimdemon. It is preserved, allowing you to coat yourself in its explosive contents at your leisure."
	desc_inert = "A decayed brimdemon organ. There's nothing usable left inside it."
	user_status = /datum/status_effect/lobster_rush
	internal_use_cooldown = 5 MINUTES

/obj/item/organ/internal/monster_core/reusable/brimdust_sac/on_life(delta_time, times_fired)
	. = ..()
	if (!owner.on_fire)
		return
	if (lavaland_equipment_pressure_check(get_turf(source))
		return
	explode_organ()

/// Your gunpowder organ blows up, uh oh
/obj/item/organ/internal/monster_core/reusable/brimdust_sac/proc/explode_organ()
	// Do something cool here
	to_chat(owner, span_boldwarning("Your [src] ignites!"))
	qdel(src)

/**
 * If you take brute damage with this buff, hurt and push everyone next to you.
 * If you catch fire and or on the space station, detonate all remaining stacks in a way which hurts you.
 * Washes off if you get wet.
 */
/datum/status_effect/stacking/brimdust_coating
	id = "brimdust_coating"
	stacks = 3
	max_stacks = 3
	tick_interval = -1
	consumed_on_threshold = FALSE
