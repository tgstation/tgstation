///divide the power in the cable net under parent by this to determine the shock damage
#define ELECTRIC_BUCKLE_SHOCK_STRENGTH_DIVISOR 5000
///it will not shock the mob buckled to parent if its required to use a cable to shock and the cable has less than this power availaible
#define ELECTRIC_BUCKLE_MINUMUM_POWERNET_STRENGTH 10


/**
 * # electrified_buckle component:
 * attach it to any atom/movable that can be buckled to in order to have it shock mobs buckled to it. by default it shocks mobs buckled to parent every shock_loop_time.
 * the parent is supposed to define its behavior with arguments in AddComponent
*/
/datum/component/electrified_buckle
	///if usage_flags has SHOCK_REQUIREMENT_ITEM, this is the item required to be inside parent in order for it to shock buckled mobs
	var/obj/item/required_object
	///this is casted to the overlay we put on parent_chair
	var/list/requested_overlays
	///it will only shock once every shock_loop_time
	COOLDOWN_DECLARE(electric_buckle_cooldown)
	///these flags tells this instance what is required in order to allow shocking
	var/usage_flags
	///if true, this will shock the buckled mob every shock_loop_time in process()
	var/shock_on_loop = TRUE
	///how long the component waits before shocking the mob buckled to parent again
	var/shock_loop_time = 5 SECONDS
	///how much damage is done per shock iff usage_flags doesnt have SHOCK_REQUIREMENT_LIVE_CABLE
	var/shock_damage = 50
	///this signal was given as an argument to register for parent to emit, if its emitted to parent then shock_on_demand is called. var is so it can be unregistered
	var/requested_signal_parent_emits = null

/**
 * Initialize args:
 *
 * * input_requirements - bitflag that defines how the component is supposed to act, see __DEFINES/electrified_buckle.dm for the options. sets usage_flags
 * * input_item - if set to an item and input_requirements has SHOCK_REQUIREMENT_ITEM, moves that item inside parent and the component will delete itself if input_item no longer exists/moves out of parent. sets required_object
 * * overlays_to_add - pass in a list of images and the component will add them to parent as well as remove them in UnregisterFromParent(). sets requested_overlays
 * * override_buckle - if TRUE, sets parent.can_buckle = TRUE and resets it on UnregisterFromParent(), usually objects that have need to be overridden will look janky on buckle
 * * damage_on_shock - if SHOCK_REQUIREMENT_LIVE_CABLE is not set in input_requirements, then this is how much damage each shock does. sets shock_damage
 * * signal_to_register_from_parent - if set, the component registers to listen for this signal targeting parent to manually shock. sets requested_signal_parent_emits
*/
/datum/component/electrified_buckle/Initialize(input_requirements, obj/item/input_item, list/overlays_to_add, override_buckle, damage_on_shock = 50, signal_to_register_from_parent, loop_length)
	var/atom/movable/parent_as_movable = parent
	if(!istype(parent_as_movable))
		return COMPONENT_INCOMPATIBLE

	usage_flags = input_requirements

	if(!parent_as_movable.can_buckle && !override_buckle)
		return COMPONENT_INCOMPATIBLE
	else if (override_buckle)
		parent_as_movable.can_buckle = TRUE

	if((usage_flags & SHOCK_REQUIREMENT_ITEM) && QDELETED(input_item))
		return COMPONENT_INCOMPATIBLE

	if(HAS_TRAIT(parent_as_movable, TRAIT_ELECTRIFIED_BUCKLE))
		return COMPONENT_INCOMPATIBLE

	if(usage_flags & SHOCK_REQUIREMENT_ITEM)
		required_object = input_item
		required_object.Move(parent_as_movable)
		RegisterSignal(required_object, COMSIG_PARENT_PREQDELETED, .proc/delete_self)
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), .proc/move_required_object_from_contents)

		if(usage_flags & SHOCK_REQUIREMENT_ON_SIGNAL_RECEIVED)
			shock_on_loop = FALSE
			RegisterSignal(required_object, COMSIG_ASSEMBLY_PULSED, .proc/shock_on_demand)
		else if(usage_flags & SHOCK_REQUIREMENT_SIGNAL_RECEIVED_TOGGLE)
			RegisterSignal(required_object, COMSIG_ASSEMBLY_PULSED, .proc/toggle_shock_loop)

	if((usage_flags & SHOCK_REQUIREMENT_PARENT_MOB_ISALIVE) && ismob(parent))
		RegisterSignal(parent, COMSIG_LIVING_DEATH, .proc/delete_self)

	RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, .proc/on_buckle)

	ADD_TRAIT(parent_as_movable, TRAIT_ELECTRIFIED_BUCKLE, INNATE_TRAIT)

	//if parent wants us to manually shock on some specified action
	if(signal_to_register_from_parent)
		RegisterSignal(parent, signal_to_register_from_parent, .proc/shock_on_demand)
		requested_signal_parent_emits = signal_to_register_from_parent

	if(overlays_to_add)
		requested_overlays = overlays_to_add
		parent_as_movable.add_overlay(requested_overlays)

	parent_as_movable.name = "electrified [initial(parent_as_movable.name)]"

	shock_damage = damage_on_shock

	if(loop_length)
		shock_loop_time = loop_length

	if(parent_as_movable.has_buckled_mobs())
		for(var/mob/living/possible_guinea_pig as anything in parent_as_movable.buckled_mobs)
			if(on_buckle(src, possible_guinea_pig))
				break

/datum/component/electrified_buckle/UnregisterFromParent()
	var/atom/movable/parent_as_movable = parent

	parent_as_movable.cut_overlay(requested_overlays)
	parent_as_movable.name = initial(parent_as_movable.name)
	parent_as_movable.can_buckle = initial(parent_as_movable.can_buckle)

	if(parent)
		REMOVE_TRAIT(parent_as_movable, TRAIT_ELECTRIFIED_BUCKLE, INNATE_TRAIT)
		UnregisterSignal(parent, list(COMSIG_MOVABLE_BUCKLE, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER)))
		if(requested_signal_parent_emits)
			UnregisterSignal(parent, requested_signal_parent_emits)

	if(required_object)
		UnregisterSignal(required_object, list(COMSIG_PARENT_PREQDELETED, COMSIG_ASSEMBLY_PULSED))
		if(parent_as_movable && (required_object in parent_as_movable.contents))
			required_object.Move(parent_as_movable.loc)

	required_object = null
	STOP_PROCESSING(SSprocessing, src)

/datum/component/electrified_buckle/proc/delete_self()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/electrified_buckle/proc/move_required_object_from_contents(datum/source, mob/living/user, obj/item/tool, tool_type)
	SIGNAL_HANDLER
	var/atom/movable/parent_as_movable = parent
	if(!QDELETED(parent_as_movable))
		tool.play_tool_sound(parent_as_movable)
		required_object.Move(parent_as_movable.loc)
	qdel(src)

/datum/component/electrified_buckle/proc/on_buckle(datum/source, mob/living/mob_to_buckle, _force)
	SIGNAL_HANDLER
	if(!istype(mob_to_buckle))
		return FALSE

	COOLDOWN_START(src, electric_buckle_cooldown, shock_loop_time)
	if(!(usage_flags & SHOCK_REQUIREMENT_ON_SIGNAL_RECEIVED) && shock_on_loop)
		START_PROCESSING(SSprocessing, src)
	return TRUE

///where the guinea pig is actually shocked if possible
/datum/component/electrified_buckle/process(delta_time)
	var/atom/movable/parent_as_movable = parent
	if(QDELETED(parent_as_movable) || !parent_as_movable.has_buckled_mobs())
		return PROCESS_KILL

	if(!shock_on_loop)
		return PROCESS_KILL

	if(!COOLDOWN_FINISHED(src, electric_buckle_cooldown))
		return

	COOLDOWN_START(src, electric_buckle_cooldown, shock_loop_time)

	var/turf/our_turf = get_turf(parent_as_movable)
	var/obj/structure/cable/live_cable = our_turf.get_cable_node()

	if(usage_flags & SHOCK_REQUIREMENT_LIVE_CABLE)
		if((!live_cable || !live_cable.powernet || live_cable.powernet.avail < ELECTRIC_BUCKLE_MINUMUM_POWERNET_STRENGTH))
			return

		for(var/mob/living/guinea_pig as anything in parent_as_movable.buckled_mobs)
			guinea_pig.electrocute_act(round(live_cable.powernet.avail / ELECTRIC_BUCKLE_SHOCK_STRENGTH_DIVISOR), parent_as_movable)
			break
	else
		for(var/mob/living/guinea_pig as anything in parent_as_movable.buckled_mobs)
			guinea_pig.electrocute_act(shock_damage, parent_as_movable)
			break

	parent_as_movable.visible_message(span_danger("The electric chair went off!"), span_hear("You hear a deep sharp shock!"))

///a shock that is toggled manually
/datum/component/electrified_buckle/proc/shock_on_demand()
	SIGNAL_HANDLER
	if((usage_flags & SHOCK_REQUIREMENT_ITEM) && QDELETED(required_object))
		return

	var/atom/movable/parent_as_movable = parent
	if(usage_flags & SHOCK_REQUIREMENT_LIVE_CABLE)
		var/turf/our_turf = get_turf(parent_as_movable)
		var/obj/structure/cable/live_cable = our_turf.get_cable_node()
		if(!live_cable || !live_cable.powernet || live_cable.powernet.avail < ELECTRIC_BUCKLE_MINUMUM_POWERNET_STRENGTH)
			return

		for(var/mob/living/guinea_pig as anything in parent_as_movable.buckled_mobs)
			var/shock_damage = round(live_cable.powernet.avail / ELECTRIC_BUCKLE_SHOCK_STRENGTH_DIVISOR)
			guinea_pig.electrocute_act(shock_damage, parent_as_movable)
			break

/datum/component/electrified_buckle/proc/toggle_shock_loop()
	SIGNAL_HANDLER
	var/atom/movable/parent_as_movable = parent
	if(shock_on_loop)
		shock_on_loop = FALSE
		STOP_PROCESSING(SSprocessing, src)
		parent_as_movable.visible_message(span_notice("The electric chair emits a snap as its circuit opens, making it safe for now."))
	else
		shock_on_loop = TRUE
		START_PROCESSING(SSprocessing, src)
		parent_as_movable.visible_message(span_notice("You hear the sound of an electric circuit closing coming from the electric chair!"))

#undef ELECTRIC_BUCKLE_SHOCK_STRENGTH_DIVISOR
#undef ELECTRIC_BUCKLE_MINUMUM_POWERNET_STRENGTH
