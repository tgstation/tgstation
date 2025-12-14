/*
 * A component given to holographic objects to make them glitch out when passed through
 */
#define GLITCH_DURATION 0.45 SECONDS
#define GLITCH_REMOVAL_DURATION 0.25 SECONDS

/datum/component/holographic_nature
	///cooldown before we can glitch out again
	COOLDOWN_DECLARE(glitch_cooldown)
	///list of signals we apply to our turf
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

/datum/component/holographic_nature/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/holographic_nature/RegisterWithParent()
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)
	if(isliving(parent))
		RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_mob_damaged))
		return

	var/atom/atom_parent = parent
	if(isobj(atom_parent) && atom_parent.uses_integrity)
		RegisterSignal(parent, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(on_object_damaged))

/datum/component/holographic_nature/proc/on_mob_damaged(mob/living/source, damage_amount, damagetype, def_zone, blocked, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER
	if(damagetype == BURN || damagetype == BRUTE)
		apply_effects()

/datum/component/holographic_nature/proc/on_object_damaged(obj/source, damage, damage_type, ...)
	SIGNAL_HANDLER
	if(damage_type == BURN || damage_type == BRUTE)
		apply_effects()

/datum/component/holographic_nature/proc/on_entered(atom/movable/source, atom/movable/thing)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	if(!isturf(movable_parent.loc))
		return
	if(isprojectile(thing) || thing.density)
		apply_effects()

/datum/component/holographic_nature/proc/apply_effects()
	if(!COOLDOWN_FINISHED(src, glitch_cooldown))
		return
	COOLDOWN_START(src, glitch_cooldown, GLITCH_DURATION + GLITCH_REMOVAL_DURATION)
	apply_wibbly_filters(parent)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_wibbly_filters), parent, GLITCH_REMOVAL_DURATION), GLITCH_DURATION)

#undef GLITCH_DURATION
#undef GLITCH_REMOVAL_DURATION
