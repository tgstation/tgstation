/obj/effect/overlay
	name = "overlay"

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name = "beam"
	icon = 'icons/effects/beam.dmi'
	icon_state = "b_beam"
	var/atom/BeamSource

/obj/effect/overlay/beam/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 10)

/obj/effect/overlay/sparkles
	gender = PLURAL
	name = "sparkles"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	anchored = TRUE

/obj/effect/overlay/thermite
	name = "thermite"
	desc = "Looks hot."
	icon = 'icons/effects/fire.dmi'
	icon_state = "medium" //what?
	anchored = TRUE
	plane = ABOVE_GAME_PLANE
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/overlay/vis
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR
	///When detected to be unused it gets set to world.time, after a while it gets removed
	var/unused = 0
	///overlays which go unused for this amount of time get cleaned up
	var/cache_expiration = 2 MINUTES

/obj/effect/overlay/atmos_excited
	name = "excited group"
	icon = null
	icon_state = null
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	appearance_flags = RESET_TRANSFORM | TILE_BOUND
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE
	plane = HIGH_GAME_PLANE

/// Door overlay for animating closets
/obj/effect/overlay/closet_door
	anchored = TRUE
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	vis_flags = VIS_INHERIT_ID
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | PIXEL_SCALE
