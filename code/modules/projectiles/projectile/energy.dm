/obj/item/projectile/energy
	name = "\improper Energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"


/obj/item/projectile/energy/electrode
	name = "\improper Electrode"
	icon_state = "spark"
	nodamage = 1
	stun = 15
	weaken = 15
	stutter = 10
	flag = "laser" //Give it a better chance to be blocked.


/obj/item/projectile/energy/declone
	name = "\improper Decloner Bolt"
	icon_state = "declone"
	nodamage = 1
	damage_type = CLONE
	irradiate = 40


/obj/item/projectile/energy/dart
	name = "\improper Dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5


/obj/item/projectile/energy/bolt
	name = "\improper Bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = 0
	weaken = 10
	stutter = 10


/obj/item/projectile/energy/bolt/large
	name = "\improper Large Bolt"
	damage = 20





