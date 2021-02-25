#define ELECTRIC_BUCKLE_WAIT_TIME 5 SECONDS
///divide the power in the cable net under parent by this to determine the shock damage
#define ELECTRIC_BUCKLE_SHOCK_STRENGTH_DIVISOR  5000
///it will not shock the mob buckled to parent if its required to use a cable to shock and the cable has less than this power availaible
#define ELECTRIC_BUCKLE_MINUMUM_POWERNET_STRENGTH 10

/datum/component/electrified_buckle
	///the shock kit attached to parent_chair
	var/obj/item/required_object
	///this is casted to the overlay we put on parent_chair TODO: make this an argument for initialize
	var/list/requested_overlays
	///it will only shock once every ELECTRIC_BUCKLE_WAIT_TIME
	COOLDOWN_DECLARE(electric_buckle_cooldown)
	///these flags tells this instance what is required in order to allow shocking
	var/usage_flags

/datum/component/electrified_buckle/Initialize(input_requirements, obj/item/input_item, list/overlays_to_add)
	var/atom/movable/parent_as_movable = parent
	if(!istype(parent_as_movable) || !parent_as_movable.can_buckle)
		return COMPONENT_INCOMPATIBLE

	usage_flags = input_requirements

	if((usage_flags & SHOCK_REQUIREMENT_ITEM) && QDELETED(input_item))
		return COMPONENT_INCOMPATIBLE
	else if(usage_flags & SHOCK_REQUIREMENT_ITEM)
		required_object = input_item
		required_object.Move(parent_as_movable.contents)
		RegisterSignal(required_object, COMSIG_PARENT_PREQDELETED, .proc/delete_self)
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), .proc/move_required_object_from_nullspace)

	RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, .proc/on_buckle)

	ADD_TRAIT(parent_as_movable, TRAIT_ELECTRIFIED_CHAIR, INNATE_TRAIT)

	requested_overlays = overlays_to_add
	parent_as_movable.add_overlay(requested_overlays)

	parent_as_movable.name = "electrified [initial(parent_as_movable.name)]"

	if(parent_as_movable.has_buckled_mobs())
		for(var/mob/living/possible_guinea_pig as anything in parent_as_movable.buckled_mobs)
			if(on_buckle(src, possible_guinea_pig, FALSE))
				break

/datum/component/electrified_buckle/UnregisterFromParent()
	var/atom/movable/parent_as_movable = parent

	parent_as_movable.cut_overlay(requested_overlays)
	parent_as_movable.name = initial(parent_as_movable.name)

	if(parent)
		REMOVE_TRAIT(parent_as_movable, TRAIT_ELECTRIFIED_CHAIR, INNATE_TRAIT)
		UnregisterSignal(parent, list(COMSIG_MOVABLE_BUCKLE, COMSIG_MOVABLE_UNBUCKLE, COMSIG_ATOM_EXIT, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER)))
	if(required_object)
		UnregisterSignal(required_object, list(COMSIG_PARENT_PREQDELETED))
	required_object = null
	STOP_PROCESSING(SSprocessing, src)

/datum/component/electrified_buckle/proc/delete_self()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/electrified_buckle/proc/move_required_object_from_nullspace()
	SIGNAL_HANDLER
	var/atom/movable/parent_as_movable = parent
	if(!QDELETED(parent_as_movable))
		required_object.Move(parent_as_movable.loc)
	delete_self()

/datum/component/electrified_buckle/proc/on_buckle(datum/source, mob/living/mob_to_buckle, _force)
	SIGNAL_HANDLER
	if(!istype(mob_to_buckle))
		return FALSE

	COOLDOWN_START(src, electric_buckle_cooldown, ELECTRIC_BUCKLE_WAIT_TIME)
	START_PROCESSING(SSprocessing, src)
	return TRUE

///where the guinea pig is actually shocked if possible
/datum/component/electrified_buckle/process(delta_time)
	var/atom/movable/parent_as_movable = parent
	if(QDELETED(parent_as_movable) || !parent_as_movable.has_buckled_mobs())
		return PROCESS_KILL

	if(!COOLDOWN_FINISHED(src, electric_buckle_cooldown))
		return

	COOLDOWN_START(src, electric_buckle_cooldown, ELECTRIC_BUCKLE_WAIT_TIME)
	var/turf/our_turf = get_turf(parent_as_movable)
	var/obj/structure/cable/live_cable = our_turf.get_cable_node()

	if(!live_cable || !live_cable.powernet || live_cable.powernet.avail < ELECTRIC_BUCKLE_MINUMUM_POWERNET_STRENGTH)
		return

	for(var/mob/living/guinea_pig as anything in parent_as_movable.buckled_mobs)
		var/shock_damage = round(live_cable.powernet.avail / ELECTRIC_BUCKLE_SHOCK_STRENGTH_DIVISOR)
		guinea_pig.electrocute_act(shock_damage, parent_as_movable)
		to_chat(guinea_pig, "<span class='userdanger'>You feel a deep shock course through your body!</span>")
		break

	parent_as_movable.visible_message("<span class='danger'>The electric chair went off!</span>", "<span class='hear'>You hear a deep sharp shock!</span>")

#undef ELECTRIC_BUCKLE_WAIT_TIME
#undef ELECTRIC_BUCKLE_SHOCK_STRENGTH_DIVISOR
#undef ELECTRIC_BUCKLE_MINUMUM_POWERNET_STRENGTH
