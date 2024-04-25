
/// how close a target needs to be to get charged
#define PLOW_TARGETING_RANGE 9
/// maximum amount of tiles a charge can move if it hits nothing
#define PLOW_MAX_MOVEMENTS 12
/// how fast we move during a charge in deciseconds
#define PLOW_SPEED 1

/datum/action/cooldown/mob_cooldown/crab_collide
	name = "Pyroclastic Plow"
	desc = "Charge left or right at a foe without warning, dealing massive damage. Only usable when a foe is located to your left or right."
	shared_cooldown = MOB_SHARED_COOLDOWN_1
	cooldown_time = 3 SECONDS
	/// how many times we've moved this charge, so we stop charging after enough moves
	var/movements_this_charge = 0
	/// direction we're charging, if we're charging
	var/charge_dir = NONE

/datum/action/cooldown/mob_cooldown/crab_collide/Grant(mob/granted_to)
	. = ..()
	RegisterSignal(granted_to, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))

/datum/action/cooldown/mob_cooldown/crab_collide/Remove(mob/removed_from)
	UnregisterSignal(removed_from, COMSIG_MOVABLE_MOVED)
	. = ..()

/datum/action/cooldown/mob_cooldown/crab_collide/Activate(atom/target_atom)
	var/direction = is_valid_charge(owner, target_atom)
	if(!direction)
		return
	var/turf/loop_target = get_turf(owner)
	for(var/i in 1 to PLOW_MAX_MOVEMENTS)
		loop_target = get_step(loop_target, direction)

	var/time_to_hit = PLOW_MAX_MOVEMENTS * PLOW_SPEED

	var/datum/move_loop/new_loop = SSmove_manager.move_to(owner, loop_target, delay = PLOW_SPEED, timeout = time_to_hit, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!new_loop)
		return
	RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(on_move_loop_postprocess))
	RegisterSignal(new_loop, COMSIG_QDELETING, PROC_REF(on_move_loop_qdel))
	StartCooldownSelf(INFINITY)
	temp_lava(owner)
	owner.visible_message(span_boldwarning("[owner] bursts into a deadly charge!"))
	charge_dir = direction

/datum/action/cooldown/mob_cooldown/crab_collide/proc/temp_lava(mob/living/basic/mining/megafauna/infernal_gigasnapper/crab)
	var/list/lava_turfs = crab.get_crab_turfs(TRUE)
	for(var/turf/lava_turf in lava_turfs)
		new /obj/effect/temp_visual/lava_warning(lava_turf)

/// signal fired when move loop qdels, to absolutely ensure a charge ends when the loop finishes
/datum/action/cooldown/mob_cooldown/crab_collide/proc/on_move_loop_qdel(datum/move_loop/source)
	SIGNAL_HANDLER
	end_charge()

/// signal fired after move loop processes, to check if the charge should end
/datum/action/cooldown/mob_cooldown/crab_collide/proc/on_move_loop_postprocess(datum/move_loop/source, result)
	SIGNAL_HANDLER
	if(!charge_dir)
		qdel(source)

/// checks if a target can be charged at, used by AI to decide if a charge makes sense,
/// used by players to cancel invalid charges
///
/// returns direction the charge should be made in, if the charge is valid
/datum/action/cooldown/mob_cooldown/crab_collide/proc/is_valid_charge(mob/living/crab, atom/target)
	if(!isliving(target))
		crab.balloon_alert(crab, "target isn't a creature!")
		return FALSE
	if(target == owner)
		crab.balloon_alert(crab, "target can't be yourself!")
		return FALSE
	var/direction = target.x < crab.x ? WEST \
		: target.x == crab.x ? NONE : EAST
	if(!direction)
		//means the target is above, below, or on top of you, all of which count as not horizontally aligned.
		crab.balloon_alert(crab, "target not sidewise to you!")
		return FALSE
	//either same y as the crab, or one above the crab (also hit by the attack)
	var/is_horizontally_aligned = target.y == crab.y || target.y == crab.y + 1
	if(!is_horizontally_aligned)
		crab.balloon_alert(crab, "target not sidewise to you!")
		return FALSE
	//in range, technically if the person is above it will be slightly less but whatever
	var/is_in_range = get_dist(crab, target) <= PLOW_TARGETING_RANGE
	if(!is_in_range)
		crab.balloon_alert(crab, "target out of range!")
		return FALSE
	return direction

/// signal that fires when the action owner moves
/datum/action/cooldown/mob_cooldown/crab_collide/proc/on_owner_moved(mob/living/basic/mining/megafauna/infernal_gigasnapper/crab, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(charge_dir)
		new /obj/effect/temp_visual/decoy/fading(crab.loc, crab)
		playsound(crab, 'sound/creatures/crab/deep_crab_clicks.ogg', 100, TRUE)
		movements_this_charge++
	var/list/crab_turfs = crab.get_crab_turfs()
	for(var/turf/crab_turf as anything in crab_turfs)
		collide(crab_turf)

/// collision logic for common things that might be hit, called when the crab collides with something during a charge.
///
/// walls end a charge if the crab has moved at least half of a full charge, mineral turfs 3/4ths of a charge
///
/// this is shamelessly taken from trams. crabs are kind of like trams when charging.
/// and you know what? i wrote tram code too. this is MY RIGHT to make crabs act like trams.
/datum/action/cooldown/mob_cooldown/crab_collide/proc/collide(atom/collided)
	var/finished_charging = FALSE
	// collided is a turf
	if(iswallturf(collided))
		hit_wall(collided)
		finished_charging = movements_this_charge >= PLOW_MAX_MOVEMENTS - (PLOW_MAX_MOVEMENTS / 2)
	else if(ismineralturf(collided))
		hit_mineral(collided)
		finished_charging = movements_this_charge >= PLOW_MAX_MOVEMENTS - (PLOW_MAX_MOVEMENTS / 4)

	for(var/obj/structure/structure_victim in collided.contents)
		//keep charging to avoid any cheese about buckling things to structures
		hit_structure(structure_victim)
	for(var/mob/living/living_victim in collided.contents)
		//but any living ends the charge
		hit_living(living_victim)
		finished_charging = TRUE
	if(finished_charging)
		end_charge()

/// logic for colliding into a wall
/datum/action/cooldown/mob_cooldown/crab_collide/proc/hit_wall(turf/closed/wall/collided_wall)
	do_sparks(2, FALSE, collided_wall)
	collided_wall.dismantle_wall(devastated = TRUE)
	for(var/mob/client_mob in SSspatial_grid.orthogonal_range_search(collided_wall, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, 8))
		shake_camera(client_mob, duration = 2, strength = 3)
	playsound(collided_wall, 'sound/effects/meteorimpact.ogg', 100, TRUE)

/// logic for colliding into a mineral
/datum/action/cooldown/mob_cooldown/crab_collide/proc/hit_mineral(turf/closed/mineral/collided_mineral)
	for(var/mob/client_mob in SSspatial_grid.orthogonal_range_search(collided_mineral, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, 8))
		shake_camera(client_mob, duration = 2, strength = 3)
	collided_mineral.gets_drilled(give_exp = FALSE)

/// logic for colliding into a structure (very important for cheese prevention)
/datum/action/cooldown/mob_cooldown/crab_collide/proc/hit_structure(obj/structure/collided_structure)
	if(QDELING(collided_structure))
		return

	if(collided_structure.anchored && initial(collided_structure.anchored) == TRUE)
		owner.visible_message(span_danger("[src] smashes through [collided_structure]!"))
		collided_structure.deconstruct(FALSE)
	else
		owner.visible_message(span_danger("[src] violently rams [collided_structure] out of the way!"))
		collided_structure.anchored = FALSE
		collided_structure.take_damage(rand(20, 25))
		throw_away(collided_structure)

/datum/action/cooldown/mob_cooldown/crab_collide/proc/hit_living(mob/living/collided_living)
	if(charge_dir)
		playsound(collided_living, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		playsound(collided_living, SFX_PUNCH, 25, TRUE, -1)
		owner.visible_message(span_danger("[owner] smashes into [collided_living] with an oversized pincer, sending [collided_living.p_them()] flying!"))
		collided_living.take_overall_damage(30, 10)
		var/turf/turf_to_bloody = get_turf(collided_living)
		turf_to_bloody.add_mob_blood(collided_living)
		shake_camera(collided_living, 4, 3)
		shake_camera(owner, 2, 3)
	else
		owner.visible_message(span_warning("[owner] knocks [collided_living] out of the way."))
		collided_living.take_overall_damage(10)
	if(!QDELETED(collided_living)) //in case it was a mob that dels on death
		throw_away(collided_living)

/// tosses an atom away from a charge.
/// no chance of a miner getting stunlocked to death as the charge ends on contact but it removes the miner from bad death zone
/datum/action/cooldown/mob_cooldown/crab_collide/proc/throw_away(atom/movable/throw_victim)
	//if charging EAST, will turn to the NORTHEAST or SOUTHEAST to throw away from another charge collision
	var/turf/throw_target = get_edge_target_turf(throw_victim, turn(charge_dir, pick(45, -45)))
	throw_victim.throw_at(throw_target, 200, 4)

/// stops charging, starts the real cooldown.
/// safe to be called multiple times to ensure a charge ends, since it can in a few hard to track ways
/datum/action/cooldown/mob_cooldown/crab_collide/proc/end_charge()
	if(!charge_dir)
		return
	movements_this_charge = 0
	charge_dir = NONE
	StartCooldown()

#undef PLOW_TARGETING_RANGE
#undef PLOW_MAX_MOVEMENTS
#undef PLOW_SPEED
