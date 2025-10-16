/**
 * cuffsnapping element replaces the item's secondary attack with an aimed attack at the kneecaps under certain circumstances.
 *
 * Element is incompatible with non-items. Requires the parent item to have a force equal to or greater than WOUND_MINIMUM_DAMAGE.
 * Also requires that the parent can actually get past pre_secondary_attack without the attack chain cancelling.
 *
 * cuffsnapping attacks have a wounding bonus between severe and critical+10 wound thresholds. Without some serious wound protecting
 * armour this all but guarantees a wound of some sort. The attack is directed specifically at a limb and the limb takes the damage.
 *
 * Requires the cutter_user to be aiming for either leg zone, which will be targeted specifically. They will than have a 3-second long
 * do_after before executing the attack.
 *
 * cuffsnapping requires the target to either be on the floor, immobilised or buckled to something. And also to have an appropriate leg.
 *
 * Passing all the checks will cancel the entire attack chain.
 */

/**
 * Cuffsnapping element! When added to an item allows it to attempt to break cuffs.
 * Depending on certain parameters and variables it might only be able to cut through cable, or take time, etc.
 *
 * Element is only compatible with items.
 */

/datum/element/cuffsnapping
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2 // let bos cutters paeper cutters and etc do it too
	/// If not null, can snap cable restraints and similar.
	var/snap_time_weak = 0 SECONDS
	/// If not null, can snap handcuffs.
	var/snap_time_strong = null
	/// Note: As of time of writing (5/9/23) it takes 4 seconds to manually remove handcuffs. Anything above that value is a waste of time.

/datum/element/cuffsnapping/Attach(datum/target, snap_time_weak = 0 SECONDS, snap_time_strong = null)
	. = ..()

	if(!isitem(target))
		stack_trace("cuffsnapping element added to non-item object: \[[target]\]")
		return ELEMENT_INCOMPATIBLE

	src.snap_time_weak = snap_time_weak
	src.snap_time_strong = snap_time_strong

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SECONDARY, PROC_REF(try_cuffsnap_target))
	RegisterSignal(target, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_item_context))

/datum/element/cuffsnapping/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ITEM_ATTACK_SECONDARY, COMSIG_ATOM_EXAMINE, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET))
	return ..()

/datum/element/cuffsnapping/proc/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	SIGNAL_HANDLER
	if(!isliving(target)) //Removing restraints takes precedence
		return NONE
	var/mob/living/living_target = target
	if(iscarbon(living_target))
		var/mob/living/carbon/carbon_target = living_target
		if(carbon_target.handcuffed)
			context[SCREENTIP_CONTEXT_RMB] = "Cut Restraints"
			return CONTEXTUAL_SCREENTIP_SET
	if(living_target.has_status_effect(/datum/status_effect/cuffed_item))
		context[SCREENTIP_CONTEXT_RMB] = "Remove Binds From Item"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

///signal called on parent being examined
/datum/element/cuffsnapping/proc/on_examine(datum/target, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/examine_string
	if(isnull(snap_time_weak))
		return
	examine_string = "It looks like it could be used to cut zipties or cable restraints off someone in [snap_time_weak] seconds"

	if(!isnull(snap_time_strong))
		examine_string += ", and handcuffs in [snap_time_strong] seconds."
	else
		examine_string += "."

	examine_list += span_notice(examine_string)

///Signal called on parent when it right-clicks another mob.
/datum/element/cuffsnapping/proc/try_cuffsnap_target(obj/item/cutter, mob/living/target, mob/living/cutter_user, list/modifiers)
	SIGNAL_HANDLER

	if(LAZYACCESS(cutter_user.do_afters, cutter))
		return

	var/mob/living/carbon/carbon_target = target
	if(!istype(carbon_target) || !carbon_target.handcuffed)
		var/datum/status_effect/cuffed_item/cuffed_status = target.has_status_effect(/datum/status_effect/cuffed_item)
		if(!cuffed_status)
			return NONE
		INVOKE_ASYNC(src, PROC_REF(try_cuffsnap_item), cutter, target, cutter_user, cuffed_status.cuffed, cuffed_status.cuffs)
		return COMPONENT_SKIP_ATTACK

	var/obj/item/restraints/handcuffs/cuffs = carbon_target.handcuffed

	if(!istype(cuffs))
		return NONE

	if(check_cuffs_strength(carbon_target, target, cutter_user, cuffs, span_notice("[cutter_user] tries to cut through [target]'s restraints with [cutter], but fails!")))
		INVOKE_ASYNC(src, PROC_REF(do_cuffsnap_target), cutter, target, cutter_user, cuffs)

	return COMPONENT_SKIP_ATTACK

///Check that the type of restraints can be cut by this element.
/datum/element/cuffsnapping/proc/check_cuffs_strength(obj/item/cutter, mob/living/target, mob/living/cutter_user, obj/item/restraints/handcuffs/cuffs, message)
	if(cuffs.restraint_strength ? snap_time_strong : snap_time_weak)
		return TRUE
	cutter_user.visible_message(message)
	playsound(source = get_turf(cutter), soundin = cutter.usesound || cutter.hitsound, vol = cutter.get_clamped_volume(), vary = TRUE)
	return FALSE

///Called when a player tries to remove the cuffs restraining another mob.
/datum/element/cuffsnapping/proc/do_cuffsnap_target(obj/item/cutter, mob/living/carbon/target, mob/cutter_user, obj/item/restraints/handcuffs/cuffs)
	if(LAZYACCESS(cutter_user.do_afters, cutter))
		return
	log_combat(cutter_user, target, "cut or tried to cut [target]'s cuffs", cutter)

	do_snip_snap(cutter, target, cutter_user, cuffs, span_notice("[cutter_user] cuts [target]'s restraints with [cutter]!"))

///Called when a player tries to remove the cuffs binding an item to their owner
/datum/element/cuffsnapping/proc/try_cuffsnap_item(obj/item/cutter, mob/living/target, mob/living/cutter_user, obj/item/cuffed, obj/item/restraints/handcuffs/cuffs)
	if(check_cuffs_strength(cutter, target, cutter_user, cuffs, span_notice("[cutter_user] tries to cut through the restraints binding [cuffed] to [target], but fails!")))
		return

	log_combat(cutter_user, target, "cut or tried to cut restraints binding [cuffed] to")

	do_snip_snap(cutter, target, cutter_user, cuffs, span_notice("[cutter_user] cuts the restraints binding [src] to [target] with [cutter]!"))

///The proc responsible for the very timed action that deletes the cuffs
/datum/element/cuffsnapping/proc/do_snip_snap(obj/item/cutter, mob/living/target, mob/cutter_user, obj/item/restraints/handcuffs/cuffs, message)
	var/snap_time = cuffs.restraint_strength ? snap_time_strong : snap_time_weak

	var/target_was_restrained = FALSE
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		target_was_restrained = carbon_target.handcuffed

	if(snap_time)
		if(!do_after(cutter_user, snap_time, target, interaction_key = cutter)) // If 0 just do it. This to bypass the do_after() creating a needless progress bar.
			return
		if(target_was_restrained) //Removing restraints takes priority over cuffed items. This only applies for carbon mobs, but we need to make sure the restraints are still the same.
			var/mob/living/carbon/carbon_target = target
			if(carbon_target.handcuffed != cuffs)
				return

	cutter_user.do_attack_animation(target, used_item = cutter)
	cutter_user.visible_message(message)
	qdel(cuffs)
	playsound(source = get_turf(cutter), soundin = cutter.usesound || cutter.hitsound, vol = cutter.get_clamped_volume(), vary = TRUE)
