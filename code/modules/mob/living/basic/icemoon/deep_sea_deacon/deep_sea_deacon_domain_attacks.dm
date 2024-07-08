#define DOMAIN_STAY_TIMER 20 SECONDS

/datum/action/cooldown/mob_cooldown/domain_teleport //jjk ahh attack
	name = "domain teleportation"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "judgement_crystal"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Its your playground now..."
	cooldown_time = 10 MINUTES
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///the boss landmark of our domain
	var/boss_landmark = /obj/effect/landmark/deacon_hell_boss
	///the victims landmark of our domain
	var/victim_landmark = /obj/effect/landmark/deacon_hell_player
	///list of people we have teleported
	var/list/victim_list = list()
	///our turf
	var/turf/previous_turf
	///how long we stay in the domain
	var/stay_timer = DOMAIN_STAY_TIMER

/datum/action/cooldown/mob_cooldown/domain_teleport/IsAvailable(feedback = FALSE)
	if(!(locate(boss_landmark) in GLOB.landmarks_list))
		return FALSE
	if(!(locate(victim_landmark) in GLOB.landmarks_list))
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/domain_teleport/Activate(atom/movable/target)
	for(var/mob/living/living_player in oview(9, owner))
		if(isnull(living_player.mind))
			continue
		victim_list[living_player] = get_turf(living_player)
	previous_turf = get_turf(owner)
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	teleport_victims()
	addtimer(CALLBACK(src, PROC_REF(end_attack)), stay_timer)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/domain_teleport/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER
	end_attack()

/datum/action/cooldown/mob_cooldown/domain_teleport/proc/teleport_victims()
	var/obj/effect/landmark/boss_marker = locate(boss_landmark) in GLOB.landmarks_list
	var/obj/effect/landmark/player_marker = locate(victim_landmark) in GLOB.landmarks_list
	do_teleport(owner, boss_marker)
	for(var/mob/living/living_player in victim_list)
		do_teleport(living_player, player_marker)

/datum/action/cooldown/mob_cooldown/domain_teleport/hell
	name = "hell domain"
	///the boss landmark of our domain
	boss_landmark = /obj/effect/landmark/deacon_hell_boss
	///the victims landmark of our domain
	victim_landmark = /obj/effect/landmark/deacon_hell_player
	///list of our crystals
	var/list/our_crystals = list()

/datum/action/cooldown/mob_cooldown/domain_teleport/hell/teleport_victims()
	. = ..()
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	var/static/list/crystal_directions = list(
		WEST,
		SOUTHWEST,
		NORTHWEST,
	)
	for(var/direction in crystal_directions)
		var/turf/crystal_turf = get_step(owner, direction)
		var/obj/structure/trial_crystal/hell_domain/my_crystal = new(crystal_turf)
		our_crystals += my_crystal
	select_shoot_crystals()

/datum/action/cooldown/mob_cooldown/domain_teleport/hell/proc/select_shoot_crystals()
	if(!length(our_crystals))
		return
	var/list/copied_list = our_crystals.Copy()
	pick_n_take(copied_list)
	for(var/atom/crystal as anything in copied_list)
		crystal.add_filter("crystal_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(shoot_crystals), copied_list), 1 SECONDS)

/datum/action/cooldown/mob_cooldown/domain_teleport/hell/proc/shoot_crystals(list/crystals_list)
	var/list/target_turf_list = list()
	for(var/atom/crystal as anything in crystals_list)
		var/turf/target_turf = get_ranged_target_turf(crystal, WEST, 10)
		if(isnull(target_turf))
			continue
		target_turf_list += get_line(crystal, target_turf)
		crystal.Beam(
			BeamTarget = target_turf,
			beam_type = /obj/effect/ebeam/reacting/judgement/crystal,
			icon = 'icons/effects/beam.dmi',
			icon_state = "holy_beam",
			beam_color = COLOR_WHITE,
			time = 1 SECONDS,
			emissive = TRUE,
		)
		crystal.remove_filter("crystal_glow")
		playsound(crystal, 'sound/magic/magic_block_holy.ogg', 60, TRUE, pressure_affected = FALSE)
	for(var/turf/current_turf as anything in target_turf_list)
		for(var/mob/living/victim in current_turf)
			victim.apply_damage(25, BURN)
	addtimer(CALLBACK(src, PROC_REF(select_shoot_crystals)), 1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/domain_teleport/proc/end_attack()
	for(var/atom/victim as anything in victim_list)
		do_teleport(victim, victim_list[victim], forced = TRUE)
		victim_list -= victim
	if(isnull(owner))
		return
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	do_teleport(owner, previous_turf, forced = TRUE)
	var/datum/ai_controller/controller = owner.ai_controller
	controller.set_ai_status(controller.get_expected_ai_status())

/datum/action/cooldown/mob_cooldown/domain_teleport/hell/end_attack()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	for(var/atom/crystal as anything in our_crystals)
		our_crystals -= crystal
		qdel(crystal)

/obj/structure/trial_crystal/hell_domain
	density = FALSE
	exist_time = DOMAIN_STAY_TIMER

/datum/action/cooldown/mob_cooldown/domain_teleport/heaven
	name = "heaven domain"
	boss_landmark = /obj/effect/landmark/deacon_heaven_boss
	victim_landmark = /obj/effect/landmark/deacon_heaven_player

/datum/action/cooldown/mob_cooldown/domain_teleport/heaven/teleport_victims()
	. = ..()
	owner.ai_controller?.set_blackboard_key(BB_DEACON_BOUNCE_MODE, TRUE) //initiate bouncing protocols

/datum/action/cooldown/mob_cooldown/domain_teleport/heaven/end_attack()
	. = ..()
	owner.ai_controller?.set_blackboard_key(BB_DEACON_BOUNCE_MODE, FALSE)

////our bounce attack
/datum/action/cooldown/mob_cooldown/bounce
	name = "bounce"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "rift"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Leap upon your target!"
	cooldown_time = 5 SECONDS
	shared_cooldown = NONE
	///angle we fire projectiles at
	var/list/projectile_angles = list(0, 90, 180, 270)
	///damage we apply to any mob we land on
	var/damage_to_apply = 50
	///should we make chasms?
	var/cast_chasm = TRUE

/datum/action/cooldown/mob_cooldown/bounce/Activate(atom/movable/target)
	if(isnull(target))
		return
	animate(owner, pixel_y = 500, time = 1 SECONDS)
	var/obj/effect/temp_visual/deacon_bounce/leap = new (get_turf(owner))
	addtimer(CALLBACK(src, PROC_REF(commence_bounce), target, leap), 1 SECONDS)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/bounce/proc/commence_bounce(atom/movable/target, atom/movable/leap)
	var/turf/target_turf = get_turf(target)
	var/turf/our_turf = get_turf(owner)
	var/pixel_x_difference = target_turf.x - our_turf.x
	var/pixel_y_difference = target_turf.y - our_turf.y
	animate(leap, pixel_x = (pixel_x_difference * 32), pixel_y = (pixel_y_difference * 32), time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_bounce), target_turf, leap), 1 SECONDS)

/datum/action/cooldown/mob_cooldown/bounce/proc/end_bounce(turf/target, atom/movable/leap)
	owner.forceMove(target)
	animate(leap, transform = matrix().Scale(0.1, 0.1), time = 0.4 SECONDS)
	animate(owner, pixel_y = initial(owner.pixel_y), time = 0.4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(apply_damage), target), 0.4 SECONDS)

/datum/action/cooldown/mob_cooldown/bounce/proc/apply_damage(atom/target)
	if(isnull(owner) || isnull(target))
		return
	playsound(owner.loc, 'sound/effects/meteorimpact.ogg', 200, TRUE)
	fire_projectiles(target)
	for(var/mob/living/living_mob in oview(9, owner))
		shake_camera(living_mob, duration = 3, strength = 1)
		if(get_dist(living_mob, owner) <= 1)
			living_mob.apply_damage(damage_to_apply)
	if(cast_chasm)
		create_chasms()

/datum/action/cooldown/mob_cooldown/bounce/proc/create_chasms()
	var/list/chasmed_turfs = list()
	for(var/turf/possible_turf as anything in RANGE_TURFS(1, owner))
		if(isclosedturf(possible_turf) || isgroundlessturf(possible_turf))
			continue
		new /obj/effect/temp_visual/mook_dust(possible_turf)
		var/old_turf_type = possible_turf.type
		var/turf/new_turf = possible_turf.TerraformTurf(/turf/open/chasm/icemoon, /turf/open/chasm/icemoon, flags = CHANGETURF_INHERIT_AIR)
		chasmed_turfs[new_turf] = old_turf_type
	addtimer(CALLBACK(src, PROC_REF(revert_turfs), chasmed_turfs), 25 SECONDS)

/datum/action/cooldown/mob_cooldown/bounce/proc/fire_projectiles(atom/target)
	var/turf/target_turf = get_turf(target)
	var/turf/my_turf = get_turf(owner)
	for(var/angle in projectile_angles)
		var/obj/projectile/deacon_wisp/wisp = new
		wisp.preparePixelProjectile(my_turf, target_turf)
		wisp.firer = owner
		wisp.original = my_turf
		wisp.fire(angle)

/datum/action/cooldown/mob_cooldown/bounce/proc/revert_turfs(list/chasmed_turfs)
	for(var/turf/old_turf as anything in chasmed_turfs)
		var/chasmed_turf_type = chasmed_turfs[old_turf]
		chasmed_turfs -= old_turf
		old_turf.TerraformTurf(chasmed_turf_type, chasmed_turf_type, flags = CHANGETURF_INHERIT_AIR)

/datum/action/cooldown/mob_cooldown/bounce/no_chasm
	cast_chasm = FALSE

/obj/effect/temp_visual/deacon_bounce
	icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "deep_sea_deacon_shadow"
	pixel_x = -32
	base_pixel_x = -32
	duration = 10 SECONDS

/datum/action/cooldown/mob_cooldown/domain_teleport/surface
	name = "surface domain"
	boss_landmark = /obj/effect/landmark/deacon_surface_boss
	victim_landmark = /obj/effect/landmark/deacon_surface_player
	stay_timer = 40 SECONDS

/datum/action/cooldown/mob_cooldown/domain_teleport/surface/teleport_victims()
	. = ..()
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	owner.status_flags |= GODMODE
	var/static/list/dirs_to_shoot = list(NORTH, NORTHWEST, WEST, SOUTHWEST)
	for(var/obj/effect/landmark/deacon_surface_plasma/plasma_loc in GLOB.landmarks_list)
		var/obj/effect/temp_visual/plasma_blob/plasma = new get_turf(plasma_loc)
		INVOKE_ASYNC(plasma, TYPE_PROC_REF(/obj/effect/temp_visual/plasma_blob, assign_shooting_directions), dirs_to_shoot)
	addtimer(CALLBACK(src, PROC_REF(teleport_around)), 10 SECONDS)

/datum/action/cooldown/mob_cooldown/domain_teleport/surface/proc/teleport_around()
	var/counter = 0
	for(var/obj/effect/landmark/deacon_surface_projectile_turfs_marker/teleport_point in GLOB.landmarks_list)
		addtimer(CALLBACK(src, PROC_REF(teleport_attack_sequence), teleport_point), counter * (8 SECONDS))
		counter++

/datum/action/cooldown/mob_cooldown/domain_teleport/surface/proc/teleport_attack_sequence(obj/effect/landmark/deacon_surface_projectile_turfs_marker/teleport_point)
	var/direction = text2dir(teleport_point.turfs_direction)
	var/turf/teleport_turf = get_ranged_target_turf(teleport_point, direction, 4)
	do_teleport(owner, teleport_turf)
	for(var/counter in 0 to 3)
		addtimer(CALLBACK(src, PROC_REF(launch_projectiles), teleport_point), counter * (1.75 SECONDS))

/datum/action/cooldown/mob_cooldown/domain_teleport/surface/proc/launch_projectiles(obj/effect/landmark/deacon_surface_projectile_turfs_marker/teleport_point)
	var/direction = text2dir(teleport_point.turfs_direction)
	var/projectile_direction = text2dir(teleport_point.projectiles_direction)
	var/atom/target = get_ranged_target_turf(teleport_point, direction, 9)
	var/list/turfs_list = get_line(teleport_point, target)
	var/turf/final_turf = turfs_list[length(turfs_list)]
	shuffle_inplace(turfs_list)

	for(var/turf/excluded_turf as anything in turfs_list) //first, exclude 2 random turfs
		if(excluded_turf == final_turf)
			continue
		turfs_list -= get_step(excluded_turf, direction)
		turfs_list -= excluded_turf
		break

	for(var/turf/turf_to_shoot as anything in turfs_list) //second, fire our projectiles
		new /obj/effect/temp_visual/celestial_explosion/directional(turf_to_shoot, projectile_direction)

/datum/action/cooldown/mob_cooldown/domain_teleport/surface/end_attack()
	. = ..()
	if(isnull(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	owner.status_flags &= ~GODMODE


/obj/effect/temp_visual/plasma_blob
	light_color = COLOR_WHITE
	icon = 'icons/effects/effects.dmi'
	icon_state = "celestial_crossing"
	plane = ABOVE_GAME_PLANE
	duration = 10 SECONDS

/obj/effect/temp_visual/plasma_blob/proc/assign_shooting_directions(list/directions)
	if(isnull(src))
		return
	var/turf/my_turf = get_turf(src)
	for(var/direction in directions)
		if(isnull(src))
			return
		var/opposite_direction = REVERSE_DIR(direction)
		var/turf/target_turf = get_beam_target_turf(direction)
		var/turf/opposite_target_turf = get_beam_target_turf(opposite_direction)
		if(isnull(target_turf) || isnull(opposite_target_turf))
			return
		for(var/turf/turf_to_beam as anything in list(target_turf, opposite_target_turf))
			my_turf.Beam(
				BeamTarget = turf_to_beam,
				beam_type = /obj/effect/ebeam/reacting/judgement,
				icon = 'icons/effects/beam.dmi',
				icon_state = "celestial_beam",
				beam_color = COLOR_WHITE,
				time = 0.3 SECONDS,
				emissive = TRUE,
			)
			playsound(src, 'sound/magic/magic_missile.ogg', 30, TRUE, pressure_affected = FALSE)
		sleep(0.4 SECONDS)
	assign_shooting_directions(directions) //recursive call until we get deleted

/obj/effect/temp_visual/plasma_blob/proc/get_beam_target_turf(direction)
	var/turf/target_turf = get_ranged_target_turf(src, direction, 10)
	if(isnull(target_turf))
		return null
	for(var/turf/projection_turf as anything in get_line(src, target_turf))
		if(isclosedturf(projection_turf))
			return projection_turf
	return target_turf

/obj/effect/temp_visual/celestial_explosion/directional
	target_mob_size = MOB_SIZE_TINY
	damage_to_apply = 10

/obj/effect/temp_visual/celestial_explosion/directional/Initialize(mapload, direction)
	. = ..()
	playsound(src, 'sound/magic/magic_missile.ogg', 5, TRUE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(create_wave), direction), 0.25 SECONDS)

/obj/effect/temp_visual/celestial_explosion/directional/proc/create_wave(direction)
	var/turf/next_turf = get_step(src, direction)
	if(isclosedturf(next_turf))
		return
	new /obj/effect/temp_visual/celestial_explosion/directional(next_turf, direction)
