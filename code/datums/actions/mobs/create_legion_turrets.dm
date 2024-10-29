/datum/action/cooldown/mob_cooldown/create_legion_turrets
	name = "Create Sentinels"
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "legion_turret"
	desc = "Create legion sentinels that fire at any enemies."
	cooldown_time = 2 SECONDS
	/// Minimum number of turrets that can be spawned
	var/minimum_turrets = 2
	/// Maximum number of turrets that can be spawned
	var/maximum_turrets = 2

/datum/action/cooldown/mob_cooldown/create_legion_turrets/Activate(atom/target_atom)
	disable_cooldown_actions()
	create(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/// Creates new legion turrets around the owner between the minimum and maximum
/datum/action/cooldown/mob_cooldown/create_legion_turrets/proc/create(atom/target)
	playsound(owner, 'sound/effects/magic/RATTLEMEBONES.ogg', 100, TRUE)
	var/list/possible_locations = list()
	for(var/turf/checked_turf in oview(owner, 4)) //Only place the turrets on open turfs
		if(checked_turf.is_blocked_turf())
			continue
		possible_locations += checked_turf
	for(var/i in 1 to min(rand(minimum_turrets, maximum_turrets), length(possible_locations))) //Makes sure aren't spawning in nullspace.
		var/chosen = pick_n_take(possible_locations)
		new /obj/structure/legionturret(chosen)

/// A basic turret that shoots at nearby mobs. Intended to be used for the legion megafauna.
/obj/structure/legionturret
	name = "\improper Legion sentinel"
	desc = "The eye pierces your soul."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_turret"
	light_power = 0.5
	light_range = 2
	max_integrity = 80
	luminosity = 6
	anchored = TRUE
	density = TRUE
	layer = ABOVE_OBJ_LAYER
	armor_type = /datum/armor/structure_legionturret
	//Compared with the targeted mobs. If they have the faction, turret won't shoot.
	faction = list(FACTION_MINING)
	///What kind of projectile the actual damaging part should be.
	var/projectile_type = /obj/projectile/beam/legion
	///Time until the tracer gets shot
	var/initial_firing_time = 1.8 SECONDS
	///How long it takes between shooting the tracer and the projectile.
	var/shot_delay = 0.8 SECONDS

/datum/armor/structure_legionturret
	laser = 100

/obj/structure/legionturret/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(set_up_shot)), initial_firing_time)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)

/// Handles an extremely basic AI
/obj/structure/legionturret/proc/set_up_shot()
	for(var/mob/living/possible_target in oview(9, src))
		if(possible_target.stat == DEAD || possible_target.stat == UNCONSCIOUS)
			continue
		if(faction_check(faction, possible_target.faction))
			continue
		fire(possible_target)
		return
	fire(get_edge_target_turf(src, pick(GLOB.cardinals)))

/// Called when attacking a target. Shoots a projectile at the turf underneath the target.
/obj/structure/legionturret/proc/fire(atom/target)
	var/turf/target_turf = get_turf(target)
	var/turf/our_turf = get_turf(src)
	if(!target_turf || !our_turf)
		return
	//Now we generate the tracer.
	var/angle = get_angle(our_turf, target_turf)
	var/datum/point/vector/V = new(our_turf.x, our_turf.y, our_turf.z, 0, 0, angle)
	generate_tracer_between_points(V, V.return_vector_after_increments(6), /obj/effect/projectile/tracer/legion/tracer, 0, shot_delay, 0, 0, 0, null)
	playsound(src, 'sound/machines/airlock/airlockopen.ogg', 100, TRUE)
	addtimer(CALLBACK(src, PROC_REF(fire_beam), angle), shot_delay)

/// Called shot_delay after the turret shot the tracer. Shoots a projectile into the same direction.
/obj/structure/legionturret/proc/fire_beam(angle)
	var/obj/projectile/ouchie = new projectile_type(loc)
	ouchie.firer = src
	ouchie.fire(angle)
	playsound(src, 'sound/effects/bin/bin_close.ogg', 100, TRUE)
	QDEL_IN(src, 0.5 SECONDS)

/// Used for the legion turret.
/obj/projectile/beam/legion
	name = "blood pulse"
	hitsound = 'sound/effects/magic/magic_missile.ogg'
	damage = 19
	range = 6
	light_color = COLOR_SOFT_RED
	impact_effect_type = /obj/effect/temp_visual/kinetic_blast
	tracer_type = /obj/effect/projectile/tracer/legion
	muzzle_type = /obj/effect/projectile/tracer/legion
	impact_type = /obj/effect/projectile/tracer/legion
	hitscan = TRUE
	projectile_piercing = ALL

/// Used for the legion turret tracer.
/obj/effect/projectile/tracer/legion/tracer
	icon = 'icons/effects/beam.dmi'
	icon_state = "blood_light"

/// Used for the legion turret beam.
/obj/effect/projectile/tracer/legion
	icon = 'icons/effects/beam.dmi'
	icon_state = "blood"
