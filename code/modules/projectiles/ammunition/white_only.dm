/obj/item/ammo_casing/white_only/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew"
	caliber = "energy"
	projectile_type = /obj/item/projectile/white_only/energy/heatgun
	var/e_cost = 150 //The amount of energy a cell needs to expend to create this shot.
	var/select_name = "energy"
	fire_sound = 'sound/weapons/laser3.ogg'

/obj/item/ammo_casing/white_only/energy/heatgun
	projectile_type = /obj/item/projectile/white_only/energy/heatgun

/obj/item/ammo_casing/white_only/traumatic
	desc = "A 9mm traumatic bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/white_only/pistol/traumaticbullet

/obj/item/ammo_casing/white_only/traumatic/lethal
	projectile_type = /obj/item/projectile/white_only/pistol/lethalbullet

/////////////////////////////////////////////Magazines////////////////////////////////////////////////////////////

/obj/item/ammo_box/magazine/white_only/traumatic
	name = "pistol magazine (traumatic)"
	desc = "A gun magazine. Contains 10 bullets."
	icon = 'icons/obj/guns/white_only.dmi'
	icon_state = "oldrifle"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/white_only/traumatic
	caliber = "9mm"
	max_ammo = 10
	multiple_sprites = 2

/obj/item/ammo_box/magazine/white_only/traumatic/lethal
	name = "pistol magazine (lethal)"
	desc = "A gun magazine. Contains 10 bullets."
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/white_only/traumatic/lethal

/obj/item/ammo_box/magazine/white_only/enhanced_traumatic
	name = "enhanced pistol magazine (traumatic)"
	desc = "A gun magazine. Contains 30 bullets."
	icon = 'icons/obj/guns/white_only.dmi'
	icon_state = "oldrifle"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/white_only/traumatic
	caliber = "9mm"
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/white_only/enhanced_traumatic/lethal
	name = "enhanced pistol magazine (lethal)"
	desc = "A gun magazine. Contains 30 bullets."
	origin_tech = "combat=5"
	ammo_type = /obj/item/ammo_casing/white_only/traumatic/lethal

/datum/design/white_only/traumatic
	name = "pistol magazine (traumatic)"
	id = "9mm_traumatic"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10000)
	build_path = /obj/item/ammo_box/magazine/white_only/traumatic
	category = list("initial", "Security")

/datum/design/white_only/enhanced_traumatic
	name = "enhanced pistol magazine (traumatic)"
	id = "9mm_traumatic_enhanced"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30000)
	build_path = /obj/item/ammo_box/magazine/white_only/enhanced_traumatic
	category = list("initial", "Security")

/datum/design/white_only/traumatic/lethal
	name = "pistol magazine (lethal)"
	id = "9mm_lethal"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 20000)
	build_path = /obj/item/ammo_box/magazine/white_only/traumatic/lethal
	category = list("hacked", "Security")

/datum/design/white_only/enhanced_traumatic/lethal
	name = "enhanced pistol magazine (lethal)"
	id = "9mm_lethal_enhanced"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 40000)
	build_path = /obj/item/ammo_box/magazine/white_only/enhanced_traumatic/lethal
	category = list("hacked", "Security")