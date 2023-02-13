/obj/projectile/bullet/cannonball
	name = "cannonball"
	icon_state = "cannonball"
	damage = 110 //gets set to 100 before first mob impact.
	sharpness = NONE
	wound_bonus = 0
	projectile_piercing = ALL
	dismemberment = 0
	paralyze = 5 SECONDS
	stutter = 20 SECONDS
	embedding = null
	hitsound = 'sound/effects/meteorimpact.ogg'
	hitsound_wall = 'sound/weapons/sonic_jackhammer.ogg'
	/// If our cannonball hits something, it reduces the damage by this value.
	var/damage_decrease_on_hit = 10
	/// This is the cutoff point of our cannonball, so that it stops piercing past this value.
	var/stop_piercing_threshold = 40
	/// This is the damage value we do to objects on hit. Usually, more than the actual projectile damage
	var/object_damage = 80
	/// Whether or not our cannonball loses object damage upon hitting an object.
	var/object_damage_decreases = FALSE
	/// How much our object damage decreases on hit, similar to normal damage.
	var/object_damage_decrease_on_hit = 0

/obj/projectile/bullet/cannonball/on_hit(atom/target, blocked = FALSE)
	damage -= damage_decrease_on_hit
	if(object_damage_decreases)
		object_damage -= min(damage, object_damage_decrease_on_hit)
	if(damage < stop_piercing_threshold)
		projectile_piercing = NONE //so it finishes its rampage
	if(blocked == 100)
		return ..()
	if(isobj(target))
		var/obj/hit_object = target
		hit_object.take_damage(object_damage, BRUTE, BULLET, FALSE)
	else if(isclosedturf(target))
		damage -= max(damage - 30, 10) //lose extra momentum from busting through a wall
		if(!isindestructiblewall(target))
			var/turf/closed/hit_turf = target
			hit_turf.ScrapeAway()
	return ..()

/obj/projectile/bullet/cannonball/explosive
	name = "explosive shell"
	color = "#FF0000"
	projectile_piercing = NONE
	damage = 40 //set to 30 before first mob impact, but they're gonna be gibbed by the explosion

/obj/projectile/bullet/cannonball/explosive/on_hit(atom/target, blocked = FALSE)
	explosion(target, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4, explosion_cause = src)
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
		explosion(target, devastation_range = GLOB.MAX_EX_DEVESTATION_RANGE, heavy_impact_range = GLOB.MAX_EX_HEAVY_RANGE, light_impact_range = GLOB.MAX_EX_LIGHT_RANGE, flash_range = GLOB.MAX_EX_FLASH_RANGE, explosion_cause = src)
	. = ..()

/obj/projectile/bullet/cannonball/trashball
	name = "trashball"
	icon_state = "trashball"
	damage = 90 //better than the biggest one but no explosion, so kinda just a worse normal cannonball

/obj/projectile/bullet/cannonball/meteorslug
	name = "meteorslug"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	damage = 40 //REALLY not as bad as a real cannonball but they'll fucking hurt
	paralyze = 1 SECONDS //The original stunned, okay?
	knockdown = 8 SECONDS
	stutter = null
	stop_piercing_threshold = 10
	object_damage_decreases = TRUE
	object_damage_decrease_on_hit = 40
	range = 7 //let's keep it a bit sane, okay?
