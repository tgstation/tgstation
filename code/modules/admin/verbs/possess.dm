
ADMIN_VERB_AND_CONTEXT_MENU(possess, R_POSSESS, "Possess Obj", "Possess an object.", ADMIN_CATEGORY_OBJECT, obj/target in world)
	var/result = user.mob.AddComponent(/datum/component/object_possession, target)

	if(isnull(result)) // trigger a safety movement just in case we yonk
		user.mob.forceMove(get_turf(user.mob))
		return

	var/turf/target_turf = get_turf(target)
	var/message = "[key_name(user)] has possessed [target] ([target.type]) at [AREACOORD(target_turf)]"
	message_admins(message)
	log_admin(message)

	BLACKBOX_LOG_ADMIN_VERB("Possess Object")

ADMIN_VERB(release, R_POSSESS, "Release Object", "Stop possessing an object.", ADMIN_CATEGORY_OBJECT)
	var/possess_component = user.mob.GetComponent(/datum/component/object_possession)
	if(!isnull(possess_component))
		qdel(possess_component)
	BLACKBOX_LOG_ADMIN_VERB("Release Object")
