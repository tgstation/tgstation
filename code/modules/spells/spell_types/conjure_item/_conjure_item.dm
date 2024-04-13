/datum/action/cooldown/spell/conjure_item
	school = SCHOOL_CONJURATION
	invocation_type = INVOCATION_NONE

	/// Typepath of whatever item we summon
	var/obj/item/item_type
	/// If TRUE, we delete any previously created items when we cast the spell
	var/delete_old = TRUE
	/// List of weakrefs to items summoned
	var/list/datum/weakref/item_refs
	/// If TRUE, deletes the item if no mob picks it up on cast
	var/delete_on_failure = TRUE
	/// If TRUE, requires the caster be able to pick it up afterwards
	var/requires_hands = FALSE

/datum/action/cooldown/spell/conjure_item/Destroy()
	// If we delete_old, clean up all of our items on delete
	if(delete_old)
		QDEL_LAZYLIST(item_refs)

	// If we don't delete_old, just let all the items be free
	else
		LAZYNULL(item_refs)

	return ..()

/datum/action/cooldown/spell/conjure_item/can_cast_spell(feedback)
	. = ..()
	if(!.)
		return FALSE

	if(!requires_hands)
		return TRUE

	if(!isliving(owner))
		return FALSE

	var/mob/living/living_owner = owner
	if(living_owner.usable_hands < 1)
		if(feedback)
			owner.balloon_alert(owner, "no free hands!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/conjure_item/is_valid_target(atom/cast_on)
	if(!requires_hands)
		return TRUE
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_cast_on = cast_on
	return living_cast_on.usable_hands >= 1

/datum/action/cooldown/spell/conjure_item/cast(atom/cast_on)
	if(delete_old && LAZYLEN(item_refs))
		QDEL_LAZYLIST(item_refs)

	var/mob/mob_caster = cast_on
	if(istype(mob_caster))
		var/obj/item/existing_item = mob_caster.get_active_held_item()
		if(existing_item)
			mob_caster.dropItemToGround(existing_item)

	var/obj/item/created = make_item(cast_on)
	if(QDELETED(created))
		CRASH("[type] tried to create an item, but failed. It's item type is [item_type].")

	if(istype(mob_caster))
		mob_caster.put_in_hands(created, del_on_fail = delete_on_failure)

	return ..()

/// Instantiates the item we're conjuring and returns it.
/// Item is made in at the caster's.
/datum/action/cooldown/spell/conjure_item/proc/make_item(atom/caster)
	var/obj/item/made_item = new item_type(caster.loc)
	LAZYADD(item_refs, WEAKREF(made_item))
	return made_item

/// Called after item has been handed to the caster, for any additional presentation
/datum/action/cooldown/spell/conjure_item/proc/post_created(atom/cast_on, atom/created)
	return
