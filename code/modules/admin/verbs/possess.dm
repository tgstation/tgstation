/proc/possess(obj/target in world)
	set name = "Possess Obj"
	set category = "Object"

	var/result = usr.AddComponent(/datum/component/object_possession, target)

	if(isnull(result)) // trigger a safety movement just in case we yonk
		usr.forceMove(get_turf(usr))
		return

	var/turf/target_turf = get_turf(target)
	var/message = "[key_name(usr)] has possessed [target] ([target.type]) at [AREACOORD(target_turf)]"
	message_admins(message)
	log_admin(message)

	BLACKBOX_LOG_ADMIN_VERB("Possess Object")

/proc/release()
	set name = "Release Obj"
	set category = "Object"

	qdel(usr.GetComponent(/datum/component/object_possession))
	BLACKBOX_LOG_ADMIN_VERB("Release Object")

/proc/give_possession_verbs(mob/dude in GLOB.mob_list)
	set desc = "Give this guy possess/release verbs"
	set category = "Debug"
	set name = "Give Possessing Verbs"

	add_verb(dude, GLOBAL_PROC_REF(possess))
	add_verb(dude, GLOBAL_PROC_REF(release))
	BLACKBOX_LOG_ADMIN_VERB("Give Possessing Verbs")
