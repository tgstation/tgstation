GLOBAL_LIST_EMPTY(contained_singularities)

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
	COOLDOWN_DECLARE(overclocked_hit_cooldown)
	COOLDOWN_DECLARE(treat_as_overclocked_cooldown)

	var/health = 100
	var/max_health = 100

	var/datum/singularity_anchor_loop/anchor_loop
	var/obj/item/gravity_anchor/gravity_anchor

	VAR_PRIVATE
		datum/component/singularity/singularity

		static/datum/delayed_power_bar/delayed_power_bar_one
		static/datum/delayed_power_bar/delayed_power_bar_two

		static/datum/delayed_power_bar/overclocked_power_bar_one
		static/datum/delayed_power_bar/overclocked_power_bar_two
		static/datum/delayed_power_bar/overclocked_power_bar_three

		damage_per_discharge = 1
		chance_of_extra_particle_at_zero_health_per_second = 0.4

		last_heal = 0
		time_since_last_hit = 0
		time_to_wait_before_healing = 13 SECONDS
		heal_per_interval = 1
		heal_interval = 12 SECONDS

/obj/contained_singularity/Initialize(mapload)
	. = ..()

	GLOB.contained_singularities += src

	singularity = AddComponent( \
		/datum/component/singularity, \
		roaming = FALSE, \
		singularity_size = STAGE_TWO, \
		consume_range = 1, \
	)

	START_PROCESSING(SSobj, src)

	update_appearance(UPDATE_ICON)

	delayed_power_bar_one = new("Singularity engine", initial_delay = 15 SECONDS, lifetime = 15 SECONDS, recharge_delay = 15 SECONDS)
	delayed_power_bar_two = new("Singularity engine", initial_delay = 12 MINUTES, lifetime = 30 SECONDS, recharge_delay = 90 SECONDS)

	overclocked_power_bar_one = new("Singularity engine (overclock)", lifetime = 7 MINUTES, wait_for_poke = TRUE, show_decay = TRUE)
	overclocked_power_bar_two = new("Singularity engine (overclock)", lifetime = 11 MINUTES, wait_for_poke = TRUE, show_decay = TRUE)
	overclocked_power_bar_three = new("Singularity engine (overclock)", lifetime = 14 MINUTES, wait_for_poke = TRUE, show_decay = TRUE)

/obj/contained_singularity/Destroy()
	GLOB.contained_singularities -= src

	gravity_anchor = null

	QDEL_NULL(anchor_loop)
	QDEL_NULL(singularity)

	QDEL_NULL(delayed_power_bar_one)
	QDEL_NULL(delayed_power_bar_two)
	QDEL_NULL(overclocked_power_bar_one)
	QDEL_NULL(overclocked_power_bar_two)
	QDEL_NULL(overclocked_power_bar_three)

	STOP_PROCESSING(SSobj, src)

	return ..()

/obj/contained_singularity/update_overlays()
	. = ..()

	var/mutable_appearance/mask = mutable_appearance('icons/effects/96x96.dmi', isnull(gravity_anchor) ? "singularity_s3" : "clockwork_gateway_active")
	mask.blend_mode = BLEND_INSET_OVERLAY
	. += mask

	return .

/obj/contained_singularity/singularity_act()
	return

/obj/contained_singularity/bullet_act(obj/projectile/projectile)
	if (istype(projectile, /obj/projectile/beam/singularity_turret))
		var/obj/projectile/beam/singularity_turret/turret_beam = projectile

		delayed_power_bar_one.poke()
		delayed_power_bar_two.poke()
		time_since_last_hit = world.time

		if (turret_beam.overclocked)
			overclocked_fire_particle_reaction()
		else
			addtimer(CALLBACK(src, PROC_REF(fire_particle_reaction)), 0.3 SECONDS)

		return

	return ..()

/obj/contained_singularity/process(seconds_per_tick)
	var/health_percent = health / max_health
	if (health_percent >= 1)
		return

	if (SPT_PROB(100 * ((1 - health_percent) * chance_of_extra_particle_at_zero_health_per_second), seconds_per_tick))
		try_fire_particle()

	if (health > 0 && world.time - time_since_last_hit >= time_to_wait_before_healing && world.time - last_heal >= heal_interval)
		health = min(round(health + heal_per_interval, 0.1), max_health)
		last_heal = world.time

/obj/contained_singularity/proc/fire_particle_reaction()
	set waitfor = FALSE

	if (!COOLDOWN_FINISHED(src, hit_cooldown))
		return

	COOLDOWN_START(src, hit_cooldown, 0.2 SECONDS)
	try_fire_particle()

/obj/contained_singularity/proc/overclocked_fire_particle_reaction()
	set waitfor = FALSE

	if (!COOLDOWN_FINISHED(src, overclocked_hit_cooldown))
		return

	COOLDOWN_START(src, overclocked_hit_cooldown, 0.1 SECONDS)
	COOLDOWN_START(src, treat_as_overclocked_cooldown, 8 SECONDS)

	overclocked_power_bar_one.poke()
	overclocked_power_bar_two.poke()
	overclocked_power_bar_three.poke()

	for (var/_ in 1 to 3)
		try_fire_particle()

/obj/contained_singularity/proc/try_fire_particle(angle)
	set waitfor = FALSE

	var/obj/projectile/singularity_particle/particle = new(get_turf(src))
	particle.fired_from = src
	particle.fire(isnull(angle) ? rand(0, 360) : angle)
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

/obj/contained_singularity/proc/discharge_from(obj/projectile/singularity_particle/projectile)
	ASSERT(istype(projectile))

	var/turf/projectile_turf = get_turf(projectile)
	playsound(projectile_turf, 'sound/effects/singulo_particle_missed.ogg', vol = 50, pressure_affected = FALSE)
	Beam(projectile_turf, icon_state = "sm_arc_supercharged", time = 0.8 SECONDS)
	projectile_turf.balloon_alert_to_viewers("it discharges back!")

	if (COOLDOWN_FINISHED(src, treat_as_overclocked_cooldown) || (health / max_health) > POWER_BAR_FLAG(FFLAG_OVERCLOCK_MAX_OVERCLOCK_DAMAGE))
		take_singularity_damage(damage_per_discharge)

	qdel(projectile)

/obj/contained_singularity/proc/console_ui_data()
	return list(
		"containment_percent" = health / max_health,
		"power_bars" = list(
			delayed_power_bar_one.bar_ui_data(),
			delayed_power_bar_two.bar_ui_data(),
		),
		"overclocked_power_bars" = list(
			overclocked_power_bar_one.bar_ui_data(),
			overclocked_power_bar_two.bar_ui_data(),
			overclocked_power_bar_three.bar_ui_data(),
		),
	)

/obj/contained_singularity/proc/take_singularity_damage(damage)
	if (health == 0)
		return

	if (!isnull(gravity_anchor))
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
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sound_to_playing_players), 'sound/effects/dimensional_rend.ogg'), 25 SECONDS)
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
	new /obj/singularity(get_turf(src), /* starting_energy = */ POWER_BAR_FLAG(FFLAG_DEFAULT_SINGULO_ENERGY))
	qdel(src)

	sound_to_playing_players('sound/effects/magic/charge.ogg')

	for (var/mob/living/living_player as anything in GLOB.alive_player_list)
		if (is_station_level(living_player.z))
			living_player.Knockdown(4 SECONDS)
			to_chat(living_player, span_userdanger("You suddenly drop to your knees after feeling a strong push, almost as if from a ghost."))
		else
			to_chat(living_player, span_userdanger("You feel a strong tug at your shoulder, almost as if from a ghost. Something is wrong..."))

	if (POWER_BAR_FLAG(FFLAG_RED_ALERT))
		addtimer(CALLBACK(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, set_level), SEC_LEVEL_RED), 15 SECONDS)

/obj/contained_singularity/proc/set_anchor(obj/item/gravity_anchor/gravity_anchor)
	if (!isnull(src.gravity_anchor))
		return FALSE

	src.gravity_anchor = gravity_anchor
	update_appearance(UPDATE_ICON)
	anchor_loop = new(src)

	return TRUE

/obj/contained_singularity/proc/remove_anchor()
	QDEL_NULL(anchor_loop)
	gravity_anchor = null
	update_appearance(UPDATE_ICON)

/obj/projectile/singularity_particle
	name = "singularity particle"
	icon_state = "pulse1"
	hitsound = 'sound/effects/magic/mm_hit.ogg'
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

#define STAGE_DELAY (2.5 SECONDS)

#define STAGE_PROJECTILE_STORM 1
#define STAGE_X_BEAM 2
#define STAGE_MAX STAGE_X_BEAM

// Separated for processing reasons
/datum/singularity_anchor_loop
	var/obj/contained_singularity/singularity

	var/time_to_next_stage
	var/stage = STAGE_PROJECTILE_STORM

	var/projectile_storm_revolution = 2 SECONDS
	var/projectile_storm_per_projectile_interval = 0.2 SECONDS
	var/projectile_storm_current_angle = 0
	COOLDOWN_DECLARE(projectile_storm_cooldown)

	var/x_beam_preview_time = 0.4 SECONDS
	var/x_beam_preview_angle = 0
	var/x_beam_half_range = 7
	var/list/turf/x_beam_peak_turfs = list()
	var/list/turf/x_beam_target_turfs = list()
	var/list/obj/effect/x_beam_preview/x_beam_previews = list()
	COOLDOWN_DECLARE(x_beam_cooldown)

/datum/singularity_anchor_loop/New(obj/contained_singularity/singularity)
	src.singularity = singularity

	time_to_next_stage = world.time + STAGE_DELAY

	START_PROCESSING(SSsingularity_anchor_loop, src)

/datum/singularity_anchor_loop/Destroy(force, ...)
	if (singularity.anchor_loop == src)
		singularity.anchor_loop = null

	singularity = null
	STOP_PROCESSING(SSsingularity_anchor_loop, src)

	QDEL_LIST(x_beam_previews)

	x_beam_peak_turfs = null
	x_beam_target_turfs = null

	return ..()

/datum/singularity_anchor_loop/process(delta_time)
	if (QDELETED(singularity.gravity_anchor))
		qdel(src)
		return

	if (world.time >= time_to_next_stage)
		time_to_next_stage = world.time + STAGE_DELAY

		if (stage == STAGE_X_BEAM)
			addtimer(CALLBACK(src, PROC_REF(fire_final_x_beam)), COOLDOWN_TIMELEFT(src, x_beam_cooldown), TIMER_STOPPABLE | TIMER_DELETE_ME)

		stage = (stage % STAGE_MAX) + 1

	switch (stage)
		if (STAGE_PROJECTILE_STORM)
			projectile_storm()
		if (STAGE_X_BEAM)
			x_beam()

/datum/singularity_anchor_loop/proc/projectile_storm()
	if (!COOLDOWN_FINISHED(src, projectile_storm_cooldown))
		return

	COOLDOWN_START(src, projectile_storm_cooldown, projectile_storm_per_projectile_interval)

	projectile_storm_current_angle += 360 * (projectile_storm_per_projectile_interval / projectile_storm_revolution)
	singularity.try_fire_particle(projectile_storm_current_angle)

/datum/singularity_anchor_loop/proc/x_beam()
	if (!COOLDOWN_FINISHED(src, x_beam_cooldown))
		return

	fire_existing_x_beam()

	COOLDOWN_START(src, x_beam_cooldown, x_beam_preview_time)

	x_beam_preview_angle += rand(25, 75)

	var/turf/singularity_turf = get_turf(singularity)

	for (var/offset in 0 to 270 step 90)
		var/turf/target_turf = get_turf_in_angle(
			SIMPLIFY_DEGREES(x_beam_preview_angle + offset),
			singularity_turf,
			x_beam_half_range,
		)

		x_beam_peak_turfs += target_turf
		x_beam_target_turfs += get_line(singularity_turf, target_turf)

	var/list/existing_x_beam_previews = x_beam_previews
	var/index = 0

	for (var/turf/target_turf in x_beam_target_turfs)
		index += 1
		var/obj/effect/x_beam_preview/preview = existing_x_beam_previews.len < index ? null : existing_x_beam_previews[index]
		if (isnull(preview))
			preview = new(target_turf)
			x_beam_previews += preview
		else
			preview.forceMove(target_turf)

	for (var/beam_index in index to existing_x_beam_previews.len)
		qdel(existing_x_beam_previews[beam_index])

	x_beam_previews.len = index

/datum/singularity_anchor_loop/proc/fire_existing_x_beam()
	if (x_beam_target_turfs.len == 0)
		return

	playsound(singularity, 'sound/effects/magic/lightningbolt.ogg', 70, vary = TRUE, pressure_affected = FALSE)

	for (var/turf/peak_turf as anything in x_beam_peak_turfs)
		singularity.Beam(peak_turf, "sm_arc_dbz_referance", time = 0.4 SECONDS)

	for (var/turf/target_turf as anything in x_beam_target_turfs)
		for (var/mob/living/victim in target_turf)
			victim.apply_damage(60, BURN)

	x_beam_peak_turfs.Cut()
	x_beam_target_turfs.Cut()

/datum/singularity_anchor_loop/proc/fire_final_x_beam()
	fire_existing_x_beam()
	QDEL_LIST(x_beam_previews)

/obj/effect/x_beam_preview
	icon_state = "shield-red"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = BELOW_MOB_LAYER

// Something something drift?
/obj/effect/x_beam_preview/newtonian_move(inertia_angle, instant = FALSE, start_delay = 0, drift_force = 1 NEWTONS, controlled_cap = null, force_loop = TRUE)
	return TRUE

PROCESSING_SUBSYSTEM_DEF(singularity_anchor_loop)
	name = "Singularity Anchor Loop"
	ss_flags = SS_NO_INIT
	wait = 0.1 SECONDS

#undef STAGE_DELAY
#undef STAGE_PROJECTILE_STORM
#undef STAGE_X_BEAM
#undef STAGE_MAX
