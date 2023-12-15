/obj/item/gun/ballistic/automatic/paintball
	name = "\improper Paintball Gun"
	desc = "A paintball gun which is designed to shoot plastic projectiles full of coloring which dyes the opponent."
	icon_state = "paintball"
	accepted_magazine_type = /obj/item/ammo_box/magazine/paintball
	actions_types = list()
	burst_size = 1
	fire_delay = 0
	can_suppress = FALSE
	mag_display = TRUE
	empty_indicator = TRUE
	special_mags = TRUE
	fire_sound = 'sound/weapons/gun/pistol/shot_suppressed.ogg'
	fire_sound_volume = 50
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/ballistic/automatic/paintball/red
	name = "\improper Red Paintball Gun"
	icon_state = "paintball_red"
	spawn_magazine_type = /obj/item/ammo_box/magazine/paintball/red

/obj/item/gun/ballistic/automatic/paintball/blue
	name = "\improper Blue Paintball Gun"
	icon_state = "paintball_blue"
	spawn_magazine_type = /obj/item/ammo_box/magazine/paintball/blue

/obj/item/gun/ballistic/automatic/paintball/pepper
	name = "\improper Pepperball Gun"
	desc = "A pepperball gun, engineered for launching pepperballs, effectively disorients and incapacitates unprotected opponents. However, it's essentially a repurposed paintball gun with a low-quality scope, its vision hindered by the obstructive magazine."
	icon_state = "pepperball"
	spawn_magazine_type = /obj/item/ammo_box/magazine/paintball/pepper
	gun_flags = NONE
