/// An element that lets you stab people in the eyes when targeting them
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
	if(istype(wall) || !user.mind)
		return
	if(!(wall.turf_flags & ENGRAVABLE))
		user.balloon_alert(user, "wall cannot be engraved!")
		return
	if(!user.mind.memories)
		user.balloon_alert(user, "nothing memorable to engrave!")
		return
	var/datum/memory/memory_to_engrave = user.mind.select_memory("engrave")
	if(!user.Adjacent(wall))
		return
	item.add_fingerprint(user)
	playsound(item, item.hitsound, 30, TRUE, -1)
	user.do_attack_animation(wall)
	user.balloon_alert(user, "engraving wall...")
	if(!do_after(user, 10 SECONDS, target = wall))
		return
	user.balloon_alert(user, "wall engraved")
	user.do_attack_animation(wall)
	wall.AddComponent(/datum/component/engraved, memory_to_engrave.generate_story(STORY_ENGRAVING, STORY_FLAG_DATED))
	///REMOVE THE MEMORY ONCE ENGRAVED
