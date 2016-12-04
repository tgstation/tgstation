/obj/item/projectile/energy/white_only/heatgun
	name = "heat beam"
	icon_state = "heat_beam"
	icon = 'icons/obj/guns/white_only.dmi'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 10
	luminosity = 1
	var/temperature = 500
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "energy"
	eyeblur = 2

/obj/item/projectile/energy/white_only/heatgun/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
	..()
	if(isliving(target))
		var/mob/living/M = target
		M.bodytemperature = M.bodytemperature + temperature
		M.adjust_fire_stacks(1)
		M.IgniteMob()
	return 1

/obj/item/projectile/energy/white_only/cross_laser
	name = "heat beam"
	icon_state = "heat_beam"
	icon = 'icons/obj/guns/white_only.dmi'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	luminosity = 1
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "energy"
	eyeblur = 2

/obj/item/projectile/energy/white_only/cross_laser/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
	..()
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/cardinal, list(target))
	playsound(target,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(target))
	return 1