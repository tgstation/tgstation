
#define PUNISHMENT_MURDER "murder"
#define PUNISHMENT_GIB "gib"
#define PUNISHMENT_TELEPORT "teleport"

//very similar to stationloving, but more made for mobs and not objects. used on derelict drones currently


/*
This component is similar to stationloving in that it is meant to keep something on the z-level
The difference is that stationloving is for objects and stationstuck is for mobs.
It has a punishment variable that is what happens to the parent when they leave the z-level. See punish() documentation
*/
/datum/component/stationstuck
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/punishment = PUNISHMENT_GIB //see defines above
	var/stuck_zlevel
	var/message = ""

/datum/component/stationstuck/Initialize(_punishment = PUNISHMENT_GIB, _message = "")
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/L = parent
	RegisterSignals(L, list(COMSIG_MOVABLE_Z_CHANGED), PROC_REF(punish))
	punishment = _punishment
	message = _message
	stuck_zlevel = L.z

/datum/component/stationstuck/InheritComponent(datum/component/stationstuck/newc, original, _punishment, _message)
	if(newc)
		punishment = newc.punishment
		message = newc.message
	else
		punishment = _punishment
		message = _message

/**
 * Called when parent leaves the zlevel this is set to (aka whichever zlevel it was on when it was added)
 * Sends a message, then does an effect depending on what the punishment was.
 *
 * Punishments:
 * * PUNISHMENT_MURDER: kills parent
 * * PUNISHMENT_GIB: gibs parent
 * * PUNISHMENT_TELEPORT:  finds a safe turf if possible, or a completely random one if not.
 */
/datum/component/stationstuck/proc/punish()
	SIGNAL_HANDLER

	var/mob/living/escapee = parent
	if(message)
		var/span = punishment == PUNISHMENT_TELEPORT ? "danger" : "userdanger"
		to_chat(escapee, "<span class='[span]'>[message]</span>")
	switch(punishment)
		if(PUNISHMENT_MURDER)
			if(escapee.stat != DEAD)
				escapee.investigate_log("has been killed by stationstuck component.", INVESTIGATE_DEATHS)
			escapee.death()
		if(PUNISHMENT_GIB)
			escapee.investigate_log("has been gibbed by stationstuck component.", INVESTIGATE_DEATHS)
			escapee.gib()
		if(PUNISHMENT_TELEPORT)
			var/targetturf = find_safe_turf(stuck_zlevel)
			if(!targetturf)
				targetturf = locate(world.maxx/2,world.maxy/2,stuck_zlevel)
			escapee.forceMove(targetturf)
