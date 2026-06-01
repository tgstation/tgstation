/// Fires out two cross patterns of damaging tentacles which reel in anything they hit, then causes a followup attack
/datum/action/cooldown/mob_cooldown/projectile_attack/tendril_lash
	name = "Tentacle Lash"
	desc = "Lash out with your tentacles in 8 directions, reeling in whatever you hit and unleashing a deadly followup attack afterwards."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = FALSE
	cooldown_time = 8 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	projectile_type = /obj/projectile/tentacle_lash

/datum/action/cooldown/mob_cooldown/projectile_attack/tendril_lash/Activate(atom/target)
	disable_cooldown_actions()

	for (var/swipe_dir in GLOB.cardinals)
		var/turf/open/line_turf = get_step(owner, swipe_dir)
		for (var/i in 1 to projectile_type::range)
			if (!istype(line_turf) || line_turf.is_blocked_turf(exclude_mobs = TRUE))
				break
			var/obj/effect/temp_visual/telegraphing/line/telegraph = new(line_turf)
			telegraph.dir = swipe_dir
			line_turf = get_step(line_turf, swipe_dir)

	SLEEP_CHECK_DEATH(0.8 SECONDS, owner)

	for (var/swipe_dir in GLOB.cardinals)
		shoot_projectile(get_turf(owner), get_step(owner, swipe_dir), dir2angle(swipe_dir), owner)

	SLEEP_CHECK_DEATH(1.6 SECONDS, owner)

	for (var/swipe_dir in GLOB.diagonals)
		var/turf/open/line_turf = get_step(owner, swipe_dir)
		for (var/i in 1 to projectile_type::range)
			if (!istype(line_turf) || line_turf.is_blocked_turf(exclude_mobs = TRUE))
				break
			var/obj/effect/temp_visual/telegraphing/line/telegraph = new(line_turf)
			telegraph.dir = swipe_dir
			line_turf = get_step(line_turf, swipe_dir)

	SLEEP_CHECK_DEATH(0.8 SECONDS, owner)

	for (var/swipe_dir in GLOB.diagonals)
		shoot_projectile(get_turf(owner), get_step(owner, swipe_dir), dir2angle(swipe_dir), owner)

	SLEEP_CHECK_DEATH(1.2 SECONDS, owner)
	StartCooldown()
	SLEEP_CHECK_DEATH(0.6 SECONDS, owner)
	enable_cooldown_actions()
	return TRUE

/obj/projectile/tentacle_lash
	name = "tentacle spike"
	icon_state = "tentacle_spike"
	pass_flags = PASSTABLE
	damage = 5 // +10 from the grab
	armor_flag = MELEE
	range = 7
	hit_prone_targets = TRUE
	hitsound = 'sound/effects/wounds/pierce1.ogg'
	sharpness = SHARP_POINTY
	/// Beam connecting us and the firer
	var/datum/beam/tentacle_beam = null
	/// Does this projectile persist and reel in targets?
	var/reel_in = TRUE
	/// How long does the projectile persist?
	var/duration = 1.2 SECONDS
	/// Damage dealt to targets who get snatched from entering the beam or being hit directly
	var/snatch_damage = 10

/obj/projectile/tentacle_lash/stab
	damage = 15
	range = 2
	duration = 0.2 SECONDS // Just for visual flair
	reel_in = FALSE

/obj/projectile/tentacle_lash/fire(fire_angle, atom/direct_target)
	. = ..()
	if (!firer)
		return
	tentacle_beam = Beam(firer, "goliath_tentacle", beam_type = (reel_in ? /obj/effect/ebeam/reacting : /obj/effect/ebeam), emissive = FALSE)
	if (reel_in)
		RegisterSignal(tentacle_beam, COMSIG_BEAM_ENTERED, PROC_REF(on_beam_entered))

/obj/projectile/tentacle_lash/Destroy()
	QDEL_NULL(tentacle_beam)
	return ..()

// Don't range out, stop and persist until we're done
/obj/projectile/tentacle_lash/on_range()
	STOP_PROCESSING(SSprojectiles, src)
	// Reset to tile center
	pixel_x = 0
	pixel_y = 0
	QDEL_IN(src, duration)

/obj/projectile/tentacle_lash/prehit_pierce(atom/target)
	// Ye 'ole colossus cheese
	if (astype(target, /mob/living)?.stat == DEAD)
		return PROJECTILE_PIERCE_PHASE
	return ..()

/obj/projectile/tentacle_lash/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if (!reel_in || !isliving(target) || blocked >= 100 || pierce_hit || . != BULLET_ACT_HIT)
		return
	snatch_target(target)

/obj/projectile/tentacle_lash/proc/on_beam_entered(datum/beam/source, obj/effect/ebeam/hit, atom/movable/entered)
	SIGNAL_HANDLER

	if (!reel_in || entered == firer || !isliving(entered))
		return

	var/mob/living/victim = entered
	if ((!firer || !firer.faction_check_atom(victim)) && victim.stat != DEAD)
		INVOKE_ASYNC(src, PROC_REF(snatch_target), entered)

/obj/projectile/tentacle_lash/proc/snatch_target(mob/living/victim)
	if (HAS_TRAIT(victim, TRAIT_TENTACLE_IMMUNE) || SEND_SIGNAL(victim, COMSIG_TENDRIL_TENTACLED_GRABBED) & COMPONENT_TENDRIL_CANCEL_TENTACLE_GRAB)
		return

	to_chat(victim, span_userdanger("You're snatched by [firer]'s tentacles!"))
	victim.apply_damage(snatch_damage, BRUTE, BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
	if (QDELETED(victim))
		qdel(src)
		return
	var/snatch_callback = null
	if (istype(firer, /mob/living/basic/mining/tendril))
		var/mob/living/basic/mining/tendril/tendril = firer
		snatch_callback = CALLBACK(tendril, TYPE_PROC_REF(/mob/living/basic/mining/tendril, snatch_react))
	victim.throw_at(firer, initial(range), 1, firer, FALSE, gentle = TRUE, callback = snatch_callback)
	playsound(victim, hitsound, 50, -3, pressure_affected = FALSE)
	qdel(src)

/// An ability which makes spikes come out of the ground towards your target
/datum/action/cooldown/mob_cooldown/tendril_chaser
	name = "Impaling Spikes"
	desc = "Send a spiked subterranean tendril chasing after your target."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "spikes_stabbing"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	cooldown_time = 8 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	/// Lazy list of references to spike trails
	var/list/active_chasers
	/// Health percentage threshold at which we send out wide charsers after the main target
	var/wide_chaser_threshold = 0.7

/datum/action/cooldown/mob_cooldown/tendril_chaser/Grant(mob/granted_to)
	. = ..()
	RegisterSignal(granted_to, COMSIG_MOB_ABILITY_STARTED, PROC_REF(on_ability_started))
	RegisterSignal(granted_to, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(on_ability_finished))

// Clean up after ourselves
/datum/action/cooldown/mob_cooldown/tendril_chaser/Remove(mob/removed_from)
	UnregisterSignal(removed_from, list(COMSIG_MOB_ABILITY_STARTED, COMSIG_MOB_ABILITY_FINISHED))
	QDEL_LIST(active_chasers)
	return ..()

/datum/action/cooldown/mob_cooldown/tendril_chaser/proc/on_ability_started(mob/living/owner, datum/action/cooldown/activated)
	SIGNAL_HANDLER

	// Delete all of our chasers when our owner triggers cross spikes as to not cause guaranteed damage
	if (istype(activated, /datum/action/cooldown/mob_cooldown/tendril_cross_spikes))
		QDEL_LIST(active_chasers)

/datum/action/cooldown/mob_cooldown/tendril_chaser/proc/on_ability_finished(mob/living/owner, datum/action/cooldown/activated)
	SIGNAL_HANDLER

	if (istype(activated, /datum/action/cooldown/mob_cooldown/tendril_cross_spikes))
		ResetCooldown()

/datum/action/cooldown/mob_cooldown/tendril_chaser/Activate(atom/target)
	. = ..()
	var/primary_type = /obj/effect/temp_visual/effect_trail/tendril_chaser
	if (isliving(owner))
		var/mob/living/as_living = owner
		if (as_living.health / as_living.maxHealth <= wide_chaser_threshold)
			primary_type = /obj/effect/temp_visual/effect_trail/tendril_chaser/wide_area

	var/obj/effect/temp_visual/effect_trail/tendril_chaser/chaser = new primary_type(get_turf(owner), target)
	LAZYADD(active_chasers, WEAKREF(chaser))
	RegisterSignal(chaser, COMSIG_QDELETING, PROC_REF(on_chaser_destroyed))
	playsound(owner, 'sound/effects/magic/demon_attack1.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)

/// Remove a spike trail from our list of active trails
/datum/action/cooldown/mob_cooldown/tendril_chaser/proc/on_chaser_destroyed(atom/chaser)
	SIGNAL_HANDLER
	LAZYREMOVE(active_chasers, WEAKREF(chaser))

/obj/effect/temp_visual/effect_trail/tendril_chaser
	duration = 10 SECONDS
	move_speed = 4
	spawned_effect = /obj/effect/temp_visual/emerging_ground_spike/tendril
	/// Do we spawn spikes around ourselves as well or only on our own turf?
	var/area_spawn = FALSE

/obj/effect/temp_visual/effect_trail/tendril_chaser/wide_area
	area_spawn = TRUE

/obj/effect/temp_visual/effect_trail/tendril_chaser/add_spawner()
	return

/obj/effect/temp_visual/effect_trail/tendril_chaser/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if (!area_spawn)
		var/turf/spawn_turf = get_turf(src)
		if (!(locate(/obj/effect/temp_visual/emerging_ground_spike/tendril) in spawn_turf) && isopenturf(spawn_turf))
			new spawned_effect(spawn_turf)
		return

	for (var/spawn_dir in GLOB.cardinals)
		if (spawn_dir & REVERSE_DIR(movement_dir))
			continue
		var/turf/spawn_loc = get_step(src, spawn_dir)
		if (!(locate(/obj/effect/temp_visual/emerging_ground_spike/tendril) in spawn_loc) && isopenturf(spawn_loc))
			new spawned_effect(spawn_loc)

/obj/effect/temp_visual/emerging_ground_spike/tendril
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "spikes_stabbing"
	duration = 0.7 SECONDS
	position_variance = 3
	impale_damage = 10
	damage_blacklist_typecache = list(
		/mob/living/basic/mining/tendril,
	)
	impale_wound_bonus = CANT_WOUND
	// Have we hit someone yet?
	var/hit_loser = FALSE

/obj/effect/temp_visual/emerging_ground_spike/tendril/single
	icon_state = "spike"
	duration = 1 SECONDS
	harm_delay = 0.25 SECONDS
	position_variance = 5

/obj/effect/temp_visual/emerging_ground_spike/tendril/impale()
	. = ..()
	hit_loser |= .
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

/obj/effect/temp_visual/emerging_ground_spike/tendril/proc/on_entered(atom/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if (!isliving(arrived))
		return

	if (harm_mob(arrived) && !hit_loser)
		playsound(src, 'sound/items/weapons/slice.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
		hit_loser = TRUE

/datum/action/cooldown/mob_cooldown/tendril_cross_spikes
	name = "Cross Spikes"
	desc = "Create a wave of spikes around yourself, impaling anyone caught in it."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "spike"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = FALSE
	cooldown_time = 10 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// Health threshold at which we reduce the amount of empty spots on the ground
	var/health_threshold = 0.3

/datum/action/cooldown/mob_cooldown/tendril_cross_spikes/Activate(atom/target)
	disable_cooldown_actions()
	spawn_spikes()
	SLEEP_CHECK_DEATH(0.4 SECONDS, owner)
	spawn_spikes(inverse = TRUE)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/tendril_cross_spikes/proc/spawn_spikes(inverse = FALSE)
	var/list/turf/spike_turfs = list()
	var/turf/owner_turf = get_turf(owner)

	var/reduced_spawns = FALSE
	if (isliving(owner))
		var/mob/living/as_living = owner
		if (as_living.health / as_living.maxHealth <= health_threshold)
			reduced_spawns = TRUE

	for (var/turf/open/target_turf in oview(7, owner_turf))
		if (sqrt((target_turf.x - owner_turf.x) ** 2 + (target_turf.y - owner_turf.y) ** 2) > 9.5) // big circle is a lie
			continue

		if (reduced_spawns)
			if (abs(target_turf.x - owner_turf.x) % 2 == abs(target_turf.y - owner_turf.y + inverse) % 2)
				new /obj/effect/temp_visual/telegraphing/circle/short(target_turf)
				spike_turfs += target_turf
			continue

		var/row_diff = inverse ? abs(target_turf.x - owner_turf.x) : abs(target_turf.y - owner_turf.y)
		var/column_diff = inverse ? abs(target_turf.y - owner_turf.y) : abs(target_turf.x - owner_turf.x)
		var/row = floor((row_diff + 1) / 3)
		if (row % 2 == 0)
			if (row_diff - row * 3 == 0)
				if (column_diff % 4 == 2)
					continue
			else
				if (column_diff % 4 != 0)
					continue
		else
			if (row_diff - row * 3 == 0)
				if (column_diff % 4 == 0)
					continue
			else
				if (column_diff % 4 != 2)
					continue

		new /obj/effect/temp_visual/telegraphing/circle/short(target_turf)
		spike_turfs += target_turf

	SLEEP_CHECK_DEATH(1 SECONDS, owner)

	for (var/turf/open/to_spawn in spike_turfs)
		new /obj/effect/temp_visual/emerging_ground_spike/tendril/single(to_spawn)

	SLEEP_CHECK_DEATH(0.8 SECONDS, owner)

/datum/action/cooldown/mob_cooldown/projectile_attack/tendril_melee
	name = "Tentacle Stab"
	desc = "Stab nearby hostiles with long tentacles."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = FALSE
	cooldown_time = 4 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	projectile_type = /obj/projectile/tentacle_lash/stab

/datum/action/cooldown/mob_cooldown/projectile_attack/tendril_melee/Activate(atom/target_atom, warning = TRUE)
	if (warning)
		for (var/stab_dir in GLOB.alldirs)
			var/turf/open/stab_turf = get_step(owner, stab_dir)
			if (!istype(stab_turf))
				continue
			var/obj/effect/temp_visual/telegraphing/line/short/telegraph = new(stab_turf)
			telegraph.dir = stab_dir

		SLEEP_CHECK_DEATH(0.5 SECONDS, owner)

	for (var/stab_dir in GLOB.alldirs)
		shoot_projectile(get_turf(owner), get_step(owner, stab_dir), firer = owner)

	SLEEP_CHECK_DEATH(0.5 SECONDS, owner)
	StartCooldown()
	return TRUE
