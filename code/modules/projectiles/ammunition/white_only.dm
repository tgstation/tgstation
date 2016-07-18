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
	desc = "A 10mm traumatic bullet casing."
	caliber = "10mm"
	projectile_type = /obj/item/projectile/white_only/pistol/traumaticbullet

/////////////////////////////////////////////Magazines////////////////////////////////////////////////////////////


/obj/item/ammo_box/magazine/white_only/traumatic
	name = "pistol magazine (traumatic)"
	desc = "A gun magazine."
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/white_only/traumatic
	caliber = "10mm"
	max_ammo = 8
	multiple_sprites = 2