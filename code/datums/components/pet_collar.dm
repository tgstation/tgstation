/**
 * Allows people to put a collar on a mob, and possibly rename it.
 */
/datum/component/pet_collar
	/// The base of the icon state for collars. Optional if you actually want a visual.
	var/collar_icon_state = null
	/// if the mob can be renamed.
	var/can_rename = TRUE
	/// If icon has extra icon states for resting
	var/has_resting_state = FALSE

	/// Our collar
	var/obj/item/clothing/neck/petcollar/collar

	/// The applied collar overlay.
	var/applied_collar_overlays

/**
 * Arguments:
 * * collar_icon_state - The base of the icon state for collars.
 * * can_rename - if the mob can be renamed.
 * * start_with_collar - Animal should have a collar already.
 */
/datum/component/pet_collar/Initialize(collar_icon_state, can_rename, has_resting_state, start_with_collar)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if(collar_icon_state)
		src.collar_icon_state = collar_icon_state

	if(!isnull(can_rename))
		src.can_rename = can_rename

	if(!isnull(has_resting_state))
		src.has_resting_state = has_resting_state

	if(start_with_collar)
		collar = new(parent)

/datum/component/pet_collar/Destroy(force, silent)
	. = ..()

	if(collar)
		QDEL_NULL(collar)

/datum/component/pet_collar/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_CONTENTS_DEL, .proc/on_handle_atom_del)
	RegisterSignal(parent, COMSIG_LIVING_GIBBED, .proc/on_gib)
	RegisterSignal(parent, list(COMSIG_LIVING_REVIVE, COMSIG_LIVING_DEATH, COMSIG_LIVING_RESTING), .proc/on_life_change)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)

	update_overlays()

/datum/component/pet_collar/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_CONTENTS_DEL,
		COMSIG_LIVING_GIBBED,
		COMSIG_LIVING_REVIVE,
		COMSIG_LIVING_DEATH,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_LIVING_RESTING,
	))

	if(applied_collar_overlays)
		var/mob/parent_mob = parent
		parent_mob.cut_overlay(applied_collar_overlays)
		applied_collar_overlays = null

/**
 * Add a collar to the pet.
 *
 * Arguments:
 * * new_collar - the collar.
 * * user - the user that did it.
 */
/datum/component/pet_collar/proc/add_collar(obj/item/clothing/neck/petcollar/new_collar, mob/user)
	if(QDELETED(new_collar) || collar)
		return
	if(!user.transferItemToLoc(new_collar, parent))
		return

	var/mob/parent_mob = parent

	collar = new_collar
	if(collar_icon_state)
		update_overlays()

	to_chat(user, span_notice("You put the [new_collar] around [parent_mob]'s neck."))
	if(new_collar.tagname && can_rename)
		parent_mob.fully_replace_character_name(null, "\proper [new_collar.tagname]")

/**
 * Remove the collar from the pet.
 */
/datum/component/pet_collar/proc/remove_collar(atom/new_loc, update_visuals = TRUE)
	if(!collar)
		return

	collar.forceMove(new_loc)
	collar = null

	if(collar_icon_state && update_visuals)
		update_overlays()

/**
 * Update the collar overlay.
 */
/datum/component/pet_collar/proc/update_overlays()
	var/mob/living/parent_mob = parent

	if(applied_collar_overlays)
		parent_mob.cut_overlay(applied_collar_overlays)
		applied_collar_overlays = null

	if(collar && collar_icon_state)
		var/stat_tag = parent_mob.stat == DEAD ? "_dead" : (parent_mob.resting ? "_rest" : "")

		applied_collar_overlays = list(
			"[collar_icon_state][stat_tag]collar",
			"[collar_icon_state][stat_tag]tag",
		)

		parent_mob.add_overlay(applied_collar_overlays)

/**
 * Handler for COMSIG_ATOM_CONTENTS_DEL
 */
/datum/component/pet_collar/proc/on_handle_atom_del(mob/parent_mob, atom/deleting_atom)
	SIGNAL_HANDLER

	if(deleting_atom != collar)
		return

	collar = null

	if(QDELETED(parent_mob))
		return

	update_overlays()

/**
 * Handler for COMSIG_LIVING_GIBBED
 */
/datum/component/pet_collar/proc/on_gib(mob/parent_mob, no_brain, no_organs, no_bodyparts)
	SIGNAL_HANDLER

	remove_collar(parent_mob.drop_location(), update_visuals = FALSE)

/**
 * Handler for COMSIG_LIVING_REVIVE and COMSIG_LIVING_DEATH
 */
/datum/component/pet_collar/proc/on_life_change(mob/parent_mob)
	SIGNAL_HANDLER

	update_overlays()

/**
 * Handler for COMSIG_PARENT_ATTACKBY
 */
/datum/component/pet_collar/proc/on_attackby(mob/parent_mob, obj/item/thing, mob/user)
	SIGNAL_HANDLER

	if(istype(thing, /obj/item/clothing/neck/petcollar) && !collar)
		add_collar(thing, user)
		return COMPONENT_NO_AFTERATTACK

	return NONE


/**
 * A corresponding strippable_item for the collar slot.
 * Note that this shouldn't be used for carbons as it overlaps the carbon neck slot.
 */
/datum/strippable_item/pet_collar
	key = STRIPPABLE_ITEM_PET_COLLAR

/datum/strippable_item/pet_collar/get_item(atom/source)
	var/datum/component/pet_collar/collar_component = source?.GetComponent(/datum/component/pet_collar)
	if(!collar_component)
		return

	return collar_component.collar

/datum/strippable_item/pet_collar/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if (!istype(equipping, /obj/item/clothing/neck/petcollar))
		to_chat(user, span_warning("That's not a collar."))
		return FALSE

	return TRUE

/datum/strippable_item/pet_collar/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/datum/component/pet_collar/collar_component = source?.GetComponent(/datum/component/pet_collar)
	if(!collar_component)
		return

	collar_component.add_collar(equipping, user)

/datum/strippable_item/pet_collar/finish_unequip(atom/source, mob/user)
	var/datum/component/pet_collar/collar_component = source?.GetComponent(/datum/component/pet_collar)
	if(!collar_component)
		return

	var/obj/collar = collar_component.remove_collar(user.drop_location())
	user.put_in_hands(collar)
