/obj/projectile/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 65
	damage_type = STAMINA
	armor_flag = BIO
	impact_effect_type = /obj/effect/temp_visual/impact_effect/neurotoxin
	armour_penetration = 50

/obj/projectile/neurotoxin/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isalien(target))
		damage = 0
	return ..()

/obj/projectile/neurotoxin/damaging //for ai controlled aliums
	damage = 30
	paralyze = 0 SECONDS


/obj/projectile/energy/xenoglob
	name = "glob of acidic neurotoxin"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "xenoshot0"
	damage = 20
	damage_type = STAMINA
	armour_penetration = 0
	reflectable = NONE
	wound_bonus = 0
	bare_wound_bonus = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/projectile/energy/xenoglob/on_hit(atom/target, blocked, pierce_hit)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/victim = target
		victim.reagents.add_reagent(/datum/reagent/toxin/acid, 3)
		victim.reagents.add_reagent(/datum/reagent/toxin/staminatoxin/neurotoxin_alien, 2)
	return ..()
