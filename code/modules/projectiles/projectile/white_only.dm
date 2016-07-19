/obj/item/projectile/white_only/energy
	name = "heat_beam"
	icon_state = "heat_beam"
	icon = 'icons/obj/guns/white_only.dmi'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 10
	luminosity = 1
	var/temperature = 500
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "heat_beam"
	eyeblur = 2

/obj/item/projectile/white_only/energy/heatgun

/obj/item/projectile/white_only/energy/heatgun/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
	..()
	if(isliving(target))
		var/mob/living/M = target
		M.bodytemperature = M.bodytemperature + temperature
		M.adjust_fire_stacks(1)
		M.IgniteMob()
	return 1

/obj/item/projectile/white_only/pistol/
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	hitsound_wall = "ricochet"

/obj/item/projectile/white_only/pistol/traumaticbullet //for traumatic pistol, heavy stamina damage
	damage = 3
	stamina = 90

/obj/item/projectile/white_only/pistol/lethalbullet //for traumatic pistol, heavy brute and stamina
	damage = 25
	stamina = 30