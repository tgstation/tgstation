///Telekinesis lets you interact with objects from range, and gives you a light blue halo around your head.
/datum/mutation/human/telekinesis
	name = "Telekinesis"
	desc = "A strange mutation that allows the holder to interact with objects through thought."
	quality = POSITIVE
	difficulty = 18
	text_gain_indication = span_notice("You feel smarter!")
	limb_req = BODY_ZONE_HEAD
	instability = POSITIVE_INSTABILITY_MAJOR
	///Typecache of atoms that TK shouldn't interact with
	var/static/list/blacklisted_atoms = typecacheof(list(/atom/movable/screen))

/datum/mutation/human/telekinesis/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/mob/effects/genetics.dmi', "telekinesishead", -MUTATIONS_LAYER))

/datum/mutation/human/telekinesis/on_acquiring(mob/living/carbon/human/homan)
	. = ..()
	if(.)
		return
	RegisterSignal(homan, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))

/datum/mutation/human/telekinesis/on_losing(mob/living/carbon/human/homan)
	. = ..()
	if(.)
		return
	UnregisterSignal(homan, COMSIG_MOB_ATTACK_RANGED)

/datum/mutation/human/telekinesis/get_visual_indicator()
	return visual_indicators[type][1]

///Triggers on COMSIG_MOB_ATTACK_RANGED. Usually handles stuff like picking up items at range.
/datum/mutation/human/telekinesis/proc/on_ranged_attack(mob/source, atom/target)
	SIGNAL_HANDLER
	if(is_type_in_typecache(target, blacklisted_atoms))
		return
	if(!tkMaxRangeCheck(source, target) || source.z != target.z)
		return
	return target.attack_tk(source)

/datum/mutation/human/elastic_arms
	name = "Elastic Arms"
	desc = "Subject's arms have become elastic, allowing them to stretch up to a meter away. However, this elasticity makes it difficult to wear gloves, handle complex tasks, or grab large objects."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MAJOR
	text_gain_indication = span_warning("You feel armstrong!")
	text_lose_indication = span_warning("Your arms stop feeling so saggy all the time.")
	difficulty = 32
	mutation_traits = list(TRAIT_CHUNKYFINGERS, TRAIT_NO_TWOHANDING)

/datum/mutation/human/elastic_arms/on_acquiring(mob/living/carbon/human/homan)
	. = ..()
	if(.)
		return
	RegisterSignal(homan, COMSIG_ATOM_CANREACH, PROC_REF(on_canreach))
	RegisterSignal(homan, COMSIG_LIVING_TRY_PUT_IN_HAND, PROC_REF(on_owner_equipping_item))
	RegisterSignal(homan, COMSIG_LIVING_TRY_PULL, PROC_REF(on_owner_try_pull))

/datum/mutation/human/elastic_arms/on_losing(mob/living/carbon/human/homan)
	. = ..()
	if(.)
		return
	UnregisterSignal(homan, list(COMSIG_ATOM_CANREACH, COMSIG_LIVING_TRY_PUT_IN_HAND, COMSIG_LIVING_TRY_PULL))

/// signal sent when prompting if an item can be equipped
/datum/mutation/human/elastic_arms/proc/on_owner_equipping_item(mob/living/carbon/human/owner, obj/item/pick_item)
	SIGNAL_HANDLER
	if((pick_item.w_class > WEIGHT_CLASS_BULKY) && !(pick_item.item_flags & ABSTRACT|HAND_ITEM)) // cant decide if i should limit to huge or bulky.
		pick_item.balloon_alert(owner, "arms too floppy to wield!")
		return COMPONENT_LIVING_CANT_PUT_IN_HAND

/// signal sent when owner tries to pull
/datum/mutation/human/elastic_arms/proc/on_owner_try_pull(mob/living/carbon/owner, atom/movable/target, force)
	SIGNAL_HANDLER
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.mob_size > MOB_SIZE_HUMAN)
			living_target.balloon_alert(owner, "arms too floppy to pull this!")
			return COMSIG_LIVING_CANCEL_PULL
	if(isitem(target))
		var/obj/item/item_target = target
		if(item_target.w_class > WEIGHT_CLASS_BULKY)
			item_target.balloon_alert(owner, "arms too floppy to pull this!")
			return COMSIG_LIVING_CANCEL_PULL

// probably buggy. let's enlist our players as bug testers
/datum/mutation/human/elastic_arms/proc/on_canreach(mob/source, atom/target)
	SIGNAL_HANDLER

	var/distance = get_dist(target, source)

	// We only care about handling the reach distance, anything closer or further is handled normally.
	// Also, no z-level shenanigans. Yet.
	if((distance != 2) || source.z != target.z)
		return

	var/direction = get_dir(source, target)
	if(!direction)
		return
	var/turf/open/adjacent_turf = get_step(source, direction)

	// Make sure it's an open turf we're trying to pass over.
	if(!istype(adjacent_turf))
		return

	// Check if there's something dense inbetween, then allow it.
	for(var/atom/thing in adjacent_turf)
		if(thing.density)
			return

	return COMPONENT_ALLOW_REACH
