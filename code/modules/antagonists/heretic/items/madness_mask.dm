#define INFINITE_DURATION TRUE

// The spooky "void" / "abyssal" / "madness" mask for heretics.
/obj/item/clothing/mask/madness_mask
	name = "Abyssal Mask"
	desc = "A mask created from the suffering of existance. Looking down it's eyes, you notice something gazing back at you."
	icon_state = "mad_mask"
	inhand_icon_state = "mad_mask"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	///Who is wearing this
	var/mob/living/carbon/human/local_user

/obj/item/clothing/mask/madness_mask/Destroy()
	local_user = null
	return ..()

/obj/item/clothing/mask/madness_mask/examine(mob/user)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		. += span_notice("Actively drains the sanity and stamina of nearby non-heretics when worn.")
		. += span_notice("If forced onto the face of a non-heretic, they will be unable to remove it willingly.")
	else
		. += span_danger("The eyes fill you with dread... You best avoid it.")

/obj/item/clothing/mask/madness_mask/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_MASK)
		return
	if(!ishuman(user) || !user.mind)
		return

	local_user = user
	START_PROCESSING(SSobj, src)

	if(IS_HERETIC_OR_MONSTER(user))
		return

	user.add_mood_event("abyssal_mask", /datum/mood_event/abyssal_mask, INFINITE_DURATION)

	ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	to_chat(user, span_userdanger("[src] clamps tightly to your face as you feel your soul draining away!"))

/obj/item/clothing/mask/madness_mask/dropped(mob/living/carbon/human/user)
	local_user = null
	STOP_PROCESSING(SSobj, src)
	REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	
	if(ishuman(user))
		user.clear_mood_event("abyssal_mask")

	return ..()

/obj/item/clothing/mask/madness_mask/process(delta_time)
	if(!local_user)
		return PROCESS_KILL

	if(IS_HERETIC_OR_MONSTER(local_user) && HAS_TRAIT(src, TRAIT_NODROP))
		REMOVE_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

	for(var/mob/living/carbon/human/human_in_range in view(local_user))
		if(IS_HERETIC_OR_MONSTER(human_in_range))
			continue
		if(human_in_range.is_blind())
			continue

		var/obj/item/clothing/mask/madness_mask/abyssal_mask = human_in_range.get_item_by_slot(ITEM_SLOT_MASK)
		var/is_wearing_mask = istype(abyssal_mask)
		human_in_range.add_mood_event("abyssal_mask", /datum/mood_event/abyssal_mask, is_wearing_mask)

		if(DT_PROB(60, delta_time))
			human_in_range.hallucination = min(human_in_range.hallucination + 5, 120)

		if(DT_PROB(40, delta_time))
			human_in_range.set_timed_status_effect(10 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)

		if(human_in_range.getStaminaLoss() <= 85 && DT_PROB(30, delta_time))
			human_in_range.emote(pick("giggle", "laugh"))
			human_in_range.adjustStaminaLoss(10)

		if(DT_PROB(25, delta_time))
			human_in_range.set_timed_status_effect(10 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)

#undef INFINITE_DURATION
