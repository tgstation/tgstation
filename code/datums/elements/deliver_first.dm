/**
 * # deliver first element!
 *
 * bespoke element (1 per set of specific arguments in existence) that makes crates unable to be sold UNTIL they are opened once (to where this element, and the block, are removed)
 * Used for non-cargo orders to not get turned into a quick buck
 */
/datum/element/deliver_first
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	///typepath of the area we will be allowed to be opened in
	var/goal_area_type
	///how much is earned on delivery of the crate
	var/payment

/datum/element/deliver_first/Attach(datum/target, goal_area_type, payment)
	. = ..()
	if(!istype(target, /obj/structure/closet))
		return ELEMENT_INCOMPATIBLE
	src.goal_area_type = goal_area_type
	src.payment = payment
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(target, COMSIG_AREA_ENTERED, .proc/on_area_enter)
	RegisterSignal(target, COMSIG_ATOM_EMAG_ACT, .proc/on_emag)
	RegisterSignal(target, COMSIG_CLOSET_POST_OPEN, .proc/on_post_open)
	ADD_TRAIT(target, TRAIT_BANNED_FROM_CARGO_SHUTTLE, src)
	//registers pre_open when appropriate
	area_check(target)

/datum/element/deliver_first/Detach(datum/target)
	. = ..()
	REMOVE_TRAIT(target, TRAIT_BANNED_FROM_CARGO_SHUTTLE, src)
	UnregisterSignal(target, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_AREA_ENTERED,
		COMSIG_AREA_ENTERED,
		COMSIG_CLOSET_PRE_OPEN,
		COMSIG_CLOSET_POST_OPEN,
	))

///signal sent from examining target
/datum/element/deliver_first/proc/on_examine(obj/structure/closet/target, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("An electronic delivery lock prevents this from opening until it reaches its destination, [GLOB.areas_by_type[goal_area_type]].")
	examine_list += span_warning("This crate cannot be sold until it is opened.")

///registers the signal that blocks target from opening when outside of the valid area.
/datum/element/deliver_first/proc/area_check(obj/structure/closet/target)
	if(get_area(target) == GLOB.areas_by_type[goal_area_type])
		UnregisterSignal(target, COMSIG_CLOSET_PRE_OPEN)
	else
		RegisterSignal(target, COMSIG_CLOSET_PRE_OPEN, .proc/on_pre_open)

/datum/element/deliver_first/proc/on_area_enter(obj/structure/closet/target, atom/movable/arrived, area/old_area)
	SIGNAL_HANDLER
	area_check(target)

/datum/element/deliver_first/proc/on_emag(obj/structure/closet/target, mob/emagger)
	SIGNAL_HANDLER
	emagger.balloon_alert(emagger, "delivery lock bypassed")
	target.RemoveElement(/datum/element/deliver_first)
	playsound(target, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

///signal called before opening target, blocks opening
/datum/element/deliver_first/proc/on_pre_open(obj/structure/closet/target, mob/living/user, force)
	SIGNAL_HANDLER
	if(force)
		return
	if(user)
		target.balloon_alert(user, "access denied until delivery!")
	playsound(target, 'sound/machines/buzz-two.ogg', 30, TRUE)
	return BLOCK_OPEN

///signal called by successfully opening target
/datum/element/deliver_first/proc/on_post_open(obj/structure/closet/target, force)
	SIGNAL_HANDLER
	//noice, delivered!
	var/datum/bank_account/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo_account.adjust_money(payment)
	target.RemoveElement(/datum/element/deliver_first)
