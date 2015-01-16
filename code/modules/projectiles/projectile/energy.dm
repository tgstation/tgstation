/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"


/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = 1
	stun = 5
	weaken = 5
	stutter = 5
	jitter = 20
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 7

/obj/item/projectile/energy/electrode/on_hit(var/atom/target, var/blocked = 0)
	if(!proj_hit)
		if(!ismob(target) || blocked >= 2) //Fully blocked by mob or collided with dense object - burst into sparks!
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread
			sparks.set_up(1, 1, src)
			sparks.start()
			proj_hit = 1
	..()

/obj/item/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	if(!proj_hit)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread
		sparks.set_up(1, 1, src)
		sparks.start()
		proj_hit = 1
	..()

/obj/item/projectile/energy/declone
	name = "radiation beam"
	icon_state = "declone"
	nodamage = 1
	damage_type = CLONE
	irradiate = 40


/obj/item/projectile/energy/dart //ninja throwing dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5
	range = 7

/obj/item/projectile/energy/bolt //ebow bolts
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	damage_type = TOX
	nodamage = 0
	weaken = 5
	stutter = 5
	range = 7

/obj/item/projectile/energy/bolt/large
	damage = 20