///Calling this component will teleport the user passed into it to the location set
/datum/linked_eigenstates
	///The target that someone will be sent to
	var/list/eigenlinked_targets = list()

/datum/component/eigenstate/Initialize(_targets)
	. = ..()
	eigen_target = _targets
	eigen_target.color = "#9999FF" //Tint the locker slightly.
	eigen_target.alpha = 200
	do_sparks(5, FALSE, eigen_target)

/datum/component/eigenstate/Destroy(force, silent)
	. = ..()
	eigen_target = null

/datum/component/eigenstate/proc/teleport_user(mob/living/user, var/atom/location)
	var/index = eigenlinked_targets.Find(location)
	if(!index)
		CRASH("[location] Attempted to eigenlink to something that didn't contain it!")
	var/eigen_target
	index++
	while:
		if(location = eigenlinked_targets[index])
			eigen_target = location
			break
		if(index > length(eigenlinked_targets))
			index = 1
		if(eigenlinked_targets[index] == null)
			eigenlinked_targets -= eigenlinked_targets[index]
		eigen_target = eigenlinked_targets[index]
		break
	if(!eigen_target)
		CRASH("No eigen target set for the eigenstate component!")
	do_teleport(AM, get_turf(eigen_target), 0)
	if(istype(eigen_target, /obj/structure/closet))
		var/obj/structure/closet/target = eigen_target
		target.bust_open()

/datum/component/eigenstate/proc/tool_interact(mob/living/user)
	to_chat(user, "<span class='notice'>The unstable nature of \the [src] makes it impossible to use the [W] on it!</span>")
	return FALSE
