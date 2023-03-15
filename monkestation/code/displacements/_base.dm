/obj/effect/distortion
	icon = 'monkestation/icons/effects/displacement_maps.dmi'
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_TOGETHER
	vis_flags = VIS_INHERIT_DIR
	mouse_opacity = FALSE

/obj/effect/distortion/Initialize(mapload)
	. = ..()
	render_target = "*\ref[src]"
