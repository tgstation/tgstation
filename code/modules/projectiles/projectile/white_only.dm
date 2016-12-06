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
	icon_state = "cross_laser"
	icon = 'icons/mob/lavaland/related_to_drone.dmi'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40
	speed = 3
	luminosity = 1
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "energy"
	eyeblur = 1

/obj/item/projectile/energy/white_only/cross_laser/proc/shoot_projectile(turf/marker, mob/firer)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/energy/drone_laser(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = firer
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	P.original = marker
	P.fire()

/obj/item/projectile/energy/white_only/cross_laser/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
	..()
	playsound(target,'sound/magic/blink.ogg', 200, 1)
	for(var/turf/turf in range(1,get_turf(src)))
		shoot_projectile(turf, firer)
	return 1