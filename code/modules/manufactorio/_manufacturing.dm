#define MANUFACTURING_FAIL 0
#define MANUFACTURING_SUCCESS 1

#define MANUFACTURING_TURF_LAG_LIMIT 10 // max items on a turf before we consider it full

/obj/machinery/power/manufacturing
	icon = 'icons/obj/machines/manufactorio.dmi'
	name = "base manufacture receiving type"
	desc = "this shouldnt exist"
	density = TRUE
	/// Do we add the simple_rotation component and a text that we are powered by cable? Also allows unwrenching
	var/may_be_moved = TRUE
	/// Allow taking in mobs from conveyors?
	var/allow_mob_bump_intake = FALSE

/obj/machinery/power/manufacturing/Initialize(mapload)
	. = ..()
	if(may_be_moved)
		AddComponent(/datum/component/simple_rotation)
	if(anchored)
		connect_to_network()

/obj/machinery/power/manufacturing/examine(mob/user)
	. = ..()
	if(may_be_moved)
		. += "It receives power via cable, but certain buildings do not need power."
	. += length(contents - circuit) ? "It contains:" : "It contains no items."
	for(var/atom/movable/thing as anything in contents - circuit)
		var/text = thing.name
		var/obj/item/stack/possible_stack = thing
		if(istype(possible_stack))
			text = "[possible_stack.amount] [text]"
		. += text


/obj/machinery/power/manufacturing/Bumped(atom/movable/bumped_atom) //attempt to put in whatever is pushed into us via conveyor
	. = ..()
	if((!allow_mob_bump_intake && ismob(bumped_atom)) || !anchored) //only uncomment if youre brave
		return
	var/conveyor = locate(/obj/machinery/conveyor) in bumped_atom.loc
	if(isnull(conveyor))
		return
	receive_resource(bumped_atom, bumped_atom.loc, get_dir(src, bumped_atom))

/obj/machinery/power/manufacturing/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!may_be_moved)
		return
	default_unfasten_wrench(user, tool)
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/power/manufacturing/setDir(newdir)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/power/manufacturing/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/proc/generate_io_overlays(direction, color, offsets_override)
	var/list/dir_offset
	if(islist(offsets_override))
		dir_offset = offsets_override
	else
		dir_offset = dir2offset(direction)
		dir_offset[1] *= 32
		dir_offset[2] *= 32
	var/image/nonemissive = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_[direction]")
	nonemissive.pixel_w = dir_offset[1]
	nonemissive.pixel_z = dir_offset[2]
	nonemissive.color = color
	var/mutable_appearance/emissive = emissive_appearance(nonemissive.icon, nonemissive.icon_state, offset_spokesman = src, alpha = nonemissive.alpha)
	emissive.pixel_w = nonemissive.pixel_w
	emissive.pixel_z = nonemissive.pixel_z
	return list(nonemissive, emissive)

/// Returns whatever object it may output, or null if it cant do that
/obj/machinery/power/manufacturing/proc/request_resource()


/obj/machinery/power/manufacturing/proc/receive_resource(atom/movable/receiving, atom/from, receive_dir)
	CRASH("Unimplemented!") //check can_receive_resource here

//use dir please
/obj/machinery/power/manufacturing/proc/send_resource(atom/movable/sending, atom/what_or_dir)
	if(isobj(what_or_dir))
		var/obj/machinery/power/manufacturing/target = what_or_dir
		return target.receive_resource(sending, src, get_step(src, what_or_dir))
	var/turf/next_turf = isturf(what_or_dir) ? what_or_dir : get_step(src, what_or_dir)
	var/obj/machinery/power/manufacturing/manufactury = locate(/obj/machinery/power/manufacturing) in next_turf
	if(!isnull(manufactury))
		if(!manufactury.anchored)
			return MANUFACTURING_FAIL
		return manufactury.receive_resource(sending, src, isturf(what_or_dir) ? get_dir(src, what_or_dir) : what_or_dir)
	if(next_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = sending) && !ischasm(next_turf))
		return MANUFACTURING_FAIL
	if(length(get_overfloor_objects(next_turf)) >= MANUFACTURING_TURF_LAG_LIMIT)
		return MANUFACTURING_FAIL
	if(isnull(sending))
		return MANUFACTURING_SUCCESS // for the sake of being used as a check
	if(isnull(sending.loc) || !sending.Move(next_turf, get_dir(src, next_turf)))
		sending.forceMove(next_turf)
	return MANUFACTURING_SUCCESS

/// Checks if this stack (if not a stack does not do anything) can merge WITHOUT creating two stacks in contents
/obj/machinery/power/manufacturing/proc/may_merge_in_contents(obj/item/stack/stack)
	if(!istype(stack))
		return
	for(var/obj/item/stack/other in contents - circuit)
		if(!stack.can_merge(other))
			continue
		if(other.amount + stack.amount <= other.max_amount)
			return other

/obj/machinery/power/manufacturing/proc/may_merge_in_contents_and_do_so(obj/item/stack/stack)
	var/merging_into = may_merge_in_contents(stack)
	if(isnull(merging_into))
		return
	return stack.merge(merging_into)

/obj/machinery/power/manufacturing/proc/get_overfloor_objects(turf/target)
	. = list()
	if(isnull(target))
		target = get_turf(src)
	for(var/atom/movable/thing as anything in target.contents)
		if(thing == src || isliving(thing) || iseffect(thing) || thing.invisibility >= INVISIBILITY_ABSTRACT || HAS_TRAIT(thing, TRAIT_UNDERFLOOR))
			continue
		. += thing
