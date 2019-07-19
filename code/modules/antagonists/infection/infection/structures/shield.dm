/obj/structure/infection/shield
	name = "strong infection"
	desc = "A solid wall of slightly twitching tendrils."
	icon = 'icons/obj/smooth_structures/infection_wall.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_TRUE
	max_integrity = 150
	brute_resist = 0.5
	fire_resist = 0.25
	explosion_block = 3
	point_return = 0
	build_time = 100
	atmosblock = TRUE
	var/list/crystal_colors = list("#3333aa" = 20, "#33aa33" = 15, "#aa3333" = 15, "#ffffff" = 8, "#822282" = 4, "#444444" = 1)

/obj/structure/infection/shield/Initialize(mapload)
	canSmoothWith = typesof(/obj/structure/infection/shield)
	if(prob(25))
		var/chosen_crystal = rand(0, 15)
		var/obj/effect/overlay/vis/crystal_overlay = new
		crystal_overlay.icon = 'icons/mob/infection/infection.dmi'
		crystal_overlay.icon_state = "crystal-[chosen_crystal]"
		crystal_overlay.layer = layer
		crystal_overlay.color = pickweight(crystal_colors)
		vis_contents += crystal_overlay
	. = ..()

/obj/structure/infection/shield/evolve_menu(var/mob/camera/commander/C)
	return

/obj/structure/infection/shield/reflective
	name = "reflective infection"
	desc = "A solid wall of slightly twitching tendrils with a reflective glow."
	icon = 'icons/mob/infection/infection.dmi'
	icon_state = "reflective"
	smooth = SMOOTH_FALSE
	flags_1 = CHECK_RICOCHET_1
	max_integrity = 200

/obj/structure/infection/shield/reflective/Initialize(mapload)
	. = ..()
	canSmoothWith = list()
	vis_contents.Cut()

/obj/structure/infection/shield/reflective/handle_ricochet(obj/item/projectile/P)
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	if(abs(incidence_s) > 90 && abs(incidence_s) < 270)
		return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	if(!(P.reflectable & REFLECT_FAKEPROJECTILE))
		visible_message("<span class='warning'>[P] reflects off [src]!</span>")
	return TRUE

/obj/structure/infection/shield/reflective/core
	name = "core reflective infection"
	point_return = 0