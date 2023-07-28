/datum/species/akula
	// Slugcats from Rain World, revamped to fit into
	name = "\improper Akula"
	plural_form = "\improper Akulae"
	id = SPECIES_AKULA
	//old traits as we migrate to the new setup
	/*species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		HAIR,
		LIPS,
		USE_TRICOLOR_ALPHA,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTCOLD,
	)*/
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_TACKLING_TAILED_DEFENDER,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTCOLD,
		USE_TRICOLOR_ALPHA,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	species_language_holder = /datum/language_holder/synthetic

	mutant_bodyparts = list("bodymarks_akula" = "None")
	external_organs = list(
		/obj/item/organ/external/horns/akula = "Perky",
		/obj/item/organ/external/snout/akula = "Full Snout",
		/obj/item/organ/external/tail/akula = "Shark",
	)
	//mutanteyes = /obj/item/organ/internal/eyes/slugcat

	coldmod = 0.5
	heatmod = 1.5

	bodytemp_normal = BODYTEMP_NORMAL - 30
	bodytemp_heat_damage_limit = BODYTEMP_NORMAL + 10
	bodytemp_cold_damage_limit = BODYTEMP_NORMAL - 70

	payday_modifier = 1 //we're going to be doing a master_files override to universally set payday mod to 1 bcuz it's still some serious wtfery

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	// NOTE- subtype tongue/ and add mutanttongue to replace these later
	//disliked_food = JUNKFOOD | BUGS
	//liked_food = MEAT | SEAFOOD
	//scugs have forced digi thru custom legs, this is necessary until we rework the digi_customization setting to allow for other digileg types
	//digitigrade_customization = DIGITIGRADE_FORCED

	ass_image = 'icons/ass/asslizard.png' //one day this system gets deleted.  one day...

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/akula,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/akula,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/akula,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/akula,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/akula,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/akula,
	)

/datum/species/akula/random_name(gender,unique,lastname)
	return "Pick your own name!"

/datum/species/akula/randomize_features(mob/living/carbon/human/human_mob)
	human_mob.undershirt = random_undershirt(human_mob.gender)
	human_mob.underwear = random_underwear(human_mob.gender)
	human_mob.socks = random_socks(human_mob.gender)
	human_mob.hairstyle = random_hairstyle(human_mob.gender)
	randomize_external_organs(human_mob)

/datum/species/akula/get_scream_sound(mob/living/carbon/human/lizard)
	return pick(
		'modular_skyraptor/modules/species_slugcat/sounds/scugscream_1.ogg',
	)

/datum/species/akula/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load)
	// so far i don't think they need any special abilities here
	return ..()


/// Pretty UI stuff goes here.
/datum/species/akula/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	/*human_for_preview.hairstyle = "Messy"
	human_for_preview.hair_color = "#365904"
	human_for_preview.dna.features["mcolor"] = "#87a629"
	human_for_preview.eye_color_left = "#39c9e6"
	human_for_preview.eye_color_right = "#ffd659"*/
	var/obj/item/organ/external/snout_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/snout/akula)
	if(snout_tmp)
		snout_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/snouts/akula/fullsnout)
		snout_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/snouts/akula/fullsnout() //do NOT do this this is bad and ugly
	var/obj/item/organ/external/horns_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/horns/akula)
	if(horns_tmp)
		horns_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/horns/akula/perky)
		horns_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/horns/akula/perky()
	var/obj/item/organ/external/tail_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/tail/akula)
	if(tail_tmp)
		tail_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/tails/akula/shark)
		tail_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/tails/akula/shark()
	human_for_preview.update_body_parts()

/datum/species/akula/get_species_description()
	return "Tall, lithe beasts from the subsurface caverns & oceans of Ceres, innermost dwarf planet of the Sol system.  \
		Impressive in stature, resilient to cold & thin atmospheres, yet frail of strength, the Akula's shark-like appearance lives rent-free in many Terran minds.  \
		Despite their appearances, they are gentle omnivores, hunters only of adventure, preferring to experience worlds so vibrant and unalike their own."

/datum/species/akula/get_species_lore()
	return list(
		"Obligate carnivores turned omnivores, the Akula are natives to the subsurface ocean & cave systems of the dwarf planet Ceres, which sits between Sol III and Sol IV.  \
			Discovered by early robotic exploration missions, the Akula made the first diplomatic overtures by trailing one of the drones to its recharge site & making cave art while it was offline, \
			depicting curiosity about the newcomers to their frigid homeworld.",

		"Despite initial trepedation on the part of the Terrans - after all, the Akula look more like sharks than anything else - they eventually sent an exploration team to meet up, and quickly found the Akula to be remarkably hospitable.  \
			Despite their size advantage and being natives to this harsh environment your everyday earthling couldn't explore without protective gear, being the absolute leaders of their homeworld's ecosystem they'd grown accustomed to other life \
			posing very little threat to them, and this extended to humanity.  It wasn't long before translation efforts began & communication was established, and soon the first Akula ventured beyond their homeworld with the protection of custom-made \
			spacesuits and exowear from the explorers.",

		"Thus would quickly begin the new standard in space exploration efforts in the Sol system - being native to a cold, low-pressure and low-oxygen environment where solar radiation was heavier than anything Earth's surface saw, \
			the Akula fared much better in early space travel than their human counterparts.  While Earth wasn't nearly as much their forte - high gravity, and a thick, temperate atmosphere is mighty far from the cold they were used to, \
			they were nevertheless fascinated by Sol III and soon began to mingle freely amongst humankind.  It wasn't long before official diplomatic accords would follow, and in 2053, an alliance would be brokered - \
			officially recognizing the Akula as fellow sentient beings with equal rights to humanity, our planetary neighbours and equal in wanderlust to humanity.",

		"From there, things escalated quickly, and it wasn't long before the Akula became major players in Sol politics and exploration efforts, their natural resilience to the hazards of space making them the primary crew of most missions \
			going forward.  By 2100, anyone from the outside could likely be mistaken for assuming they were native to Earth itself - humanity and the Akula had well and truly integrated despite their differences.  They have remained a major part of \
			Sol politics moving forward, and claim the one and only title as being one of two original founding species from the Solar Federation.",
	)

/datum/species/akula/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add = list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-empty",
			SPECIES_PERK_NAME = "Frigid Native",
			SPECIES_PERK_DESC = "Being native to an icy dwarf planet with only subsurface pockets of atmosphere and water, Akula are resilient to low pressures and temperatures and can walk freely where others would need protective gear.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-hot",
			SPECIES_PERK_NAME = "Heat Averse",
			SPECIES_PERK_DESC = "Being good in the cold means suffering in the heat.  Sol standard of 293K is already a bit uncomfortable for them - too much hotter or higher pressure and they suffer, whereas your everyday human might not notice.",
		)
	)

	return to_add
