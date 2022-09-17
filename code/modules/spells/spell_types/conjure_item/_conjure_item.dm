/datum/action/cooldown/spell/conjure_item
	school = SCHOOL_CONJURATION
	invocation_type = INVOCATION_NONE

	/// Typepath of whatever item we summon
	var/obj/item/item_type
	/// If TRUE, we delete any previously created items when we cast the spell
	var/delete_old = TRUE
	/// List of weakrefs to items summoned
	var/list/datum/weakref/item_refs

/datum/action/cooldown/spell/conjure_item/Destroy()
	// If we delete_old, clean up all of our items on delete
	if(delete_old)
		QDEL_LAZYLIST(item_refs)

	// If we don't delete_old, just let all the items be free
	else
		LAZYNULL(item_refs)

	return ..()

/datum/action/cooldown/spell/conjure_item/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/conjure_item/cast(mob/living/carbon/cast_on)
	if(delete_old && LAZYLEN(item_refs))
		QDEL_LAZYLIST(item_refs)

	var/obj/item/existing_item = cast_on.get_active_held_item()
	if(existing_item)
		cast_on.dropItemToGround(existing_item)

	var/obj/item/created = make_item()
	if(QDELETED(created))
		CRASH("[type] tried to create an item, but failed. It's item type is [item_type].")

	cast_on.put_in_hands(created, del_on_fail = TRUE)
	return ..()

/// Instantiates the item we're conjuring and returns it.
/// Item is made in nullspace and moved out in cast().
/datum/action/cooldown/spell/conjure_item/proc/make_item()
	var/obj/item/made_item = new item_type()
	LAZYADD(item_refs, WEAKREF(made_item))
	return made_item
