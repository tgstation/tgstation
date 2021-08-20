/// An element that lets you engrave walls when right click is used
/datum/element/wall_engraver
	element_flags = ELEMENT_DETACH

/datum/element/wall_engraver/Attach(datum/target)
	. = ..()

	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK_SECONDARY, .proc/on_item_pre_attack_secondary)

/datum/element/wall_engraver/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(source, COMSIG_ITEM_PRE_ATTACK_SECONDARY)

///signal called on parent being examined
/datum/element/wall_engraver/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("You can engrave some walls with your secondary attack if you can think of something interesting to engrave.")

///signal called on parent being used to right click attack something
/datum/element/wall_engraver/proc/on_item_pre_attack_secondary(datum/source, atom/target, mob/living/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, .proc/try_chisel, source, target, user)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/element/wall_engraver/proc/try_chisel(obj/item/item, turf/closed/wall, mob/living/user)
	if(!istype(wall) || !user.mind)
		return
	if(HAS_TRAIT_FROM(wall, NOT_ENGRAVABLE, INNATE_TRAIT))
		user.balloon_alert(user, "wall cannot be engraved!")
		return
	if(HAS_TRAIT_FROM(wall, NOT_ENGRAVABLE, TRAIT_GENERIC))
		user.balloon_alert(user, "wall has already been engraved!")
		return
	if(!user.mind.memories)
		user.balloon_alert(user, "nothing memorable to engrave!")
		return
	var/datum/memory/memory_to_engrave = user.mind.select_memory("engrave")
	if(!memory_to_engrave)
		return
	if(!user.Adjacent(wall))
		return
	item.add_fingerprint(user)
	playsound(item, item.hitsound, 30, TRUE, -1)
	user.do_attack_animation(wall)
	user.balloon_alert(user, "engraving wall...")
	if(!do_after(user, 5 SECONDS, target = wall))
		return
	user.balloon_alert(user, "wall engraved")
	user.do_attack_animation(wall)

	var/do_persistent_save = TRUE
	if(memory_to_engrave.memory_flags & MEMORY_FLAG_NOPERSISTENCE)
		do_persistent_save = FALSE

	wall.AddComponent(/datum/component/engraved, memory_to_engrave.generate_story(STORY_ENGRAVING, STORY_FLAG_DATED), persistent_save = do_persistent_save, story_value = memory_to_engrave.story_value)
	///while someone just engraved a story "worth engraving" we should add this to SSpersistence for a possible prison tattoo
	memory_to_engrave.memory_flags |= MEMORY_FLAG_ALREADY_USED

	if(do_persistent_save)
		var/list/tattoo_entry = list()
		tattoo_entry["story"] = memory_to_engrave.generate_story(STORY_TATTOO)
		SSpersistence.prison_tattoos_to_save += list(tattoo_entry)
