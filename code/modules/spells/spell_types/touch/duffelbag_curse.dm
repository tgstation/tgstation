
/datum/action/cooldown/spell/touch/duffelbag
	name = "Bestow Cursed Duffel Bag"
	desc = "A spell that summons a duffel bag demon on the target, slowing them down and slowly eating them."
	button_icon_state = "duffelbag_curse"
	sound = 'sound/effects/magic/mm_hit.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 6 SECONDS
	cooldown_reduction_per_rank = 1 SECONDS

	invocation = "HU'SWCH H'ANS!!"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	hand_path = /obj/item/melee/touch_attack/duffelbag

	/// Some meme "elaborate backstories" to use.
	var/static/list/elaborate_backstory = list(
		"spacewar origin story",
		"military background",
		"corporate connections",
		"life in the colonies",
		"anti-government activities",
		"upbringing on the space farm",
		"fond memories with your buddy Keith",
	)

/datum/action/cooldown/spell/touch/duffelbag/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/touch/duffelbag/on_antimagic_triggered(obj/item/melee/touch_attack/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	to_chat(caster, span_warning("The spell can't seem to affect [victim]!"))
	to_chat(victim, span_warning("You really don't feel like talking about your [pick(elaborate_backstory)] with complete strangers today."))

/datum/action/cooldown/spell/touch/duffelbag/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/victim, mob/living/carbon/caster)

	// To get it started, stun and knockdown the person being hit
	victim.flash_act()
	victim.Immobilize(5 SECONDS)
	victim.apply_damage(80, STAMINA)
	victim.Knockdown(5 SECONDS)

	// If someone's already cursed, don't try to give them another
	if(istype(victim.back, /obj/item/storage/backpack/duffelbag/cursed))
		to_chat(caster, span_warning("The burden of [victim]'s duffel bag becomes too much, shoving them to the floor!"))
		to_chat(victim, span_warning("The weight of this bag becomes overburdening!"))
		return TRUE

	// However if they're uncursed, they're fresh for getting a cursed bag
	var/obj/item/storage/backpack/duffelbag/cursed/conjured_duffel = new get_turf(victim)
	victim.visible_message(
		span_danger("A growling duffel bag appears on [victim]!"),
		span_danger("You feel something attaching itself to you, and a strong desire to discuss your [pick(elaborate_backstory)] at length!"),
	)

	conjured_duffel.pickup(victim)
	conjured_duffel.forceMove(victim)

	// Put it on their back first
	if(victim.dropItemToGround(victim.back))
		victim.equip_to_slot_if_possible(conjured_duffel, ITEM_SLOT_BACK, TRUE, TRUE)
		return TRUE

	// If the back equip failed, put it in their hands first
	if(victim.put_in_hands(conjured_duffel))
		return TRUE

	// If they had no empty hands, try to put it in their inactive hand first
	victim.dropItemToGround(victim.get_inactive_held_item())
	if(victim.put_in_hands(conjured_duffel))
		return TRUE

	// If their inactive hand couldn't be emptied or found, put it in their active hand
	victim.dropItemToGround(victim.get_active_held_item())
	if(victim.put_in_hands(conjured_duffel))
		return TRUE

	// Well, we failed to give them the duffel bag,
	// but technically we still stunned them so that's something
	return TRUE

/obj/item/melee/touch_attack/duffelbag
	name = "\improper burdening touch"
	desc = "Where is the bar from here?"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "duffelcurse"
	inhand_icon_state = "duffelcurse"
