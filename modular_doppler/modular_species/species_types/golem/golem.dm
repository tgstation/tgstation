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

/datum/species/golem/on_species_gain(mob/living/carbon/new_golem, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	new_golem.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/snail, multiplicative_slowdown = golem_speed_mod)

/datum/outfit/golem_preview
	name = "Golem (Species Preview)"
	head = /obj/item/food/grown/poppy/geranium/fraxinella

/datum/species/golem/get_species_description()
	return "Golems, informally known as Moonmen, are typically spacebound alien species of extremophile invertebrates closely related to tardigrades and basilisks. \
	They are predominantly known for their several-inch-thick outer shells, using dense compounds to conceal and protect their insectile, myriapodan bodies. \
	Another unusual feature is their unique metabolism, which is almost wholly reliant on inorganic minerals and raw ores."

/datum/species/golem/get_species_lore()
	return list(
		"Without their rock layer golems can be easily mistaken as giant myriapods. With an average length of seven feet, the true form of a golem is defined by their cylindrical trunks and tapered heads. \
			Hundreds of sticky cilia- paired in twos- line each flank of a golem's cuticle coated body, their opaque exoskeleton typically grey in coloration. \
			Relying on a mixture of antennae and ocelli for sight, they are one of the few sapient species that can see into the ultraviolet range.",

		"Golems are currently, aside from silicon-based lifeforms, the only recorded species capable of indefinite exposure to the vacuum of space. \
			Although the species lacks a large-scale society which could independently develop spacefaring tech, golems exploit their robust physiology to float through space until they impact a new asteroid or planetary body. \
			Golems trapped in the gravity well of an uncolonized planet seldom have a way to leave, sometimes making them the sole inhabitant.",

		"Those that choose to integrate into society undergo a miraculous process not dissimilar to a plasmaman's fungal colony. By coupling with one to three other golems, the group creates a single humanoid-shaped body called a family unit. \
			Family units typically have one member independently controlling a limb, interchangeably swapping roles as the hands or feet in a form of facultative bipedalism. \
			Whereas plasmamen coalesce into hivemind colonies, golems in a family unit remain as independently thinking entities.",

		"Still, many live hermetic lifestyles as recluses, content with a simple life grazing on ores divorced from societal life. \
			These golems typically retain their mono-bodied forms, only coupling with other golems to reproduce or to form a family unit in times of resource scarcity. \
			In rare cases, these hermits will congregate into aggressive organized colonies. \
			The most recent recording of this phenomena occurred on Mars, when an Akhter colonization project had unknowingly disturbed a colony of moonmen who had been living in the red planet's subterranean.",
	)

/datum/crafting_recipe/golem_stomach
	name = "Silicate Grinder"
	result = /obj/item/organ/stomach/golem
	time = 120
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 10, /obj/item/stack/sheet/plasteel = 10)
	category = CAT_MISC

/datum/crafting_recipe/golem_liver
	name = "Porous Rock"
	result = /obj/item/organ/liver/golem
	time = 120
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 10)
	category = CAT_MISC

/datum/crafting_recipe/golem_tongue
	name = "Golem Tongue"
	result = /obj/item/organ/tongue/golem
	time = 120
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 10)
	category = CAT_MISC

/datum/crafting_recipe/golem_eyes
	name = "Resonating Crystal"
	result = /obj/item/organ/eyes/golem
	time = 120
	tool_behaviors = list(TOOL_MINING)
	reqs = list(/obj/item/stack/stone = 10, /obj/item/stack/sheet/glass = 15)
	category = CAT_MISC

/datum/crafting_recipe/golem_appendix
	name = "Internal Forge"
	result = /obj/item/organ/appendix/golem
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
