/turf/open/floor/glass
	name = "glass floor"
	desc = "Don't jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon_state = "glass"
	baseturfs = /turf/baseturf_bottom
	layer = GLASS_FLOOR_LAYER
	underfloor_accessibility = UNDERFLOOR_VISIBLE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS
	canSmoothWith = SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	floor_tile = /obj/item/stack/tile/glass
	overfloor_placed = FALSE
	/// List of /atom/movable/render_step that are being used to make this glass floor glow
	/// These are OWNED by this floor, they delete when we delete them, not before not after
	var/list/glow_stuff
	/// How much alpha to leave when cutting away emissive blockers
	var/alpha_to_leave = 255
	/// Color of starlight to use
	var/starlight_color = COLOR_STARLIGHT

/turf/open/floor/glass/broken_states()
	return list("glass-damaged1", "glass-damaged2", "glass-damaged3")

/turf/open/floor/glass/Initialize(mapload)
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/glass/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency)
	setup_glow()

/turf/open/floor/glass/Destroy()
	. = ..()
	QDEL_LIST(glow_stuff)

/// If this turf is at the bottom of the local rendering stack
/// Then we're gonna make it emissive block so the space below glows
/turf/open/floor/glass/proc/setup_glow()
	if(GET_TURF_PLANE_OFFSET(src) != GET_LOWEST_STACK_OFFSET(z)) // We ain't the bottom brother
		return
	// We assume no parallax means no space means no light
	if(SSmapping.level_trait(z, ZTRAIT_NOPARALLAX))
		return

	glow_stuff = partially_block_emissives(src, alpha_to_leave)
	set_light(2, 0.75, starlight_color)

/turf/open/floor/glass/make_plating()
	return

/turf/open/floor/glass/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/glass/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/glass/reinforced
	name = "reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"
	floor_tile = /obj/item/stack/tile/rglass
	alpha_to_leave = 206

/turf/open/floor/glass/reinforced/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/glass/reinforced/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/glass/plasma
	name = "plasma glass floor"
	desc = "Studies by the Nanotrasen Materials Safety Division have not yet determined if this is safe to jump on, do so at your own risk."
	icon = 'icons/turf/floors/plasma_glass.dmi'
	icon_state = "plasma_glass-0"
	base_icon_state = "plasma_glass"
	floor_tile = /obj/item/stack/tile/glass/plasma
	starlight_color = COLOR_STRONG_VIOLET
	alpha_to_leave = 255

/turf/open/floor/glass/plasma/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/glass/plasma/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/glass/reinforced/plasma
	name = "reinforced plasma glass floor"
	desc = "Do jump on it, jump on it while in a mecha, it can take it."
	icon = 'icons/turf/floors/reinf_plasma_glass.dmi'
	icon_state = "reinf_plasma_glass-0"
	base_icon_state = "reinf_plasma_glass"
	floor_tile = /obj/item/stack/tile/rglass/plasma
	starlight_color = COLOR_STRONG_VIOLET
	alpha_to_leave = 206

/turf/open/floor/glass/reinforced/plasma/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/glass/reinforced/plasma/airless
	initial_gas_mix = AIRLESS_ATMOS
