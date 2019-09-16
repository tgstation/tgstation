// C3D (Borgs)

/obj/item/projectile/bullet/c3d
	damage = 20

// Mech LMG

/obj/item/projectile/bullet/lmg
	damage = 20

// Mech FNX-99

/obj/item/projectile/bullet/incendiary/fnx99
	damage = 20
	embed_target = FALSE
// Turrets

/obj/item/projectile/bullet/manned_turret
	damage = 20

/obj/item/projectile/bullet/syndicate_turret
	damage = 20

// 7.12x82mm (SAW)

/obj/item/projectile/bullet/mm712x82
	name = "7.12x82mm bullet"
	damage = 45
	armour_penetration = 5
	embed_damage = 2

/obj/item/projectile/bullet/mm712x82_ap
	name = "7.12x82mm armor-piercing bullet"
	damage = 40
	armour_penetration = 75
	embed_damage = 2

/obj/item/projectile/bullet/mm712x82_hp
	name = "7.12x82mm hollow-point bullet"
	damage = 60
	armour_penetration = -60
	embed_damage = 4 // hollow point bullets are very bad for your health

/obj/item/projectile/bullet/incendiary/mm712x82
	name = "7.12x82mm incendiary bullet"
	damage = 20
	fire_stacks = 3
	embed_target = FALSE
