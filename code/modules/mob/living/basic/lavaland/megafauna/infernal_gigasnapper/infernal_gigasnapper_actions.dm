//OTHER IDEAS
// force pull a single target into the fissure? to prevent players from trying to stay out of it
// past 50% health, can activate hazards inside the fissure to make fight more difficult
// charging bubble blast that deals heavy damage and blows player back into magma if caught, hitbox is wide as crab sprite above and below


/// how close a target needs to be to get charged
#define PLOW_TARGETING_RANGE 9
#define PLOW_COOLDOWN 3 SECONDS
#define PLOW_MAX_MOVEMENTS 12

/datum/action/cooldown/mob_cooldown/side_charge
	name = "Pyroclastic Plow"
	desc = "Charge left or right at a foe without warning, dealing massive damage. Only usable when a foe is located to your left or right."
	shared_cooldown = MOB_SHARED_COOLDOWN_1
	cooldown_time = PLOW_COOLDOWN
	/// how many times we've moved this charge, so we stop charging after enough moves
	var/movements_this_charge = 0
	/// direction we're charging, if we're charging
	var/charge_dir = NONE

/datum/action/cooldown/mob_cooldown/side_charge/Activate(atom/target_atom)
	var/mob/living/basic/mining/megafauna/infernal_gigasnapper/crab = owner
	var/direction = is_valid_charge(crab, target_atom)
	if(!direction)
		return
	StartCooldownSelf(INFINITY)
	RegisterSignal(crab, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	crab.charge_dir = direction

/// checks if a target can be charged at, used by AI to decide if a charge makes sense,
/// used by players to cancel invalid charges
///
/// returns direction the charge should be made in, if the charge is valid
/datum/action/cooldown/mob_cooldown/side_charge/proc/is_valid_charge(mob/living/crab, atom/target)
	if(!isliving(target))
		return FALSE
	var/direction = target.y < crab.y ? WEST \
		: target.y == crab.y ? NONE : EAST
	if(!direction)
		return FALSE
	//either same y as the crab, or one above the crab (also hit by the attack)
	var/is_horizontally_aligned = target.y == crab.y || target.y == crab.y + 1
	if(!is_horizontally_aligned)
		return FALSE
	//in range, technically if the person is above it will be slightly
	var/is_in_range = get_dist(crab, target) <= PLOW_TARGETING_RANGE
	if(!is_in_range)
		return FALSE
	return direction

/datum/action/cooldown/mob_cooldown/side_charge/proc/on_owner_moved(mob/living/crab, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(!charge_dir || movements_this_charge >= PLOW_MAX_MOVEMENTS)
		end_charge()
		return
	movements_this_charge++

///collision logic for common things that might be hit, called when the crab collides with something during a charge.
/// this is shamelessly taken from trams. crabs are kind of like trams when charging.
/// and you know what? i wrote tram code too. this is MY RIGHT to make crabs act like trams.
/datum/action/cooldown/mob_cooldown/side_charge/proc/charge_collide(mob/living/crab, atom/collided)
	if(iswallturf(collided))
		hit_wall(collided)
	if(ismineralturf(collided))
		hit_mineral(collided)

	for(var/obj/structure/victim_structure in collided.contents)
		if(QDELING(victim_structure))
			continue

		if(victim_structure.anchored && initial(victim_structure.anchored) == TRUE)
			owner.visible_message(span_danger("[src] smashes through [victim_structure]!"))
			victim_structure.deconstruct(FALSE)

		else
			if(!throw_target)
				throw_target = get_edge_target_turf(src, turn(travel_direction, pick(45, -45)))
			owner.visible_message(span_danger("[src] violently rams [victim_structure] out of the way!"))
			victim_structure.anchored = FALSE
			victim_structure.take_damage(rand(20, 25) * collision_lethality)
			victim_structure.throw_at(throw_target, 200 * collision_lethality, 4 * collision_lethality)

/datum/action/cooldown/mob_cooldown/side_charge/proc/hit_wall(turf/closed/wall/collided_wall)
	do_sparks(2, FALSE, collided_wall)
	collided_wall.dismantle_wall(devastated = TRUE)
	for(var/mob/client_mob in SSspatial_grid.orthogonal_range_search(collided_wall, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, 8))
		shake_camera(client_mob, duration = 2, strength = 3)
	playsound(collided_wall, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	// ends charge if crab has moved half of its maximum
	return movements_this_charge >= PLOW_MAX_MOVEMENTS - PLOW_MAX_MOVEMENTS / 2

/datum/action/cooldown/mob_cooldown/side_charge/proc/hit_mineral(turf/closed/mineral/collided_mineral)
	for(var/mob/client_mob in SSspatial_grid.orthogonal_range_search(collided_mineral, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, 8))
		shake_camera(client_mob, duration = 2, strength = 3)
	collided_mineral.gets_drilled(give_exp = FALSE)
	// ends charge if crab has moved 3/4ths of its maximum, can go through a lot of mineral turfs
	return movements_this_charge >= PLOW_MAX_MOVEMENTS - PLOW_MAX_MOVEMENTS / 4

/datum/action/cooldown/mob_cooldown/side_charge/proc/hit_living(mob/living/collided_living)
	owner.visible_message(span_danger("[owner] smashes into [collided_living] with a frontal claw, sending [collided_living.p_them()] flying!"))
	collided_living.heal_overall_damage(30, 10)
	if(QDELETED(collided_living)) //in case it was a mob that dels on death
		return TRUE

	//if charging EAST, will turn to the NORTHEAST or SOUTHEAST to throw away from another charge
	var/turf/throw_target = get_edge_target_turf(src, turn(charge_dir, pick(45, -45)))
	var/turf/turf_to_bloody = get_turf(collided_living)
	turf_to_bloody.add_mob_blood(collided_living)
	collided_living.throw_at()
	collided_living.throw_at(throw_target, 200, 4)
	return TRUE

/datum/action/cooldown/mob_cooldown/side_charge/proc/end_charge()
	if(!charge_dir)
		return
	charge_dir = NONE
	UnregisterSignal(crab, COMSIG_MOVABLE_MOVED)
	side_charge_action.StartCooldown()

#undef PLOW_TARGETING_RANGE
#undef PLOW_COOLDOWN

/datum/action/cooldown/mob_cooldown/jump
	name = "Crustacean Reposition"
	desc = "Jump to a new location without creating a fissure. Much shorter cooldown than the full version."
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/jump/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	jump(owner, target_atom)
	StartCooldownOthers(1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/jump/proc/jump(mob/living/crab, atom/target)
	///TODO
	//player chooses a location with a point and click before activate
	//	if no player, auto decision somewhere on a nearby target or random if none
	//chargeup sequence, cant do anything
	//leap
	return

/datum/action/cooldown/mob_cooldown/jump/molten_wall
	name = "Molten Fissure Leap"
	desc = "After charging up, jump to a new spot. After landing, channel again to create a long lasting invulnerable wall above and below you that damages targets when they touch it."

/datum/action/cooldown/mob_cooldown/jump/molten_wall/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	jump(owner, target_atom)
	//wall after jump is done
	StartCooldownOthers(1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/jump/molten_wall/jump(mob/living/crab, atom/target)
	..()
	wall()

/datum/action/cooldown/mob_cooldown/jump/molten_wall/proc/wall(mob/living/crab, atom/target)
	///TODO
	//raise a molten wall above and below
	return

/datum/action/cooldown/mob_cooldown/toggle_pinching
	name = "Toggle Pinching"
	desc = "While pinching is active, you will randomly pinch above and below you when enemies are nearby. If for some reason you don't want to, you can disable it."
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/toggle_pinching/Activate(atom/target_atom)
	//TODO: disable passive behavior to pinch nearby enemies, this should just be a var toggle
	StartCooldownSelf(1 SECONDS)
