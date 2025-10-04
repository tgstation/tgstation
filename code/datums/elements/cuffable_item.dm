#define WIP_CUFFABLE_ITEM_TRAIT "wip_cuff"

/datum/element/cuffable_item

/datum/element/cuffable_item/Attach(datum/target)
	. = ..()

	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(item_interaction))

	var/atom/atom_target = target
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

///signal called on parent being examined
/datum/element/cuffable_item/proc/on_examine_more(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(length(user.held_items) < 0 || iscyborg(user) || source.anchored)
		return
	examine_list += span_smallnotice("You could bind [source.p_they()] to your wrist with a pair of handcuffs...")

/datum/element/cuffable_item/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if (istype(held_item, /obj/item/restraints/handcuffs))
		context[SCREENTIP_CONTEXT_RMB] = "Cuff to your wrist"
		return CONTEXTUAL_SCREENTIP_SET

/datum/element/cuffable_item/proc/item_interaction(obj/item/source, mob/living/user, obj/item/tool, modifiers)
	if(!istype(tool, /obj/item/restraints/handcuffs) || iscyborg(user) || source.anchored)
		return NONE

	if(DOING_INTERACTION_WITH_TARGET(user, source))
		return ITEM_INTERACT_BLOCKING

	if(HAS_TRAIT_FROM(source, TRAIT_NODROP, WIP_CUFFABLE_ITEM_TRAIT))
		to_chat(user, span_warning("[source] is already cuffed to your wrist!"))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/restraints/handcuffs/cuffs = tool

	if(cuffs.handcuffs_clumsiness_check(user))
		return ITEM_INTERACT_BLOCKING

	source.balloon_alert(user, "cuffing item...")
	playsound(source, cuffs.cuffsound, 30, TRUE, -2)
	if(!do_after(user, cuffs.get_handcuff_time(user), source))
		return ITEM_INTERACT_BLOCKING

	playsound(source, cuffs.cuffsuccesssound, 30, TRUE, -2)

	if(user.apply_status_effect(/datum/status_effect/cuffed_item, source, cuffs))
		source.balloon_alert(user, "item cuffed to wrist")
		return ITEM_INTERACT_SUCCESS

	source.balloon_alert(user, "couldn't cuff to wrist!")
	return ITEM_INTERACT_BLOCKING

/datum/status_effect/cuffed_item
	id = "cuffed_item"
	status_type = STATUS_EFFECT_MULTIPLE
	var/obj/item/cuffed
	var/obj/item/restraints/handcuffs/cuffs

/datum/status_effect/cuffed_item/on_creation(mob/living/new_owner, obj/item/cuffed, obj/item/restraints/handcuffs/cuffs)
	src.cuffed = cuffed
	src.cuffs = cuffs
	return ..()

/datum/status_effect/cuffed_item/on_apply()
	if(HAS_TRAIT_FROM(cuffed, TRAIT_NODROP, WIP_CUFFABLE_ITEM_TRAIT))
		qdel(src)
		return FALSE
	owner.temporarilyRemoveItemFromInventory(cuffs, force = TRUE)
	if(!owner.is_holding(cuffed) && !owner.put_in_hands(cuffed))
		owner.put_in_hands(cuffs)
		qdel(src)
		return FALSE

	ADD_TRAIT(cuffed, TRAIT_NODROP, WIP_CUFFABLE_ITEM_TRAIT)

	RegisterSignals(cuffed, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(on_displaced))
	RegisterSignal(cuffed, COMSIG_ATOM_EXAMINE, PROC_REF(cuffed_reminder))
	RegisterSignal(cuffed, COMSIG_TOPIC, PROC_REF(topic_handler))

	RegisterSignals(cuffs, list(COMSIG_ITEM_EQUIPPED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(on_displaced))

	return TRUE

/datum/status_effect/cuffed_item/on_remove()
	UnregisterSignal(cuffed, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	UnregisterSignal(cuffs, list(COMSIG_ITEM_EQUIPPED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	REMOVE_TRAIT(cuffed, TRAIT_NODROP, WIP_CUFFABLE_ITEM_TRAIT)
	cuffed = null

	if(!QDELETED(owner) && cuffs.loc == owner && !(cuffs in owner.get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD)))
		cuffs.forceMove(owner.drop_location())
	cuffs = null

/datum/status_effect/cuffed_item/proc/on_displaced(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/cuffed_item/proc/cuffed_reminder(obj/item/item, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	if(user == owner)
		examine_texts += span_notice("[item.p_Theyre()] cuffed to you by \a [cuffs]. You can <a href='byond://?src=[REF(item)];remove_cuffs_item=1'>remove them.</a>.")

/datum/status_effect/cuffed_item/proc/topic_handler(atom/source, user, href_list)
	SIGNAL_HANDLER

	if(user == owner && href_list["remove_cuffs_item"])
		try_remove_cuffs(user)

/datum/status_effect/cuffed_item/proc/try_remove_cuffs(mob/living/user)

	var/interaction_key = REF(src)

	if(LAZYACCESS(user.do_afters, interaction_key))
		return FALSE

	if(user.incapacitated || (user != owner && !user.CanReach(owner)))
		owner.balloon_alert("can't do it right now!")
		return FALSE

	owner.balloon_alert(user, "removing cuffs...")
	playsound(owner, cuffs.cuffsound, 30, TRUE, -2)
	if(!do_after(user, cuffs.get_handcuff_time(user) * 1.5, owner, interaction_key = interaction_key) || QDELETED(src))
		owner.balloon_alert("interrupted!")
		return FALSE

	var/obj/item/restraints/handcuffs/ref_cuffs = cuffs
	ref_cuffs.forceMove(owner.drop_location()) //This will cause the status effect to delete itself, which unsets the 'cuffs' var
	user.put_in_hands(ref_cuffs)
	owner.balloon_alert(user, "cuffs removed from item")
	return TRUE

#undef WIP_CUFFABLE_ITEM_TRAIT
