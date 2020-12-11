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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 90, ACID = 90)

/obj/structure/blob/shield/scannerreport()
	if(atmosblock)
		return "Will prevent the spread of atmospheric changes."
	return "N/A"

/obj/structure/blob/shield/core
	point_return = 0

/obj/structure/blob/shield/update_name(updates)
	. = ..()
	name = "[(obj_integrity < (max_integrity * 0.5)) ? "weakened " : null][initial(name)]"

/obj/structure/blob/shield/update_desc(updates)
	. = ..()
	desc = (obj_integrity < (max_integrity * 0.5)) ? "[damaged_desc]" : initial(desc)

/obj/structure/blob/shield/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		atmosblock = obj_integrity < (max_integrity * 0.5)
		air_update_turf(1)

/obj/strcture/blob/shield/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][(obj_integrity < (max_integrity * 0.5)) ? "_damaged" : null]"

/obj/structure/blob/shield/reflective
	name = "reflective blob"
	desc = "A solid wall of slightly twitching tendrils with a reflective glow."
	damaged_desc = "A wall of twitching tendrils with a reflective glow."
	icon_state = "blob_glow"
	flags_ricochet = RICOCHET_SHINY
	point_return = 8
	explosion_block = 2
