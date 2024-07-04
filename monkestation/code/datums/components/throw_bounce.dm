//an item with this component will bounce around the mobs in the room if it impacts a mob
/datum/component/throw_bounce
	//how often an item can start a bounce proc
	var/bounce_cooldown = 1 SECONDS
	//the maximum amount of times an item can start a bounce proc, set to 0 for unlimited
	var/bounce_charge_max = 1
	//the current bounce charge count
	var/bounce_charges = 1
	//if set then how long it takes for a bounce charge to regenerate, set to a time
	var/bounce_recharge_rate
	//how far away will the parent item try and bounce to something
	var/targeting_range = 5

	//if the parent item is currently bouncing
	var/bouncing = FALSE
	//var used for tracking how close to gaining a charge if it has a recharge rate
	var/recharge_timer = 0
	//who threw the parent item, used to mark who to return to and to not hit, might not need to be a weakref
	var/datum/weakref/item_thrower
	//timer for bounce_cooldown tracking
	var/bounce_timer = 0


/datum/component/throw_bounce/Initialize(bounce_cooldown, bounce_charge_max, bounce_recharge_rate, targeting_range)
	if(!isitem(parent)) //cant throw non-items
		return COMPONENT_INCOMPATIBLE

	src.bounce_cooldown = bounce_cooldown
	src.bounce_charge_max = bounce_charge_max
	if(bounce_recharge_rate)
		src.bounce_recharge_rate = bounce_recharge_rate
		START_PROCESSING(SSobj, src) //unsure if this is the correct SS to use but this is applied to an item so im just gonna use it
	src.targeting_range = targeting_range
	bounce_charges = bounce_charge_max

/datum/component/throw_bounce/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_check))
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(hit_throw))
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(on_ground))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/throw_bounce/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_THROW_LANDED, COMSIG_ATOM_EXAMINE))

/datum/component/throw_bounce/Destroy()
	. = ..()
	if(bounce_recharge_rate)
		STOP_PROCESSING(SSobj, src)

/datum/component/throw_bounce/process(delta_time)
	if(bounce_charges >= bounce_charge_max)
		recharge_timer = 0
		return
	recharge_timer += delta_time
	if(recharge_timer < bounce_recharge_rate)
		return
	recharge_timer = 0
	bounce_charges++

/datum/component/throw_bounce/proc/throw_check(datum/source, datum/thrownthing/thrown_thing)
	SIGNAL_HANDLER
	if(thrown_thing?.thrower && !item_thrower)
		item_thrower = WEAKREF(thrown_thing.thrower)
	return

/datum/component/throw_bounce/proc/hit_throw(datum/source, atom/hit_atom)
	SIGNAL_HANDLER
	if(!world.time >= bounce_timer + bounce_cooldown) //if this timer fails we dont want to do anything here
		return

	if(item_thrower && (istype(hit_atom, /mob/living)) && !(bouncing))
		if(bounce_charges >= 1 || !(bounce_charge_max))
			var/list/possible_targets = list()
			for(var/mob/living/target_mob in oview(targeting_range, item_thrower?.resolve())) //find bounce targets
				if(target_mob == item_thrower?.resolve() || target_mob == hit_atom)
					continue
				possible_targets += target_mob

			start_bounce(possible_targets)
	return

/datum/component/throw_bounce/proc/on_ground(datum/source)
	SIGNAL_HANDLER
	if(!bouncing)
		item_thrower = null //if we miss then we dont want to do anything so set thrower to null

/datum/component/throw_bounce/proc/on_examine(mob/living/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("It can bounce [bounce_charges >= 1 ? (bounce_charges) : (0)] more times.")

/datum/component/throw_bounce/proc/start_bounce(list/targets_list)
	if(bouncing) //this should never happen
		return

	var/obj/item/parent_item = parent
	bounce_timer = world.time
	bounce_charges--
	bouncing = TRUE
	var/obj/effect/throw_bounce_visual/spawned_effect = new(get_turf(parent_item), src, parent_item, targets_list)
	if(spawned_effect)
		parent_item.forceMove(spawned_effect)

/datum/component/throw_bounce/proc/finish_bounce(obj/effect/throw_bounce_visual/bounce_effect)
	bouncing = FALSE
	var/obj/item/parent_item = parent
	if(!item_thrower)
		parent_item.forceMove(get_turf(bounce_effect))
		return qdel(bounce_effect)
	var/mob/living/thrower_ref = item_thrower?.resolve()
	parent_item.forceMove(get_turf(thrower_ref))
	ASYNC //gotta do this async as it can sleep which hande_bounce() dislikes
		thrower_ref.put_in_hands(parent_item)
	item_thrower = null
	return qdel(bounce_effect)

#define MOVING_TO_THROWER "thrower"
#define MOVING_TO_TARGET "target"
#define START_PHASING_TIME 2 SECONDS
#define FORCED_MOVE_TO_OWNER_TIME 8 SECONDS
//the visual created of the item bouncing between mobs, also handles impacting and targeting
/obj/effect/throw_bounce_visual
	movement_type = FLYING
	//are we currently moving towards a mob, uses the MOVING_TO defines
	var/moving_to_mob = FALSE
	//when to call a forced move_to_thrower(), set to world.time + 8 SECONDS on init
	var/move_to_timer = 0
	//how long since our last mob hit, if its been too long there is most likely something blocking us so start phasing movement until we hit something
	var/last_hit_timer = 0

	//list of mob to clear from possible_targets on process(), also used for preventing hitting someone twice
	var/list/hit_mobs = list()
	//a ref to our owning component
	var/datum/weakref/owning_component
	//a ref to our owning component's parent
	var/datum/weakref/owning_component_parent
	//what is the current target
	var/datum/weakref/current_target
	//weakref list to our possible targets
	var/list/datum/weakref/possible_targets = list()

/obj/effect/throw_bounce_visual/Initialize(mapload, datum/component/throw_bounce/owning_component, obj/item/owning_component_parent, list/possible_targets)
	. = ..()
	if(owning_component && owning_component_parent)
		src.owning_component = WEAKREF(owning_component)
		src.owning_component_parent = WEAKREF(owning_component_parent)
		src.name = owning_component_parent.name //set the basic vars like name, desc, and icon to those of the parent item
		src.desc = owning_component_parent.desc
		src.icon = owning_component_parent.icon
		src.icon_state = owning_component_parent.icon_state
	else
		message_admins("No provided owning_component or owning_component_parent provided for a throw_bounce_visual")
	for(var/mob/living/entry_mob in possible_targets)
		src.possible_targets += WEAKREF(entry_mob)

	move_to_timer = world.time + FORCED_MOVE_TO_OWNER_TIME

	RegisterSignal(src, COMSIG_MOVABLE_CROSS_OVER, PROC_REF(handle_hit))
	START_PROCESSING(SSfastprocess, src)

/obj/effect/throw_bounce_visual/Destroy()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

//process() handles targeting
/obj/effect/throw_bounce_visual/process(delta_time)
	if(!(owning_component) || !(owning_component_parent))
		return qdel(src)

	if(!last_hit_timer)
		last_hit_timer = world.time + START_PHASING_TIME //this moves pretty fast, so if we have not hit something for this long there is most likely something blocking
	if(world.time >= last_hit_timer)
		movement_type = PHASING

	if(moving_to_mob == MOVING_TO_THROWER) //no need to run targeting things if we are MOVING_TO_THROWER
		return

	if(world.time >= move_to_timer)
		move_to_thrower()
		return

	var/list/targets_list = list()
	for(var/datum/weakref/mob_ref as anything in possible_targets) //turn the weakref list into a usable list
		var/mob/living/resolved_ref = mob_ref?.resolve()
		if(resolved_ref in hit_mobs) //if resolved_ref was in hit_mobs then remove it from possible_targets
			if(resolved_ref == current_target?.resolve()) //if the the ref was also our current_target then null current_target as well, also set moving_to_mob to FALSE
				current_target = null
				moving_to_mob = FALSE
			possible_targets -= mob_ref
			continue
		if(resolved_ref)
			targets_list += resolved_ref

	if(!current_target)
		targets_list.len ? (current_target = WEAKREF(targets_list[1])) : move_to_thrower() //if we have a targets_list then set current_target to [1] in the list. else, move_to_thrower
		if(current_target && !(moving_to_mob))
			moving_to_mob = MOVING_TO_TARGET
			addtimer(CALLBACK(SSmove_manager, TYPE_PROC_REF(/datum/controller/subsystem/move_manager, home_onto), src, current_target?.resolve(), 1), 1)


//this proc handles impacts and returning to the thrower
/obj/effect/throw_bounce_visual/proc/handle_hit(datum/source, atom/movable/crossed)
	SIGNAL_HANDLER
	if(!istype(crossed, /mob/living)) //dont interact if crossed is not a mob
		return
	if(!(owning_component) || !(owning_component_parent))
		return qdel(src)

	var/datum/component/throw_bounce/owning_ref = owning_component?.resolve()
	var/mob/living/thrower_ref = owning_ref.item_thrower?.resolve()
	if((moving_to_mob == MOVING_TO_THROWER) && thrower_ref && (crossed == thrower_ref))
		owning_ref.finish_bounce(src)
		return

	if(!(owning_ref) || !(owning_component_parent))
		return qdel(src) //if our component or its parent item somehow get destroyed we wont work so qdel us
	if((crossed == owning_ref.item_thrower?.resolve()) || (crossed in hit_mobs)) //dont hit the thrower, if it turns out to be a problem we could also make this only hit possible_targets
		return

	last_hit_timer = 0 //every time we hit something new it means there is nothing blocking, so reset these
	movement_type = FLYING

	var/obj/item/item_ref = owning_component_parent?.resolve()
	item_ref?.throw_impact(crossed)

	if(!(crossed in hit_mobs))
		hit_mobs += crossed
	return

//starts moving us towards our thrower
/obj/effect/throw_bounce_visual/proc/move_to_thrower()
	var/datum/component/throw_bounce/owning_ref = owning_component?.resolve()
	if(!(owning_ref) || !(owning_component_parent))
		return qdel(src)

	moving_to_mob = MOVING_TO_THROWER

//	var/mob/living/thrower_ref = owning_ref.item_thrower?.resolve() might need this still
	if(owning_ref.item_thrower)
		addtimer(CALLBACK(SSmove_manager, TYPE_PROC_REF(/datum/controller/subsystem/move_manager, home_onto), src, owning_ref.item_thrower?.resolve(), 1), 1)
	else
		owning_ref.finish_bounce(src)
#undef MOVING_TO_THROWER
#undef MOVING_TO_TARGET
#undef START_PHASING_TIME
#undef FORCED_MOVE_TO_OWNER_TIME
