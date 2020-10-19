/obj/projectile/bullet/cannonball
	name = "cannonball"
	icon_state = "cannonball"
	damage = 110 //gets set to 100 before first mob impact.
	sharpness = SHARP_NONE
	wound_bonus = 10
	dismemberment = 5
	embedding = null
	hitsound = 'sound/effects/wounds/pierce1.ogg'
	hitsound_wall = 'sound/weapons/sonic_jackhammer.ogg'


/obj/projectile/bullet/cannonball/on_hit(atom/target, blocked = FALSE)
	damage -= 10
	if(isliving(target) && damage > 40)
		return BULLET_ACT_FORCE_PIERCE
	..()
