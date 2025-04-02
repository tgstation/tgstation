#define PONY_HEAD_SIZE_MODIFIER 1.5
/obj/item/bodypart/head/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	is_dimorphic = FALSE
	bodyshape = BODYSHAPE_PONY
	head_flags = HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_DEBRAIN|HEAD_HAIR
	teeth_count = 24
	/// Offset to apply to equipment held in the mouth.
	var/datum/worn_feature_offset/worn_mouth_item_offset

/obj/item/bodypart/head/pony/Initialize(mapload)
	. = ..()
	QDEL_NULL(worn_face_offset)
/*
	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_x = list("north" = -2, "south" = 2, "east" = 4, "west" = -4),
		offset_y = list("north" = -1, "south" = -1, "east" = -1, "west" = -1),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_x = list("north" = 0, "south" = 0, "east" = 8, "west" = -8),
		offset_y = list("north" = -6, "south" = -6, "east" = -6, "west" = -6),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	worn_face_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACE,
		offset_x = list("north" = 0, "south" = 0, "east" = 5, "west" = -5),
		offset_y = list("north" = -6, "south" = -6, "east" = -6, "west" = -6),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
*/

	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_x = list("north" = -4, "south" = 4, "east" = 7, "west" = -7),
		offset_y = list("north" = 3, "south" = 3, "east" = 3, "west" = 3),
	)
	worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -7, "south" = -7, "east" = -7, "west" = -7),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -7, "south" = -7, "east" = -7, "west" = -7),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_x = list("north" = 0, "south" = 0, "east" = 8, "west" = -8),
		offset_y = list("north" = -6, "south" = -6, "east" = -6, "west" = -6),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)
	/*worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -3, "south" = -3, "east" = -3, "west" = -3),
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -1, "south" = -2, "east" = -2, "west" = -2),
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_x = list("north" = 0, "south" = 0, "east" = 8, "west" = -8),
		offset_y = list("north" = -4, "south" = -4, "east" = -3, "west" = -3),
	)*/
	worn_face_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACE,
		offset_x = list("north" = 0, "south" = 0, "east" = 5, "west" = -5),
		offset_y = list("north" = -5, "south" = -6, "east" = -6, "west" = -6),
		size_modifier = list("north" = PONY_HEAD_SIZE_MODIFIER, "south" = PONY_HEAD_SIZE_MODIFIER, "east" = PONY_HEAD_SIZE_MODIFIER, "west" = PONY_HEAD_SIZE_MODIFIER)
	)

/obj/item/bodypart/chest/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	is_dimorphic = FALSE
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/chest/pony/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.hug_verb = "nudge"
	RegisterSignal(new_owner, COMSIG_MOB_UPDATE_HELD_ITEMS, PROC_REF(on_updated_held_items))
	RegisterSignal(new_owner, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(on_removed_limb))

/obj/item/bodypart/chest/pony/on_removal(mob/living/carbon/old_owner)
	. = ..()
	old_owner.hug_verb = initial(old_owner.hug_verb)
	UnregisterSignal(old_owner, COMSIG_MOB_UPDATE_HELD_ITEMS)
	UnregisterSignal(old_owner, COMSIG_CARBON_POST_REMOVE_LIMB)

/obj/item/bodypart/chest/pony/proc/update_movespeed(mob/living/holding_mob)
	holding_mob.remove_movespeed_modifier(/datum/movespeed_modifier/pony_holding_no_items)
	holding_mob.remove_movespeed_modifier(/datum/movespeed_modifier/pony_holding_two_items)
	if(HAS_TRAIT(holding_mob, TRAIT_FLOATING_HELD) && holding_mob.num_hands == 2)
		holding_mob.add_movespeed_modifier(/datum/movespeed_modifier/pony_holding_no_items)
		return
	var/amount_of_held_items = 0
	for(var/obj/item/held in holding_mob.held_items)
		amount_of_held_items++
	if(amount_of_held_items >= 2 || holding_mob.num_hands == 0) // no front legs, gonna have a hard time getting around
		holding_mob.add_movespeed_modifier(/datum/movespeed_modifier/pony_holding_two_items)
	else if(amount_of_held_items == 0 && holding_mob.num_hands == 2) // still got both of your front legs
		holding_mob.add_movespeed_modifier(/datum/movespeed_modifier/pony_holding_no_items)

/obj/item/bodypart/chest/pony/proc/on_updated_held_items(mob/living/holding_mob)
	SIGNAL_HANDLER
	update_movespeed(holding_mob)

/obj/item/bodypart/chest/pony/proc/on_removed_limb(datum/source, obj/item/bodypart/removed_limb, special, dismembered, mob/living/carbon/limb_owner)
	SIGNAL_HANDLER
	update_movespeed(limb_owner)

/obj/item/bodypart/chest/pony/Initialize(mapload)
	. = ..()
	worn_back_offset = new(
		attached_part = src,
		feature_key = OFFSET_BACK,
		offset_x = list("north" = 0, "south" = 0, "east" = 2, "west" = -2),
		offset_y = list("north" = -4, "south" = -4, "east" = -5, "west" = -5),
	)
	worn_belt_offset = new(
		attached_part = src,
		feature_key = OFFSET_BELT,
		offset_x = list("north" = 0, "south" = 0, "east" = 2, "west" = -2),
		offset_y = list("north" = -4, "south" = -4, "east" = -5, "west" = -5),
		rotation_modifier = list("north" = 0, "south" = 0, "east" = 90, "west" = -90)
	)
	worn_suit_storage_offset = new(
		attached_part = src,
		feature_key = OFFSET_S_STORE,
		offset_x = list("north" = 0, "south" = 0, "east" = 2, "west" = -2),
		offset_y = list("north" = -4, "south" = -4, "east" = -5, "west" = -5),
		rotation_modifier = list("north" = 0, "south" = 0, "east" = 90, "west" = -90)
	)
	worn_id_offset = new(
		attached_part = src,
		feature_key = OFFSET_ID,
		offset_x = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 5),
	)
	worn_suit_offset = new(
		attached_part = src,
		feature_key = OFFSET_SUIT,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = -6),
		offset_y = list("north" = -5, "south" = -6, "east" = -5, "west" = -5),
	)

/obj/item/bodypart/arm/left/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	unarmed_attack_verbs = list("kick", "hoof", "stomp")
	grappled_attack_verb = "stomp"
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/arm/left/pony/Initialize(mapload)
	. = ..()
	worn_glove_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLOVES,
		offset_x = list("north" = 0, "south" = 0, "east" = 5, "west" = -5),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	)
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = 4, "south" = -4, "east" = 3, "west" = -5),
		offset_y = list("north" = -9, "south" = -9, "east" = -9, "west" = -9),
	)


/obj/item/bodypart/arm/right/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	unarmed_attack_verbs = list("kick", "hoof", "stomp")
	grappled_attack_verb = "stomp"
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/arm/right/pony/Initialize(mapload)
	. = ..()
	worn_glove_offset = new( // even though they can't wear gloves. we're cheating and using this for the front leg offsets
		attached_part = src,
		feature_key = OFFSET_GLOVES,
		offset_x = list("north" = -1, "south" = -1, "east" = 5, "west" = -5),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	)
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = -3, "south" = 3, "east" = 5, "west" = 0),
		offset_y = list("north" = -9, "south" = -9, "east" = -9, "west" = -9),
	)

/obj/item/bodypart/leg/left/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/leg/left/pony/Initialize(mapload)
	. = ..()
	worn_foot_offset = new(
		attached_part = src,
		feature_key = OFFSET_SHOES,
		offset_x = list("north" = 0, "south" = 0, "east" = -4, "west" = 4),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	)

/obj/item/bodypart/leg/right/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/leg/right/pony/Initialize(mapload)
	. = ..()
	worn_foot_offset = new(
		attached_part = src,
		feature_key = OFFSET_SHOES,
		offset_x = list("north" = 0, "south" = 0, "east" = -4, "west" = 4),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	)

/obj/item/organ/eyes/pony
	name = "pony eyes"
	eye_icon_state = "pony_eye"

/obj/item/organ/eyes/pony/generate_body_overlay_before_eyelids(mob/living/carbon/human/parent)
	var/mutable_appearance/eyelashes = mutable_appearance('icons/mob/human/human_face.dmi', "pony_eyelids", -BODY_LAYER, parent)
	return list(eyelashes)

/obj/item/organ/ears/pony
	icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	icon_state = "m_pony_ears_pony_FRONT"
	worn_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	worn_icon_state = "m_pony_ears_pony_FRONT"
	visual = TRUE
	damage_multiplier = 2 // pony ears are big and sensitive to loud noises

	restyle_flags = EXTERNAL_RESTYLE_FLESH

	dna_block = DNA_EARS_BLOCK

	bodypart_overlay = /datum/bodypart_overlay/mutant/pony_ears

/datum/bodypart_overlay/mutant/pony_ears
	layers = EXTERNAL_FRONT | EXTERNAL_ADJACENT | EXTERNAL_BEHIND
	color_source = ORGAN_COLOR_INHERIT
	feature_key = "pony_ears"
	dyable = TRUE

/datum/bodypart_overlay/mutant/pony_ears/get_global_feature_list()
	return SSaccessories.pony_ears_list

/datum/bodypart_overlay/mutant/pony_ears/can_draw_on_bodypart(mob/living/carbon/human/human)
	//if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
	//	return FALSE
	return TRUE

/obj/item/organ/tail/pony
	name = "pony tail"
	preference = "feature_pony_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/pony_tail

	wag_flags = NONE
	dna_block = DNA_PONY_TAIL_BLOCK

/datum/bodypart_overlay/mutant/pony_tail
	dyable = TRUE
	color_source = ORGAN_COLOR_HAIR
	feature_key = "pony_tail"
	layers = EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/pony_tail/get_global_feature_list()
	return SSaccessories.pony_tail_list

/datum/preference/choiced/pony_tail
	savefile_key = "feature_pony_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/pony

/datum/preference/choiced/pony_tail/init_possible_values()
	return assoc_to_keys_features(SSaccessories.pony_tail_list)

/datum/preference/choiced/pony_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["pony_tail"] = value

/datum/preference/choiced/pony_tail/create_default_value()
	return /datum/sprite_accessory/pony_tail/pony::name

/datum/preference/choiced/pony_choice
	savefile_key = "feature_pony_choice"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_inherent_trait = TRAIT_PONY_PREFS

/datum/preference/choiced/pony_choice/init_possible_values()
	return list("Unicorn", "Pegasus", "Earth")

/datum/preference/choiced/pony_choice/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["pony_archetype"] = value

/datum/preference/choiced/pony_choice/create_default_value()
	return pick(list("Unicorn", "Pegasus", "Earth"))

/datum/preference/color/unicorn_tk_color
	savefile_key = "unicorn_tk_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/unicorn_tk_color/create_default_value()
	return "#FF99FF"

/datum/preference/color/unicorn_tk_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["pony_unicorn_tk_color"] = value

/datum/preference/color/unicorn_tk_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return preferences.read_preference(/datum/preference/choiced/pony_choice) == "Unicorn"

/datum/action/innate/toggle_floating_items
	name = "Toggle Psionic Holding"
	button_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	button_icon_state = "telekinesis_throw"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS
	var/obj/item/organ/pony_horn/my_horn

/datum/action/innate/toggle_floating_items/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!COOLDOWN_FINISHED(my_horn, psionic_cooldown))
		owner.balloon_alert(owner, "still recovering!")
		return FALSE
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_FLOATING_HELD))
			REMOVE_TRAIT(owner, TRAIT_FLOATING_HELD, ORGAN_TRAIT)
			if(ishuman(owner))
				var/mob/living/carbon/human/owner_human = owner
				var/obj/item/bodypart/chest/pony/pony_bodypart = owner_human.get_bodypart(BODY_ZONE_CHEST)
				if(pony_bodypart && istype(pony_bodypart))
					pony_bodypart.update_movespeed(owner_human)
				owner_human.update_held_items()
		else
			ADD_TRAIT(owner, TRAIT_FLOATING_HELD, ORGAN_TRAIT)
			if(ishuman(owner))
				var/mob/living/carbon/human/owner_human = owner
				var/obj/item/bodypart/chest/pony/pony_bodypart = owner_human.get_bodypart(BODY_ZONE_CHEST)
				if(pony_bodypart && istype(pony_bodypart))
					pony_bodypart.update_movespeed(owner_human)
				owner_human.update_held_items()
	return TRUE

/obj/effect/temp_visual/pony_aura_feedback
	name = "aura feedback"
	desc = "Feedback from a pony's aura manifesting."
	icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	icon_state = "tele_effect"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE
	duration = 1 SECONDS

/obj/effect/temp_visual/pony_aura_feedback/Initialize(mapload, aura_color)
	. = ..()
	color = aura_color

/obj/item/organ/pony_horn
	name = "unicorn horn"
	icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	icon_state = "m_pony_horn_pony_FRONT"
	worn_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	worn_icon_state = "m_pony_horn_pony_FRONT"
	visual = TRUE
	organ_flags = ORGAN_ORGANIC | ORGAN_VIRGIN | ORGAN_EXTERNAL | ORGAN_VITAL
	bodypart_overlay = /datum/bodypart_overlay/mutant/pony_horn
	slot = ORGAN_SLOT_EXTERNAL_PONY_HORN
	zone = BODY_ZONE_HEAD
	var/grab_range = 3
	var/hit_cooldown_time = 1 SECONDS
	var/atom/movable/grabbed_atom
	var/mutable_appearance/kinesis_icon
	var/atom/movable/screen/fullscreen/cursor_catcher/kinesis/kinesis_catcher
	var/datum/looping_sound/gravgen/kinesis/soundloop
	var/datum/action/innate/toggle_floating_items/toggle
	COOLDOWN_DECLARE(hit_cooldown)
	COOLDOWN_DECLARE(psionic_cooldown)

/obj/item/organ/pony_horn/Initialize(mapload)
	. = ..()
	soundloop = new(src)

/obj/item/organ/pony_horn/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(toggle)
	QDEL_NULL(kinesis_icon)
	QDEL_NULL(kinesis_catcher)
	return ..()



/obj/item/organ/pony_horn/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	toggle = new
	toggle.my_horn = src
	toggle.Grant(organ_owner)
	add_organ_trait(TRAIT_VIRUS_WEAKNESS)
	RegisterSignal(organ_owner, COMSIG_MOB_CLICKON, PROC_REF(start_kinesis))
	RegisterSignal(organ_owner, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))

/obj/item/organ/pony_horn/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(owner && HAS_TRAIT(owner, TRAIT_FLOATING_HELD))
		REMOVE_TRAIT(owner, TRAIT_FLOATING_HELD, ORGAN_TRAIT)
		if(ishuman(owner))
			var/mob/living/carbon/human/owner_human = owner
			var/obj/item/bodypart/chest/pony/pony_bodypart = owner_human.get_bodypart(BODY_ZONE_CHEST)
			if(pony_bodypart && istype(pony_bodypart))
				pony_bodypart.update_movespeed(owner_human)
			owner_human.update_held_items()
	if(grabbed_atom)
		clear_grab(playsound = FALSE)
	remove_organ_trait(TRAIT_VIRUS_WEAKNESS)
	qdel(toggle)
	clear_grab(playsound = FALSE)
	UnregisterSignal(organ_owner, COMSIG_MOB_CLICKON)
	UnregisterSignal(organ_owner, COMSIG_ATOM_EMP_ACT)

/obj/item/organ/pony_horn/proc/on_emp_act(datum/source, severity, protection)
	SIGNAL_HANDLER
	if(protection & EMP_PROTECT_SELF)
		return
	if(grabbed_atom || HAS_TRAIT(owner, TRAIT_FLOATING_HELD))
		new /obj/effect/temp_visual/pony_aura_feedback(get_turf(owner), owner.dna.features["pony_unicorn_tk_color"] ? owner.dna.features["pony_unicorn_tk_color"] : "#FF99FF")
		owner.flash_act(1, TRUE, FALSE, TRUE)
		to_chat(owner, span_userdanger("Your brain flashes with every color imaginable as sharp, searing pain runs through your skull through your horn!"))
		if(HAS_TRAIT(owner, TRAIT_FLOATING_HELD))
			REMOVE_TRAIT(owner, TRAIT_FLOATING_HELD, ORGAN_TRAIT)
			if(ishuman(owner))
				var/mob/living/carbon/human/owner_human = owner
				var/obj/item/bodypart/chest/pony/pony_bodypart = owner_human.get_bodypart(BODY_ZONE_CHEST)
				if(pony_bodypart && istype(pony_bodypart))
					pony_bodypart.update_movespeed(owner_human)
				owner_human.update_held_items()
		if(grabbed_atom)
			clear_grab(playsound = FALSE)
		COOLDOWN_START(src, psionic_cooldown, 60 SECONDS)
		owner.set_jitter_if_lower(40 SECONDS)
		owner.set_confusion_if_lower(10 SECONDS)
		owner.set_stutter_if_lower(16 SECONDS)

		SEND_SIGNAL(owner, COMSIG_LIVING_MINOR_SHOCK)
		addtimer(CALLBACK(src, PROC_REF(apply_stun_effect_end), owner), 2 SECONDS)

/obj/item/organ/pony_horn/proc/apply_stun_effect_end(mob/living/target)
	target.Knockdown(5 SECONDS)

/obj/item/organ/pony_horn/proc/start_kinesis(mob/living/source, atom/clicked_on, modifiers)
	SIGNAL_HANDLER
	if(LAZYACCESS(modifiers, MIDDLE_CLICK) && !LAZYACCESS(modifiers, SHIFT_CLICK))
		if(!COOLDOWN_FINISHED(src, psionic_cooldown))
			balloon_alert(owner, "still recovering!")
			return COMSIG_MOB_CANCEL_CLICKON
		if(grabbed_atom)
			var/launched_object = grabbed_atom
			clear_grab(playsound = FALSE)
			launch(launched_object)
			return COMSIG_MOB_CANCEL_CLICKON
		if(!range_check(clicked_on))
			balloon_alert(owner, "too far!")
			return COMSIG_MOB_CANCEL_CLICKON
		if(!can_grab(clicked_on))
			balloon_alert(owner, "can't grab!")
			return COMSIG_MOB_CANCEL_CLICKON
		grab_atom(clicked_on)
		return COMSIG_MOB_CANCEL_CLICKON
	return NONE

/obj/item/organ/pony_horn/process(seconds_per_tick)
	if(!owner)
		return
	if(!owner?.client || INCAPACITATED_IGNORING(owner, INCAPABLE_GRAB))
		clear_grab()
		return
	if(!range_check(grabbed_atom))
		balloon_alert(owner, "out of range!")
		clear_grab()
		return
	if(kinesis_catcher.mouse_params)
		kinesis_catcher.calculate_params()
	if(!kinesis_catcher.given_turf)
		return
	if(grabbed_atom.loc == kinesis_catcher.given_turf)
		if(grabbed_atom.pixel_x == kinesis_catcher.given_x - ICON_SIZE_X/2 && grabbed_atom.pixel_y == kinesis_catcher.given_y - ICON_SIZE_Y/2)
			return //spare us redrawing if we are standing still
		animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + kinesis_catcher.given_x - ICON_SIZE_X/2, pixel_y = grabbed_atom.base_pixel_y + kinesis_catcher.given_y - ICON_SIZE_Y/2)
		return
	animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + kinesis_catcher.given_x - ICON_SIZE_X/2, pixel_y = grabbed_atom.base_pixel_y + kinesis_catcher.given_y - ICON_SIZE_Y/2)
	var/turf/next_turf = get_step_towards(grabbed_atom, kinesis_catcher.given_turf)
	if(grabbed_atom.Move(next_turf, get_dir(grabbed_atom, next_turf), 8))
		if(isitem(grabbed_atom) && (owner in next_turf))
			var/obj/item/grabbed_item = grabbed_atom
			clear_grab()
			grabbed_item.pickup(owner)
			owner.put_in_hands(grabbed_item)
		return
	var/pixel_x_change = 0
	var/pixel_y_change = 0
	var/direction = get_dir(grabbed_atom, next_turf)
	if(direction & NORTH)
		pixel_y_change = ICON_SIZE_Y/2
	else if(direction & SOUTH)
		pixel_y_change = -ICON_SIZE_Y/2
	if(direction & EAST)
		pixel_x_change = ICON_SIZE_X/2
	else if(direction & WEST)
		pixel_x_change = -ICON_SIZE_X/2
	animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + pixel_x_change, pixel_y = grabbed_atom.base_pixel_y + pixel_y_change)
	if(!isitem(grabbed_atom) || !COOLDOWN_FINISHED(src, hit_cooldown))
		return
	var/atom/hitting_atom
	if(next_turf.density)
		hitting_atom = next_turf
	for(var/atom/movable/movable_content as anything in next_turf.contents)
		if(ismob(movable_content))
			continue
		if(movable_content.density)
			hitting_atom = movable_content
			break
	var/obj/item/grabbed_item = grabbed_atom
	grabbed_item.melee_attack_chain(owner, hitting_atom)
	COOLDOWN_START(src, hit_cooldown, hit_cooldown_time)

/obj/item/organ/pony_horn/proc/can_grab(atom/target)
	if(!ismovable(target))
		return FALSE
	if(iseffect(target))
		return FALSE
	var/atom/movable/movable_target = target
	if(movable_target.anchored)
		return FALSE
	if(movable_target.throwing)
		return FALSE
	if(movable_target.move_resist >= MOVE_FORCE_OVERPOWERING)
		return FALSE
	if(ismob(movable_target))
		return FALSE
	else if(isitem(movable_target))
		var/obj/item/item_target = movable_target
		if(item_target.w_class >= WEIGHT_CLASS_GIGANTIC)
			return FALSE
		if(item_target.item_flags & ABSTRACT)
			return FALSE
	return TRUE

/obj/item/organ/pony_horn/proc/grab_atom(atom/movable/target)
	grabbed_atom = target
	if(isliving(grabbed_atom))
		grabbed_atom.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), REF(src))
	ADD_TRAIT(grabbed_atom, TRAIT_NO_FLOATING_ANIM, REF(src))
	RegisterSignal(grabbed_atom, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(on_setanchored))
	playsound(grabbed_atom, 'sound/effects/magic.ogg', 75, TRUE)
	kinesis_icon = mutable_appearance(icon = 'icons/mob/human/species/pony/bodyparts.dmi', icon_state = "telekinesis_throw", layer = grabbed_atom.layer - 0.1)
	kinesis_icon.color = owner.dna.features["pony_unicorn_tk_color"] ? owner.dna.features["pony_unicorn_tk_color"] : "#FF99FF"
	kinesis_icon.appearance_flags = RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM
	kinesis_icon.overlays += emissive_appearance(icon = 'icons/mob/human/species/pony/bodyparts.dmi', icon_state = "telekinesis_throw", offset_spokesman = grabbed_atom)
	grabbed_atom.add_overlay(kinesis_icon)
	kinesis_catcher = owner.overlay_fullscreen("kinesis_pony", /atom/movable/screen/fullscreen/cursor_catcher/kinesis/no_icon, 0)
	kinesis_catcher.assign_to_mob(owner)
	var/datum/bodypart_overlay/mutant/pony_horn/horn_overlay = bodypart_overlay
	horn_overlay.doing_tk = TRUE
	horn_overlay.tk_color = owner.dna.features["pony_unicorn_tk_color"] ? owner.dna.features["pony_unicorn_tk_color"] : "#FF99FF"
	owner.update_body_parts()
	RegisterSignal(kinesis_catcher, COMSIG_SCREEN_ELEMENT_CLICK, PROC_REF(on_catcher_click))
	soundloop.start()
	START_PROCESSING(SSfastprocess, src)

/atom/movable/screen/fullscreen/cursor_catcher/kinesis/no_icon
	icon_state = "fullscreen_blocker"

/obj/item/organ/pony_horn/proc/clear_grab(playsound = TRUE)
	if(!grabbed_atom)
		return
	. = grabbed_atom
	if(playsound)
		playsound(grabbed_atom, 'sound/effects/magic/summonitems_generic.ogg', 75, TRUE)
	STOP_PROCESSING(SSfastprocess, src)
	UnregisterSignal(grabbed_atom, list(COMSIG_MOB_STATCHANGE, COMSIG_MOVABLE_SET_ANCHORED))
	owner.clear_fullscreen("kinesis_pony")
	kinesis_catcher = null
	grabbed_atom.cut_overlay(kinesis_icon)
	if(isliving(grabbed_atom))
		grabbed_atom.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), REF(src))
	REMOVE_TRAIT(grabbed_atom, TRAIT_NO_FLOATING_ANIM, REF(src))
	if(!isitem(grabbed_atom))
		animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x, pixel_y = grabbed_atom.base_pixel_y)
	grabbed_atom = null
	soundloop.stop()
	var/datum/bodypart_overlay/mutant/pony_horn/horn_overlay = bodypart_overlay
	horn_overlay.doing_tk = FALSE
	owner.update_body_parts()

/obj/item/organ/pony_horn/proc/range_check(atom/target)
	if(!isturf(owner.loc))
		return FALSE
	if(ismovable(target) && !isturf(target.loc))
		return FALSE
	if(!can_see(owner, target, grab_range))
		return FALSE
	return TRUE

/obj/item/organ/pony_horn/proc/on_catcher_click(atom/source, location, control, params, user)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		clear_grab()

/obj/item/organ/pony_horn/proc/on_setanchored(atom/movable/grabbed_atom, anchorvalue)
	SIGNAL_HANDLER

	if(grabbed_atom.anchored)
		clear_grab()

/obj/item/organ/pony_horn/proc/launch(atom/movable/launched_object)
	playsound(launched_object, 'sound/effects/gravhit.ogg', 100, TRUE)
	RegisterSignal(launched_object, COMSIG_MOVABLE_IMPACT, PROC_REF(launch_impact))
	var/turf/target_turf = get_turf_in_angle(get_angle(owner, launched_object), get_turf(src), 10)
	launched_object.throw_at(target_turf, range = 8, speed = launched_object.density ? 3 : 4, thrower = owner, spin = isitem(launched_object))

/obj/item/organ/pony_horn/proc/launch_impact(atom/movable/source, atom/hit_atom, datum/thrownthing/thrownthing)
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!(isstructure(source) || ismachinery(source) || isvehicle(source)))
		return
	var/damage_self = TRUE
	var/damage = 8
	if(source.density)
		damage_self = FALSE
		damage = 15
	if(isliving(hit_atom))
		var/mob/living/living_atom = hit_atom
		living_atom.apply_damage(damage, BRUTE)
	else if(hit_atom.uses_integrity)
		hit_atom.take_damage(damage, BRUTE, MELEE)
	if(damage_self && source.uses_integrity)
		source.take_damage(source.max_integrity/5, BRUTE, MELEE)

/datum/bodypart_overlay/mutant/pony_horn/get_global_feature_list()
	return SSaccessories.pony_wings_list

/datum/bodypart_overlay/mutant/pony_horn/get_image(image_layer, obj/item/bodypart/limb)
	var/mutable_appearance/appearance = mutable_appearance('icons/mob/human/species/pony/bodyparts.dmi', "m_pony_horn_pony_FRONT", layer = image_layer)
	if(doing_tk)
		var/mutable_appearance/appearance_tk = mutable_appearance('icons/mob/human/species/pony/bodyparts.dmi', "horn_tk_overlay", layer = image_layer)
		appearance_tk.color = tk_color
		appearance.overlays += appearance_tk
	return appearance

/datum/bodypart_overlay/mutant/pony_horn/generate_icon_cache()
	. = ..()
	if(doing_tk)
		. += "_doing_tk_[tk_color]"

/datum/bodypart_overlay/mutant/pony_horn
	dyable = TRUE
	color_source = ORGAN_COLOR_INHERIT
	feature_key = "pony_horn"
	layers = EXTERNAL_FRONT
	use_feature_offset = TRUE
	var/doing_tk = FALSE
	var/tk_color = "#FF99FF"

/datum/bodypart_overlay/mutant/pony_horn/get_global_feature_list()
	return SSaccessories.pony_horn_list

/obj/item/organ/pony_wings
	name = "pegasus wings"
	icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	icon_state = "m_pony_wings_pony_FRONT"
	worn_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	worn_icon_state = "m_pony_wings_pony_FRONT"
	organ_flags = ORGAN_ORGANIC | ORGAN_VIRGIN | ORGAN_EXTERNAL | ORGAN_VITAL
	visual = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/pony_wings
	slot = ORGAN_SLOT_EXTERNAL_PONY_WINGS
	zone = BODY_ZONE_CHEST
	var/datum/action/cooldown/spell/icarian_flight/jumping_power
	var/datum/component/tackler

/obj/item/organ/pony_wings/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/jetpack, \
		TRUE, \
		1, \
		1, \
		COMSIG_ORGAN_IMPLANTED, \
		COMSIG_ORGAN_REMOVED, \
		null, \
		CALLBACK(src, PROC_REF(allow_flight)), \
		null, \
	)
	jumping_power = new(src)
	jumping_power.background_icon_state = "bg_tech_blue"
	jumping_power.base_background_icon_state = jumping_power.background_icon_state
	jumping_power.active_background_icon_state = "[jumping_power.base_background_icon_state]_active"
	jumping_power.overlay_icon_state = "bg_tech_blue_border"
	jumping_power.active_overlay_icon_state = null
	jumping_power.panel = "Genetic"
	jumping_power.our_wings = src

/obj/item/organ/pony_wings/Destroy()
	qdel(tackler)
	qdel(jumping_power)
	. = ..()

/obj/item/organ/pony_wings/proc/allow_flight()
	if(!owner || !owner.client)
		return FALSE
	if(owner.has_gravity())
		return FALSE
	var/datum/gas_mixture/current = owner.loc.return_air()
	if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85))
		return TRUE
	return FALSE

/obj/item/organ/pony_wings/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	add_organ_trait(TRAIT_CATLIKE_GRACE)
	add_organ_trait(TRAIT_SOFT_FALL)
	add_organ_trait(TRAIT_VIRUS_WEAKNESS)
	tackler = organ_owner.AddComponent(/datum/component/tackler, stamina_cost = 25, base_knockdown = 1 SECONDS, range = 4, speed = 1, skill_mod = 1, min_distance = 0)
	jumping_power.Grant(organ_owner)

/obj/item/organ/pony_wings/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	remove_organ_trait(TRAIT_CATLIKE_GRACE)
	remove_organ_trait(TRAIT_SOFT_FALL)
	remove_organ_trait(TRAIT_VIRUS_WEAKNESS)
	jumping_power.Remove(organ_owner)

/datum/bodypart_overlay/mutant/pony_wings
	dyable = TRUE
	color_source = ORGAN_COLOR_INHERIT
	feature_key = "pony_wings"
	layers = EXTERNAL_FRONT
	var/unfurled = FALSE

/datum/bodypart_overlay/mutant/pony_wings/get_global_feature_list()
	return SSaccessories.pony_wings_list

/datum/bodypart_overlay/mutant/pony_wings/get_image(image_layer, obj/item/bodypart/limb)
	var/state_to_use = unfurled ? "m_pony_wings_pony_FRONT" : "m_pony_wings_pony_folded_FRONT"
	var/mutable_appearance/appearance = mutable_appearance('icons/mob/human/species/pony/bodyparts.dmi', state_to_use, layer = image_layer)
	return appearance

/datum/bodypart_overlay/mutant/pony_wings/generate_icon_cache()
	. = ..()
	if(unfurled)
		. += "_unfurled"

#define ICARIAN_FLIGHT "icarian_flight"

/datum/action/cooldown/spell/icarian_flight
	name = "Icarian Flight"
	desc = "Take flight with your wings and fly over obstacles!"
	button_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	button_icon_state = "m_pony_wings_pony_FRONT"
	cooldown_time = 7 SECONDS
	spell_requirements = NONE
	var/mob/living/carbon/human/last_caster
	var/obj/item/organ/pony_wings/our_wings

/datum/action/cooldown/spell/icarian_flight/cast(mob/living/cast_on)
	. = ..()
	last_caster = cast_on
	var/mob/living/carbon/human/pegasus = cast_on
	pegasus.visible_message(span_warning("[pegasus] flies with their wings!"))
	pegasus.balloon_alert_to_viewers("flies")
	playsound(pegasus, 'sound/effects/arcade_jump.ogg', 75, vary=TRUE)

	var/datum/bodypart_overlay/mutant/pony_wings/wings_overlay = our_wings.bodypart_overlay
	wings_overlay.unfurled = TRUE
	pegasus.update_body_parts()
	pegasus.layer = ABOVE_MOB_LAYER
	pegasus.pass_flags |= PASSTABLE|PASSMACHINE|PASSSTRUCTURE
	ADD_TRAIT(pegasus, TRAIT_SILENT_FOOTSTEPS, ICARIAN_FLIGHT)
	ADD_TRAIT(pegasus, TRAIT_MOVE_FLYING, ICARIAN_FLIGHT)
	pegasus.zMove(UP)
	cast_on.add_filter(ICARIAN_FLIGHT, 2, drop_shadow_filter(color = "#03020781", size = 0.9))
	var/shadow_filter = cast_on.get_filter(ICARIAN_FLIGHT)
	var/jump_height = 24
	var/jump_duration = 1.5 SECONDS
	new /obj/effect/temp_visual/mook_dust(get_turf(cast_on))
	animate(cast_on, pixel_y = cast_on.pixel_y + jump_height, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT)
	animate(pixel_y = initial(owner.pixel_y), time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	animate(shadow_filter, y = -jump_height, size = 4, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT)
	animate(y = 0, size = 0.9, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(end_jump), cast_on), jump_duration)

///Ends the jump
/datum/action/cooldown/spell/icarian_flight/proc/end_jump(mob/living/jumper)
	var/datum/bodypart_overlay/mutant/pony_wings/wings_overlay = our_wings.bodypart_overlay
	wings_overlay.unfurled = FALSE
	last_caster.update_body_parts()
	jumper.remove_filter(ICARIAN_FLIGHT)
	jumper.layer = initial(jumper.layer)
	jumper.pass_flags = initial(jumper.pass_flags)
	REMOVE_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, ICARIAN_FLIGHT)
	REMOVE_TRAIT(jumper, TRAIT_MOVE_FLYING, ICARIAN_FLIGHT)
	new /obj/effect/temp_visual/mook_dust(get_turf(jumper))

/obj/item/organ/earth_pony_core
	name = "beating core of earth"
	icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	icon_state = "earth_pony_core"
	worn_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	worn_icon_state = "earth_pony_core"
	organ_flags = ORGAN_ORGANIC | ORGAN_VIRGIN | ORGAN_EDIBLE | ORGAN_VITAL
	slot = ORGAN_SLOT_PONY_EARTH
	zone = BODY_ZONE_CHEST
	var/datum/action/cooldown/spell/touch/pony_kick/hind_kick

/obj/item/organ/earth_pony_core/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	hind_kick.Grant(organ_owner)

/obj/item/organ/earth_pony_core/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	hind_kick.Remove(organ_owner)

/obj/item/organ/earth_pony_core/Initialize(mapload)
	. = ..()
	hind_kick = new(src)
	hind_kick.background_icon_state = "bg_tech_blue"
	hind_kick.base_background_icon_state = hind_kick.background_icon_state
	hind_kick.active_background_icon_state = "[hind_kick.base_background_icon_state]_active"
	hind_kick.overlay_icon_state = "bg_tech_blue_border"
	hind_kick.active_overlay_icon_state = null
	hind_kick.panel = "Genetic"

/obj/item/organ/earth_pony_core/Destroy()
	QDEL_NULL(hind_kick)
	return ..()

/datum/action/cooldown/spell/touch/pony_kick
	name = "Hind-leg Kick"
	desc = "Kick backwards with all your might, throwing the target away and knocking anything loose."
	sound = null
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_PHASED|AB_CHECK_INCAPACITATED|AB_CHECK_LYING
	school = SCHOOL_PSYCHIC
	cooldown_time = 20 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	hand_path = /obj/item/melee/touch_attack/pony_kick

/datum/action/cooldown/spell/touch/pony_kick/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/movable/victim, mob/living/carbon/caster)
	if(isliving(victim))
		var/mob/living/living_victim = victim
		caster.setDir(turn(get_dir(caster, living_victim), 180))
		victim.visible_message(span_danger("[caster] rears up and kicks [victim]!"), \
						span_userdanger("You're kicked away by [caster]!"), span_hear("You hear a sickening sound of hoof hitting flesh!"), COMBAT_MESSAGE_RANGE, caster)
		to_chat(caster, span_danger("You rear up and kick [victim]!"))
		caster.do_attack_animation(living_victim)
		playsound(caster.loc, SFX_SWING_HIT, 50, TRUE)
		living_victim.apply_damage(
			damage = rand(10,20),
			damagetype = BRUTE,
			def_zone = BODY_ZONE_CHEST,
			attacking_item = hand,
			attack_direction = get_dir(caster, living_victim)
		)
		var/turf/T = get_edge_target_turf(caster, get_dir(caster, get_step_away(living_victim, caster)))
		if (T && isturf(T))
			living_victim.Paralyze(2 SECONDS)
			living_victim.throw_at(T, 5, 2)
		log_combat(caster, living_victim, "hind-leg-kicked")
	else if(istype(victim, /obj/structure/flora/tree))
		caster.do_attack_animation(victim)
		playsound(caster.loc, SFX_SWING_HIT, 50, TRUE)
		victim.Shake(3, 0, duration = 0.3 SECONDS)
		new /obj/item/food/grown/pineapple(get_turf(victim))
	return TRUE

/datum/action/cooldown/spell/touch/pony_kick/is_valid_target(atom/cast_on)
	return isliving(cast_on) || istype(cast_on, /obj/structure/flora/tree)

/obj/item/melee/touch_attack/pony_kick
	name = "\improper hind-leg kick"
	desc = "Rear up and kick someone!"
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "jetboot"

/obj/item/organ/brain/pony
	name = "pony brain"
	desc = "Has an enlarged, overly active pineal gland."
	var/static/regex/how_hungry
	var/datum/action/cooldown/spell/pointed/telepathy/telepathy_power

/obj/item/organ/brain/pony/Initialize(mapload)
	. = ..()
	if(!how_hungry)
		how_hungry = regex(@"(so hungry)", "i")
	telepathy_power = new(src)
	telepathy_power.background_icon_state = "bg_tech_blue"
	telepathy_power.base_background_icon_state = telepathy_power.background_icon_state
	telepathy_power.active_background_icon_state = "[telepathy_power.base_background_icon_state]_active"
	telepathy_power.overlay_icon_state = "bg_tech_blue_border"
	telepathy_power.active_overlay_icon_state = null
	telepathy_power.panel = "Genetic"

/obj/item/organ/brain/pony/Destroy()
	qdel(telepathy_power)
	. = ..()

/obj/item/organ/brain/pony/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	add_organ_trait(TRAIT_EMPATH)
	telepathy_power.Grant(organ_owner)
	RegisterSignal(organ_owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_moodlets))
	RegisterSignal(organ_owner, COMSIG_CARBON_SEE_GAIN_WOUND, PROC_REF(mirror_neuron))
	RegisterSignal(organ_owner, COMSIG_MOVABLE_HEAR, PROC_REF(how_hungry))

/obj/item/organ/brain/pony/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	remove_organ_trait(TRAIT_EMPATH)
	telepathy_power.Remove(organ_owner)
	UnregisterSignal(organ_owner, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(organ_owner, COMSIG_CARBON_SEE_GAIN_WOUND)
	UnregisterSignal(organ_owner, COMSIG_MOVABLE_HEAR)

/obj/item/organ/brain/pony/proc/how_hungry(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	if(!owner.can_hear() || owner == hearing_args[HEARING_SPEAKER])
		return

	var/mob/hungry_person = hearing_args[HEARING_SPEAKER]
	var/mob/living/carbon/possible_food = owner
	if(how_hungry.Find(hearing_args[HEARING_RAW_MESSAGE]))
		possible_food.setDir(get_dir(possible_food, hungry_person))
		INVOKE_ASYNC(possible_food, TYPE_PROC_REF(/mob, emote), "stare")

/obj/item/organ/brain/pony/proc/mirror_neuron(mob/living/carbon/wound_seer, mob/living/carbon/wounded, datum/wound/W, obj/item/bodypart/L)
	SIGNAL_HANDLER
	if(!LAZYLEN(wound_seer.all_wounds))
		wound_seer.add_mood_event("mirror_neuron", /datum/mood_event/mirror_neuron, wounded)

/obj/item/organ/brain/pony/proc/check_moodlets(mob/living/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/my_pony = source
	var/static/list/pony_friendly_turfs = list(
		/turf/open/misc/basalt,
		/turf/open/misc/ashplanet,
		/turf/open/misc/asteroid,
		/turf/open/misc/grass,
		/turf/open/floor/grass,
		/turf/open/floor/hay, // also for horses
		/turf/open/floor/fake_snow,
		/turf/open/floor/fakebasalt,
		/turf/open/misc/hay, // also for horses
		/turf/open/misc/dirt,
		/turf/open/misc/beach,
		/turf/open/misc/snow,
		/turf/open/water,
	)
	if(is_type_in_list(get_turf(source), pony_friendly_turfs))
		my_pony.add_mood_event("pony_brain_grounded", /datum/mood_event/pony_grounded)
	else
		my_pony.clear_mood_event("pony_brain_grounded")

/datum/action/cooldown/spell/pointed/telepathy
	name = "Telepathic Communication"
	desc = "<b>Left click</b>: point target to project a thought to them. <b>Right click</b>: project to your last thought target, if in range."
	button_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_MIND
	cooldown_time = 1 SECONDS
	cast_range = 7
	/// What's the last mob we point-targeted with this ability?
	var/datum/weakref/last_target_ref
	/// The message we send
	var/message
	/// Are we blocking casts?
	var/blocked = FALSE

/datum/action/cooldown/spell/pointed/telepathy/is_valid_target(atom/cast_on)
	. = ..()
	if (!.)
		return FALSE

	if (!isliving(cast_on))
		to_chat(owner, span_warning("Inanimate objects can't hear your thoughts."))
		owner.balloon_alert(owner, "not a thing with thoughts!")
		return FALSE

	var/mob/living/living_target = cast_on
	if (living_target.stat == DEAD)
		to_chat(owner, span_warning("The disruptive noise of departed resonance inhibits your ability to communicate with the dead."))
		owner.balloon_alert(owner, "can't transmit to the dead!")
		return FALSE

	if (get_dist(living_target, owner) > cast_range)
		owner.balloon_alert(owner, "too far away!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/telepathy/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST || blocked)
		return

	message = capitalize(tgui_input_text(owner, "What do you wish to whisper to [cast_on]?", "[src]", max_length = MAX_MESSAGE_LEN))
	if(QDELETED(src) || QDELETED(owner) || QDELETED(cast_on) || !can_cast_spell())
		return . | SPELL_CANCEL_CAST

	if(get_dist(cast_on, owner) > cast_range)
		owner.balloon_alert(owner, "they're too far!")
		return . | SPELL_CANCEL_CAST

	if(!message || length(message) == 0)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/telepathy/Trigger(trigger_flags, atom/target)
	if (trigger_flags & TRIGGER_SECONDARY_ACTION)
		var/mob/living/last_target = last_target_ref?.resolve()

		if(isnull(last_target))
			last_target_ref = null
			owner.balloon_alert(owner, "last target is not available!")
			return
		else if(get_dist(last_target, owner) > cast_range)
			owner.balloon_alert(owner, "[last_target] is too far away!")
			return

		blocked = TRUE

		message = capitalize(tgui_input_text(owner, "What do you wish to whisper to [last_target]?", "[src]", max_length = MAX_MESSAGE_LEN))
		if(QDELETED(src) || QDELETED(owner) || QDELETED(last_target) || !can_cast_spell())
			blocked = FALSE
			return
		send_thought(owner, last_target, message)
		src.StartCooldown()
		blocked = FALSE
		return

	. = ..()

/datum/action/cooldown/spell/pointed/telepathy/cast(mob/living/cast_on)
	. = ..()
	send_thought(owner, cast_on, message)

/datum/action/cooldown/spell/pointed/telepathy/proc/send_thought(mob/living/caster, mob/living/target, message)
	log_directed_talk(caster, target, message, LOG_SAY, tag = "telepathy")

	last_target_ref = WEAKREF(target)

	to_chat(owner, span_boldnotice("You reach out and convey to [target]: \"[span_purple(message)]\""))
	// flub a runechat chat message, do something with the language later
	if(owner.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
		owner.create_chat_message(owner, owner.get_selected_language(), message, list("italics"))
	if(!target.can_block_magic(antimagic_flags, charge_cost = 0) && target.client) //make sure we've got a client before we bother sending anything
		to_chat(target, span_boldnotice("A voice echoes in your head: \"[span_purple(message)]\""))

		if(target.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
			target.create_chat_message(target, target.get_selected_language(), message, list("italics")) // it appears over them since they hear it in their head
	else
		owner.balloon_alert(owner, "something blocks your thoughts!")
		to_chat(owner, span_warning("Your mind encounters impassable resistance: the thought was blocked!"))
		return

	// send to ghosts as well i guess
	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		if(!isobserver(ghost))
			continue

		var/from_link = FOLLOW_LINK(ghost, owner)
		var/from_mob_name = span_boldnotice("[owner]")
		var/to_link = FOLLOW_LINK(ghost, target)
		var/to_mob_name = span_name("[target]")

		to_chat(ghost, "[from_link] " + span_purple("<b>\[Telepathy\]</b> [from_mob_name] transmits, \"[message]\"") + " to [to_mob_name] [to_link]")

/obj/item/organ/tongue/pony
	name = "pony tongue"
	desc = "A tongue with a light psionic aura. Overly large tastebuds for sweet flavors."
	taste_sensitivity = 50 // very sensitive to bad tastes
	liked_foodtypes = VEGETABLES | FRUIT | JUNKFOOD | SUGAR
	disliked_foodtypes = RAW | GROSS | CLOTH
	toxic_foodtypes = TOXIC | GROSS | BUGS | GORE | MEAT | SEAFOOD

/obj/item/organ/lungs/pony
	name = "pony lungs"
	desc = "A pair of lungs belonging to a pony. Used to the crisp, fresh air of their home planet. Doesn't react well to miasma."

/obj/item/organ/lungs/pony/too_much_miasma(mob/living/carbon/breather, datum/gas_mixture/breath, miasma_pp, old_miasma_pp)
	breathe_gas_volume(breath, /datum/gas/miasma)
	if (HAS_TRAIT(breather, TRAIT_ANOSMIA))
		return
	switch(miasma_pp)
		if(0.25 to 5)
			to_chat(breather, span_warning("You smell something horribly decayed inside this room."))
			breather.add_mood_event("smell", /datum/mood_event/disgust/bad_smell)
		if(5 to 15)
			to_chat(breather, span_warning("The stench of rotting carcasses is unbearable!"))
			breather.add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
			if(prob(10))
				breather.vomit(VOMIT_CATEGORY_DEFAULT)
		if(15 to 30)
			to_chat(breather, span_warning("The stench of rotting carcasses is unbearable!"))
			breather.add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
			if(prob(30))
				breather.vomit(VOMIT_CATEGORY_DEFAULT)
		if(30 to INFINITY)
			to_chat(breather, span_warning("The stench of rotting carcasses is unbearable!"))
			breather.add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
			if(prob(50))
				breather.vomit(VOMIT_CATEGORY_DEFAULT)
		else
			breather.clear_mood_event("smell")
	breather.adjust_disgust(0.25 * miasma_pp)

/datum/preference_middleware/icon
	action_delegations = list(
		"start_editing_pref" = PROC_REF(start_editing_pref),
		"stop_editing_pref" = PROC_REF(stop_editing_pref),
		"save_pref" = PROC_REF(save_pref),
		"spriteEditorCommand" = PROC_REF(sprite_editor_command)
	)
	var/datum/preference/icon/edited_pref
	var/datum/sprite_editor_workspace/workspace

/datum/preference_middleware/icon/on_ui_close(mob/user)
	stop_editing_pref()

/datum/preference_middleware/icon/proc/start_editing_pref(list/params, mob/user)
	var/key = params["key"]
	var/datum/preference/icon/icon_pref = GLOB.preference_entries_by_key[key]
	if(!istype(icon_pref))
		return TRUE
	edited_pref = icon_pref
	workspace = new(icon_pref.width, icon_pref.height)
	edited_pref.apply_to_new_workspace(workspace, preferences.read_preference(edited_pref.type))
	return TRUE

/datum/preference_middleware/icon/proc/stop_editing_pref()
	edited_pref = null
	QDEL_NULL(workspace)
	return TRUE

/datum/preference_middleware/icon/proc/save_pref(list/params, mob/user)
	if(!workspace)
		return TRUE
	var/icon/canvas = new/icon('icons/blanks/32x32.dmi', "nothing")
	var/width = edited_pref.width
	var/height = edited_pref.height
	canvas.Crop(1, 1, width, height)
	// We only use one sprite editor layer for this pref, for now
	var/list/layer = workspace.layers[1]["data"]["[SOUTH]"]
	for(var/y in 1 to height)
		var/actual_y = height-y+1
		for(var/x in 1 to width)
			canvas.DrawBox(layer[actual_y][x], x, y)
	var/icon/out_icon = edited_pref.process_icon(canvas)
	preferences.write_preference(edited_pref, out_icon)
	return stop_editing_pref()

/datum/preference_middleware/icon/proc/sprite_editor_command(list/params, mob/user)
	if(!workspace)
		return TRUE
	var/command = params["command"]
	switch(command)
		if("transaction")
			workspace.new_transaction(params["transaction"])
		if("undo")
			workspace.undo()
		if("redo")
			workspace.redo()
	return TRUE

/datum/preference_middleware/icon/get_ui_data(mob/user)
	var/data = list()
	if(workspace)
		data["workspaceData"] = workspace.sprite_editor_ui_data()
		data["editingIcon"] = TRUE
	else
		data["editingIcon"] = FALSE
	return data

/datum/preference/icon
	abstract_type = /datum/preference/icon
	can_randomize = FALSE
	var/width = 32
	var/height = 32
	var/destination_file

/datum/preference/icon/create_informed_default_value(datum/preferences/preferences)
	var/client/client = preferences.parent
	var/ckey = client.ckey
	var/path = "data/player_saves/[ckey[1]]/[ckey]/icons/[destination_file]_[preferences.default_slot].dmi"
	var/icon/new_icon = icon('icons/blanks/32x32.dmi', "nothing")
	new_icon.Crop(1, 1, width, height)
	var/icon/out_icon = process_icon(new_icon)
	fcopy(out_icon, path)
	return path

/datum/preference/icon/proc/process_icon(icon/in_icon)
	return in_icon

/datum/preference/icon/proc/apply_to_new_workspace(datum/sprite_editor_workspace/workspace, value)
	return

/datum/preference/icon/deserialize(input, datum/preferences/preferences)
	var/client/client = preferences.parent
	var/ckey = client.ckey
	var/path = "data/player_saves/[ckey[1]]/[ckey]/icons/[destination_file]_[preferences.default_slot].dmi"
	if(isicon(input))
		fcopy(input, path)
	return path

/datum/preference/icon/cutie_mark
	savefile_key = "feature_pony_cutie_mark"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/cutie_mark
	width = 4
	height = 4
	destination_file = "cutie_mark"

/datum/preference/icon/cutie_mark/is_valid(value)
	return isicon(value) || (istext(value) && fexists(value))

/datum/preference/icon/cutie_mark/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["pony_cutie_mark"] = value

/datum/preference/icon/cutie_mark/compile_ui_data(mob/user, value)
	var/icon/mark_icon = icon(value, "cutie_mark_chest", EAST)
	mark_icon.Crop(12, 11, 15, 14)
	return icon2base64(mark_icon)

/datum/preference/icon/cutie_mark/process_icon(icon/in_icon)
	var/icon/new_icon = icon('icons/blanks/32x32.dmi', "nothing")
	in_icon.Crop(1, 1, 32, 32)
	in_icon.Shift(EAST, 11)
	in_icon.Shift(NORTH, 10)
	new_icon.Insert(in_icon, "cutie_mark_chest", EAST)
	in_icon.Shift(EAST, 7)
	new_icon.Insert(in_icon, "cutie_mark_chest", WEST)
	return new_icon

/datum/preference/icon/cutie_mark/apply_to_new_workspace(datum/sprite_editor_workspace/workspace, value)
	var/icon/mark_icon = icon(value, "cutie_mark_chest", EAST)
	var/list/layer = workspace.layers[1]["data"]["[SOUTH]"]
	for(var/y in 1 to height)
		for(var/x in 1 to height)
			var/actual_y = 15-y
			var/actual_x = 11+x
			layer[y][x] = mark_icon.GetPixel(actual_x, actual_y) || "#00000000"

/datum/sprite_accessory/cutie_mark
	natural_spawn = FALSE
	icon_state = "cutie_mark"
	compatible_bodyshapes = BODYSHAPE_PONY
	color_src = null
	var/icon_path

/datum/bodypart_overlay/simple/body_marking/cutie_mark
	dna_feature_key = "pony_cutie_mark"
	applies_to = list(
		/obj/item/bodypart/chest
	)

/datum/bodypart_overlay/simple/body_marking/cutie_mark/get_accessory(value)
	if(value == SPRITE_ACCESSORY_NONE)
		return
	var/datum/sprite_accessory/cutie_mark/accessory = new()
	accessory.icon_path = value
	accessory.icon = icon(value)
	return accessory

/datum/bodypart_overlay/simple/body_marking/cutie_mark/generate_icon_cache()
	. = ..()
	. += md5(icon)

