//very similar to stationloving, but more made for mobs and not objects. used on derelict drones currently
/datum/component/stationstuck
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/murder = TRUE //teleports if not
	var/stuck_zlevel
	var/teleport_message = ""
	var/death_message = ""

/datum/component/stationstuck/Initialize(_murder = TRUE, _teleport_message = "", _death_message = "")
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/L = parent
	RegisterSignal(L, list(COMSIG_MOVABLE_Z_CHANGED), .proc/punish)
	murder = _murder
	teleport_message = _teleport_message
	death_message = _death_message

	stuck_zlevel = L.z

/datum/component/stationstuck/InheritComponent(datum/component/stationstuck/newc, original, list/arguments)
	if(original)
		if(istype(newc))
			murder = newc.murder
			teleport_message = newc.teleport_message
			death_message = newc.death_message

/datum/component/stationstuck/proc/punish()
	var/mob/living/L = parent
	if(murder)
		if(death_message)
			to_chat(L, "<span class='userdanger'>[death_message]</span>")
		L.gib()
		return
	if(teleport_message)
		to_chat(L, "<span class='danger'>[teleport_message]</span>")
	var/targetturf = find_safe_turf(stuck_zlevel)
	if(!targetturf)
		targetturf = locate(world.maxx/2,world.maxy/2,stuck_zlevel)

	L.forceMove(targetturf)
	return targetturf
