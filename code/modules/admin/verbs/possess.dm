ADMIN_VERB_CONTEXT_MENU(possess, "Possess Obj", R_POSSESS, obj/target in world)
	if((target.obj_flags & DANGEROUS_POSSESSION) && CONFIG_GET(flag/forbid_singulo_possession))
		to_chat(user, "[target] is too powerful for you to possess.", confidential = TRUE)
		return

	var/turf/T = get_turf(target)
	if(T)
		log_admin("[key_name(user)] has possessed [target] ([target.type]) at [AREACOORD(T)]")
		message_admins("[key_name(user)] has possessed [target] ([target.type]) at [AREACOORD(T)]")
	else
		log_admin("[key_name(user)] has possessed [target] ([target.type]) at an unknown location")
		message_admins("[key_name(user)] has possessed [target] ([target.type]) at an unknown location")

	var/mob/user_mob = user.mob
	if(!user.mob.control_object) //If you're not already possessing something...
		user_mob.name_archive = user_mob.real_name

	user_mob.forceMove(target)
	user_mob.real_name = target.name
	user_mob.name = target.name
	user_mob.reset_perspective(target)
	user_mob.control_object = target
	target.AddElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)

ADMIN_VERB_CONTEXT_MENU(release, "Release Obj", R_POSSESS)
	var/mob/user_mob = user.mob
	if(!user_mob.control_object) //lest we are banished to the nullspace realm.
		return

	if(user_mob.name_archive) //if you have a name archived
		user_mob.real_name = user_mob.name_archive
		user_mob.name_archive = ""
		user_mob.name = user_mob.real_name
		if(ishuman(user_mob))
			var/mob/living/carbon/human/H = user_mob
			H.name = H.get_visible_name()

	user_mob.control_object.RemoveElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)
	user_mob.forceMove(get_turf(user_mob.control_object))
	user_mob.reset_perspective()
	user_mob.control_object = null
