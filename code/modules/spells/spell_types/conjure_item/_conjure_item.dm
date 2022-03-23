/datum/action/cooldown/spell/conjure_item
	school = SCHOOL_CONJURATION
	invocation_type = INVOCATION_NONE

	/// Typepath of whatever item we summon
	var/obj/item/item_type
	/// Whether we delete the last item(s) we made after the spell is cast
	var/delete_old = TRUE
	/// List of weakrefs to items summoned
	var/list/datum/weakref/item_refs

/datum/action/cooldown/spell/conjure_item/Destroy()
	QDEL_LAZYLIST(item_refs)
	return ..()

/datum/action/cooldown/spell/conjure_item/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/conjure_item/cast(mob/living/carbon/cast_on)
	if(delete_old && LAZYLEN(item_refs))
		QDEL_LAZYLIST(item_refs)
		return

	var/obj/item/existing_item = cast_on.get_active_held_item()
	if(existing_item)
		cast_on.dropItemToGround(existing_item)

	cast_on.put_in_hands(make_item(), TRUE)
	return ..()

/datum/action/cooldown/spell/conjure_item/proc/make_item()
	var/obj/item/made_item = new item_type()
	LAZYADD(item_refs, WEAKREF(made_item))
	return made_item
