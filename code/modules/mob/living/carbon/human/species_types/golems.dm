/// Animated beings of stone. They have increased defenses, and do not need to breathe. They must eat minerals to live, which give additional buffs.
/datum/species/golem
	name = "Golem"
	id = SPECIES_GOLEM
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_LAVA_IMMUNE,
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
	)
	mutantheart = null
	mutantlungs = null
	inherent_biotypes = MOB_HUMANOID|MOB_MINERAL
	damage_modifier = 10 //golem is stronk
	payday_modifier = 1.0
	siemens_coeff = 0
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	sexes = FALSE
	meat = /obj/item/food/meat/slab/human/mutant/golem
	species_language_holder = /datum/language_holder/golem

	bodytemp_heat_damage_limit = BODYTEMP_HEAT_LAVALAND_SAFE
	bodytemp_cold_damage_limit = BODYTEMP_COLD_ICEBOX_SAFE

	mutant_organs = list(/obj/item/organ/internal/adamantine_resonator)
	mutanteyes = /obj/item/organ/internal/eyes/golem
	mutantbrain = /obj/item/organ/internal/brain/golem
	mutanttongue = /obj/item/organ/internal/tongue/golem
	mutantstomach = /obj/item/organ/internal/stomach/golem
	mutantliver = /obj/item/organ/internal/liver/golem
	mutantappendix = /obj/item/organ/internal/appendix/golem
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

	/// Chance that we will generate a human surname, for lore reasons
	var/human_surname_chance = 3

/datum/species/golem/random_name(gender,unique,lastname)
	var/name = pick(GLOB.golem_names)
	if (prob(human_surname_chance))
		name += " [pick(GLOB.last_names)]"
	return name

/datum/species/golem/get_physical_attributes()
	return "Golems are hardy creatures made out of stone, which are thus naturally resistant to many dangers, including asphyxiation, fire, radiation, electricity, and viruses.\
		They gain special abilities depending on the type of material consumed, but they need to consume material to keep their body animated."

/datum/species/golem/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "user-shield",
		SPECIES_PERK_NAME = "Lithoid",
		SPECIES_PERK_DESC = "Lithoids are creatures made out of minerals instead of \
			blood and flesh. They are strong and immune to many environmental and personal dangers \
			such as fire, radiation, lack of air, lava, viruses, and dismemberment.",
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "gem",
		SPECIES_PERK_NAME = "Metamorphic Rock",
		SPECIES_PERK_DESC = "Consuming minerals can grant Lithoids temporary benefits based on the type consumed.",
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "pickaxe",
		SPECIES_PERK_NAME = "Natural Miners",
		SPECIES_PERK_DESC = "Golems can see dimly in the dark, sense minerals, and mine stone with their bare hands. \
			They can even smelt ores in an internal furnace, if their surrounding environment is hot enough.",
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "bolt",
		SPECIES_PERK_NAME = "Anima",
		SPECIES_PERK_DESC = "Maintaining the force animating stone is taxing. Lithoids must eat frequently \
			in order to avoid returning to inanimate statues, and only derive nutrition from eating minerals.",
	))

	return to_add
