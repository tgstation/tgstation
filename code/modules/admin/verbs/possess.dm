/proc/possess(obj/target in world)
	set name = "Possess Obj"
	set category = "Object"

	target.AddComponent(/datum/component/object_possession, usr)

	if(!HAS_TRAIT(usr, TRAIT_CURRENTLY_CONTROLLING_OBJECT)) // something failed, component will handle feedback and potential dupes
		return

	var/turf/target_turf = get_turf(target)
	var/message = "[key_name(usr)] has possessed [target] ([target.type]) at [AREACOORD(target_turf)]"
	message_admins(message)
	log_admin(message)

	BLACKBOX_LOG_ADMIN_VERB("Possess Object")

/proc/release()
	set name = "Release Obj"
	set category = "Object"

	SEND_SIGNAL(usr, COMSIG_END_OBJECT_POSSESSION_VIA_VERB)
	BLACKBOX_LOG_ADMIN_VERB("Release Object")

/proc/give_possession_verbs(mob/dude in GLOB.mob_list)
	set desc = "Give this guy possess/release verbs"
	set category = "Debug"
	set name = "Give Possessing Verbs"

	add_verb(dude, GLOBAL_PROC_REF(possess))
	add_verb(dude, GLOBAL_PROC_REF(release))
	BLACKBOX_LOG_ADMIN_VERB("Give Possessing Verbs")
