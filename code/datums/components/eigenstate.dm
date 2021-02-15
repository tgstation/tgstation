///Calling this component will teleport the user passed into it to the location set
/datum/linked_eigenstates
	///The target that someone will be sent to
	var/list/eigen_targets = list()

/datum/component/eigenstate/Initialize(_targets)
	. = ..()
	eigen_targets = _targets
	for(var/target in eigen_targets)
		RegisterSignal(target, COMSIG_CLOSET_INSERT, .proc/teleport_atom)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/remove_entry)
		RegisterSignal(target, COMSIG_ATOM_TOOL_ACT, .proc/tool_interact)
		var/obj/item = target
		if(item)
			item.color = "#9999FF" //Tint the locker slightly.
			item.alpha = 200
	do_sparks(5, FALSE, item)

/datum/component/eigenstate/Destroy(force, silent)
	. = ..()
	eigen_targets = null

/datum/component/eigenstate/proc/remove_entry(entry)
	eigen_targets -= entry
	UnregisterSignal(entry, COMSIG_PARENT_QDELETING)
	UnregisterSignal(entry, COMSIG_CLOSET_INSERT)
	UnregisterSignal(entry, COMSIG_ATOM_TOOL_ACT)
	if(!length(eigen_targets))
		qdel(src)

/datum/component/eigenstate/proc/teleport_atom(var/atom/thing, var/atom/location)
	var/index = eigen_targets.Find(location)
	if(!index)
		CRASH("[location] Attempted to eigenlink to something that didn't contain it!")
	var/eigen_target
	index++
	while:
		if(location = eigen_targets[index])
			eigen_target = location
			break
		if(index > length(eigen_targets))
			index = 1
		if(eigen_targets[index] == null) //if deleted
			eigen_targets -= eigen_targets[index]
		eigen_target = eigen_targets[index]
		break
	if(!eigen_target)
		CRASH("No eigen target set for the eigenstate component!")
	do_teleport(thing, get_turf(eigen_target), 0)
	if(istype(eigen_target, /obj/structure/closet))
		var/obj/structure/closet/target = eigen_target
		target.bust_open()

/datum/component/eigenstate/proc/tool_interact(mob/living/user)
	to_chat(user, "<span class='notice'>The unstable nature of \the [src] makes it impossible to use the [W] on it!</span>")
	return COMPONENT_BLOCK_TOOL_ATTACK
