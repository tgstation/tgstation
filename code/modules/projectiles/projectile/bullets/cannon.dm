/obj/projectile/bullet/cannonball
	name = "cannonball"
	icon_state = "cannonball"
	damage = 110 //gets set to 100 before first mob impact.
	sharpness = NONE
	wound_bonus = 0
	projectile_piercing = ALL
	dismemberment = 0
	paralyze = 5 SECONDS
	stutter = 10 SECONDS
	embedding = null
	hitsound = 'sound/effects/meteorimpact.ogg'
	hitsound_wall = 'sound/weapons/sonic_jackhammer.ogg'

/obj/projectile/bullet/cannonball/on_hit(atom/target, blocked = FALSE)
	damage -= 10
	if(damage < 40)
		projectile_piercing = NONE //so it finishes its rampage
	if(blocked == 100)
		return ..()
	if(isobj(target))
		var/obj/hit_object = target
		hit_object.take_damage(80, BRUTE, BULLET, FALSE)
	else if(isclosedturf(target))
		damage -= max(damage - 30, 10) //lose extra momentum from busting through a wall
		var/turf/closed/hit_turf = target
		hit_turf.ScrapeAway()
	return ..()

/obj/projectile/bullet/cannonball/explosive
	name = "explosive shell"
	color = "#FF0000"
	projectile_piercing = NONE
	damage = 40 //set to 30 before first mob impact, but they're gonna be gibbed by the explosion

/obj/projectile/bullet/cannonball/explosive/on_hit(atom/target, blocked = FALSE)
	explosion(target, 2, 3, 4)
	. = ..()

/obj/projectile/bullet/cannonball/emp
	name = "malfunction shot"
	icon_state = "emp_cannonball"
	projectile_piercing = NONE
	damage = 15 //very low

/obj/projectile/bullet/cannonball/emp/on_hit(atom/target, blocked = FALSE)
	empulse(src, 4, 10)
	. = ..()

/obj/projectile/bullet/cannonball/biggest_one
	name = "\"The Biggest One\""
	icon_state = "biggest_one"
	damage = 70 //low pierce

/obj/projectile/bullet/cannonball/biggest_one/on_hit(atom/target, blocked = FALSE)
	if(projectile_piercing == NONE)
		explosion(target, GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
	. = ..()
