/**
 * The status effect given by the cuffable_item.
 * It basically binds an item to your arm, basically making it undroppable until the cuffs or item are removed, usually done by one of:
 * - clicking the status alert
 * - using the topic hyperlink
 * - strip menu for others
 * - alternatively, dismemberment or destroying the item
 */
/datum/status_effect/cuffed_item
	id = "cuffed_item"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = /atom/movable/screen/alert/status_effect/cuffed_item
	///Reference to the item stuck into the player's hand
	var/obj/item/cuffed
	///Reference to the pair of handcuffs used to bind the item
	var/obj/item/restraints/handcuffs/cuffs

/datum/status_effect/cuffed_item/on_creation(mob/living/new_owner, obj/item/cuffed, obj/item/restraints/handcuffs/cuffs)
	src.cuffed = cuffed
	src.cuffs = cuffs
	. = ..() //throws the alert and all
	linked_alert.update_appearance(UPDATE_OVERLAYS)

/datum/status_effect/cuffed_item/on_apply()
	if(HAS_TRAIT_FROM(cuffed, TRAIT_NODROP, CUFFED_ITEM_TRAIT))
		qdel(src)
		return FALSE
	owner.temporarilyRemoveItemFromInventory(cuffs, force = TRUE)
	if(!owner.is_holding(cuffed) && !owner.put_in_hands(cuffed))
		owner.put_in_hands(cuffs)
		qdel(src)
		return FALSE

	ADD_TRAIT(cuffed, TRAIT_NODROP, CUFFED_ITEM_TRAIT)

	RegisterSignals(cuffed, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(on_displaced))
	RegisterSignal(cuffed, COMSIG_ATOM_UPDATE_APPEARANCE, PROC_REF(on_item_update_appearance))
	RegisterSignal(cuffed, COMSIG_ATOM_EXAMINE, PROC_REF(cuffed_reminder))
	RegisterSignal(cuffed, COMSIG_TOPIC, PROC_REF(topic_handler))
	RegisterSignal(cuffed, COMSIG_ITEM_GET_STRIPPABLE_ALT_ACTIONS, PROC_REF(get_strippable_action))
	RegisterSignal(cuffed, COMSIG_ITEM_STRIPPABLE_ALT_ACTION, PROC_REF(do_strippable_action))

	RegisterSignals(cuffs, list(COMSIG_ITEM_EQUIPPED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(on_displaced))
	RegisterSignal(cuffs, COMSIG_ATOM_UPDATE_APPEARANCE, PROC_REF(on_item_update_appearance))

	RegisterSignal(owner, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))

	owner.log_message("bound [src] to themselves with restraints", LOG_GAME)

	return TRUE

/datum/status_effect/cuffed_item/on_remove()
	//Prevent possible recursions from these signals
	UnregisterSignal(cuffed, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	UnregisterSignal(cuffs, list(COMSIG_ITEM_EQUIPPED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

	REMOVE_TRAIT(cuffed, TRAIT_NODROP, CUFFED_ITEM_TRAIT)
	cuffed = null

	if(!QDELETED(cuffs))
		cuffs.on_uncuffed(wearer = owner)
		if(!QDELETED(owner) && cuffs.loc == owner && !(cuffs in owner.get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD)))
			cuffs.forceMove(owner.drop_location())
	cuffs = null

///Called when someone examines the owner twice, so they can know if someone has a cuffed item
/datum/status_effect/cuffed_item/proc/on_examine_more(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_warning("[cuffed.examine_title(user)] is bound to [owner.p_their()] [owner.get_held_index_name(owner.get_held_index_of_item(cuffed))] by [cuffs.examine_title(user)]")

///What happens if one of the items is moved away from the mob
/datum/status_effect/cuffed_item/proc/on_displaced(datum/source)
	SIGNAL_HANDLER
	qdel(src)

///Tell the player that the item is stuck to their hands someway. Also another way to trigger the try_remove_cuffs proc.
/datum/status_effect/cuffed_item/proc/cuffed_reminder(obj/item/item, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	if(user == owner)
		examine_texts += span_notice("[item.p_Theyre()] cuffed to you by \a [cuffs]. You can <a href='byond://?src=[REF(item)];remove_cuffs_item=1'>remove them</a>.")

/// This mainly exists as a fallback in the rare case the alert icon is not reachable (too many alerts?). You should be somewhat able to examine items while blind so all good.
/datum/status_effect/cuffed_item/proc/topic_handler(atom/source, user, href_list)
	SIGNAL_HANDLER

	if(user == owner && href_list["remove_cuffs_item"])
		INVOKE_ASYNC(src, PROC_REF(try_remove_cuffs), user)

/datum/status_effect/cuffed_item/proc/get_strippable_action(obj/item/source, atom/owner, mob/user, list/alt_actions)
	SIGNAL_HANDLER
	alt_actions += "remove_item_cuffs"

/datum/status_effect/cuffed_item/proc/do_strippable_action(obj/item/source, atom/owner, mob/user, action_key)
	SIGNAL_HANDLER
	if(action_key != "remove_item_cuffs")
		return NONE
	if(source != cuffed || !isliving(user))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(try_remove_cuffs), user)
	return COMPONENT_ALT_ACTION_DONE

///The main proc responsible for attempting to remove the hancfuss.
/datum/status_effect/cuffed_item/proc/try_remove_cuffs(mob/living/user)

	var/interaction_key = REF(src)
	if(LAZYACCESS(user.do_afters, interaction_key))
		return FALSE

	if(!(user.mobility_flags & MOBILITY_USE) || (user != owner && !owner.IsReachableBy(user)))
		owner.balloon_alert(user, "can't do it right now!")
		return FALSE

	if(user != owner)
		owner.visible_message(span_notice("[user] tries to remove [cuffs] binding [cuffed] to [owner]"), span_warning("[user] is trying to remove [cuffs] binding [cuffed] to you."))

	owner.balloon_alert(user, "removing cuffs...")
	playsound(owner, cuffs.cuffsound, 30, TRUE, -2)
	if(!do_after(user, cuffs.get_handcuff_time(user) * 1.5, owner, interaction_key = interaction_key) || QDELETED(src))
		owner.balloon_alert(user, "interrupted!")
		return FALSE

	if(user != owner)
		owner.visible_message(span_notice("[user] removes [cuffs] binding [cuffed] to [owner]"), span_warning("[user] removes [cuffs] binding [cuffed] to you."))

	log_combat(user, owner, "removed restraints binding [cuffed] to")

	var/obj/item/restraints/handcuffs/ref_cuffs = cuffs
	ref_cuffs.forceMove(owner.drop_location()) //This will cause the status effect to delete itself, which unsets the 'cuffs' var
	user.put_in_hands(ref_cuffs)
	owner.balloon_alert(user, "cuffs removed from item")

	return TRUE

///Whenever the appearance of one of either cuffed or cuffs is updated, update the alert appearance
/datum/status_effect/cuffed_item/proc/on_item_update_appearance(datum/source)
	SIGNAL_HANDLER
	linked_alert.update_appearance(UPDATE_OVERLAYS)

///The status alert linked to the cuffed_item status effect
/atom/movable/screen/alert/status_effect/cuffed_item
	name = "Cuffed Item"
	desc = "You've an item firmly cuffed to your arm. You probably won't be accidentally dropping it somewhere anytime soon."
	use_user_hud_icon = TRUE
	clickable_glow = TRUE
	click_master = FALSE

/atom/movable/screen/alert/status_effect/cuffed_item/update_overlays()
	. = ..()
	if(!attached_effect)
		return
	var/datum/status_effect/cuffed_item/effect = attached_effect
	. += add_atom_icon(effect.cuffed)
	var/mutable_appearance/cuffs_appearance = add_atom_icon(effect.cuffs)
	cuffs_appearance.transform *= 0.8
	. += cuffs_appearance

/atom/movable/screen/alert/status_effect/cuffed_item/Click(location, control, params)
	. = ..()
	if(.)
		var/datum/status_effect/cuffed_item/effect = attached_effect
		effect?.try_remove_cuffs(owner)
