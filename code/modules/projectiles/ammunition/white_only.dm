/obj/item/ammo_casing/white_only
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew"
	caliber = "energy"
	projectile_type = /obj/item/projectile/white_only/heatgun
	var/e_cost = 150 //The amount of energy a cell needs to expend to create this shot.
	var/select_name = "energy"
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/ammo_casing/white_only/heatgun
	projectile_type = /obj/item/projectile/white_only/heatgun