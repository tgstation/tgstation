/obj/projectile/energy/inferno
	name = "molten nanite bullet"
	icon_state = "infernoshot"
	damage = 20
	damage_type = BURN
	armor_flag = ENERGY
	armour_penetration = 10
	reflectable = NONE
	wound_bonus = 0
	exposed_wound_bonus = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser

/obj/projectile/energy/inferno/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!ishuman(target))
		return

	if(HAS_TRAIT(target, TRAIT_RESISTCOLD))
		return

	var/mob/living/carbon/cold_target = target
	var/how_cold_is_target = cold_target.bodytemperature
	var/danger_zone = cold_target.dna.species.bodytemp_cold_damage_limit - 150
	if(how_cold_is_target < danger_zone)
		explosion(cold_target, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flame_range = 3) //maybe stand back a bit
		cold_target.bodytemperature = cold_target.dna.species.bodytemp_normal //avoids repeat explosions, maybe could be used to heat up again?
		playsound(cold_target, 'sound/items/weapons/sear.ogg', 30, TRUE, -1)

/obj/projectile/energy/cryo
	name = "frozen nanite bullet"
	icon_state = "cryoshot"
	damage = 20
	damage_type = BRUTE
	armour_penetration = 10
	armor_flag = ENERGY
	sharpness = SHARP_POINTY //it's a big ol' shard of ice
	reflectable = NONE
	wound_bonus = 0
	exposed_wound_bonus = 10

/obj/projectile/energy/cryo/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!ishuman(target))
		return

	if(HAS_TRAIT(target, TRAIT_RESISTHEAT))
		return

	var/mob/living/carbon/hot_target = target
	var/how_hot_is_target = hot_target.bodytemperature
	var/danger_zone = hot_target.dna.species.bodytemp_heat_damage_limit + 300
	if(how_hot_is_target > danger_zone)
		hot_target.Knockdown(100)
		hot_target.apply_damage(20, BURN)
		hot_target.bodytemperature = hot_target.dna.species.bodytemp_normal //avoids repeat knockdowns, maybe could be used to cool down again?
		playsound(hot_target, 'sound/items/weapons/sonic_jackhammer.ogg', 30, TRUE, -1)
