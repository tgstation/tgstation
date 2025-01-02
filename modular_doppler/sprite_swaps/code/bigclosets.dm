/obj/structure/closet/emcloset
	desc = "A sturdy closet to store breach control equipment and materials. It could probably protect you from dangerous air pressure."
	icon = 'modular_doppler/sprite_swaps/icons/elockers.dmi'
	max_integrity = 300
	contents_pressure_protection = 1
	door_anim_time = 0
	max_mob_size = MOB_SIZE_LARGE
	mob_storage_capacity = 4
	storage_capacity = 45

/obj/structure/closet/firecloset
	desc = "A sturdy closet to store fire suppression equipment and materials. It could probably protect you from dangerous ambient temperatures."
	icon = 'modular_doppler/sprite_swaps/icons/elockers.dmi'
	max_integrity = 300
	contents_thermal_insulation = 1
	door_anim_time = 0
	max_mob_size = MOB_SIZE_LARGE
	mob_storage_capacity = 4
	storage_capacity = 45
	armor_type = /datum/armor/fire_closet

/datum/armor/fire_closet
	melee = 20
	bullet = 10
	laser = 10
	bomb = 10
	fire = 100
	acid = 60
