/datum/element/climbable
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	///Time it takes to climb onto the object
	var/climb_time = (2 SECONDS)
	///Stun duration for when you get onto the object
	var/climb_stun = (2 SECONDS)
	///Assoc list of object being climbed on - climbers.  This allows us to check who needs to be shoved off a climbable object when its clicked on.
	var/list/current_climbers

/datum/element/climbable/Attach(datum/target, climb_time, climb_stun)
	. = ..()

	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	if(climb_time)
		src.climb_time = climb_time
	if(climb_stun)
		src.climb_stun = climb_stun

	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(mousedrop_receive))
	RegisterSignal(target, COMSIG_ATOM_BUMPED, PROC_REF(try_speedrun))
	ADD_TRAIT(target, TRAIT_CLIMBABLE, ELEMENT_TRAIT(type))

/datum/element/climbable/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_EXAMINE, COMSIG_MOUSEDROPPED_ONTO, COMSIG_ATOM_BUMPED))
	REMOVE_TRAIT(target, TRAIT_CLIMBABLE, ELEMENT_TRAIT(type))
	return ..()

/datum/element/climbable/proc/on_examine(atom/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER
	examine_texts += span_notice("[source] looks climbable.")

/datum/element/climbable/proc/can_climb(atom/source, mob/user)
	var/dir_step = get_dir(user, source.loc)
	//To jump over a railing you have to be standing next to it, not far behind it.
	if(source.flags_1 & ON_BORDER_1 && user.loc != source.loc && (dir_step & source.dir) == source.dir)
		return FALSE
	return TRUE

/datum/element/climbable/proc/attack_hand(atom/climbed_thing, mob/user)
	SIGNAL_HANDLER
	var/list/climbers = LAZYACCESS(current_climbers, climbed_thing)
	for(var/i in climbers)
		var/mob/living/structure_climber = i
		if(structure_climber == user)
			return
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(climbed_thing)
		structure_climber.Paralyze(40)
		structure_climber.visible_message(span_warning("[structure_climber] is knocked off [climbed_thing]."), span_warning("You're knocked off [climbed_thing]!"), span_hear("You hear a cry from [structure_climber], followed by a slam."))


/datum/element/climbable/proc/climb_structure(atom/climbed_thing, mob/living/user, params)
	if(!can_climb(climbed_thing, user))
		return
	climbed_thing.add_fingerprint(user)
	user.visible_message(span_warning("[user] starts climbing onto [climbed_thing]."), \
								span_notice("You start climbing onto [climbed_thing]..."))
	var/adjusted_climb_time = climb_time
	var/adjusted_climb_stun = climb_stun
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //climbing takes twice as long without help from the hands.
		adjusted_climb_time *= 2
	if(isalien(user))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8
		adjusted_climb_stun *= 0.8
	LAZYADDASSOCLIST(current_climbers, climbed_thing, user)
	if(do_after(user, adjusted_climb_time, climbed_thing))
		if(QDELETED(climbed_thing)) //Checking if structure has been destroyed
			return
		if(do_climb(climbed_thing, user, params))
			user.visible_message(span_warning("[user] climbs onto [climbed_thing]."), \
								span_notice("You climb onto [climbed_thing]."))
			log_combat(user, climbed_thing, "climbed onto")
			if(adjusted_climb_stun)
				user.Stun(adjusted_climb_stun)
		else
			to_chat(user, span_warning("You fail to climb onto [climbed_thing]."))
	LAZYREMOVEASSOC(current_climbers, climbed_thing, user)


/datum/element/climbable/proc/do_climb(atom/climbed_thing, mob/living/user, params)
	if(!can_climb(climbed_thing, user))
		return
	climbed_thing.set_density(FALSE)
	var/dir_step = get_dir(user, climbed_thing.loc)
	var/same_loc = climbed_thing.loc == user.loc
	// on-border objects can be vaulted over and into the next turf.
	// The reverse dir check is for when normal behavior should apply instead (e.g. John Doe hops east of a railing facing west, ending on the same turf as it).
	if(climbed_thing.flags_1 & ON_BORDER_1 && (same_loc || !(dir_step & REVERSE_DIR(climbed_thing.dir))))
		//it can be vaulted over in two different cardinal directions. we choose one.
		if(ISDIAGONALDIR(climbed_thing.dir) && same_loc)
			if(params) //we check the icon x and y parameters of the click-drag to determine step_dir.
				var/list/modifiers = params2list(params)
				var/x_dist = (text2num(LAZYACCESS(modifiers, ICON_X)) - world.icon_size/2) * (climbed_thing.dir & WEST ? -1 : 1)
				var/y_dist = (text2num(LAZYACCESS(modifiers, ICON_Y)) - world.icon_size/2) * (climbed_thing.dir & SOUTH ? -1 : 1)
				dir_step = (x_dist >= y_dist ? (EAST|WEST) : (NORTH|SOUTH)) & climbed_thing.dir
			else //user is being moved by a forced_movement datum. dir_step will be the direction to the forced movement target.
				dir_step = get_dir(user, user.force_moving.target)
		else
			dir_step = get_dir(user, get_step(climbed_thing, climbed_thing.dir))
	. = step(user, dir_step)
	climbed_thing.set_density(TRUE)

///Handles climbing onto the atom when you click-drag
/datum/element/climbable/proc/mousedrop_receive(atom/climbed_thing, atom/movable/dropped_atom, mob/user, params)
	SIGNAL_HANDLER
	if(user == dropped_atom && isliving(dropped_atom))
		var/mob/living/living_target = dropped_atom
		if(isanimal(living_target))
			var/mob/living/simple_animal/animal = dropped_atom
			if (!animal.dextrous)
				return
		if(living_target.mobility_flags & MOBILITY_MOVE)
			INVOKE_ASYNC(src, PROC_REF(climb_structure), climbed_thing, living_target, params)
			return

///Tries to climb onto the target if the forced movement of the mob allows it
/datum/element/climbable/proc/try_speedrun(datum/source, mob/bumpee)
	SIGNAL_HANDLER
	if(!istype(bumpee))
		return
	if(bumpee.force_moving?.allow_climbing)
		do_climb(source, bumpee)
