/// This element will allow the mob it's attached to to pass through a specified type of wall, and drag anything through it.
/datum/element/wall_walker
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// What kind of walls can we pass through?
	var/wall_type

/datum/element/wall_walker/Attach(
	datum/target,
	wall_type = /turf/closed/wall,
)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.wall_type = wall_type
	RegisterSignal(target, COMSIG_LIVING_WALL_BUMP, PROC_REF(try_pass_wall))
	RegisterSignal(target, COMSIG_LIVING_WALL_EXITED, PROC_REF(exit_wall))

/datum/element/wall_walker/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_LIVING_WALL_BUMP, COMSIG_LIVING_WALL_EXITED))
	return ..()

/// If the wall is of the proper type, pass into it and keep hold on whatever you're pulling
/datum/element/wall_walker/proc/try_pass_wall(mob/living/passing_mob, turf/closed/bumped_wall)
	if(!istype(bumped_wall, wall_type))
		return

	var/atom/movable/stored_pulling = passing_mob.pulling
	if(stored_pulling) //force whatever you're pulling to come with you
		stored_pulling.setDir(get_dir(stored_pulling.loc, passing_mob.loc))
		stored_pulling.forceMove(passing_mob.loc)
	passing_mob.forceMove(bumped_wall)

	if(stored_pulling) //don't drop them because we went into a wall
		passing_mob.start_pulling(stored_pulling, supress_message = TRUE)

/// If the wall is of the proper type, pull whatever you're pulling into it
/datum/element/wall_walker/proc/exit_wall(mob/living/passing_mob, turf/closed/exited_wall)
	if(!istype(exited_wall, wall_type))
		return

	var/atom/movable/stored_pulling = passing_mob.pulling
	if(isnull(stored_pulling))
		return

	stored_pulling.setDir(get_dir(stored_pulling.loc, passing_mob.loc))
	stored_pulling.forceMove(exited_wall)
	passing_mob.start_pulling(stored_pulling, supress_message = TRUE)
