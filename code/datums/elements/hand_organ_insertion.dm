/datum/element/hand_organ_insertion
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	var/insertion_time = 0 SECONDS

/datum/element/hand_organ_insertion/Attach(datum/target, insertion_time = 5 SECONDS)
	. = ..()
	if (!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	src.insertion_time = insertion_time

	RegisterSignal(target, COMSIG_USER_ITEM_INTERACTION_SECONDARY, PROC_REF(on_item_interaction_secondary))

/datum/element/hand_organ_insertion/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_USER_ITEM_INTERACTION_SECONDARY)

/datum/element/hand_organ_insertion/proc/on_item_interaction_secondary(mob/living/carbon/parent, atom/target, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if (target != parent)
		return FALSE
	if (!isorgan(tool))
		return FALSE

	INVOKE_ASYNC(src, PROC_REF(attempt_to_insert_organ), parent, tool)
	return TRUE

/datum/element/hand_organ_insertion/proc/attempt_to_insert_organ(mob/living/carbon/user, obj/item/organ/organ)
	if (!can_insert_organ(user, organ, feedback = TRUE))
		return

	var/zone_name = user.parse_zone_with_bodypart(organ.zone)

	user.visible_message(
		message = span_danger("\The [user] begin[user.p_s()] inserting \the [organ] into [user.p_their()] [zone_name]!"),
		self_message = span_danger("You begin inserting \the [organ] into your [zone_name]!"),
		blind_message = span_hear("You hear squelching!")
	)

	user.balloon_alert(user, "inserting...")

	playsound(user, 'sound/items/handling/surgery/organ2.ogg', vol = 80, vary = TRUE, ignore_walls = FALSE)

	if (!do_after(user, insertion_time, extra_checks = CALLBACK(src, PROC_REF(can_insert_organ), user, organ)))
		user.balloon_alert(user, "interrupted!")
		return

	zone_name = user.parse_zone_with_bodypart(organ.zone)

	user.visible_message(
		message = span_danger("\The [user] insert[user.p_s()] \the [organ] into [user.p_their()] [zone_name]!"),
		self_message = span_danger("You insert \the [organ] into your [zone_name]!"),
		blind_message = span_hear("You hear a loud, final squelch!")
	)

	user.balloon_alert(user, "inserted!")

	playsound(user, 'sound/items/handling/surgery/organ1.ogg', vol = 80, vary = TRUE, ignore_walls = FALSE)

	user.temporarilyRemoveItemFromInventory(organ, force = TRUE)
	organ.Insert(user)
	organ.on_surgical_insertion(user, user, organ.zone, organ)

/datum/element/hand_organ_insertion/proc/can_insert_organ(mob/living/carbon/user, obj/item/organ/organ, feedback = FALSE)
	if (!user.get_bodypart(deprecise_zone(organ.zone)))
		user.balloon_alert(user, "you don't have a [parse_zone(organ.zone)]!")
		return FALSE

	var/obj/item/organ/existing_organ = user.get_organ_slot(organ.slot)
	if (existing_organ)
		user.balloon_alert(user, "your [existing_organ] [existing_organ.p_are()] in the way!")
		return FALSE

	if (!organ.pre_surgical_insertion(user, user, organ.zone))
		user.balloon_alert(user, "failed!")
		return FALSE
	if (!organ.useable)
		user.balloon_alert(user, "unusable!")
		return FALSE
	return TRUE
