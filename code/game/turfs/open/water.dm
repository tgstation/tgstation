/turf/open/water
	gender = PLURAL
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/chasm/lavaland
	planetary_atmos = TRUE
	slowdown = 1
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	turf_flags = NO_RUST
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	/**
	 * Used as the color arg/var for the immerse element. It should be kept more or less in line with
	 * the hue of the turf, as semi-transparent vis overlays can opacify the semi-transparent bits of an icon,
	 * and we're kinda trying to offset that issue.
	 */
	var/immerse_overlay_color = "#5AAA88"

	/// Fishing element for this specific water tile
	var/datum/fish_source/fishing_datum = /datum/fish_source/portal

/turf/open/water/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/immerse, icon, icon_state, "immerse", immerse_overlay_color)
	AddElement(/datum/element/watery_tile)
	if(!isnull(fishing_datum))
		AddElement(/datum/element/lazy_fishing_spot, fishing_datum)

/turf/open/water/jungle

/turf/open/water/beach
	planetary_atmos = FALSE
	gender = PLURAL
	desc = "Come on in, it's great!"
	icon = 'icons/turf/beach.dmi'
	icon_state = "water"
	base_icon_state = "water"
	baseturfs = /turf/open/water/beach
	immerse_overlay_color = "#7799AA"
	fishing_datum = /datum/fish_source/ocean/beach
