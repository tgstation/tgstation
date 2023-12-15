/obj/item/ammo_casing/paintball
	name = "colorless paintball"
	desc = "A paintball full of nothing."
	caliber = CALIBER_PAINTBALL
	projectile_type = /obj/projectile/paintball
	icon_state = "ball"
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT*5)
	harmful = FALSE

/obj/item/ammo_casing/paintball/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/paintball/red
	name = "red paintball"
	desc = "A paintball full of red dye."
	projectile_type = /obj/projectile/paintball/red
	color = "#eb180c"

/obj/item/ammo_casing/paintball/blue
	name = "blue paintball"
	desc = "A paintball full of blue dye."
	projectile_type = /obj/projectile/paintball/blue
	color = "#0c4beb"

/obj/item/ammo_casing/paintball/pepper
	name = "pepperball"
	desc = "A ball full of Condensed Capsaicin. Used by Security forces for riot control and non-lethal takedowns."
	projectile_type = /obj/projectile/paintball/pepper
	color = "#B31008"
