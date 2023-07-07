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
	var/mutable_appearance/creamface
	/// Creampie bodypart overlay we use for carbon mobs
	var/datum/bodypart_overlay/simple/creampie/creampie
	/// Cached head for carbons, to ensure proper removal of the creampie overlay
	var/obj/item/bodypart/my_head

/datum/component/creamed/Initialize()
	if(!is_type_in_typecache(parent, GLOB.creamable))
		return COMPONENT_INCOMPATIBLE

	SEND_SIGNAL(parent, COMSIG_MOB_CREAMED, src)

	add_memory_in_range(parent, 7, /datum/memory/witnessed_creampie, protagonist = parent)

/datum/component/creamed/Destroy(force)
	creamface = null
	my_head = null
	QDEL_NULL(creampie)
	return ..()

/datum/component/creamed/RegisterWithParent()
	if(iscarbon(parent))
		var/mob/living/carbon/human/carbon_parent = parent
		my_head = carbon_parent.get_bodypart(BODY_ZONE_HEAD)
		if(!my_head) //just to be sure
			qdel(src)
			return
		creampie = new()
		if(my_head.bodytype & BODYTYPE_SNOUTED)
			creampie.icon_state = "creampie_lizard"
		else if(my_head.bodytype & BODYTYPE_MONKEY)
			creampie.icon_state = "creampie_monkey"
		else
			creampie.icon_state = "creampie_human"
		my_head.add_bodypart_overlay(creampie)
		RegisterSignal(my_head, COMSIG_BODYPART_REMOVED, PROC_REF(lost_head))
		carbon_parent.add_mood_event("creampie", /datum/mood_event/creampie)
		carbon_parent.update_body_parts()
	else if(iscorgi(parent))
		creamface = mutable_appearance('icons/effects/creampie.dmi', "creampie_corgi")
	else if(isAI(parent))
		creamface = mutable_appearance('icons/effects/creampie.dmi', "creampie_ai")

	RegisterSignals(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_COMPONENT_CLEAN_FACE_ACT),
		PROC_REF(clean_up)
	)
	if(creamface)
		var/atom/atom_parent = parent
		RegisterSignal(atom_parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_overlays))
		atom_parent.update_appearance()

/datum/component/creamed/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_COMPONENT_CLEAN_FACE_ACT))
	if(my_head)
		if(creampie)
			my_head.remove_bodypart_overlay(creampie)
		UnregisterSignal(my_head, COMSIG_BODYPART_REMOVED)
	if(iscarbon(parent))
		var/mob/living/carbon/carbon_parent = parent
		carbon_parent.clear_mood_event("creampie")
		carbon_parent.update_body_parts()
	if(creamface)
		var/atom/atom_parent = parent
		UnregisterSignal(atom_parent, COMSIG_ATOM_UPDATE_OVERLAYS)
		atom_parent.update_appearance()

///Callback to remove pieface
/datum/component/creamed/proc/clean_up(datum/source, clean_types)
	SIGNAL_HANDLER

	. = NONE
	if(!(clean_types & CLEAN_TYPE_BLOOD))
		return
	qdel(src)
	return COMPONENT_CLEANED

/// Ensures creamface overlay in case the mob is not a carbon
/datum/component/creamed/proc/update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(creamface)
		overlays += creamface

/// Removes creampie when the head gets dismembered
/datum/component/creamed/proc/lost_head(obj/item/bodypart/source, mob/living/carbon/owner, dismembered)
	SIGNAL_HANDLER

	qdel(src)
