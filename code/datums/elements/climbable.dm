/datum/element/climbable
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
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

	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, .proc/attack_hand)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(target, COMSIG_MOUSEDROPPED_ONTO, .proc/mousedrop_receive)
	RegisterSignal(target, COMSIG_ATOM_BUMPED, .proc/try_speedrun)

/datum/element/climbable/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_EXAMINE, COMSIG_MOUSEDROPPED_ONTO, COMSIG_ATOM_BUMPED))
	return ..()

/datum/element/climbable/proc/on_examine(atom/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	if(can_climb(source, user))
		examine_texts += "<span class='notice'>[source] looks climbable</span>"

/datum/element/climbable/proc/can_climb(atom/source, mob/user)
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
		structure_climber.visible_message("<span class='warning'>[structure_climber] is knocked off [climbed_thing].</span>", "<span class='warning'>You're knocked off [climbed_thing]!</span>", "<span class='warning'>You see [structure_climber] get knocked off [climbed_thing].</span>")


/datum/element/climbable/proc/climb_structure(atom/climbed_thing, mob/living/user)
	if(!can_climb(climbed_thing, user))
		return
	climbed_thing.add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] starts climbing onto [climbed_thing].</span>", \
								"<span class='notice'>You start climbing onto [climbed_thing]...</span>")
	var/adjusted_climb_time = climb_time
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //climbing takes twice as long without help from the hands.
		adjusted_climb_time *= 2
	if(isalien(user))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8
	LAZYADDASSOC(current_climbers, climbed_thing, user)
	if(do_after(user, adjusted_climb_time, climbed_thing))
		if(QDELETED(climbed_thing)) //Checking if structure has been destroyed
			return
		if(do_climb(climbed_thing, user))
			user.visible_message("<span class='warning'>[user] climbs onto [climbed_thing].</span>", \
								"<span class='notice'>You climb onto [climbed_thing].</span>")
			log_combat(user, climbed_thing, "climbed onto")
			if(climb_stun)
				user.Stun(climb_stun)
		else
			to_chat(user, "<span class='warning'>You fail to climb onto [climbed_thing].</span>")
	LAZYREMOVEASSOC(current_climbers, climbed_thing, user)


/datum/element/climbable/proc/do_climb(atom/climbed_thing, mob/living/user)
	climbed_thing.density = FALSE
	. = step(user, get_dir(user,climbed_thing.loc))
	climbed_thing.density = TRUE

///Handles climbing onto the atom when you click-drag
/datum/element/climbable/proc/mousedrop_receive(atom/climbed_thing, atom/movable/dropped_atom, mob/user)
	SIGNAL_HANDLER
	if(user == dropped_atom && isliving(dropped_atom))
		var/mob/living/living_target = dropped_atom
		if(isanimal(living_target))
			var/mob/living/simple_animal/animal = dropped_atom
			if (!animal.dextrous)
				return
		if(living_target.mobility_flags & MOBILITY_MOVE)
			INVOKE_ASYNC(src, .proc/climb_structure, climbed_thing, living_target)
			return

///Tries to climb onto the target if the forced movement of the mob allows it
/datum/element/climbable/proc/try_speedrun(datum/source, mob/bumpee)
	SIGNAL_HANDLER
	if(!istype(bumpee))
		return
	if(bumpee.force_moving?.allow_climbing)
		do_climb(source, bumpee)
