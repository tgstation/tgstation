GLOBAL_LIST_INIT(creamable, typecacheof(list(
	/mob/living/carbon/human,
	/mob/living/basic/pet/dog/corgi,
	/mob/living/silicon/ai)))

/**
 * Creamed component
 *
 * For when you have pie on your face
 */
/datum/component/creamed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Creampie overlay we use for non-carbon mobs
	var/mutable_appearance/normal_overlay
	/// Creampie bodypart overlay we use for carbon mobs
	var/datum/bodypart_overlay/simple/creampie/bodypart_overlay
	/// Cached head for carbons, to ensure proper removal of the creampie overlay
	var/obj/item/bodypart/my_head

/datum/component/creamed/Initialize()
	if(!is_type_in_typecache(parent, GLOB.creamable))
		return COMPONENT_INCOMPATIBLE

	SEND_SIGNAL(parent, COMSIG_MOB_CREAMED, src)

	add_memory_in_range(parent, 7, /datum/memory/witnessed_creampie, protagonist = parent)

/datum/component/creamed/Destroy(force)
	. = ..()
	normal_overlay = null
	my_head = null
	QDEL_NULL(bodypart_overlay)

/datum/component/creamed/RegisterWithParent()
	if(iscarbon(parent))
		var/mob/living/carbon/human/carbon_parent = parent
		my_head = carbon_parent.get_bodypart(BODY_ZONE_HEAD)
		if(!my_head) //just to be sure
			qdel(src)
			return
		bodypart_overlay = new()
		if(carbon_parent.bodyshape & BODYSHAPE_SNOUTED) //stupid, but external organ bodytypes are not stored on the limb
			bodypart_overlay.icon_state = "creampie_lizard"
		else if(my_head.bodyshape & BODYSHAPE_MONKEY)
			bodypart_overlay.icon_state = "creampie_monkey"
		else
			bodypart_overlay.icon_state = "creampie_human"
		my_head.add_bodypart_overlay(bodypart_overlay)
		RegisterSignals(my_head, list(COMSIG_BODYPART_REMOVED, COMSIG_QDELETING), PROC_REF(lost_head))
		carbon_parent.add_mood_event("creampie", /datum/mood_event/creampie)
		carbon_parent.update_body_parts()
	else if(iscorgi(parent))
		normal_overlay = mutable_appearance('icons/mob/effects/creampie.dmi', "creampie_corgi")
	else if(isAI(parent))
		normal_overlay = mutable_appearance('icons/mob/effects/creampie.dmi', "creampie_ai")

	RegisterSignals(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_COMPONENT_CLEAN_FACE_ACT),
		PROC_REF(clean_up)
	)
	if(normal_overlay)
		var/atom/atom_parent = parent
		RegisterSignal(atom_parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_overlays))
		atom_parent.update_appearance()

/datum/component/creamed/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_COMPONENT_CLEAN_FACE_ACT))
	if(my_head)
		if(bodypart_overlay)
			my_head.remove_bodypart_overlay(bodypart_overlay)
			if(!my_head.owner)
				my_head.update_icon_dropped()
			QDEL_NULL(bodypart_overlay)
		UnregisterSignal(my_head, list(COMSIG_BODYPART_REMOVED, COMSIG_QDELETING))
		my_head = null
	if(iscarbon(parent))
		var/mob/living/carbon/carbon_parent = parent
		carbon_parent.clear_mood_event("creampie")
		carbon_parent.update_body_parts()
	if(normal_overlay)
		var/atom/atom_parent = parent
		UnregisterSignal(atom_parent, COMSIG_ATOM_UPDATE_OVERLAYS)
		atom_parent.update_appearance()
		normal_overlay = null

///Callback to remove pieface
/datum/component/creamed/proc/clean_up(datum/source, clean_types)
	SIGNAL_HANDLER

	if(!(clean_types & CLEAN_TYPE_BLOOD))
		return NONE

	qdel(src)
	return COMPONENT_CLEANED

/// Ensures normal_overlay overlay in case the mob is not a carbon
/datum/component/creamed/proc/update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(normal_overlay)
		overlays += normal_overlay

/// Removes creampie when the head gets dismembered
/datum/component/creamed/proc/lost_head(obj/item/bodypart/source, mob/living/carbon/owner, dismembered)
	SIGNAL_HANDLER

	qdel(src)
