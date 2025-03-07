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
	unarmed_attack_verbs = list("kicks", "hoofs", "stomps")
	grappled_attack_verb = "stomps"
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/arm/left/pony/Initialize(mapload)
	. = ..()
	worn_glove_offset = new( // even though they can't wear gloves. we're cheating and using this for the front leg offsets
		attached_part = src,
		feature_key = OFFSET_GLOVES,
		offset_x = list("north" = 0, "south" = 0, "east" = 5, "west" = -5),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
	)


/obj/item/bodypart/arm/right/pony
	icon_greyscale = 'icons/mob/human/species/pony/bodyparts.dmi'
	limb_id = SPECIES_PONY
	unarmed_attack_verbs = list("kicks", "hoofs", "stomps")
	grappled_attack_verb = "stomps"
	bodyshape = BODYSHAPE_PONY

/obj/item/bodypart/arm/right/pony/Initialize(mapload)
	. = ..()
	worn_glove_offset = new( // even though they can't wear gloves. we're cheating and using this for the front leg offsets
		attached_part = src,
		feature_key = OFFSET_GLOVES,
		offset_x = list("north" = -1, "south" = -1, "east" = 5, "west" = -5),
		offset_y = list("north" = 0, "south" = 0, "east" = 0, "west" = 0),
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
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
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
	return "Unicorn"

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

/datum/bodypart_overlay/mutant/pony_horn/get_image(image_layer, obj/item/bodypart/limb)
	var/mutable_appearance/appearance = mutable_appearance('icons/mob/human/species/pony/bodyparts.dmi', "m_pony_horn_pony_FRONT", layer = image_layer)
	return appearance

/datum/bodypart_overlay/mutant/pony_horn
	dyable = TRUE
	color_source = ORGAN_COLOR_INHERIT
	feature_key = "pony_horn"
	layers = EXTERNAL_FRONT

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
	tackler = null
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
	tackler = organ_owner.AddComponent(
		/datum/component/tackler,
		stamina_cost = /obj/item/clothing/gloves/tackler::tackle_stam_cost,
		base_knockdown = /obj/item/clothing/gloves/tackler::base_knockdown,
		range = /obj/item/clothing/gloves/tackler::tackle_range,
	 	speed = /obj/item/clothing/gloves/tackler::tackle_speed,
		skill_mod = /obj/item/clothing/gloves/tackler::skill_mod,
	 	min_distance = /obj/item/clothing/gloves/tackler::min_distance
	)
	jumping_power.Grant(organ_owner)

/obj/item/organ/pony_wings/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	remove_organ_trait(TRAIT_CATLIKE_GRACE)
	remove_organ_trait(TRAIT_SOFT_FALL)
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
	desc = "Take flight with your wings and fly over obstacles and through windows!"
	button_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	button_icon_state = "m_pony_wings_pony_FRONT"
	cooldown_time = 7 SECONDS
	spell_requirements = NONE
	var/mob/living/carbon/human/last_caster
	var/obj/item/organ/pony_wings/our_wings

/datum/action/cooldown/spell/icarian_flight/cast(mob/living/cast_on)
	. = ..()
	last_caster = cast_on
	var/hindered = FALSE
	var/mob/living/carbon/human/pegasus = cast_on
	if(pegasus.getStaminaLoss() > 0 || pegasus.legcuffed) // cannot reach maximum jump if you have any stamina loss or are legcuffed(bola, bear trap, etc.)
		hindered = TRUE
		pegasus.visible_message(span_warning("[pegasus] weakly flies with their wings, hampered by their lack of stamina!"))
		pegasus.balloon_alert_to_viewers("weakly flies")
	else
		pegasus.visible_message(span_warning("[pegasus] flies with their wings!"))
		pegasus.balloon_alert_to_viewers("flies")
	playsound(pegasus, 'sound/effects/arcade_jump.ogg', 75, vary=TRUE)

	var/datum/bodypart_overlay/mutant/pony_wings/wings_overlay = our_wings.bodypart_overlay
	wings_overlay.unfurled = TRUE
	pegasus.update_body_parts()
	pegasus.layer = ABOVE_MOB_LAYER
	if(!hindered)
		pegasus.pass_flags |= PASSTABLE|PASSGRILLE|PASSWINDOW|PASSMACHINE|PASSSTRUCTURE
		RegisterSignal(pegasus, COMSIG_MOVABLE_MOVED, PROC_REF(break_glass))
	else
		pegasus.pass_flags |= PASSTABLE|PASSGRILLE|PASSMACHINE|PASSSTRUCTURE
		RegisterSignal(pegasus, COMSIG_MOVABLE_MOVED, PROC_REF(break_grilles))
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

/datum/action/cooldown/spell/icarian_flight/proc/break_glass(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/pegasus = mover
	for(var/obj/structure/window/window in get_turf(pegasus))
		window.deconstruct(disassembled = FALSE)
		mover.balloon_alert_to_viewers("smashed through!")
		pegasus.apply_damage(damage = rand(5,15), damagetype = BRUTE, wound_bonus = 15, bare_wound_bonus = 25, sharpness = SHARP_EDGED, attack_direction = get_dir(window, oldloc))
		new /obj/effect/decal/cleanable/glass(get_step(pegasus, pegasus.dir))
	for(var/obj/machinery/door/window/windoor in get_turf(pegasus))
		windoor.deconstruct(disassembled = FALSE)
		mover.balloon_alert_to_viewers("smashed through!")
		pegasus.apply_damage(damage = rand(5,15), damagetype = BRUTE, wound_bonus = 15, bare_wound_bonus = 25, sharpness = SHARP_EDGED, attack_direction = get_dir(windoor, oldloc))
		new /obj/effect/decal/cleanable/glass(get_step(pegasus, pegasus.dir))
	for(var/obj/structure/grille/grille in get_turf(pegasus))
		grille.shock(pegasus, 70)
		grille.deconstruct(disassembled = FALSE)
		mover.balloon_alert_to_viewers("smashed through!")
		pegasus.apply_damage(damage = rand(5,10), damagetype = BRUTE, wound_bonus = 5, bare_wound_bonus = 15, attack_direction = get_dir(grille, oldloc))
		new /obj/effect/decal/cleanable/generic(get_step(pegasus, pegasus.dir))

/datum/action/cooldown/spell/icarian_flight/proc/break_grilles(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/pegasus = mover
	for(var/obj/structure/grille/grille in get_turf(pegasus))
		grille.shock(pegasus, 70)
		grille.deconstruct(disassembled = FALSE)
		mover.balloon_alert_to_viewers("smashed through!")
		pegasus.apply_damage(damage = rand(5,10), damagetype = BRUTE, wound_bonus = 5, bare_wound_bonus = 15, attack_direction = get_dir(grille, oldloc))
		new /obj/effect/decal/cleanable/generic(get_step(pegasus, pegasus.dir))

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
	UnregisterSignal(jumper, COMSIG_MOVABLE_MOVED)


/obj/item/organ/earth_pony_core
	name = "beating core of earth"
	icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	icon_state = "earth_pony_core"
	worn_icon = 'icons/mob/human/species/pony/bodyparts.dmi'
	worn_icon_state = "earth_pony_core"
	organ_flags = ORGAN_ORGANIC | ORGAN_VIRGIN | ORGAN_EDIBLE | ORGAN_VITAL
	slot = ORGAN_SLOT_PONY_EARTH
	zone = BODY_ZONE_CHEST
