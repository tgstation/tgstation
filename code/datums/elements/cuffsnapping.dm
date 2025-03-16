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

/datum/element/cuffsnapping/proc/add_item_context(obj/item/source, list/context, mob/living/carbon/target, mob/living/user)
	SIGNAL_HANDLER
	if(!iscarbon(target) || !target.handcuffed)
		return NONE
	context[SCREENTIP_CONTEXT_RMB] = "Cut Restraints"
	return CONTEXTUAL_SCREENTIP_SET

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

/datum/element/cuffsnapping/proc/try_cuffsnap_target(obj/item/cutter, mob/living/carbon/target, mob/living/cutter_user, list/modifiers)
	SIGNAL_HANDLER

	if(!istype(target)) //we aren't the kind of mob that can even have cuffs, so we skip.
		return

	if(!target.handcuffed)
		return

	var/obj/item/restraints/handcuffs/cuffs = target.handcuffed

	if(!istype(cuffs))
		return

	if(cuffs.restraint_strength && isnull(src.snap_time_strong))
		cutter_user.visible_message(span_notice("[cutter_user] tries to cut through [target]'s restraints with [cutter], but fails!"))
		playsound(source = get_turf(cutter), soundin = cutter.usesound ? cutter.usesound : cutter.hitsound, vol = cutter.get_clamped_volume(), vary = TRUE)
		return COMPONENT_SKIP_ATTACK

	else if(isnull(src.snap_time_weak))
		cutter_user.visible_message(span_notice("[cutter_user] tries to cut through [target]'s restraints with [cutter], but fails!"))
		playsound(source = get_turf(cutter), soundin = cutter.usesound ? cutter.usesound : cutter.hitsound, vol = cutter.get_clamped_volume(), vary = TRUE)
		return COMPONENT_SKIP_ATTACK

	. = COMPONENT_SKIP_ATTACK

	INVOKE_ASYNC(src, PROC_REF(do_cuffsnap_target), cutter, target, cutter_user, cuffs)

/datum/element/cuffsnapping/proc/do_cuffsnap_target(obj/item/cutter, mob/living/carbon/target, mob/cutter_user, obj/item/restraints/handcuffs/cuffs)
	if(LAZYACCESS(cutter_user.do_afters, cutter))
		return

	log_combat(cutter_user, target, "cut or tried to cut [target]'s cuffs", cutter)

	var/snap_time = src.snap_time_weak
	if(cuffs.restraint_strength)
		snap_time = src.snap_time_strong

	if(snap_time == 0 || do_after(cutter_user, snap_time, target, interaction_key = cutter)) // If 0 just do it. This to bypass the do_after() creating a needless progress bar.
		cutter_user.do_attack_animation(target, used_item = cutter)
		cutter_user.visible_message(span_notice("[cutter_user] cuts [target]'s restraints with [cutter]!"))
		qdel(target.handcuffed)
		playsound(source = get_turf(cutter), soundin = cutter.usesound ? cutter.usesound : cutter.hitsound, vol = cutter.get_clamped_volume(), vary = TRUE)

	return
