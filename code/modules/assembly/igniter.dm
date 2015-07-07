/obj/item/device/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances."
	icon_state = "igniter"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1"
	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread


/obj/item/device/assembly/igniter/New()
	..()
	sparks.set_up(2, 0, src)
	sparks.attach(src)


/obj/item/device/assembly/igniter/activate()
	if(!..())	return 0//Cooldown check
	var/turf/location = get_turf(loc)
	if(location)	location.hotspot_expose(1000,1000)
	sparks.start()
	return 1


/obj/item/device/assembly/igniter/attack_self(mob/user as mob)
	activate()
	add_fingerprint(user)
	return