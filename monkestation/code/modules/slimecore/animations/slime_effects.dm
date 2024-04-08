/obj/effect/abstract/blank
	name = ""
	alpha = 150
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon ='monkestation/code/modules/slimecore/icons/filters.dmi'
	icon_state = "diag"
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	blend_mode = BLEND_INSET_OVERLAY

/atom/movable/proc/rainbow_effect() // this just animates between the primary colors of a rainbow
	var/obj/effect/abstract/blank/rainbow_effect = new

	appearance_flags &= ~KEEP_APART
	appearance_flags |= KEEP_TOGETHER
	vis_contents += rainbow_effect

/atom/movable/proc/remove_rainbow_effect()
	var/obj/effect/abstract/blank/rainbow_effect = locate() in vis_contents
	qdel(rainbow_effect)

/image/proc/rainbow_effect() // this just animates between the primary colors of a rainbow
	var/obj/effect/abstract/blank/rainbow_effect = new

	appearance_flags &= ~KEEP_APART
	appearance_flags |= KEEP_TOGETHER
	vis_contents += rainbow_effect

/atom/proc/ungulate()
	var/matrix/ungulate_matrix = matrix(transform)
	ungulate_matrix.Scale(1, 0.9)
	var/matrix/base_matrix = matrix(transform)
	var/base_pixel_y = pixel_y

	animate(src, transform = ungulate_matrix, time = 0.1 SECONDS, easing = EASE_OUT, loop = -1)
	animate(pixel_y = -1, time = 0.1 SECONDS, easing = EASE_OUT)
	animate(transform = base_matrix, time = 0.1 SECONDS, easing = EASE_IN)
	animate(pixel_y = base_pixel_y, time = 0.1 SECONDS, easing = EASE_IN)
