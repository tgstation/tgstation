/obj/projectile/energy/inferno
	name = "molten nanite bullet"
	icon_state = "infernoshot"
	damage = 20
	damage_type = BURN
	flag = ENERGY
	armour_penetration = 10
	reflectable = NONE
	wound_bonus = 0
	bare_wound_bonus = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser

/obj/projectile/energy/inferno/on_hit(atom/target, blocked, pierce_hit)
	..()
	if(iscarbon(target))
		var/mob/living/carbon/cold_target = target
		var/how_cold_is_target = cold_target.bodytemperature
		if(how_cold_is_target < 100)
			cold_target.Knockdown(100)
			cold_target.apply_damage(20, BRUTE)
			playsound(cold_target, 'sound/weapons/sear.ogg', 30, TRUE, -1)

/obj/projectile/energy/cryo
	name = "frozen nanite bullet"
	icon_state = "cryoshot"
	damage = 20
	damage_type = BRUTE
	armour_penetration = 10
	flag = ENERGY
	sharpness = SHARP_POINTY //it's a big ol' shard of ice
	reflectable = NONE
	wound_bonus = 0
	bare_wound_bonus = 10

/obj/projectile/energy/cryo/on_hit(atom/target, blocked, pierce_hit)
	..()
	if(iscarbon(target))
		var/mob/living/carbon/hot_target = target
		var/how_hot_is_target = hot_target.bodytemperature
		if(how_hot_is_target > 600)
			hot_target.Knockdown(100)
			hot_target.apply_damage(20, BURN)
			playsound(hot_target, 'sound/weapons/sonic_jackhammer.ogg', 30, TRUE, -1)
