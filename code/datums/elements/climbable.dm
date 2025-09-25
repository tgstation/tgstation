/datum/element/climbable
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	///Time it takes to climb onto the object
	var/climb_time
	///Stun duration for when you get onto the object
	var/climb_stun
	///Assoc list of object being climbed on - climbers.  This allows us to check who needs to be shoved off a climbable object when its clicked on.
	var/list/current_climbers

/datum/element/climbable/Attach(
	datum/target,
	climb_time = 2 SECONDS,
	climb_stun = 2 SECONDS,
)
	. = ..()

	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	src.climb_time = climb_time
	src.climb_stun = climb_stun

	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(get_examine_tags))
	RegisterSignal(target, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(mousedrop_receive))
	ADD_TRAIT(target, TRAIT_CLIMBABLE, ELEMENT_TRAIT(type))

/datum/element/climbable/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_EXAMINE_TAGS, COMSIG_MOUSEDROPPED_ONTO, COMSIG_ATOM_BUMPED))
	REMOVE_TRAIT(target, TRAIT_CLIMBABLE, ELEMENT_TRAIT(type))
	return ..()

///Someone inspected our embeddable item
/datum/element/climbable/proc/get_examine_tags(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list["climbable"] = "It looks like it can be climbed on."

/datum/element/climbable/proc/can_climb(atom/source, mob/user)
	if (!user.CanReach(source))
		return FALSE
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
	// Time in deciseoncds it takes to complete the climb do_after()
	var/adjusted_climb_time = climb_time
	// Time in deciseonds that the mob is stunned after climbing successfully.
	var/adjusted_climb_stun = climb_stun
	// Our climbers fitness level, which removes some climb time and speeds up our climbing do_after, assuming they worked out
	var/fitness_level = user.mind?.get_skill_level(/datum/skill/athletics) - 1
	adjusted_climb_time = clamp(adjusted_climb_time - fitness_level, 1, climb_time) //Here we adjust the number of deciseconds we shave off per level of fitness, with a minimum of 1 decisecond and a maximum of climb_time (just in case)

	var/obj/item/organ/cyberimp/chest/spine/potential_spine = user.get_organ_slot(ORGAN_SLOT_SPINE)
	if(istype(potential_spine))
		adjusted_climb_time *= potential_spine.athletics_boost_multiplier
		adjusted_climb_stun *= potential_spine.athletics_boost_multiplier

	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //climbing takes twice as long without help from the hands.
		adjusted_climb_time *= 2
	if(isalien(user))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8
		adjusted_climb_stun *= 0.8
	if(HAS_TRAIT(user, TRAIT_STUBBY_BODY)) //hold on, gimme a moment, my tiny legs can't get over the goshdamn table
		adjusted_climb_time *= 1.5
		adjusted_climb_stun *= 1.5
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
			var/atom/movable/buckle_target = climbed_thing
			if(istype(buckle_target))
				if(buckle_target.is_buckle_possible(user))
					buckle_target.buckle_mob(user)
			user.mind?.adjust_experience(/datum/skill/athletics, round(ATHLETICS_SKILL_MISC_EXP/(fitness_level || 1), 1)) //Get a bit fitter with every climb. But it has diminishing returns at a certain point.
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
				var/x_dist = (text2num(LAZYACCESS(modifiers, ICON_X)) - ICON_SIZE_X/2) * (climbed_thing.dir & WEST ? -1 : 1)
				var/y_dist = (text2num(LAZYACCESS(modifiers, ICON_Y)) - ICON_SIZE_Y/2) * (climbed_thing.dir & SOUTH ? -1 : 1)
				dir_step = (x_dist >= y_dist ? (EAST|WEST) : (NORTH|SOUTH)) & climbed_thing.dir
		else
			dir_step = get_dir(user, get_step(climbed_thing, climbed_thing.dir))
	. = step(user, dir_step)
	climbed_thing.set_density(TRUE)

///Handles climbing onto the atom when you click-drag
/datum/element/climbable/proc/mousedrop_receive(atom/climbed_thing, atom/movable/dropped_atom, mob/user, params)
	SIGNAL_HANDLER

	if(user != dropped_atom || !isliving(dropped_atom))
		return
	if(!HAS_TRAIT(dropped_atom, TRAIT_FENCE_CLIMBER) && !HAS_TRAIT(dropped_atom, TRAIT_CAN_HOLD_ITEMS)) // If you can hold items you can probably climb a fence
		return
	var/mob/living/living_target = dropped_atom
	if(living_target.mobility_flags & MOBILITY_MOVE)
		INVOKE_ASYNC(src, PROC_REF(climb_structure), climbed_thing, living_target, params)
	return COMPONENT_CANCEL_MOUSEDROPPED_ONTO
