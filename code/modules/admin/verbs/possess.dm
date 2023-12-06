/proc/possess(obj/target in world)
	set name = "Possess Obj"
	set category = "Object"

	var/turf/target_turf = get_turf(target)
	var/message = "[key_name(user)] has possessed [target] ([target.type]) at [AREACOORD(target_turf)]"
	message_admins(message)
	log_admin(message)

	BLACKBOX_LOG_ADMIN_VERB("Possess Object")

/proc/release()
	set name = "Release Obj"
	set category = "Object"



	BLACKBOX_LOG_ADMIN_VERB("Release Object")

/proc/givetestverbs(mob/M in GLOB.mob_list)
	set desc = "Give this guy possess/release verbs"
	set category = "Debug"
	set name = "Give Possessing Verbs"
	add_verb(M, GLOBAL_PROC_REF(possess))
	add_verb(M, GLOBAL_PROC_REF(release))
	BLACKBOX_LOG_ADMIN_VERB("Give Possessing Verbs")
