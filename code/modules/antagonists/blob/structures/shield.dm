/obj/structure/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_shield"
	desc = "A solid wall of slightly twitching tendrils."
	var/damaged_desc = "A wall of twitching tendrils."
	max_integrity = 150
	brute_resist = 0.25
	explosion_block = 3
	point_return = 4
	atmosblock = TRUE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90)

/obj/structure/blob/shield/scannerreport()
	if(atmosblock)
		return "Will prevent the spread of atmospheric changes."
	return "N/A"

/obj/structure/blob/shield/core
	point_return = 0

/obj/structure/blob/shield/update_icon()
	..()
	if(obj_integrity < max_integrity * 0.5)
		icon_state = "[initial(icon_state)]_damaged"
		name = "weakened [initial(name)]"
		desc = "[damaged_desc]"
		atmosblock = FALSE
	else
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)
		atmosblock = TRUE
	air_update_turf(1)

/obj/structure/blob/shield/reflective
	name = "reflective blob"
	desc = "A solid wall of slightly twitching tendrils with a reflective glow."
	damaged_desc = "A wall of twitching tendrils with a reflective glow."
	icon_state = "blob_glow"
	flags_ricochet = RICOCHET_SHINY
	point_return = 8
	max_integrity = 100
	brute_resist = 0.5
	explosion_block = 2
