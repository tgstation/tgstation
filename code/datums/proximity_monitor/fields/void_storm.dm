/*!
 * Void storm for the void heretic ascension
 *
 * Follows the heretic around and acts like an aura with damaging effects for non-heretics
 */
/datum/proximity_monitor/advanced/void_storm
	edge_is_a_field = TRUE
	// lazylist that keeps track of the overlays added
	var/list/turf_effects
	var/static/image/storm_overlay = image('icons/effects/weather_effects.dmi', "snow_storm")

/datum/proximity_monitor/advanced/void_storm/New(atom/_host, range, _ignore_if_not_on_turf)
	. = ..()
	recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/void_storm/recalculate_field(full_recalc)
	full_recalc = TRUE // We always perform a full recalc because we need to update ALL the sprites
	return ..()

/datum/proximity_monitor/advanced/void_storm/cleanup_field_turf(turf/target)
	. = ..()
	var/obj/effect/abstract/effect = LAZYACCESS(turf_effects, target)
	LAZYREMOVE(turf_effects, target)
	if(effect)
		qdel(effect)

/datum/proximity_monitor/advanced/void_storm/setup_field_turf(turf/target)
	. = ..()
	var/obj/effect/abstract/effect = new(target) // Makes the field visible to players.
	effect.alpha = 255 - get_dist(target, host.loc) * 23
	effect.color = COLOR_BLACK
	effect.icon = storm_overlay.icon
	effect.icon_state = storm_overlay.icon_state
	effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	effect.layer = ABOVE_ALL_MOB_LAYER
	SET_PLANE(effect, ABOVE_GAME_PLANE, target)
	LAZYSET(turf_effects, target, effect)
