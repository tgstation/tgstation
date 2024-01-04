///Tail parent, it doesn't do very much.
/obj/item/organ/external/tail
	name = "tail"
	desc = "A severed tail. What did you cut this off of?"
	icon_state = "severedtail"

	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_EXTERNAL_TAIL

	dna_block = DNA_TAIL_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	// defaults to cat, but the parent type shouldn't be created regardless
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/cat

	///Does this tail have a wagging sprite, and is it currently wagging?
	var/wag_flags = NONE
	///The original owner of this tail
	var/original_owner //Yay, snowflake code!
	///The overlay for tail spines, if any
	var/datum/bodypart_overlay/mutant/tail_spines/tail_spines_overlay

/obj/item/organ/external/tail/Insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	if(.)
		RegisterSignal(receiver, COMSIG_ORGAN_WAG_TAIL, PROC_REF(wag))
		original_owner ||= WEAKREF(receiver)

		receiver.clear_mood_event("tail_lost")
		receiver.clear_mood_event("tail_balance_lost")

		if(IS_WEAKREF_OF(receiver, original_owner))
			receiver.clear_mood_event("wrong_tail_regained")
		else if(type in receiver.dna.species.external_organs)
			receiver.add_mood_event("wrong_tail_regained", /datum/mood_event/tail_regained_wrong)

/obj/item/organ/external/tail/on_bodypart_insert(obj/item/bodypart/bodypart)
	var/obj/item/organ/external/spines/our_spines = bodypart.owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_SPINES)
	if(our_spines)
		try_insert_tail_spines(bodypart)
	return ..()

/obj/item/organ/external/tail/on_bodypart_remove(obj/item/bodypart/bodypart)
	remove_tail_spines(bodypart)
	return ..()

/// If the owner has spines and an appropriate overlay exists, add a tail spines overlay.
/obj/item/organ/external/tail/proc/try_insert_tail_spines(obj/item/bodypart/bodypart)
	// Don't insert another overlay if there already is one.
	if(tail_spines_overlay)
		return
	// If this tail doesn't have a valid set of tail spines, don't insert them
	var/datum/sprite_accessory/tails/tail_sprite_datum = bodypart_overlay.sprite_datum
	if(!istype(tail_sprite_datum))
		return
	var/tail_spine_key = tail_sprite_datum.spine_key
	if(!tail_spine_key)
		return

	tail_spines_overlay = new
	tail_spines_overlay.tail_spine_key = tail_spine_key
	var/feature_name = bodypart.owner.dna.features["spines"] //tail spines don't live in DNA, but share feature names with regular spines
	tail_spines_overlay.set_appearance_from_name(feature_name)
	bodypart.add_bodypart_overlay(tail_spines_overlay)

/// If we have a tail spines overlay, delete it
/obj/item/organ/external/tail/proc/remove_tail_spines(obj/item/bodypart/bodypart)
	if(!tail_spines_overlay)
		return
	bodypart.remove_bodypart_overlay(tail_spines_overlay)
	QDEL_NULL(tail_spines_overlay)

/obj/item/organ/external/tail/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()

	if(wag_flags & WAG_WAGGING)
		wag(organ_owner, start = FALSE)

	UnregisterSignal(organ_owner, COMSIG_ORGAN_WAG_TAIL)

	if(type in organ_owner.dna.species.external_organs)
		organ_owner.add_mood_event("tail_lost", /datum/mood_event/tail_lost)
		organ_owner.add_mood_event("tail_balance_lost", /datum/mood_event/tail_balance_lost)

/obj/item/organ/external/tail/proc/wag(mob/living/carbon/organ_owner, start = TRUE, stop_after = 0)
	if(!(wag_flags & WAG_ABLE))
		return

	if(start)
		if(start_wag(organ_owner) && stop_after)
			addtimer(CALLBACK(src, PROC_REF(wag), organ_owner, FALSE), stop_after, TIMER_STOPPABLE|TIMER_DELETE_ME)
	else
		stop_wag(organ_owner)

///We need some special behaviour for accessories, wrapped here so we can easily add more interactions later
/obj/item/organ/external/tail/proc/start_wag(mob/living/carbon/organ_owner)
	if(wag_flags & WAG_WAGGING) // we are already wagging
		return FALSE
	if(organ_owner.stat == DEAD || organ_owner != owner) // no wagging when owner is dead or tail has been disembodied
		return FALSE

	var/datum/bodypart_overlay/mutant/tail/accessory = bodypart_overlay
	wag_flags |= WAG_WAGGING
	accessory.wagging = TRUE
	if(tail_spines_overlay) //if there are spines, they should wag with the tail
		tail_spines_overlay.wagging = TRUE
	organ_owner.update_body_parts()
	RegisterSignal(organ_owner, COMSIG_LIVING_DEATH, PROC_REF(stop_wag))
	return TRUE

///We need some special behaviour for accessories, wrapped here so we can easily add more interactions later
/obj/item/organ/external/tail/proc/stop_wag(mob/living/carbon/organ_owner)
	SIGNAL_HANDLER

	var/datum/bodypart_overlay/mutant/tail/accessory = bodypart_overlay
	wag_flags &= ~WAG_WAGGING
	accessory.wagging = FALSE
	if(tail_spines_overlay) //if there are spines, they should stop wagging with the tail
		tail_spines_overlay.wagging = FALSE
	if(isnull(organ_owner))
		return

	organ_owner.update_body_parts()
	UnregisterSignal(organ_owner, COMSIG_LIVING_DEATH)

///Tail parent type, with wagging functionality
/datum/bodypart_overlay/mutant/tail
	layers = EXTERNAL_FRONT|EXTERNAL_BEHIND
	var/wagging = FALSE

/datum/bodypart_overlay/mutant/tail/get_base_icon_state()
	return (wagging ? "wagging_" : "") + sprite_datum.icon_state //add the wagging tag if we be wagging

/datum/bodypart_overlay/mutant/tail/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE
	return TRUE

/obj/item/organ/external/tail/cat
	name = "tail"
	preference = "feature_human_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/cat

	wag_flags = WAG_ABLE

///Cat tail bodypart overlay
/datum/bodypart_overlay/mutant/tail/cat
	feature_key = "tail_cat"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/tail/cat/get_global_feature_list()
	return GLOB.tails_list_human

/obj/item/organ/external/tail/monkey
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/monkey

///Monkey tail bodypart overlay
/datum/bodypart_overlay/mutant/tail/monkey
	color_source = NONE
	feature_key = "tail_monkey"

/datum/bodypart_overlay/mutant/tail/monkey/get_global_feature_list()
	return GLOB.tails_list_monkey

/obj/item/organ/external/tail/lizard
	name = "lizard tail"
	desc = "A severed lizard tail. Somewhere, no doubt, a lizard hater is very pleased with themselves."
	preference = "feature_lizard_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/lizard

	wag_flags = WAG_ABLE
	dna_block = DNA_LIZARD_TAIL_BLOCK

///Lizard tail bodypart overlay datum
/datum/bodypart_overlay/mutant/tail/lizard
	feature_key = "tail_lizard"

/datum/bodypart_overlay/mutant/tail/lizard/get_global_feature_list()
	return GLOB.tails_list_lizard

/obj/item/organ/external/tail/lizard/fake
	name = "fabricated lizard tail"
	desc = "A fabricated severed lizard tail. This one's made of synthflesh. Probably not usable for lizard wine."

///Bodypart overlay for tail spines. Handled by the tail - has no actual organ associated.
/datum/bodypart_overlay/mutant/tail_spines
	layers = EXTERNAL_ADJACENT|EXTERNAL_BEHIND
	feature_key = "tailspines"
	///Spines wag when the tail does
	var/wagging = FALSE
	/// Key for tail spine states, depends on the shape of the tail. Defined in the tail sprite datum.
	var/tail_spine_key = NONE

/datum/bodypart_overlay/mutant/tail_spines/get_global_feature_list()
	return GLOB.tail_spines_list

/datum/bodypart_overlay/mutant/tail_spines/get_base_icon_state()
	return (!isnull(tail_spine_key) ? "[tail_spine_key]_" : "") + (wagging ? "wagging_" : "") + sprite_datum.icon_state // Select the wagging state if appropriate

/datum/bodypart_overlay/mutant/tail_spines/can_draw_on_bodypart(mob/living/carbon/human/human)
	. = ..()
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE
