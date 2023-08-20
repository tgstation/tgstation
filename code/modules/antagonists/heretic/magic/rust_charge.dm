// Rust charge, a charge action that can only be started on rust (and only destroys rust tiles)
/datum/action/cooldown/mob_cooldown/charge/rust
	name = "Rust Charge"
	desc = "A charge that must be started on a rusted tile and will destroy any rusted objects you come into contact with, will deal high damage to others and rust around you during the charge. As it is the rust that empoweres you for this ability, no focus is needed"
	charge_distance = 10
	charge_damage = 50
	cooldown_time = 45 SECONDS

/datum/action/cooldown/mob_cooldown/charge/rust/Activate(atom/target_atom)
	var/turf/open/start_turf = get_turf(owner)
	if(!istype(start_turf) || !HAS_TRAIT(start_turf, TRAIT_RUSTY))
		return FALSE
	StartCooldown(135 SECONDS, 135 SECONDS)
	charge_sequence(owner, target_atom, charge_delay, charge_past)
	StartCooldown()
	return TRUE
/datum/action/cooldown/mob_cooldown/charge/rust/on_move(atom/source, atom/new_loc, atom/target)
	var/turf/victim = get_turf(owner)
	if(!actively_moving)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	new /obj/effect/temp_visual/decoy/fading(source.loc, source)
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	victim.rust_heretic_act()
	for(var/dir in GLOB.cardinals)
		var/turf/nearby_turf = get_step(victim, dir)
		if(istype(nearby_turf))
			nearby_turf.rust_heretic_act()

/datum/action/cooldown/mob_cooldown/charge/rust/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return
	for(var/dir in GLOB.cardinals)
		var/turf/source = get_turf(owner)
		var/turf/closed/next_turf = get_step(charger, dir)
		if(!istype(source) || !istype(next_turf) || !HAS_TRAIT(source, TRAIT_RUSTY) || !HAS_TRAIT(next_turf, TRAIT_RUSTY))
			continue
		SSexplosions.medturf += next_turf

/datum/action/cooldown/mob_cooldown/charge/rust/on_bump(atom/movable/source, atom/target)
	if(owner == target)
		return
	if(destroy_objects)
		if(isturf(target))
			INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
		if(isobj(target) && target.density)
			SSexplosions.med_mov_atom += target

	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	hit_target(source, target, charge_damage)
