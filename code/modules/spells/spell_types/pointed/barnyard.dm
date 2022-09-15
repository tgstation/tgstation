/datum/action/cooldown/spell/pointed/barnyardcurse
	name = "Curse of the Barnyard"
	desc = "This spell dooms an unlucky soul to possess the speech and facial attributes of a barnyard animal."
	button_icon_state = "barn"
	ranged_mousepointer = 'icons/effects/mouse_pointers/barn_target.dmi'

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 15 SECONDS
	cooldown_reduction_per_rank = 3 SECONDS

	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to curse a target..."
	deactive_msg = "You dispel the curse."

/datum/action/cooldown/spell/pointed/barnyardcurse/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	if(!human_target.wear_mask)
		return TRUE

	return !(human_target.wear_mask.type in GLOB.cursed_animal_masks)

/datum/action/cooldown/spell/pointed/barnyardcurse/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		cast_on.visible_message(
			span_danger("[cast_on]'s face bursts into flames, which instantly burst outward, leaving [cast_on.p_them()] unharmed!"),
			span_danger("Your face starts burning up, but the flames are repulsed by your anti-magic protection!"),
		)
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	var/chosen_type = pick(GLOB.cursed_animal_masks)
	var/obj/item/clothing/mask/animal/cursed_mask = new chosen_type(get_turf(target))

	cast_on.visible_message(
		span_danger("[target]'s face bursts into flames, and a barnyard animal's head takes its place!"),
		span_userdanger("Your face burns up, and shortly after the fire you realise you have the face of a [cursed_mask.animal_type]!"),
	)

	// Can't drop? Nuke it
	if(!cast_on.dropItemToGround(cast_on.wear_mask))
		qdel(cast_on.wear_mask)

	cast_on.equip_to_slot_if_possible(cursed_mask, ITEM_SLOT_MASK, TRUE, TRUE)
	cast_on.flash_act()
	return TRUE
