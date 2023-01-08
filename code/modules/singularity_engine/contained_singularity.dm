// MBTODO: Play the NarSie tearing effect when it's about to release (lol)
// MBTODO: Insta-red alert for the sake of the prototype...
/obj/contained_singularity
	name = "contained singularity"
	desc = "A gravitational singularity. Through a battle-tested, though heavily confidential technique, it is contained in the folds of space, making it reasonably safe to extract energy from by firing lasers into it. Looking at it gives you a headache."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	plane = ABOVE_LIGHTING_PLANE // idk
	light_range = 6
	flags_1 = SUPERMATTER_IGNORES_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	appearance_flags = KEEP_TOGETHER
	pixel_x = -28
	pixel_y = -28

	COOLDOWN_DECLARE(hit_cooldown)

	var/health = 100
	var/max_health = 100

	VAR_PRIVATE
		datum/component/singularity/singularity
		datum/delayed_power_bar/delayed_power_bar_one
		datum/delayed_power_bar/delayed_power_bar_two

		damage_per_discharge = 1

/obj/contained_singularity/Initialize(mapload)
	. = ..()

	singularity = AddComponent( \
		/datum/component/singularity, \
		roaming = FALSE, \
		singularity_size = STAGE_THREE, \
		consume_range = 1, \
	)

	update_appearance(UPDATE_ICON)

	delayed_power_bar_one = new("Singularity engine", initial_delay = 15 SECONDS, lifetime = 15 SECONDS, recharge_delay = 15 SECONDS)
	delayed_power_bar_two = new("Singularity engine", initial_delay = 5 MINUTES, lifetime = 30 SECONDS, recharge_delay = 90 SECONDS)

/obj/contained_singularity/Destroy()
	QDEL_NULL(singularity)
	QDEL_NULL(delayed_power_bar_one)
	QDEL_NULL(delayed_power_bar_two)

	return ..()

/obj/contained_singularity/update_overlays()
	. = ..()

	var/mutable_appearance/mask = mutable_appearance('icons/effects/96x96.dmi', "singularity_s3")
	mask.blend_mode = BLEND_INSET_OVERLAY
	. += mask

	return .

/obj/contained_singularity/singularity_act()
	return

/obj/contained_singularity/bullet_act(obj/projectile/projectile)
	if (istype(projectile, /obj/projectile/beam/singularity_turret))
		delayed_power_bar_one.poke()
		delayed_power_bar_two.poke()

		addtimer(CALLBACK(src, PROC_REF(try_fire_particle)), 0.3 SECONDS)
		return

	return ..()

/obj/contained_singularity/proc/try_fire_particle()
	if (!COOLDOWN_FINISHED(src, hit_cooldown))
		return

	COOLDOWN_START(src, hit_cooldown, 0.2 SECONDS)

	var/obj/projectile/singularity_particle/particle = new(get_turf(src))
	particle.fired_from = src
	particle.fire(rand(0, 360))
	RegisterSignal(particle, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_hit))
	addtimer(CALLBACK(src, PROC_REF(projectile_expired), particle), 3.5 SECONDS)

	playsound(particle, sound("sound/effects/singulo_particle_throw[rand(1, 2)].ogg"), vol = 50, pressure_affected = FALSE)

// Should count field gens themselves
/obj/contained_singularity/proc/on_projectile_hit(obj/projectile/source, obj/contained_singularity/firer, atom/target)
	SIGNAL_HANDLER

	if (istype(target, /obj/machinery/field/containment/singularity))
		return

	discharge_from(source)

/obj/contained_singularity/proc/projectile_expired(obj/projectile/projectile)
	if (QDELETED(projectile))
		return

	discharge_from(projectile)

/obj/contained_singularity/proc/discharge_from(obj/projectile/projectile)
	var/turf/projectile_turf = get_turf(projectile)
	playsound(projectile_turf, 'sound/effects/singulo_particle_missed.ogg', vol = 50, pressure_affected = FALSE)
	Beam(projectile_turf, icon_state = "sm_arc_supercharged", time = 0.8 SECONDS)
	projectile_turf.balloon_alert_to_viewers("it discharges back!")

	// Logarithmic?
	take_singularity_damage(damage_per_discharge)

	qdel(projectile)

/obj/contained_singularity/proc/console_ui_data()
	return list(
		"containment_percent" = health / max_health,
		"delay_to_overclock" = 0,
		"power_bars" = list(
			delayed_power_bar_one.bar_ui_data(),
			delayed_power_bar_two.bar_ui_data(),
		),
	)

/obj/contained_singularity/proc/take_singularity_damage(damage)
	if (health == 0)
		return

	health = clamp(health - damage, 0, max_health)
	SEND_SIGNAL(src, COMSIG_SINGULARITY_TAKE_DAMAGE, damage)

	if (health == 0)
		self_destruct()

/obj/contained_singularity/proc/self_destruct()
	PRIVATE_PROC(TRUE)

	SEND_SIGNAL(src, COMSIG_SINGULARITY_SELF_DESTRUCTING)

	// Prototype: Would be dynamic to SINGULARITY_BREACH_TIME
	addtimer(CALLBACK(src, PROC_REF(step_self_destruct), 20), 10 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(step_self_destruct), 10), 20 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(step_self_destruct), 5), 25 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(step_self_destruct), 4), 26 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(step_self_destruct), 3), 27 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(step_self_destruct), 2), 28 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(step_self_destruct), 1), 29 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(breach)), 30 SECONDS)

/obj/contained_singularity/proc/step_self_destruct(time_left)
	SEND_SIGNAL(src, COMSIG_SINGULARITY_ADVANCE_SELF_DESTRUCT_STAGE, time_left)

/obj/contained_singularity/proc/breach()
	// Make sure we don't try to suck up any singularities
	qdel(singularity)
	new /obj/singularity(get_turf(src), /* starting_energy = */ 800)
	qdel(src)

/obj/projectile/singularity_particle
	name = "singularity particle"
	icon_state = "pulse1"
	hitsound = 'sound/magic/mm_hit.ogg'
	damage = 60
	damage_type = BRUTE
	armour_penetration = 40
	pass_flags = PASSTABLE | PASSSTRUCTURE

/obj/projectile/singularity_particle/singularity_act()
	return

/obj/projectile/singularity_particle/singularity_pull()
	return

/obj/projectile/singularity_particle/can_hit_target(atom/target, direct_target, ignore_loc, cross_failed)
	// Haaaaack
	if (istype(target, /obj/machinery/singularity_turret) || istype(target, /obj/machinery/field/generator/singularity))
		return FALSE

	return ..()
