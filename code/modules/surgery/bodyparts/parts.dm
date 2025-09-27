
/obj/item/bodypart/chest
	name = BODY_ZONE_CHEST
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = LIMB_MAX_HP_CORE
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST
	plaintext_zone = "chest"
	is_dimorphic = TRUE
	px_x = 0
	px_y = 0
	grind_results = null
	wound_resistance = 10
	bodypart_trait_source = CHEST_TRAIT
	///The bodyshape(s) allowed to attach to this chest.
	var/acceptable_bodyshape = BODYSHAPE_HUMANOID
	///The bodytype(s) allowed to attach to this chest.
	var/acceptable_bodytype = ALL

	var/obj/item/cavity_item

	/// Offset to apply to equipment worn as a uniform
	var/datum/worn_feature_offset/worn_uniform_offset
	/// Offset to apply to equipment worn on the id slot
	var/datum/worn_feature_offset/worn_id_offset
	/// Offset to apply to equipment worn in the suit slot
	var/datum/worn_feature_offset/worn_suit_storage_offset
	/// Offset to apply to equipment worn on the hips
	var/datum/worn_feature_offset/worn_belt_offset
	/// Offset to apply to overlays placed on the back
	var/datum/worn_feature_offset/worn_back_offset
	/// Offset to apply to equipment worn as a suit
	var/datum/worn_feature_offset/worn_suit_offset
	/// Offset to apply to equipment worn on the neck
	var/datum/worn_feature_offset/worn_neck_offset
	/// Which functional (i.e. flightpotion) wing types (if any) does this bodypart support? If count is >1 a radial menu is used to choose between all icons in list
	var/list/wing_types = list(/obj/item/organ/wings/functional/angel)

/obj/item/bodypart/chest/forced_removal(dismembered, special, move_to_floor)
	var/mob/living/carbon/old_owner = owner
	..(special = TRUE) //special because we're self destructing

	//If someones chest is teleported away, they die pretty hard
	if(!old_owner)
		return
	message_admins("[ADMIN_LOOKUPFLW(old_owner)] was gibbed after their chest teleported to [ADMIN_VERBOSEJMP(loc)].")
	old_owner.gib(DROP_ALL_REMAINS)

/obj/item/bodypart/chest/can_dismember(obj/item/item)
	if((!HAS_TRAIT(owner, TRAIT_CURSED) && owner.stat < HARD_CRIT) || !contents.len)
		return FALSE
	return ..()

/obj/item/bodypart/chest/Destroy()
	QDEL_NULL(cavity_item)
	QDEL_NULL(worn_uniform_offset)
	QDEL_NULL(worn_id_offset)
	QDEL_NULL(worn_suit_storage_offset)
	QDEL_NULL(worn_belt_offset)
	QDEL_NULL(worn_back_offset)
	QDEL_NULL(worn_suit_offset)
	QDEL_NULL(worn_neck_offset)
	return ..()

/obj/item/bodypart/chest/drop_organs(mob/user, violent_removal)
	if(cavity_item)
		cavity_item.forceMove(drop_location())
		cavity_item = null
	return ..()

/// Sprite to show for photocopying mob butts
/obj/item/bodypart/chest/proc/get_butt_sprite()
	if(!ishuman(owner))
		return null
	var/mob/living/carbon/human/human_owner = owner
	var/obj/item/organ/tail/tail = human_owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(tail)
		return tail.get_butt_sprite()

	return icon('icons/mob/butts.dmi', human_owner.physique == FEMALE ? BUTT_SPRITE_HUMAN_FEMALE : BUTT_SPRITE_HUMAN_MALE)

/obj/item/bodypart/chest/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_chest"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	wound_resistance = -10
	bodyshape = BODYSHAPE_MONKEY
	acceptable_bodyshape = BODYSHAPE_MONKEY
	dmg_overlay_type = SPECIES_MONKEY

/obj/item/bodypart/chest/monkey/Initialize(mapload)
	worn_neck_offset = new(
		attached_part = src,
		feature_key = OFFSET_NECK,
		offset_y = list("south" = 1),
	)
	return ..()

/obj/item/bodypart/chest/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "alien_chest"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = LIMB_MAX_HP_ALIEN_CORE
	burn_modifier = LIMB_ALIEN_BURN_DAMAGE_MULTIPLIER
	acceptable_bodyshape = BODYSHAPE_HUMANOID
	wing_types = null

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "larva_chest"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = LIMB_MAX_HP_ALIEN_LARVA
	burn_modifier = LIMB_ALIEN_BURN_DAMAGE_MULTIPLIER
	bodytype = BODYTYPE_LARVA_PLACEHOLDER | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_LARVA_PLACEHOLDER
	wing_types = null

/// Parent Type for arms, should not appear in game.
/obj/item/bodypart/arm
	name = "arm"
	desc = "Hey buddy give me a HAND and report this to the github because you shouldn't be seeing this."
	abstract_type = /obj/item/bodypart/arm
	attack_verb_continuous = list("slaps", "punches")
	attack_verb_simple = list("slap", "punch")
	max_damage = LIMB_MAX_HP_DEFAULT
	aux_layer = BODYPARTS_HIGH_LAYER
	body_damage_coeff = LIMB_BODY_DAMAGE_COEFFICIENT_DEFAULT
	can_be_disabled = TRUE
	unarmed_attack_verbs = list("punch") /// The classic punch, wonderfully classic and completely random
	unarmed_attack_verbs_continuous = list("punches")
	grappled_attack_verb = "pummel"
	grappled_attack_verb_continuous = "pummels"
	unarmed_damage_low = 5
	unarmed_damage_high = 10
	unarmed_pummeling_bonus = 1.5
	body_zone = BODY_ZONE_L_ARM
	/// Datum describing how to offset things worn on the hands of this arm, note that an x offset won't do anything here
	var/datum/worn_feature_offset/worn_glove_offset
	/// Datum describing how to offset things held in the hands of this arm, the x offset IS functional here
	var/datum/worn_feature_offset/held_hand_offset
	/// The noun to use when referring to this arm's appendage, e.g. "hand" or "paw"
	var/appendage_noun = "hand"

	biological_state = BIO_STANDARD_JOINTED

/obj/item/bodypart/arm/Destroy()
	QDEL_NULL(worn_glove_offset)
	QDEL_NULL(held_hand_offset)
	return ..()

/// We need to clear out hand hud items and appearance, so do that here
/obj/item/bodypart/arm/clear_ownership(mob/living/carbon/old_owner)
	..()

	old_owner.update_worn_gloves()

	if(!held_index)
		return

	old_owner.on_lost_hand(src)

	if(!old_owner.hud_used)
		return

	var/atom/movable/screen/inventory/hand/hand = old_owner.hud_used.hand_slots["[held_index]"]
	hand?.update_appearance()

/// We need to add hand hud items and appearance, so do that here
/obj/item/bodypart/arm/apply_ownership(mob/living/carbon/new_owner)
	..()

	new_owner.update_worn_gloves()

	if(!held_index)
		return

	new_owner.on_added_hand(src, held_index)

	if(!new_owner.hud_used)
		return

	var/atom/movable/screen/inventory/hand/hand = new_owner.hud_used.hand_slots["[held_index]"]
	hand?.update_appearance()

/obj/item/bodypart/arm/left
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	body_zone = BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	plaintext_zone = "left arm"
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	held_index = 1
	px_x = -6
	px_y = 0
	bodypart_trait_source = LEFT_ARM_TRAIT

/obj/item/bodypart/arm/left/apply_ownership(mob/living/carbon/new_owner)
	if(HAS_TRAIT(new_owner, TRAIT_PARALYSIS_L_ARM))
		ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
		RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_loss))
	else
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
		RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_gain))
	..()

/obj/item/bodypart/arm/left/clear_ownership(mob/living/carbon/old_owner)
	. = ..()
	if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_ARM))
		UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	else
		UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))

///Proc to react to the owner gaining the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/arm/left/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_loss))

///Proc to react to the owner losing the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/arm/left/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_gain))

/obj/item/bodypart/arm/left/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_hands(owner.usable_hands - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("You lose control of your [plaintext_zone]!"))
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(!bodypart_disabled)
		owner.set_usable_hands(owner.usable_hands + 1)

	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/hand_screen_object = owner.hud_used.hand_slots["[held_index]"]
		hand_screen_object?.update_appearance()

/obj/item/bodypart/arm/left/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_l_arm"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_MONKEY
	wound_resistance = -10
	px_x = -5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 8
	unarmed_effectiveness = 5
	appendage_noun = "paw"

/obj/item/bodypart/arm/left/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "alien_l_arm"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = LIMB_MAX_HP_ALIEN_LIMBS
	burn_modifier = LIMB_ALIEN_BURN_DAMAGE_MULTIPLIER
	should_draw_greyscale = FALSE
	appendage_noun = "scythe-like hand"

/obj/item/bodypart/arm/right
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	icon_state = "default_human_r_arm"
	plaintext_zone = "right arm"
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	aux_layer = BODYPARTS_HIGH_LAYER
	held_index = 2
	px_x = 6
	px_y = 0
	bodypart_trait_source = RIGHT_ARM_TRAIT

/obj/item/bodypart/arm/right/apply_ownership(mob/living/carbon/new_owner)
	if(HAS_TRAIT(new_owner, TRAIT_PARALYSIS_R_ARM))
		ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
		RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_loss))
	else
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
		RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_gain))
	..()

/obj/item/bodypart/arm/right/clear_ownership(mob/living/carbon/old_owner)
	. = ..()
	if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_ARM))
		UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	else
		UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))

///Proc to react to the owner gaining the TRAIT_PARALYSIS_R_ARM trait.
/obj/item/bodypart/arm/right/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_loss))

///Proc to react to the owner losing the TRAIT_PARALYSIS_R_ARM trait.
/obj/item/bodypart/arm/right/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_gain))

/obj/item/bodypart/arm/right/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_hands(owner.usable_hands - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("You lose control of your [plaintext_zone]!"))
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(!bodypart_disabled)
		owner.set_usable_hands(owner.usable_hands + 1)

	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/hand_screen_object = owner.hud_used.hand_slots["[held_index]"]
		hand_screen_object?.update_appearance()

/obj/item/bodypart/arm/right/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_r_arm"
	limb_id = SPECIES_MONKEY
	bodyshape = BODYSHAPE_MONKEY
	should_draw_greyscale = FALSE
	wound_resistance = -10
	px_x = 5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 8
	unarmed_effectiveness = 0
	appendage_noun = "paw"

/obj/item/bodypart/arm/right/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "alien_r_arm"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = LIMB_MAX_HP_ALIEN_LIMBS
	burn_modifier = LIMB_ALIEN_BURN_DAMAGE_MULTIPLIER
	should_draw_greyscale = FALSE
	appendage_noun = "scythe-like hand"

/// Parent Type for legs, should not appear in game.
/obj/item/bodypart/leg
	name = "leg"
	desc = "This item shouldn't exist. Talk about breaking a leg. Badum-Tss!"
	abstract_type = /obj/item/bodypart/leg
	attack_verb_continuous = list("kicks", "stomps")
	attack_verb_simple = list("kick", "stomp")
	max_damage = LIMB_MAX_HP_DEFAULT
	body_damage_coeff = LIMB_BODY_DAMAGE_COEFFICIENT_DEFAULT
	can_be_disabled = TRUE
	unarmed_attack_effect = ATTACK_EFFECT_KICK
	body_zone = BODY_ZONE_L_LEG
	unarmed_attack_verbs = list("kick") // The lovely kick, typically only accessable by attacking a grouded foe. 1.5 times better than the punch.
	unarmed_attack_verbs_continuous = list("kicks")
	unarmed_damage_low = 7
	unarmed_damage_high = 15
	unarmed_effectiveness = 15
	biological_state = BIO_STANDARD_JOINTED
	/// Datum describing how to offset things worn on the foot of this leg, note that an x offset won't do anything here
	var/datum/worn_feature_offset/worn_foot_offset
	/// Used by the bloodysoles component to make footprints
	var/footprint_sprite = FOOTPRINT_SPRITE_SHOES
	/// What does our footsteps (barefoot) sound like? Only BAREFOOT, CLAW, HEAVY, and SHOE (or null, I guess) are valid
	var/footstep_type = FOOTSTEP_MOB_BAREFOOT
	/// You can set this to a list of sounds to pick from when a footstep is played rather than use the footstep types
	/// Requires special formatting: list(list(sounds, go, here), volume, range modifier)
	var/list/special_footstep_sounds

/obj/item/bodypart/leg/Initialize(mapload)
	. = ..()
	if(PERFORM_ALL_TESTS(focus_only/humanstep_validity))
		// Update this list if more types are suported in the footstep element
		var/list/supported_types = list(
			null,
			FOOTSTEP_MOB_BAREFOOT,
			FOOTSTEP_MOB_CLAW,
			FOOTSTEP_MOB_HEAVY,
			FOOTSTEP_MOB_SHOE,
		)
		if(!(footstep_type in supported_types))
			stack_trace("Invalid footstep type set on leg: \[[footstep_type]\] \
				If you want to use this type, you will need to create a global footstep index for it.")

/obj/item/bodypart/leg/Destroy()
	QDEL_NULL(worn_foot_offset)
	return ..()

/obj/item/bodypart/leg/left
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "default_human_l_leg"
	body_zone = BODY_ZONE_L_LEG
	body_part = LEG_LEFT
	plaintext_zone = "left leg"
	px_x = -2
	px_y = 12
	can_be_disabled = TRUE
	bodypart_trait_source = LEFT_LEG_TRAIT

/obj/item/bodypart/leg/left/apply_ownership(mob/living/carbon/new_owner)
	if(HAS_TRAIT(new_owner, TRAIT_PARALYSIS_L_LEG))
		ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
		RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_loss))
	else
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
		RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_gain))
	..()

/obj/item/bodypart/leg/left/clear_ownership(mob/living/carbon/old_owner)
	. = ..()
	if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_LEG))
		UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	else
		UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))

///Proc to react to the owner gaining the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/leg/left/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_loss))

///Proc to react to the owner losing the TRAIT_PARALYSIS_L_LEG trait.
/obj/item/bodypart/leg/left/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_gain))

/obj/item/bodypart/leg/left/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_legs(owner.usable_legs - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("You lose control of your [plaintext_zone]!"))
	else if(!bodypart_disabled)
		owner.set_usable_legs(owner.usable_legs + 1)

/obj/item/bodypart/leg/left/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_l_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_MONKEY
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 3
	unarmed_effectiveness = 5
	footprint_sprite = FOOTPRINT_SPRITE_PAWS

/obj/item/bodypart/leg/left/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "alien_l_leg"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = LIMB_MAX_HP_ALIEN_LIMBS
	burn_modifier = LIMB_ALIEN_BURN_DAMAGE_MULTIPLIER
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	// alternative spellings of 'pokey' are available
	icon_state = "default_human_r_leg"
	body_zone = BODY_ZONE_R_LEG
	body_part = LEG_RIGHT
	plaintext_zone = "right leg"
	px_x = 2
	px_y = 12
	bodypart_trait_source = RIGHT_LEG_TRAIT

/obj/item/bodypart/leg/right/apply_ownership(mob/living/carbon/new_owner)
	if(HAS_TRAIT(new_owner, TRAIT_PARALYSIS_R_LEG))
		ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
		RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_loss))
	else
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
		RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_gain))
	..()

/obj/item/bodypart/leg/right/clear_ownership(mob/living/carbon/old_owner)
	. = ..()
	if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_LEG))
		UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	else
		UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))

///Proc to react to the owner gaining the TRAIT_PARALYSIS_R_LEG trait.
/obj/item/bodypart/leg/right/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_loss))

///Proc to react to the owner losing the TRAIT_PARALYSIS_R_LEG trait.
/obj/item/bodypart/leg/right/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_gain))


/obj/item/bodypart/leg/right/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_legs(owner.usable_legs - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("You lose control of your [plaintext_zone]!"))
	else if(!bodypart_disabled)
		owner.set_usable_legs(owner.usable_legs + 1)

/obj/item/bodypart/leg/right/monkey
	icon = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/monkey/bodyparts.dmi'
	icon_husk = 'icons/mob/human/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_r_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_MONKEY
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 3
	unarmed_effectiveness = 5
	footprint_sprite = FOOTPRINT_SPRITE_PAWS

/obj/item/bodypart/leg/right/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "alien_r_leg"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = LIMB_MAX_HP_ALIEN_LIMBS
	burn_modifier = LIMB_ALIEN_BURN_DAMAGE_MULTIPLIER
	should_draw_greyscale = FALSE
