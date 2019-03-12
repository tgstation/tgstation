/obj/structure/infection/shield
	name = "strong infection"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_shield"
	desc = "A solid wall of slightly twitching tendrils."
	max_integrity = 150
	brute_resist = 0.25
	explosion_block = 3
	point_return = 4
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90)
	upgrade_type = "Shield"
	cost_per_level = 15
	extra_description = "Turns into a reflective shield with less brute resistance but more overall health."
	var/damaged_icon = "blob_shield_damaged"
	var/damaged_desc = "A wall of twitching tendrils."
	var/damaged_name = "weakened strong infection"

/obj/structure/infection/shield/scannerreport()
	if(atmosblock)
		return "Will prevent the spread of atmospheric changes."
	return "N/A"

/obj/structure/infection/shield/do_upgrade()
	change_to(/obj/structure/infection/shield/reflective, overmind)

/obj/structure/infection/shield/update_icon()
	..()
	if(obj_integrity <= 75)
		icon_state = damaged_icon
		name = damaged_name
		desc = damaged_desc
		atmosblock = FALSE
	else
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)
		atmosblock = TRUE
	air_update_turf(1)

/obj/structure/infection/shield/reflective
	name = "reflective infection"
	desc = "A solid wall of slightly twitching tendrils with a reflective glow."
	damaged_icon = "blob_glow_damaged"
	damaged_desc = "A wall of twitching tendrils with a reflective glow."
	damaged_name = "weakened reflective infection"
	icon_state = "blob_glow"
	flags_1 = CHECK_RICOCHET_1
	point_return = 8
	max_integrity = 200
	brute_resist = 0.5
	explosion_block = 2
	infection_level = 2
	extra_description = "Upgrades the brute resistance to be the same as a normal shield."

/obj/structure/infection/shield/reflective/do_upgrade()
	change_to(/obj/structure/infection/shield/reflective/strong, overmind)

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

/obj/structure/infection/shield/reflective/strong
	name = "strong reflective infection"
	damaged_icon = "blob_glow_damaged"
	damaged_desc = "A wall of twitching tendrils with a reflective glow."
	damaged_name = "weakened strong reflective infection"
	icon_state = "blob_idle_glow"
	infection_level = 3
	extra_description = null
	brute_resist = 0.25