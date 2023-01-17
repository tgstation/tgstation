ADMIN_VERB(object, possess_object, "", R_POSSESS, obj/target in world)
	if((target.obj_flags & DANGEROUS_POSSESSION) && CONFIG_GET(flag/forbid_singulo_possession))
		to_chat(usr, "[target] is too powerful for you to possess.", confidential = TRUE)
		return

	var/turf/target_turf = get_turf(target)

	if(target_turf)
		log_admin("[key_name(usr)] has possessed [target] ([target.type]) at [AREACOORD(target_turf)]")
		message_admins("[key_name(usr)] has possessed [target] ([target.type]) at [AREACOORD(target_turf)]")
	else
		log_admin("[key_name(usr)] has possessed [target] ([target.type]) at an unknown location")
		message_admins("[key_name(usr)] has possessed [target] ([target.type]) at an unknown location")

	if(!usr.control_object) //If you're not already possessing something...
		usr.name_archive = usr.real_name

	usr.forceMove(target)
	usr.real_name = target.name
	usr.name = target.name
	usr.reset_perspective(target)
	usr.control_object = target
	target.AddElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)

ADMIN_VERB(object, release_object, "", R_POSSESS)
	if(!usr.control_object) //lest we are banished to the nullspace realm.
		return

	if(usr.name_archive) //if you have a name archived
		usr.real_name = usr.name_archive
		usr.name_archive = ""
		usr.name = usr.real_name
		if(ishuman(usr))
			var/mob/living/carbon/human/user = usr
			user.name = user.get_visible_name()

	usr.control_object.RemoveElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)
	usr.forceMove(get_turf(usr.control_object))
	usr.reset_perspective()
	usr.control_object = null
