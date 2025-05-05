
/obj/effect/anomaly/dimensional
	name = "dimensional anomaly"
	icon_state = "dimensional"
	anomaly_core = /obj/item/assembly/signaler/anomaly/dimensional
	lifespan = ANOMALY_COUNTDOWN_TIMER * 20 // will generally be killed off by reaching max teleports first
	move_chance = 0
	/// Range of effect, if left alone anomaly will convert a 2(range)+1 squared area.
	var/range = 3
	/// List of turfs this anomaly will try to transform before relocating
	var/list/turf/target_turfs = list()
	/// Current anomaly 'theme', dictates what tiles to create.
	var/datum/dimension_theme/theme
	/// Effect displaying on the anomaly to represent the theme.
	var/mutable_appearance/theme_icon
	/// How many times we can still teleport. Delete self if it hits 0 and we try to teleport. If immortal, will simply stay where it is
	var/teleports_left
	/// Minimum teleports it will do before going away permanently
	var/minimum_teleports = 1
	/// Maximum teleports it will do before going away permanently
	var/maximum_teleports = 4

/obj/effect/anomaly/dimensional/Initialize(mapload, new_lifespan)
	. = ..()
	overlays += mutable_appearance('icons/effects/effects.dmi', "dimensional_overlay")

	animate(src, transform = matrix()*0.85, time = 3, loop = -1)
	animate(transform = matrix(), time = 3, loop = -1)

	teleports_left = rand(minimum_teleports, maximum_teleports)

/obj/effect/anomaly/dimensional/Destroy()
	theme = null
	target_turfs = null
	return ..()

/obj/effect/anomaly/dimensional/anomalyEffect(seconds_per_tick)
	. = ..()
	transmute_area()

/**
 * Transforms a turf in our prepared area.
 */
/obj/effect/anomaly/dimensional/proc/transmute_area()
	if (!theme)
		prepare_area()
	if (!target_turfs.len)
		if(teleports_left <= 0 && !immortal)
			detonate()
			return
		teleports_left--
		relocate()
		return

	var/turf/affected_turf = target_turfs[1]
	theme.apply_theme(affected_turf, show_effect = TRUE)
	target_turfs -= affected_turf

/**
 * Prepare a new area for transformation into a new theme.
 * Optionally pass in the typepath of an anomaly theme to use that one.
 */
/obj/effect/anomaly/dimensional/proc/prepare_area(new_theme_path)
	if (!new_theme_path)
		new_theme_path = pick(subtypesof(/datum/dimension_theme))
	theme = SSmaterials.dimensional_themes[new_theme_path]
	apply_theme_icon()

	target_turfs = list()
	for (var/turf/turf as anything in spiral_range_turfs(range, src))
		if (theme.can_convert(turf))
			target_turfs += turf

/**
 * Applies an overlay icon based on the current theme.
 */
/obj/effect/anomaly/dimensional/proc/apply_theme_icon()
	overlays -= theme_icon
	theme_icon = mutable_appearance(theme.icon, theme.icon_state, FLOAT_LAYER - 1, appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon

/**
 * Moves the anomaly somewhere else and announces it.
 */
/obj/effect/anomaly/dimensional/proc/relocate()
	var/datum/anomaly_placer/placer = new()
	var/area/new_area = placer.findValidArea()
	var/turf/new_turf = placer.findValidTurf(new_area)

	priority_announce("Dimensional instability relocated. Expected location: [new_area.name].", "Anomaly Alert")
	src.forceMove(new_turf)
	prepare_area()

/obj/effect/anomaly/dimensional/detonate()
	qdel(src)

/obj/effect/temp_visual/transmute_tile_flash
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	duration = 3
