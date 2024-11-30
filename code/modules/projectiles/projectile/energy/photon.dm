#define MULTIPLY_SPEED 0.8

/obj/projectile/energy/photon
	name = "photon bolt"
	icon_state = "solarflare"
	damage_type = STAMINA
	armor_flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	damage = 5 //It's literally a weaker tesla bolt, which is already weak. Don't worry, we'll fix that.
	range = 20
	speed = 1
	projectile_piercing = PASSMOB
	light_color = LIGHT_COLOR_DEFAULT
	light_system = OVERLAY_LIGHT
	light_power = 5
	light_range = 6


/obj/projectile/energy/photon/Initialize(mapload)
	. = ..()
	RegisterSignals(src, list(COMSIG_MOVABLE_CROSS, COMSIG_MOVABLE_CROSS_OVER), PROC_REF(blast_touched))
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(scorch_earth))
	set_light_on(TRUE)

/**
 * Handle side effects for the phonon bolt.
 * behaves like a higher power direct flash if hit, and sparks silicons like they're getting microwaved.
 */
/obj/projectile/energy/photon/proc/blast_touched(datum/source, atom/flashed)
	SIGNAL_HANDLER
	if(isliving(flashed))
		var/mob/living/flashed_creature = flashed
		flashed_creature.flash_act(intensity = 3, affect_silicon = TRUE, length = 6)
		flashed_creature.adjust_confusion(1.5 SECONDS)
	if(issilicon(flashed))
		do_sparks(rand(1, 4), FALSE, src)

/**
 * When traveling to a new turf, throws a probability to generate a hotspot across its path.
 */
/obj/projectile/energy/photon/proc/scorch_earth(turf/open/floor/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(prob(40))
		new /obj/effect/hotspot(arrived)

/obj/projectile/energy/photon/reduce_range()
	. = ..()
	speed *= MULTIPLY_SPEED

/obj/projectile/energy/photon/on_range()
	do_sparks(rand(4, 9), FALSE, src)
	playsound(loc, 'sound/items/weapons/solarflare.ogg', 100, FALSE, 8, 0.9)
	for(var/mob/living/flashed_mob in viewers(5, loc))
		flashed_mob.flash_act()
	return ..()

#undef MULTIPLY_SPEED
