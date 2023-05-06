/datum/action/innate/clockcult/recall_slab
	name = "Recall Slab"
	desc = "Recall your latest used Clockwork Slab from anywhere in the universe."
	button_icon_state = "Replicant"

	///The slab marked for recall
	var/obj/item/clockwork/clockwork_slab/marked_slab


/// Set the passed object as our marked item
/datum/action/innate/clockcult/recall_slab/proc/mark_item(obj/to_mark)
	marked_slab = to_mark
	RegisterSignal(marked_slab, COMSIG_PARENT_QDELETING, PROC_REF(on_marked_item_deleted))


/// Unset our current marked item
/datum/action/innate/clockcult/recall_slab/proc/unmark_item()
	if(!marked_slab)
		return

	UnregisterSignal(marked_slab, COMSIG_PARENT_QDELETING)
	marked_slab = null


/// Signal proc for COMSIG_PARENT_QDELETING on our marked item, unmarks our item if it's deleted
/datum/action/innate/clockcult/recall_slab/proc/on_marked_item_deleted(datum/source)
	SIGNAL_HANDLER

	if(owner)
		to_chat(owner, span_boldwarning("You sense your Clockwork Slab has been destroyed!"))

	unmark_item()


/datum/action/innate/clockcult/recall_slab/Activate()
	try_recall_item()


/// Recalls our marked item to the caster. May bring some unexpected things along.
/datum/action/innate/clockcult/recall_slab/proc/try_recall_item()
	var/obj/item_to_retrieve = marked_slab

	if(!item_to_retrieve)
		to_chat(usr, span_brass("You don't have a slab attuned!"))

	if(!item_to_retrieve.loc)
		return

	// just being safe
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
				holding_mark.forceMove(usr.loc)
				holding_mark.loc.visible_message(span_warning("[holding_mark] suddenly appears!"))
				item_to_retrieve = null
				break

			SEND_SIGNAL(holding_mark, COMSIG_MAGIC_RECALL, usr, item_to_retrieve)
			holding_mark.dropItemToGround(item_to_retrieve)

		else if(isobj(item_to_retrieve.loc))
			var/obj/retrieved_item = item_to_retrieve.loc
			// Can't bring anchored things
			if(retrieved_item.anchored)
				break

			// Edge cases for moving certain machinery...
			if(istype(retrieved_item, /obj/machinery/portable_atmospherics))
				var/obj/machinery/portable_atmospherics/atmos_item = retrieved_item
				atmos_item.disconnect()
				atmos_item.update_appearance()

			// Otherwise bring the whole thing with us
			item_to_retrieve = retrieved_item

		infinite_recursion += 1

	if(!item_to_retrieve)
		return

	item_to_retrieve.loc?.visible_message(span_warning("[item_to_retrieve] suddenly disappears!"))

	if(isitem(item_to_retrieve) && usr.put_in_hands(item_to_retrieve))
		item_to_retrieve.loc.visible_message(span_warning("[item_to_retrieve] suddenly appears in [usr]'s hand!"))

	else
		item_to_retrieve.forceMove(usr.drop_location())
		item_to_retrieve.loc.visible_message(span_warning("[item_to_retrieve] suddenly appears!"))

	playsound(get_turf(item_to_retrieve), 'sound/magic/summonitems_generic.ogg', 50, TRUE)
