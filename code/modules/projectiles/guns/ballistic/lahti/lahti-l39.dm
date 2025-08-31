/obj/item/gun/ballistic/automatic/lahti
	name = "\improper Lahti L-39"
	desc = "The Lahti L-39, now manufactured in space with better materials making it more portable and reliable- still loaded in the same massive cartridge, \
		this thing was made to go through a tank and come out the other end- imagine what it could do to an exosuit, there's also a completely useless sight which is totally obstructed by the magazine."
	icon = 'icons/obj/weapons/guns/lahtil39.dmi'
	icon_state = "lahtil"
	inhand_icon_state = "sniper"
	worn_icon_state = "sniper"
	fire_sound = 'sound/items/weapons/gun/sniper/shot.ogg'
	fire_sound_volume = 90
	load_sound = 'sound/items/weapons/gun/sniper/mag_insert.ogg'
	rack_sound = 'sound/items/weapons/gun/sniper/rack.ogg'
	suppressed_sound = 'sound/items/weapons/gun/general/heavy_shot_suppressed.ogg'
	mag_display = FALSE
	recoil = 15
	w_class = WEIGHT_CLASS_BULKY
	accepted_magazine_type = /obj/item/ammo_box/magazine/lahtimagazine
	fire_delay = 8 SECONDS
	slowdown = 2
	burst_size = 1
	slot_flags = ITEM_SLOT_BACK
	actions_types = list()
	suppressor_x_offset = 3
	suppressor_y_offset = 3

/obj/item/ammo_box/magazine/lahtimagazine
	name = "\improper Lahti sniper rounds (20x138mm)"
	desc = "A 20x138mm magazine suitable ammo for anti kaiju-rifles."
	icon_state = ".50mag"
	base_icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/mm20x138
	max_ammo = 9
	caliber = CALIBER_50BMG

/obj/item/ammo_casing/mm20x138
	name = "20x138mm bullet casing"
	desc = "A 20x138mm bullet casing."
	caliber = CALIBER_50BMG
	projectile_type = /obj/projectile/bullet/mm20x138
	icon_state = ".50"
	newtonian_force = 1.5

/obj/projectile/bullet/mm20x138
	name ="20x138mm bullet"
	speed = 3.5
	range = 400 // Enough to travel from one corner of the Z to the opposite corner and then some.
	damage = 400
	paralyze = 100
	dismemberment = 50
	catastropic_dismemberment = TRUE
	armour_penetration = 50
	ignore_range_hit_prone_targets = TRUE

