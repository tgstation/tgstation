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
	projectile_phasing =  PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS

// 7.62 (Nagant Rifle)

/obj/projectile/bullet/a762
	name = "7.62 bullet"
	damage = 60
	armour_penetration = 10
	wound_bonus = -45
	wound_falloff_tile = 0

/obj/projectile/bullet/a762/enchanted
	name = "enchanted 7.62 bullet"
	damage = 20
	stamina = 80

// Harpoons (Harpoon Gun)

/obj/projectile/bullet/harpoon
	name = "harpoon"
	icon_state = "gauss"
	damage = 60
	armour_penetration = 50
	wound_bonus = -20
	bare_wound_bonus = 80
	embedding = list(embed_chance=100, fall_chance=3, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)
	wound_falloff_tile = -5
