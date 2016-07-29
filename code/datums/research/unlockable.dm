/datum/unlockable
	var/id = "" // Used in prerequisites.
	var/name=""
	var/desc=""
	var/cost=0 // Cost to unlock
	var/cost_units=""
	var/time=0 // Time to unlock
	var/unlocked=0
	//var/remove_on_detach=1

	var/list/prerequisites=list() //these must be unlocked for the unlockable to be accessible
	var/list/antirequisites=list() //these must NOT be unlocked for the unlockable to be accessible
	var/datum/research_tree/tree

// CALL BEFORE USING ANY OTHER PROCS.
/datum/unlockable/proc/set_context(var/datum/research_tree/T)
	tree = T

/datum/unlockable/proc/check_prerequisites()
	if(prerequisites.len>0)
		for(var/prereq in prerequisites)
			if(!(prereq in tree.unlocked))
				return 0
	return 1

/datum/unlockable/proc/check_antirequisites()
	if(antirequisites.len>0)
		for(var/antireq in antirequisites)
			if(antireq in tree.unlocked)
				return 0
	return 1

// INTERNAL: Begin unlocking process.
/datum/unlockable/proc/unlock()
	if(tree.unlocking)
		return 0

	begin_unlock()

	// Lock tree
	tree.unlocking=1
	if(unlock_check())
		sleep(time) // do_after has too many human-specific checks that don't work on a glorified datum.
		            //  We don't have hands, and we can't control if the host moves.
		if(unlock_check())
			unlock_action()
			end_unlock()
			unlocked=1
	tree.unlocking=0
	return 1

// INTERNAL: Relock
/datum/unlockable/proc/relock()
	unlocked=0
	relock_action()
	return 1

// Do this, then wait and unlock.
/datum/unlockable/proc/begin_unlock()
	return


// Finished unlocking.
/datum/unlockable/proc/end_unlock()
	return


/datum/unlockable/proc/toTableRow(var/datum/research_tree/tree, var/mob/user)
	return {"
	<tr>
		<th>
			<a href="?src=\ref[tree];user=\ref[user];unlock=[id]">[name]</a>
		</th>
		<th>
			[cost][cost_units]
		</th>
		<th>
			[altFormatTimeDuration(time)]
		</th>
	</tr>
	<tr>
		<td colspan="3">[desc]</td>
	</tr>"}

/**
 * additional checks to perform when unlocking things.
 * @returns Can unlock
 */
/datum/unlockable/proc/unlock_check()
	return 0

/**
 * What to do when unlocked.
 */
/datum/unlockable/proc/unlock_action()
	return

/**
 * How to remove the unlockable (such as when detached)
 */
/datum/unlockable/proc/relock_action()
	return

/datum/unlockable/proc/can_buy()
	return unlock_check() && !tree.unlocking