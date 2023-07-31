/// An element that lets you engrave walls and statues when right click is used
/datum/element/engraver

/datum/element/engraver/Attach(obj/item/target)
	. = ..()

	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_item_pre_attack_secondary))
	RegisterSignal(target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))
	target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

/datum/element/engraver/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_EXAMINE, COMSIG_ITEM_PRE_ATTACK_SECONDARY, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM))

///signal called on parent being examined
/datum/element/engraver/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("You can engrave with RMB if you can think of something interesting.")

///signal called on parent being used to right click attack something
/datum/element/engraver/proc/on_item_pre_attack_secondary(datum/source, atom/target, mob/living/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(try_chisel), source, target, user)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/element/engraver/proc/try_chisel(obj/item/item, atom/target, mob/living/user)
	if(!is_type_in_typecache(target, GLOB.engravable_whitelist) || !user.mind)
		return

	if(HAS_TRAIT_FROM(target, TRAIT_NOT_ENGRAVABLE, INNATE_TRAIT))
		user.balloon_alert(user, "cannot be engraved!")
		return
	if(HAS_TRAIT_FROM(target, TRAIT_NOT_ENGRAVABLE, TRAIT_GENERIC))
		user.balloon_alert(user, "already been engraved!")
		return
	if(!length(user.mind?.memories))
		user.balloon_alert(user, "nothing memorable to engrave!")
		return
	var/datum/memory/memory_to_engrave = user.mind.select_memory("engrave")
	if(!memory_to_engrave)
		return
	if(!user.Adjacent(target))
		return
	item.add_fingerprint(user)
	playsound(item, 'sound/effects/break_stone.ogg', 30, TRUE, -1)
	user.do_attack_animation(target)
	user.balloon_alert(user, "engraving...")
	if(!do_after(user, 5 SECONDS, target = target))
		return
	user.balloon_alert(user, "engraved")
	user.do_attack_animation(target)

	var/do_persistent_save = !(memory_to_engrave.memory_flags & MEMORY_FLAG_NOPERSISTENCE)
	var/engraved_story = memory_to_engrave.generate_story(STORY_ENGRAVING, STORY_FLAG_DATED)

	if(!engraved_story)
		CRASH("Tried to submit a memory with an invalid story [memory_to_engrave]")

	target.AddComponent(/datum/component/engraved, engraved_story, persistent_save = do_persistent_save, story_value = memory_to_engrave.story_value)
	memory_to_engrave.memory_flags |= MEMORY_FLAG_ALREADY_USED
	//while someone just engraved a story "worth engraving" we should add this to SSpersistence for a possible prison tattoo

	if(do_persistent_save)
		var/list/tattoo_entry = list()

		var/tattoo_story = memory_to_engrave.generate_story(STORY_TATTOO)

		if(!tattoo_story)
			CRASH("Tried to submit a memory with an invalid story [memory_to_engrave]")

		tattoo_entry["story"] = tattoo_story
		SSpersistence.prison_tattoos_to_save += list(tattoo_entry)

/datum/element/engraver/proc/on_requesting_context_from_item(atom/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(source, GLOB.engravable_whitelist))
		return NONE

	if(HAS_TRAIT(source, TRAIT_NOT_ENGRAVABLE))
		return NONE

	context[SCREENTIP_CONTEXT_RMB] = "Engrave memory"
	return CONTEXTUAL_SCREENTIP_SET
