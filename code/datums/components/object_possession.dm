/// Component that allows admins to control any object as if it were a mob.
/datum/component/object_possession
	/// Stores a reference to the mob that is currently possessing the object.
	var/datum/weakref/poltergeist = null
	/**
	  * back up of the real name during admin possession
	  *
	  * If an admin possesses an object it's real name is set to the admin name and this
	  * stores whatever the real name was previously. When possession ends, the real name
	  * is reset to this value
	  */
	var/stashed_name = null


/datum/component/object_possession/Initialize(mob/user)
	. = ..()
	if(!isobj(parent) || !ismob(user))
		return COMPONENT_INCOMPATIBLE

	if(HAS_TRAIT(user, TRAIT_CURRENTLY_CONTROLLING_OBJECT))
		if(tgui_alert(user, "You are already possessing an object. Would you like to relinquish control?", "Possession Error", list("Cancel", "Yes")) != "Yes")
			SEND_SIGNAL(user, COMSIG_END_OBJECT_POSSESSION)
		return COMPONENT_INCOMPATIBLE

	var/obj/obj_parent = parent

	if((obj_parent.obj_flags & DANGEROUS_POSSESSION) && CONFIG_GET(flag/forbid_singulo_possession))
		to_chat(user, "[obj_parent] is too powerful for you to possess.", confidential = TRUE)
		return COMPONENT_INCOMPATIBLE

	if(HAS_TRAIT(user, TRAIT_CURRENTLY_CONTROLLING_OBJECT))
		stashed_name = user.name

	ADD_TRAIT(user, TRAIT_CURRENTLY_CONTROLLING_OBJECT, REF(parent))

	user.forceMove(obj_parent)
	user.real_name = obj_parent.name
	user.name = obj_parent.name
	user.reset_perspective(obj_parent)
	poltergeist = WEAKREF(user)

	obj_parent.AddElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)

	RegisterSignal(user, COMSIG_END_OBJECT_POSSESSION, PROC_REF(end_possession))

/datum/component/object_possession/Destroy()
	cleanup_ourselves()
	return ..()

/// Cleans up everything when the admin wants out.
/datum/component/object_possession/proc/cleanup_ourselves()
	parent.RemoveElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)

	var/mob/user = poltergeist?.resolve()
	if(isnull(user))
		return

	REMOVE_TRAIT(user, TRAIT_CURRENTLY_CONTROLLING_OBJECT, REF(parent))

	if(!isnull(stashed_name))
		user.real_name = stashed_name
		user.name = stashed_name
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			human_user.name = human_user.get_visible_name()

	user.forceMove(get_turf(parent))
	user.reset_perspective()

/datum/component/object_possession/proc/end_possession(datum/source)
	SIGNAL_HANDLER
	qdel(src)
