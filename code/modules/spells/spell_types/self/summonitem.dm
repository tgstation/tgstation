/datum/action/cooldown/spell/summonitem
	name = "Instant Summons"
	desc = "This spell can be used to recall a previously marked item to your hand from anywhere in the universe."
	button_icon_state = "summons"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS

	invocation = "GAR YOK"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	spell_max_level = 1 //cannot be improved

	///The obj marked for recall
	var/obj/marked_item

/datum/action/cooldown/spell/summonitem/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/// Set the passed object as our marked item
/datum/action/cooldown/spell/summonitem/proc/mark_item(obj/to_mark)
	name = "Recall [to_mark]"
	marked_item = to_mark
	RegisterSignal(marked_item, COMSIG_PARENT_QDELETING, .proc/on_marked_item_deleted)

/// Unset our current marked item
/datum/action/cooldown/spell/summonitem/proc/unmark_item()
	name = initial(name)
	UnregisterSignal(marked_item, COMSIG_PARENT_QDELETING)
	marked_item = null

/// Signal proc for COMSIG_PARENT_QDELETING on our marked item, unmarks our item if it's deleted
/datum/action/cooldown/spell/summonitem/proc/on_marked_item_deleted(datum/source)
	SIGNAL_HANDLER

	if(owner)
		to_chat(owner, span_boldwarning("You sense your marked item has been destroyed!"))
	unmark_item()

/datum/action/cooldown/spell/summonitem/cast(mob/living/cast_on)
	. = ..()
	if(QDELETED(marked_item))
		try_link_item(cast_on)
		return

	if(marked_item == cast_on.get_active_held_item())
		try_unlink_item(cast_on)
		return

	try_recall_item(cast_on)

/// If we don't have a marked item, attempts to mark the caster's held item.
/datum/action/cooldown/spell/summonitem/proc/try_link_item(mob/living/caster)
	var/obj/item/potential_mark = caster.get_active_held_item()
	if(!potential_mark)
		if(caster.get_inactive_held_item())
			to_chat(caster, span_warning("You must hold the desired item in your hands to mark it for recall!"))
		else
			to_chat(caster, span_warning("You aren't holding anything that can be marked for recall!"))
		return FALSE

	var/link_message = ""
	if(potential_mark.item_flags & ABSTRACT)
		return FALSE
	if(SEND_SIGNAL(potential_mark, COMSIG_ITEM_MARK_RETRIEVAL, src, caster) & COMPONENT_BLOCK_MARK_RETRIEVAL)
		return FALSE
	if(HAS_TRAIT(potential_mark, TRAIT_NODROP))
		link_message += "Though it feels redundant... "

	link_message += "You mark [potential_mark] for recall."
	to_chat(caster, span_notice(link_message))
	mark_item(potential_mark)
	return TRUE

/// If we have a marked item and it's in our hand, we will try to unlink it
/datum/action/cooldown/spell/summonitem/proc/try_unlink_item(mob/living/caster)
	to_chat(caster, span_notice("You begin removing the mark on [marked_item]..."))
	if(!do_after(caster, 5 SECONDS, marked_item))
		to_chat(caster, span_notice("You decide to keep [marked_item] marked."))
		return FALSE

	to_chat(caster, span_notice("You remove the mark on [marked_item] to use elsewhere."))
	unmark_item()
	return TRUE

/// Recalls our marked item to the caster. May bring some unexpected things along.
/datum/action/cooldown/spell/summonitem/proc/try_recall_item(mob/living/caster)
	var/obj/item_to_retrieve = marked_item

	if(item_to_retrieve.loc)
		// I don't want to know how someone could put something
		// inside itself but these are wizards so let's be safe
		var/infinite_recursion = 0

		// if it's in something, you get the whole thing.
		while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10)
			if(isitem(item_to_retrieve.loc))
				var/obj/item/mark_loc = item_to_retrieve.loc
				// Being able to summon abstract things because
				// your item happened to get placed there is a no-no
				if(mark_loc.item_flags & ABSTRACT)
					break

			// If its on someone, properly drop it
			if(ismob(item_to_retrieve.loc))
				var/mob/holding_mark = item_to_retrieve.loc

				// Items in silicons warp the whole silicon
				if(issilicon(holding_mark))
					holding_mark.loc.visible_message(span_warning("[holding_mark] suddenly disappears!"))
					holding_mark.forceMove(caster.loc)
					holding_mark.loc.visible_message(span_warning("[holding_mark] suddenly appears!"))
					item_to_retrieve = null
					break

				holding_mark.dropItemToGround(item_to_retrieve)

			else if(isobj(item_to_retrieve.loc))
				var/obj/retrieved_item = item_to_retrieve.loc
				// Can't bring anchored things
				if(retrieved_item.anchored)
					return
				// Edge cases for moving certain machinery...
				if(istype(retrieved_item, /obj/machinery/portable_atmospherics))
					var/obj/machinery/portable_atmospherics/atmos_item = retrieved_item
					atmos_item.disconnect()
					atmos_item.update_appearance()

				// Otherwise bring the whole thing with us
				item_to_retrieve = retrieved_item

			infinite_recursion += 1

	else
		// Organs are usually stored in nullspace
		if(isorgan(item_to_retrieve))
			var/obj/item/organ/organ = item_to_retrieve
			if(organ.owner)
				// If this code ever runs I will be happy
				log_combat(caster, organ.owner, "magically removed [organ.name] from", addition = "COMBAT MODE: [uppertext(caster.combat_mode)]")
				organ.Remove(organ.owner)

	if(!item_to_retrieve)
		return

	item_to_retrieve.loc?.visible_message(span_warning("[item_to_retrieve] suddenly disappears!"))

	if(isitem(item_to_retrieve) && caster.put_in_hands(item_to_retrieve))
		item_to_retrieve.loc.visible_message(span_warning("[item_to_retrieve] suddenly appears in [caster]'s hand!"))
	else
		item_to_retrieve.forceMove(caster.drop_location())
		item_to_retrieve.loc.visible_message(span_warning("[item_to_retrieve] suddenly appears!"))
	playsound(get_turf(item_to_retrieve), 'sound/magic/summonitems_generic.ogg', 50, TRUE)
