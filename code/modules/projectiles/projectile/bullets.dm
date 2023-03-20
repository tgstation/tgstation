/obj/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	armor_flag = BULLET
	hitsound_wall = SFX_RICOCHET
	sharpness = SHARP_POINTY
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	shrapnel_type = /obj/item/shrapnel/bullet
	embedding = list(embed_chance=20, fall_chance=2, jostle_chance=0, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.5, pain_mult=3, rip_time=10)
	wound_falloff_tile = -5
	embed_falloff_tile = -3

/obj/projectile/bullet/smite
	name = "divine retribution"
	damage = 10
