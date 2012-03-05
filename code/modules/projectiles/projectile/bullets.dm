/obj/item/projectile/bullet
	name = "\improper Bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"


/obj/item/projectile/bullet/weakbullet
	damage = 15
	stun = 5
	weaken = 5


/obj/item/projectile/bullet/midbullet
	damage = 30
	stun = 5
	weaken = 5
	eyeblur = 3

/obj/item/projectile/bullet/suffocationbullet//How does this even work?
//	name = "\improper ullet"
	damage = 20
	damage_type = OXY


/obj/item/projectile/bullet/cyanideround
	name = "\improper Poison Bullet"
	damage = 40
	damage_type = TOX


/obj/item/projectile/bullet/burstbullet//I think this one needs something for the on hit
	name = "\improper Exploding Bullet"
	damage = 20


/obj/item/projectile/bullet/stunshot
	name = "\improper Stunshot"
	damage = 15
	stun = 10
	weaken = 10
	stutter = 10