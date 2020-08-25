// 5.56mm (M-90gl Carbine)

/obj/projectile/bullet/a556
	name = "5.56mm bullet"
	damage = 35
	armour_penetration = 30
	wound_bonus = -40

/obj/projectile/bullet/a556/phasic
	name = "5.56mm phasic bullet"
	icon_state = "gaussphase"
	damage = 20
	armour_penetration = 70
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE

// 7.62 (Nagant Rifle)

/obj/projectile/bullet/a762
	name = "7.62 bullet"
	damage = 60
	wound_bonus = -35
	wound_falloff_tile = 0

/obj/projectile/bullet/a762_enchanted
	name = "enchanted 7.62 bullet"
	damage = 20
	stamina = 80
