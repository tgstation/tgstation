//// Doppler Golems - Overwrites and continuiations of
// code/modules/mob/living/carbon/human/species_types/golems.dm
/datum/species/golem
	preview_outfit = /datum/outfit/golem_preview
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_LAVA_IMMUNE,
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
	//	TRAIT_NODISMEMBER,	removing this for now...
		TRAIT_NOFIRE,
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_NO_UNDERWEAR,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_SNOWSTORM_IMMUNE,
		TRAIT_UNHUSKABLE,
		TRAIT_BOULDER_BREAKER,
		//deviating from TG here <--
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_GOLEM_LIMBATTACHMENT,
	)
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN //golem ERT

	var/golem_speed_mod = 0.8

/datum/species/golem/on_species_gain(mob/living/carbon/new_golem, datum/species/old_species, pref_load)
	. = ..()
	new_golem.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/snail, multiplicative_slowdown = golem_speed_mod)

/datum/outfit/golem_preview
	name = "Golem (Species Preview)"
	head = /obj/item/food/grown/poppy/geranium/fraxinella

/datum/species/golem/get_species_lore()
	return list(
		"@Lobster",
	)

/datum/crafting_recipe/golem_stomach
	name = "Silicate Grinder"
	result = /obj/item/organ/internal/stomach/golem
	time = 120
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 10, /obj/item/stack/sheet/plasteel = 10)
	category = CAT_MISC

/datum/crafting_recipe/golem_liver
	name = "Porous Rock"
	result = /obj/item/organ/internal/liver/golem
	time = 120
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 10, )
	category = CAT_MISC

/datum/crafting_recipe/golem_tongue
	name = "Golem Tongue"
	result = /obj/item/organ/internal/tongue/golem
	time = 120
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 10)
	category = CAT_MISC

/datum/crafting_recipe/golem_eyes
	name = "Resonating Crystal"
	result = /obj/item/organ/internal/eyes/golem
	time = 120
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 10, /obj/item/stack/sheet/glass = 15)
	category = CAT_MISC

/datum/crafting_recipe/golem_appendix
	name = "Internal Forge"
	result = /obj/item/organ/internal/appendix/golem
	time = 120
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 10, /obj/item/stack/sheet/mineral/plasma = 15)
	category = CAT_MISC

/datum/crafting_recipe/golem_arm
	name = "Right Golem Arm"
	result = /obj/item/bodypart/arm/right/golem
	time = 60
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 6)
	category = CAT_MISC

/datum/crafting_recipe/golem_arm/left
	name = "Left Golem Arm"
	result = /obj/item/bodypart/arm/left/golem
	time = 60
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 6)
	category = CAT_MISC

/datum/crafting_recipe/golem_leg
	name = "Right Golem Leg"
	result = /obj/item/bodypart/leg/right/golem
	time = 60
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 6)
	category = CAT_MISC

/datum/crafting_recipe/golem_leg/left
	name = "Left Golem Leg"
	result = /obj/item/bodypart/leg/left/golem
	time = 60
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 6)
	category = CAT_MISC

/datum/crafting_recipe/golem_head
	name = "Golem Head"
	result = /obj/item/bodypart/head/golem
	time = 60
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 12)
	category = CAT_MISC

/datum/crafting_recipe/golem_torso
	name = "Golem Torso"
	result = /obj/item/bodypart/chest/golem
	time = 60
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 12)
	category = CAT_MISC

/obj/item/bodypart/arm/left/golem/drop_limb(special, dismembered, move_to_floor = FALSE)
	if(special)
		return ..()

	to_chat(owner, span_warning("Your [name] crumbles into loose stone!"))
	playsound(owner, 'sound/effects/rock/rock_break.ogg', 60, TRUE)
	new /obj/item/stack/stone(drop_location(), 4)
	. = ..()
	drop_organs(src, TRUE)
	qdel(src)
	return .

/obj/item/bodypart/arm/right/golem/drop_limb(special, dismembered, move_to_floor = FALSE)
	if(special)
		return ..()

	to_chat(owner, span_warning("Your [name] crumbles into loose stone!"))
	playsound(owner, 'sound/effects/rock/rock_break.ogg', 60, TRUE)
	new /obj/item/stack/stone(drop_location(), 4)
	. = ..()
	drop_organs(src, TRUE)
	qdel(src)
	return .

/obj/item/bodypart/leg/left/golem/drop_limb(special, dismembered, move_to_floor = FALSE)
	if(special)
		return ..()

	to_chat(owner, span_warning("Your [name] crumbles into loose stone!"))
	playsound(owner, 'sound/effects/rock/rock_break.ogg', 60, TRUE)
	new /obj/item/stack/stone(drop_location(), 4)
	. = ..()
	drop_organs(src, TRUE)
	qdel(src)
	return .

/obj/item/bodypart/leg/right/golem/drop_limb(special, dismembered, move_to_floor = FALSE)
	if(special)
		return ..()

	to_chat(owner, span_warning("Your [name] crumbles into loose stone!"))
	playsound(owner, 'sound/effects/rock/rock_break.ogg', 60, TRUE)
	new /obj/item/stack/stone(drop_location(), 4)
	. = ..()
	drop_organs(src, TRUE)
	qdel(src)
	return .
