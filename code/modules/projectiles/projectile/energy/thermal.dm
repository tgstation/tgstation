/obj/projectile/energy/inferno
	name = "molten nanite bullet"
	icon_state = "infernoshot"
	damage = 20
	damage_type = BURN
	flag = ENERGY
	reflectable = NONE
	wound_bonus = 0
	bare_wound_bonus = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser

/obj/projectile/energy/cryo
	name = "frozen nanite bullet"
	icon_state = "cryoshot"
	damage = 15
	damage_type = BRUTE
	armour_penetration = 40
	flag = ENERGY
	sharpness = SHARP_POINTY //it's a big ol' shard of ice
	reflectable = NONE
	shrapnel_type = /obj/item/shrapnel/bullet
	embedding = list(embed_chance=40, fall_chance=2, jostle_chance=0, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.5, pain_mult=3, rip_time=10)
	wound_bonus = -5
	bare_wound_bonus = 15
