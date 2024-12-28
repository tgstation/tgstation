/**
 * # deliver first element!
 *
 * bespoke element (1 per set of specific arguments in existence) that makes crates unable to be sold UNTIL they are opened once (to where this element, and the block, are removed)
 * Used for non-cargo orders to not get turned into a quick buck
 *
 * for the future coders or just me: please convert this into a component to allow for more feedback on the crate's status (clicking when unlocked, overlays, etc)
 */

#define DENY_SOUND_COOLDOWN (2 SECONDS)
/datum/element/deliver_first
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///typepath of the area we will be allowed to be opened in
	var/goal_area_type
	///how much is earned on delivery of the crate
	var/payment
	///cooldown for the deny sound
	COOLDOWN_DECLARE(deny_cooldown)

/datum/element/deliver_first/Attach(datum/target, goal_area_type, payment)
	. = ..()
	if(!istype(target, /obj/structure/closet))
		return ELEMENT_INCOMPATIBLE
	src.goal_area_type = goal_area_type
	src.payment = payment
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(target, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))
	RegisterSignal(target, COMSIG_CLOSET_POST_OPEN, PROC_REF(on_post_open))
	ADD_TRAIT(target, TRAIT_BANNED_FROM_CARGO_SHUTTLE, REF(src))
	//registers pre_open when appropriate
	area_check(target)

/datum/element/deliver_first/Detach(datum/target)
	. = ..()
	REMOVE_TRAIT(target, TRAIT_BANNED_FROM_CARGO_SHUTTLE, REF(src))
	UnregisterSignal(target, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_EMAG_ACT,
		COMSIG_CLOSET_PRE_OPEN,
		COMSIG_CLOSET_POST_OPEN,
	))

///signal sent from examining target
/datum/element/deliver_first/proc/on_examine(obj/structure/closet/target, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("An electronic delivery lock prevents this from opening until it reaches its destination, [GLOB.areas_by_type[goal_area_type]].")
	examine_list += span_warning("This crate cannot be sold until it is opened.")

///registers the signal that blocks target from opening when outside of the valid area, returns if it is now unlocked
/datum/element/deliver_first/proc/area_check(obj/structure/closet/target)
	var/area/target_area = get_area(target)
	if(target_area.type == goal_area_type)
		UnregisterSignal(target, COMSIG_CLOSET_PRE_OPEN)
		return TRUE
	else
		RegisterSignal(target, COMSIG_CLOSET_PRE_OPEN, PROC_REF(on_pre_open), override = TRUE) //very purposefully overriding
		return FALSE

/datum/element/deliver_first/proc/on_moved(obj/structure/closet/target, atom/oldloc, direction)
	SIGNAL_HANDLER
	area_check(target)

/datum/element/deliver_first/proc/on_emag(obj/structure/closet/target, mob/emagger)
	SIGNAL_HANDLER
	emagger.balloon_alert(emagger, "delivery lock bypassed")
	remove_lock(target)

///signal called before opening target, blocks opening
/datum/element/deliver_first/proc/on_pre_open(obj/structure/closet/target, mob/living/user, force)
	SIGNAL_HANDLER
	if(force)
		return
	if(istype(target, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/opening_crate = target
		if(opening_crate.manifest) //we don't want to send feedback if they're just tearing off the manifest
			return BLOCK_OPEN
	if(user)
		target.balloon_alert(user, "access denied until delivery!")
	if(COOLDOWN_FINISHED(src, deny_cooldown))
		playsound(target, 'sound/machines/buzz/buzz-two.ogg', 30, TRUE)
		COOLDOWN_START(src, deny_cooldown, DENY_SOUND_COOLDOWN)
	return BLOCK_OPEN

///signal called by successfully opening target
/datum/element/deliver_first/proc/on_post_open(obj/structure/closet/target, mob/living/user, force)
	SIGNAL_HANDLER
	if(area_check(target))
		//noice, delivered!
		var/datum/bank_account/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
		cargo_account.adjust_money(payment)
	remove_lock(target)

///called to remove the element in a flavorful way, either from delivery or from emagging/breaking open the crate
/datum/element/deliver_first/proc/remove_lock(obj/structure/closet/target)
	target.visible_message(span_notice("[target]'s delivery lock self destructs, spewing sparks from the mechanism!"))
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(4, 0, target.loc)
	spark_system.start()
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	target.RemoveElement(/datum/element/deliver_first, goal_area_type, payment)

#undef DENY_SOUND_COOLDOWN
