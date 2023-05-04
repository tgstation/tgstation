/**
 * cuffsnapping element replaces the item's secondary attack with an aimed attack at the kneecaps under certain circumstances.
 *
 * Element is incompatible with non-items. Requires the parent item to have a force equal to or greater than WOUND_MINIMUM_DAMAGE.
 * Also requires that the parent can actually get past pre_secondary_attack without the attack chain cancelling.
 *
 * cuffsnapping attacks have a wounding bonus between severe and critical+10 wound thresholds. Without some serious wound protecting
 * armour this all but guarantees a wound of some sort. The attack is directed specifically at a limb and the limb takes the damage.
 *
 * Requires the cutter_user to be aiming for either leg zone, which will be targetted specifically. They will than have a 3-second long
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

/datum/element/cuffsnapping // let bos cutters paeper cutters and etc do it too
	/// If not null, can snap cable restraints and similar.
	var/snap_time_weak = 0 SECONDS
	/// If not null, can snap handcuffs.
	var/snap_time_strong = null

/datum/element/cuffsnapping/Attach(datum/target, snap_time_weak = 0 SECONDS, snap_time_strong = null)
	. = ..()

	if(!isitem(target))
		stack_trace("cuffsnapping element added to non-item object: \[[target]\]")
		return ELEMENT_INCOMPATIBLE

	var/obj/item/target_item = target

	src.snap_time_weak = snap_time_weak
	src.snap_time_strong = snap_time_strong

	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(examine))
	RegisterSignal(target, COMSIG_ITEM_ATTACK , PROC_REF(try_cuffsnap_target))

/datum/element/cuffsnapping/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_EXAMINE))

	return ..()

///signal called on parent being examined
/datum/element/cuffsnapping/proc/on_examine(datum/target, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!isnull(snap_time_weak) && !isnull(snap_time_strong))
xxx
	examine_list += span_notice

/**
 * Signal handler for COMSIG_ITEM_ATTACK_SECONDARY. Does checks for pacifism, zones and target state before either returning nothing
 * if the special attack could not be attempted, performing the ordinary attack procs instead - Or cancelling the attack chain if
 * the attack can be started.
 */
/datum/element/cuffsnapping/proc/try_cuffsnap_target(obj/item/source, mob/living/carbon/target, mob/cutter_user, params)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return

	if(!target.handcuffed)
		return

	var/obj/item/restraints/handcuffs/cuffs = attacked_carbon.handcuffed

	if(!istype(cuffs))
		return

	if(cuffs.restraint_strength == HANDCUFFS_TYPE_STRONG && isnull(src.snap_strength))
		user.visible_message(span_notice("[user] tries to cut through [target]'s restraints with [src], but fails!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	. = COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(do_cuffsnap_target), source, target, cutter_user)

/datum/element/cuffsnapping/proc/do_kneecap_target(obj/item/cutter, mob/living/carbon/target, mob/cutter_user)
	if(LAZYACCESS(cutter_user.do_afters, cutter))
		return

	log_combat(cutter_user, target, "cut or tried to cut [target]'s cuffs", cutter)

	var/snap_time = src.snap_time_weak
	if(cuffs.restraint_strength != HANDCUFFS_TYPE_WEAK)
		snap_time = src.snap_time_strong

	if(do_after(cutter_user, snap_time, target, interaction_key = cutter))
		cutter_user.do_attack_animation(target, used_item = cutter)
		user.visible_message(span_notice("[user] cuts [target]'s restraints with [src]!"))
		qdel(target.handcuffed)
		playsound(source = get_turf(cutter), soundin = cutter.hitsound, vol = cutter.get_clamped_volume(), vary = TRUE)

	return
