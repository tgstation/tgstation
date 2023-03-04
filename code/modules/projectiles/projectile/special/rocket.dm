/obj/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/gyro/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, light_impact_range = 2, explosion_cause = src)
	return BULLET_ACT_HIT

/// PM9 standard HE rocket
/obj/projectile/bullet/rocket
	name = "\improper HE rocket"
	desc = "Boom."
	icon_state= "missile"
	damage = 50
	ricochets_max = 0
	/// Whether we do extra damage when hitting a mech or silicon
	var/anti_armour_damage = 0
	/// Whether the rocket is capable of instantly killing a living target
	var/random_crits_enabled = TRUE // Worst thing Valve ever added

/obj/projectile/bullet/rocket/on_hit(atom/target, blocked = FALSE)
	if(isliving(target) && prob(1) && random_crits_enabled)
		var/mob/living/gibbed_dude = target
		if(gibbed_dude.stat < HARD_CRIT)
			gibbed_dude.say("Is that a fucking ro-", forced = "hit by rocket")
	..()

	do_boom(target)
	if(anti_armour_damage && ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		M.take_damage(anti_armour_damage)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_overall_damage(anti_armour_damage*0.75, anti_armour_damage*0.25)
	return BULLET_ACT_HIT

/** This proc allows us to customize the conditions necesary for the rocket to detonate, allowing for different explosions for living targets, turf targets,
among other potential differences. This granularity is helpful for things like the special rockets mechs use. */
/obj/projectile/bullet/rocket/proc/do_boom(atom/target)
	if(!isliving(target)) //if the target isn't alive, so is a wall or something
		explosion(target, heavy_impact_range = 1, light_impact_range = 2, flame_range = 3, flash_range = 4, explosion_cause = src)
	else
		explosion(target, light_impact_range = 2, flame_range = 3, flash_range = 4,  explosion_cause = src)

/// PM9 HEAP rocket - the anti-anything missile you always craved.
/obj/projectile/bullet/rocket/heap
	name = "\improper HEAP rocket"
	desc = "I am become death."
	icon_state = "84mm-heap"
	damage = 80
	armour_penetration = 100
	dismemberment = 100
	anti_armour_damage = 200

/obj/projectile/bullet/rocket/heap/do_boom(atom/target, blocked=0)
	explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flame_range = 4, flash_range = 1, adminlog = FALSE)

/// PM9 weak rocket - just kind of a failure
/obj/projectile/bullet/rocket/weak
	name = "low-yield rocket"
	desc = "Boom, but less so."
	damage = 30

/obj/projectile/bullet/rocket/weak/do_boom(atom/target, blocked=0)
	if(!isliving(target)) //if the target isn't alive, so is a wall or something
		explosion(target, heavy_impact_range = 1, light_impact_range = 2, flame_range = 3, flash_range = 4, explosion_cause = src)
	else
		explosion(target, light_impact_range = 2, flame_range = 3, flash_range = 4, explosion_cause = src)

/** SRM-8 Missile - Used by the SRM-8 Exosuit missile rack.
* Employed by Nuclear Operatives Maulers and Nanotrasen Marauders and Seraphs to kill everything and anyone.
*
* Explodes when it hits literally anything.
*/
/obj/projectile/bullet/rocket/srm
	name = "short range missile"
	desc = "Today's not your day, pal."

/** PEP-6 Missile - Used by the PEP-6 Exosuit missile rack.
* Employed by Roboticists out of spite to put down enemy hereteks, mechanized nuclear operatives, the janitor's hot rod,
* the clown's 'taxi service', uppity borgs, vengeful ais, doors they don't like, the escape shuttle's hull, and more!
*
* Explodes only when it hits specifically one of the following types:
* (/obj/structure), (/obj/machinery), (/obj/vehicle), (/turf/closed), (/mob/living/silicon)
*
* Does NOT explode if it hits any random mob, or any random object. Only if it is a subtype of one of the above valid atoms.
*/
/obj/projectile/bullet/rocket/pep
	name = "precise explosive missile"
	desc = "Human friendly, metal unfriendly."
	damage = 30
	anti_armour_damage = 80 //Doesn't (probably) kill borgs in one shot, but it will hurt
	random_crits_enabled = FALSE //yeah, no

/obj/projectile/bullet/rocket/pep/do_boom(atom/target, blocked=0)
	if(issilicon(target)) //if the target is a borg, just give them one of these to make it loud, most of the damage is in the projectile itself
		explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
		return
	if(isstructure(target) || isvehicle (target) || isclosedturf (target) || ismachinery (target)) //if the target is a structure, machine, vehicle or closed turf like a wall, explode that shit
		if(target.density) //Dense objects get blown up a bit harder
			explosion(target, heavy_impact_range = 1, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			return
		else
			explosion(target, light_impact_range = 1, flash_range = 2, explosion_cause = src)
			return
	else //if the target is anything else, we drop a missile on the ground and do nothing
		new /obj/item/broken_missile(get_turf(src), 1)

/obj/item/broken_missile
	name = "broken missile"
	desc = "A missile that did not detonate. The tail has snapped and it is in no way fit to be used again."
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "missile_broken"
	w_class = WEIGHT_CLASS_TINY
