// Rust charge, a charge action that can only be started on rust (and only destroys rust tiles)
/datum/action/cooldown/mob_cooldown/charge/rust
	name = "Rust Charge"
	desc = "A charge that must be started on a rusted tile and will destroy any rusted objects you come into contact with, \
		will deal high damage to others and rust around you during the charge. \
		As it is the rust that empowers you with this ability, no focus is needed."
	charge_distance = 10
	charge_damage = 25
	cooldown_time = 45 SECONDS
	charge_past = 0

/datum/action/cooldown/mob_cooldown/charge/rust/Activate(atom/target_atom)
	var/turf/open/start_turf = get_turf(owner)
	if(!istype(start_turf) || !HAS_TRAIT(start_turf, TRAIT_RUSTY))
		return FALSE
	StartCooldown(135 SECONDS, 135 SECONDS)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.damage_resistance += 100
	RegisterSignal(owner, COMSIG_FINISHED_CHARGE, PROC_REF(affect_aoe))
	charge_sequence(owner, target_atom, charge_delay, charge_past)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/charge/rust/on_move(atom/source, atom/new_loc, atom/target)
	var/turf/victim = get_turf(owner)
	if(!actively_moving)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	new /obj/effect/temp_visual/decoy/fading(source.loc, source)
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	var/mob/living/living_owner = owner
	living_owner.do_rust_heretic_act(victim)
	for(var/dir in GLOB.alldirs)
		var/turf/nearby_turf = get_step(victim, dir)
		if(istype(nearby_turf))
			living_owner.do_rust_heretic_act(nearby_turf)

/datum/action/cooldown/mob_cooldown/charge/rust/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return
	for(var/dir in GLOB.alldirs)
		var/turf/source = get_turf(owner)
		var/turf/closed/next_turf = get_step(charger, dir)
		if(!istype(source) || !istype(next_turf))
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
	try_hit_target(source, target, charge_damage)

/datum/action/cooldown/mob_cooldown/charge/rust/proc/affect_aoe()
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_FINISHED_CHARGE)
	for(var/mob/living/nearby_mob in view(1, owner))
		if(nearby_mob == owner)
			continue
		nearby_mob.apply_damage(charge_damage, BRUTE, wound_bonus = CANT_WOUND)
		nearby_mob.Knockdown(5 SECONDS)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.damage_resistance -= 100
