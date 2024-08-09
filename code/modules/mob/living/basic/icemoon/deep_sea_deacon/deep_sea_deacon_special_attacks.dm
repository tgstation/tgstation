#define CRYSTAL_MAYHEM_TIMER 15 SECONDS
#define ALL_DIRECTIONS "all_directions"
#define IN_BETWEEN_DIRECTIONS "in_between_directions"
#define BEAM_TRIAL_DURATION 18 SECONDS

////black and white attack
/datum/action/cooldown/mob_cooldown/black_n_white
	name = "beams of judgement"
	button_icon = 'icons/effects/beam.dmi'
	button_icon_state = "holy_beam"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Release beams of judgement in all directions."
	cooldown_time = 25 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///how many times we fire off.
	var/fire_amount = 4
	/// time between entrappment and damaging attack
	var/time_to_fire = 2 SECONDS
	/// angle we fire projectiles at
	var/list/projectile_angles = list(22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5)

/datum/action/cooldown/mob_cooldown/black_n_white/Activate(atom/movable/target)
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	animate(owner, alpha = 0, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(telegraph_attack)), 1 SECONDS)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/black_n_white/proc/telegraph_attack()
	owner.icon_state = "deep_sea_deacon_blacknwhite"
	animate(owner, alpha = 255, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(commence_fire)), 2 SECONDS)

/datum/action/cooldown/mob_cooldown/black_n_white/proc/commence_fire()
	for(var/count in 0 to fire_amount)
		addtimer(CALLBACK(src, PROC_REF(shoot_projectiles)), count * time_to_fire * 2)
	for(var/count in 1 to fire_amount)
		beam_directions(GLOB.cardinals)
		SLEEP_CHECK_DEATH(time_to_fire, owner)
		beam_directions(GLOB.diagonals)
		SLEEP_CHECK_DEATH(time_to_fire, owner)
	if(isnull(owner))
		return
	animate(owner, alpha = 0, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_attack)), 1 SECONDS)

/datum/action/cooldown/mob_cooldown/black_n_white/proc/shoot_projectiles()
	if(isnull(owner))
		return
	var/turf/my_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	for(var/angle in projectile_angles)
		var/obj/projectile/deacon_wisp/wisp = new
		wisp.preparePixelProjectile(my_turf, target_turf)
		wisp.firer = owner
		wisp.original = my_turf
		wisp.fire(angle)


/datum/action/cooldown/mob_cooldown/black_n_white/proc/end_attack()
	if(isnull(owner))
		return
	owner.icon_state = initial(owner.icon_state)
	REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	animate(owner, alpha = 255, time = 1 SECONDS)

/datum/action/cooldown/mob_cooldown/black_n_white/proc/beam_directions(list/directions)
	for(var/direction in directions)
		playsound(owner, 'sound/magic/magic_block_holy.ogg', 60, TRUE)
		var/turf/next_turf = get_step(owner, direction)
		var/turf/target_turf = get_ranged_target_turf(owner, direction, 9)
		if(isnull(target_turf))
			continue
		next_turf.Beam(
			BeamTarget = target_turf,
			beam_type = /obj/effect/ebeam/reacting/judgement,
			icon = 'icons/effects/beam.dmi',
			icon_state = "holy_beam",
			beam_color = COLOR_WHITE,
			time = time_to_fire,
			emissive = TRUE,
		)
		damage_enemies_in_line(get_line(next_turf, target_turf))

/datum/action/cooldown/mob_cooldown/black_n_white/proc/damage_enemies_in_line(list/turfs)
	for(var/turf/current_turf as anything in turfs)
		for(var/mob/living/victim in current_turf) //this is sin
			victim.apply_damage(50, BURN)

////healing pylon attack
/datum/action/cooldown/mob_cooldown/healing_pylon
	name = "healing pylon"
	button_icon = 'icons/obj/service/hand_of_god_structures.dmi'
	button_icon_state = "healing_pylon"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Summon crystals that give you all the power."
	cooldown_time = 25 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///list of pylons we have created
	var/list/our_pylons = list()

/datum/action/cooldown/mob_cooldown/healing_pylon/Activate(atom/movable/target)
	var/turf/my_turf = get_turf(owner)

	for(var/direction in GLOB.diagonals)
		var/turf/destination_turf = get_ranged_target_turf(owner, direction, 5)
		var/obj/projectile/healing_crystal/crystal = new
		crystal.preparePixelProjectile(destination_turf, my_turf)
		crystal.firer = owner
		crystal.ability = src
		crystal.fire()

	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))

	owner.add_filter("healing_pylon", 2, list("type" = "outline", "color" = "#6b2d8f", "alpha" = 0, "size" = 1))
	var/filter = owner.get_filter("healing_pylon")
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)

	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/healing_pylon/proc/add_pylon(atom/pylon)
	our_pylons += pylon
	RegisterSignal(pylon, COMSIG_QDELETING, PROC_REF(on_pylon_delete))

/datum/action/cooldown/mob_cooldown/healing_pylon/proc/on_pylon_delete(datum/source)
	SIGNAL_HANDLER
	our_pylons -= source
	if(!length(our_pylons))
		terminate_ability()

/datum/action/cooldown/mob_cooldown/healing_pylon/proc/terminate_ability()
	REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	owner.remove_filter("healing_pylon")

/obj/projectile/healing_crystal
	name = "healing crystal"
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "healing_pylon"
	damage = 0
	light_range = 2
	range = 9
	light_color = LIGHT_COLOR_BABY_BLUE
	speed = 1
	can_hit_turfs = TRUE
	pixel_speed_multiplier = 0.75
	pass_flags = PASSTABLE | PASSMOB
	///the ability that owns us
	var/datum/action/cooldown/mob_cooldown/healing_pylon/ability

/obj/projectile/healing_crystal/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/obj/structure/healing_crystal/healing = new(get_turf(src))
	ability.add_pylon(healing)
	healing.set_owner(firer)

/obj/projectile/healing_crystal/Destroy(force)
	. = ..()
	ability = null

/obj/structure/healing_crystal
	name = "healing pylon"
	desc = "Probably a good idea to destroy this..."
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "healing_pylon"
	light_range = 2
	layer = ABOVE_OBJ_LAYER
	light_color = COLOR_WHITE
	max_integrity = 10
	density = TRUE

	anchored = TRUE
	///the owner we must heal
	var/mob/living/our_owner
	///the beam we are using
	var/datum/beam/our_beam
	///how much we heal on processing
	var/heal_tick = 5

/obj/structure/healing_crystal/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)
	AddElement(/datum/element/temporary_atom, life_time = 15 SECONDS, fade_time = 1 SECONDS)

/obj/structure/healing_crystal/proc/set_owner(mob/living/owner)
	our_owner = owner
	RegisterSignal(our_owner, COMSIG_QDELETING, PROC_REF(on_master_delete))
	var/turf/my_turf = get_turf(src)
	our_beam = my_turf.Beam(
		BeamTarget = our_owner,
		icon = 'icons/effects/beam.dmi',
		icon_state = "blood",
		beam_color = COLOR_WHITE,
		override_target_pixel_x = 12,
		emissive = TRUE,
	)
	START_PROCESSING(SSobj, src)

/obj/structure/healing_crystal/process(seconds_per_tick)
	if(isnull(our_owner))
		return PROCESS_KILL
	our_owner.heal_overall_damage(heal_tick)

/obj/structure/healing_crystal/proc/on_master_delete(datum/source)
	SIGNAL_HANDLER
	our_owner = null
	qdel(src)

/obj/structure/healing_crystal/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	our_owner = null
	QDEL_NULL(our_beam)

/////beam trial attack
/datum/action/cooldown/mob_cooldown/beam_trial
	name = "beam trial"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "judgement_crystal"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "A holy crystal that will unleash beams on your target."
	cooldown_time = 25 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///max distance of crystals from the target
	var/distance = 3
	///our list of pylons
	var/list/our_pylons = list()
	///amount of trials
	var/trial_amount = 6

/datum/action/cooldown/mob_cooldown/beam_trial/Activate(atom/movable/target)
	if(isnull(target))
		return
	var/static/list/directions_ordered = list( //clockwise direction
		SOUTH,
		SOUTHWEST,
		WEST,
		NORTHWEST,
		NORTH,
		NORTHEAST,
		EAST,
		SOUTHEAST,
	)

	for(var/direction in directions_ordered)
		var/turf/destination_turf = get_ranged_target_turf(target, direction, distance)
		var/obj/structure/trial_crystal/crystal = new(destination_turf)
		our_pylons[dir2text(direction)] = crystal
		RegisterSignal(crystal, COMSIG_QDELETING, PROC_REF(crystal_deleted))

	for(var/count in 1 to length(directions_ordered))
		var/direction = directions_ordered[count]
		var/next_direction = count == length(directions_ordered) ? directions_ordered[1] : directions_ordered[count + 1]
		var/obj/structure/trial_crystal/first = our_pylons[dir2text(direction)]
		var/obj/structure/trial_crystal/next = our_pylons[dir2text(next_direction)]
		first.Beam(
			BeamTarget = next,
			beam_type = /obj/effect/ebeam/reacting/judgement/barrier,
			icon = 'icons/effects/beam.dmi',
			icon_state = "holy_beam",
			beam_color = COLOR_WHITE,
			time = BEAM_TRIAL_DURATION,
			emissive = TRUE,
		)
	INVOKE_ASYNC(src, PROC_REF(commence_trials))
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	StartCooldown()
	if(get_dist(owner, target) > distance)
		return TRUE
	var/list/outside_bound_turfs = RANGE_TURFS(distance + 2, target) - RANGE_TURFS(distance, target)
	for(var/turf/possible_turf as anything in outside_bound_turfs)
		if(isclosedturf(possible_turf))
			continue
		do_teleport(owner, possible_turf)
		break
	return TRUE

/datum/action/cooldown/mob_cooldown/beam_trial/proc/commence_trials()
	for(var/count in 1 to trial_amount)
		var/list/copied_directions = GLOB.alldirs.Copy()
		var/first_direction = pick_n_take(copied_directions)
		copied_directions -= REVERSE_DIR(first_direction)
		var/second_direction = pick_n_take(copied_directions)
		beam_directions(list(first_direction, second_direction))
		SLEEP_CHECK_DEATH(3.5 SECONDS, owner)

/datum/action/cooldown/mob_cooldown/beam_trial/proc/beam_directions(list/directions)
	for(var/direction in directions)
		var/obj/structure/trial_crystal = our_pylons[dir2text(direction)]
		var/obj/structure/next_crystal = our_pylons[dir2text(REVERSE_DIR(direction))]
		if(isnull(trial_crystal) || isnull(next_crystal))
			return
		trial_crystal.add_filter("crystal_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 2))
		next_crystal.add_filter("crystal_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 2))
		addtimer(CALLBACK(src, PROC_REF(beam_opposite_crystal), trial_crystal, next_crystal), 1 SECONDS)


/datum/action/cooldown/mob_cooldown/beam_trial/proc/beam_opposite_crystal(atom/our_crystal, atom/target_crystal)
	our_crystal.Beam(
		BeamTarget = target_crystal,
		beam_type = /obj/effect/ebeam/reacting/judgement/crystal,
		icon = 'icons/effects/beam.dmi',
		icon_state = "holy_beam",
		beam_color = COLOR_WHITE,
		time = 2 SECONDS,
		emissive = TRUE,
	)
	playsound(our_crystal, 'sound/magic/magic_block_holy.ogg', 100, TRUE)
	var/list/turfs = get_line(our_crystal, target_crystal)
	for(var/turf/current_turf as anything in turfs)
		for(var/mob/living/victim in current_turf) //this is sin
			victim.apply_damage(10, BURN)
	our_crystal.remove_filter("crystal_glow")
	target_crystal.remove_filter("crystal_glow")

/datum/action/cooldown/mob_cooldown/beam_trial/proc/crystal_deleted(datum/source)
	SIGNAL_HANDLER

	for(var/direction in our_pylons)
		if(our_pylons[direction] == source)
			our_pylons -= direction
	if(!length(our_pylons))
		REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))

/obj/structure/trial_crystal
	name = "Red crystal"
	desc = "Gotta get outta here..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "judgement_crystal"
	alpha = 0
	light_range = 2
	light_color = COLOR_WHITE
	max_integrity = INFINITY
	plane = ABOVE_GAME_PLANE
	density = TRUE
	anchored = TRUE
	///how long do we exist for
	var/exist_time = BEAM_TRIAL_DURATION

/obj/structure/trial_crystal/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)
	AddElement(/datum/element/temporary_atom, life_time = exist_time, fade_time = 1 SECONDS)

/obj/effect/ebeam/reacting/judgement/barrier
	density = TRUE

////crystal mayhem attack
/datum/action/cooldown/mob_cooldown/crystal_mayhem
	name = "Crystal Mayhem"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "flame_crystal"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Unleash a mayhem of crystals!"
	cooldown_time = 25 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS

/datum/action/cooldown/mob_cooldown/crystal_mayhem/Activate(atom/target)
	if(isnull(target))
		return FALSE
	var/static/list/in_between_directions = list()
	var/turf/my_turf = get_turf(owner)
	for(var/direction in GLOB.diagonals)
		var/turf/target_turf = get_ranged_target_turf(owner, direction, 2)
		playsound(owner, 'sound/magic/holy_crystal_fire.ogg', 60, TRUE)
		var/obj/projectile/flame_crystal/flame = new
		flame.preparePixelProjectile(target_turf, my_turf)
		flame.firer = owner
		flame.original = target_turf
		flame.fire()
	var/turf/beaming_turf =  get_ranged_target_turf(owner, SOUTH, 3)
	var/obj/projectile/judgement_crystal/judgement = new
	judgement.preparePixelProjectile(beaming_turf, my_turf)
	judgement.firer = owner
	judgement.original = beaming_turf
	judgement.fire()
	judgement.to_beam = WEAKREF(target)
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	addtimer(CALLBACK(src, PROC_REF(end_attack)), CRYSTAL_MAYHEM_TIMER)
	return TRUE

/datum/action/cooldown/mob_cooldown/crystal_mayhem/proc/end_attack()
	REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))

/obj/projectile/flame_crystal
	name = "flame crystal"
	icon = 'icons/effects/effects.dmi'
	icon_state = "flame_crystal"
	damage = 0
	light_range = 2
	range = 9
	light_color = COLOR_WHITE
	speed = 1
	can_hit_turfs = TRUE
	pixel_speed_multiplier = 0.75
	pass_flags = PASSTABLE | PASSMOB
	impact_effect_type = /obj/effect/temp_visual/flame_crystal

/obj/effect/temp_visual/flame_crystal
	icon = 'icons/effects/effects.dmi'
	icon_state = "flame_crystal"
	light_range = 2
	light_color = COLOR_WHITE
	duration = CRYSTAL_MAYHEM_TIMER
	///how long we wait before firing
	var/shoot_intervals = 3 SECONDS
	///first set of directions to fire in
	var/static/list/directions_to_fire = list(
		ALL_DIRECTIONS = list(0, 45, 90, 135, 180, 225, 270, 315),
		IN_BETWEEN_DIRECTIONS = list(22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5),
	)

/obj/effect/temp_visual/flame_crystal/Initialize(mapload)
	. = ..()
	var/static/list/to_pick_from = list(ALL_DIRECTIONS, IN_BETWEEN_DIRECTIONS)
	addtimer(CALLBACK(src, PROC_REF(start_firing), pick(to_pick_from)), shoot_intervals)

/obj/effect/temp_visual/flame_crystal/proc/start_firing(index)
	var/next_directions = (index == ALL_DIRECTIONS) ? IN_BETWEEN_DIRECTIONS : ALL_DIRECTIONS
	var/list/all_angles = directions_to_fire[index]
	var/turf/my_turf = get_turf(src)
	for(var/angle in all_angles)
		var/turf/target_turf = get_step(src, SOUTH)
		var/obj/projectile/deacon_wisp/wisp = new
		wisp.preparePixelProjectile(target_turf, my_turf)
		wisp.firer = src
		wisp.original = my_turf
		wisp.fire(angle)
	addtimer(CALLBACK(src, PROC_REF(start_firing), next_directions), shoot_intervals)


