/datum/action/cooldown/spell/conjure_item
	name = "Summon Weapon"
	desc = "A generic spell that should not exist. This summons an instance of a specific type of item, \
		or if one already exists, un-summons it. Summons into hand if possible."

	school = SCHOOL_CONJURATION
	cooldown_time = 15 SECONDS
	cooldown_reduction_per_rank = 3 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	/// Typepath of whatever item we summon
	var/item_type = /obj/item/banhammer
	/// Whether we delete the last item(s) we made after the spell is cast
	var/delete_old = TRUE
	/// List of weakrefs to items summoned
	var/list/datum/weakref/item_refs = list()

/datum/action/cooldown/spell/conjure_item/Destroy()
	QDEL_LIST(item_refs)
	return ..()

/datum/action/cooldown/spell/conjure_item/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/conjure_item/cast(mob/living/carbon/cast_on)
	if (delete_old && length(item_refs))
		QDEL_LIST(item_refs)
		return

	var/obj/item/existing_item = cast_on.get_active_held_item()
	if(existing_item)
		cast_on.dropItemToGround(existing_item)

	cast_on.put_in_hands(make_item(), TRUE)

/obj/effect/proc_holder/spell/targeted/conjure_item/proc/make_item()
	var/obj/item/made_item = new item_type()
	item_refs += WEAKREF(made_item)
	return made_item
