/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"

/obj/item/projectile/bullet/slug
	name = "slug"


/obj/item/projectile/bullet/rubberbullet
	damage = 10
	stun = 5
	weaken = 5


/obj/item/projectile/bullet/midbullet12
	damage = 20
	stun = 5
	weaken = 5

/obj/item/projectile/bullet/midbullet9
	damage = 25


/obj/item/projectile/bullet/midbullet45
	damage = 25
	stun = 1
	weaken = 1


/obj/item/projectile/bullet/midbullet10 //Only used with the Stechkin Pistol - RobRichards
	damage = 30

/obj/item/projectile/bullet/buck
	name = "pellet"
	damage = 15



/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 20
	damage_type = OXY


/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 40
	damage_type = TOX


/obj/item/projectile/bullet/burstbullet//I think this one needs something for the on hit
	name = "exploding bullet"
	damage = 20


/obj/item/projectile/bullet/stunshot
	name = "stunshot"
	damage = 5
	stun = 10
	weaken = 10
	stutter = 10

/obj/item/projectile/bullet/a762
	damage = 25


/obj/item/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6

	New()
		..()
		flags |= NOREACT
		create_reagents(50)

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon))
			var/mob/living/carbon/M = target
			reagents.trans_to(M, reagents.total_volume)
		else
			flags &= ~NOREACT
			reagents.handle_reactions()
		return 1

/obj/item/projectile/bullet/dart/metalfoam
	New()
		..()
		reagents.add_reagent("aluminium", 15)
		reagents.add_reagent("foaming_agent", 5)
		reagents.add_reagent("pacid", 5)

//This one is for future syringe guns update
/obj/item/projectile/bullet/dart/syringe
	name = "syringe"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"

/obj/item/projectile/bullet/blank
	name = "blankshot"
	nodamage = 1