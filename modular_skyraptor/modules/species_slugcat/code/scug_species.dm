#define SCUG_NAMES list("Survivor", "Monk", "Hunter", "Gourmand", "Artificer", "Rivulet", "Saint", "Guardian", "Protector", "Emissary", "Prophet", "Warrior", "Artist", "Explorer", "Wanderer", "Traveler", \
						"Cook", "Engineer", "Tinkerer", "Mage", "Magician", "Gardener", "Leader", "Guide", "Nomad", "Technomancer", "Vanguard", "Nymph", "Lancer", "Savage", "Florist", "Luminary", \
						"Apothecary", "Healer", "Inventor", "Coder", "Commander", "Beastmaster", "Attendant")

/datum/species/slugcat
	// Slugcats from Rain World, revamped to fit into
	name = "\improper Slugcat"
	plural_form = "Slugcats"
	id = SPECIES_SLUGCAT
	/*species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		HAIR,
		LIPS,
		USE_TRICOLOR_ALPHA,
	)*/
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_TACKLING_TAILED_DEFENDER,
		USE_TRICOLOR_ALPHA,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	species_language_holder = /datum/language_holder/slugcat_mark

	mutant_bodyparts = list("bodymarks_scug" = "None")
	external_organs = list(
		/obj/item/organ/external/horns/slugcat = "Standard",
		/obj/item/organ/external/snout/slugcat = "Standard",
		/obj/item/organ/external/tail/slugcat = "Standard",
		/obj/item/organ/external/frills/slugcat = "None",
	)
	mutanteyes = /obj/item/organ/internal/eyes/slugcat

	coldmod = 1
	heatmod = 1
	payday_modifier = 1 //we're going to be doing a master_files override to universally set payday mod to 1 bcuz it's still some serious wtfery

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	// see the other species, we need a new tongue for scugs.
	//disliked_food = DAIRY | SUGAR | FRIED
	//liked_food = GORE | MEAT | RAW
	//scugs have forced digi thru custom legs, this is necessary until we rework the digi_customization setting to allow for other digileg types
	//digitigrade_customization = DIGITIGRADE_FORCED

	ass_image = 'icons/ass/asslizard.png' //one day this system gets deleted.  one day...

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/slugcat,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/slugcat,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/slugcat,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/slugcat,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/slugcat,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/slugcat,
	)

/datum/species/slugcat/random_name(gender,unique,lastname)
	return "The [pick(SCUG_NAMES)]"

/datum/species/slugcat/randomize_features(mob/living/carbon/human/human_mob)
	human_mob.undershirt = random_undershirt(human_mob.gender)
	human_mob.underwear = random_underwear(human_mob.gender)
	human_mob.socks = random_socks(human_mob.gender)
	human_mob.hairstyle = random_hairstyle(human_mob.gender)
	randomize_external_organs(human_mob)

/datum/species/slugcat/get_scream_sound(mob/living/carbon/human/lizard)
	return pick(
		'modular_skyraptor/modules/species_slugcat/sounds/scugscream_1.ogg',
	)

/datum/species/slugcat/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load)
	var/mob/living/carbon/human/human_being = carbon_being
	if(human_being)
		to_chat(carbon_being, span_notice("The mark of communication be upon you."))
		if(!human_being.has_quirk(/datum/quirk/item_quirk/signer))
			human_being.add_quirk(/datum/quirk/item_quirk/signer)
		else
			to_chat(carbon_being, span_danger("You can't seem to sign any more than you already can.  (Did you take a duplicate Signer?)"))
		if(!human_being.has_quirk(/datum/quirk/mute))
			human_being.add_quirk(/datum/quirk/mute)
		else
			to_chat(carbon_being, span_danger("You can't seem to get any more mute.  (Did you take a duplicate Mute?)"))
	return ..()

/datum/species/slugcat/on_species_loss(mob/living/carbon/human/human_being, datum/species/old_species, pref_load)
	if(human_being.client)
		if(human_being.client.prefs)
			if(human_being.client.prefs.all_quirks)
				to_chat(human_being, span_danger("The mark of communication leaves you!"))
				// FOR THE LOVE OF GOD DON'T HARDCODE THESE IF YOU CAN HELP IT
				if("Signer" in human_being.client.prefs.all_quirks)
					human_being.remove_quirk(/datum/quirk/item_quirk/signer)
				else
					to_chat(human_being, span_notice("You never knew how to sign to begin with..."))
				if("Mute" in human_being.client.prefs.all_quirks)
					human_being.remove_quirk(/datum/quirk/mute)
				else
					to_chat(human_being, span_notice("You were never mute!  Whew."))
	return ..()


/// Pretty UI stuff goes here.
/datum/species/slugcat/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	//previews Saint
	human_for_preview.hairstyle = "Messy"
	human_for_preview.hair_color = "#365904"
	human_for_preview.dna.features["mcolor"] = "#87a629"
	human_for_preview.eye_color_left = "#39c9e6"
	human_for_preview.eye_color_right = "#ffd659"
	world.log << "SKYRAPTOR ALERT: SETTING UP SCUG PREVIEW"
	var/obj/item/organ/external/snout_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/snout/slugcat)
	if(snout_tmp)
		snout_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/snouts/slugcat/standard)
		snout_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/snouts/slugcat/standard() //do NOT do this this is bad and ugly
	var/obj/item/organ/external/horns_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/horns/slugcat)
	if(horns_tmp)
		horns_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/horns/slugcat/standard)
		horns_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/horns/slugcat/standard()
	var/obj/item/organ/external/tail_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/tail/slugcat)
	if(tail_tmp)
		tail_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/tails/slugcat/standard)
		tail_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/tails/slugcat/standard()
	human_for_preview.update_body_parts()

/datum/species/slugcat/get_species_description()
	return "Nimble omnivores with chronic mutism and a natural aptitude for talking to machines, the Slugcats are a rare sight in systems far from their homeworld of Talon III.  \
		Genetically engineered over untold cycles by their AI caretakers, the Iterators, Slugcats are crafty and intelligent, with incredible capabilities yet incredible fragility, \
		still carrying the scars of their homeworld's brush with death."

/datum/species/slugcat/get_species_lore()
	return list(
		"Nimble omnivores, both predator and prey, they served as the eyes and ears of the Iterators as they worked to uncover the secrets of their progenitor species, the Ancients.  \
			Over time, Iterators began to see Slugcats as more than mere servants, treating them as friends and trusted allies despite their small stature.  Gazes At Satellites, the leader \
			of the Primary Group began a research project in tandem with 6 Small Stones to uplift the Slugcats to a more sturdy form.",

		"After many cycles of genetic engineering and aid towards guided evolution, Slugcats have ascended to a more recognizable humanoid form, trading some of their nimbleness for craftiness \
			and intelligence to more than rival their most notable compeititors, the Scavs.  When SolFed exploration probes entered orbit of Tallon III, they were contacted by Gazes At Satellites, \
			and soon Slugcats entered the collective consciousness of the Solar Federation.",

		"Slugcats remain uncommonly seen beyond the Talon system, as their numbers remain few despite improvements that have been made to the safety and stability of the so-called \"Rain World's\" eco-system.  \
			As such, those who do choose to venture beyond their world must do so with their Iterator's express approval and guidance, and typically seek employ and residence within SolFed outposts near the Talon system.  \
			Slugcats who venture beyond Talon III typically retain the titles given to them by their tribe & Iterator, such as \"The Hunter\" or \"The Artificer\", although some take on the names given to them by their compatriots beyond the stars.",
	)

/datum/species/slugcat/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hands",
			SPECIES_PERK_NAME = "Natural Signer",
			SPECIES_PERK_DESC = "As a species of mutes, Slugcats communicate almost solely through sign language.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-robot",
			SPECIES_PERK_NAME = "Mark of Communication",
			SPECIES_PERK_DESC = "All slugcats who leave Talon III must receive the Mark of Communication from their Iterator, letting them understand artificial tongues.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "message-slash",
			SPECIES_PERK_NAME = "Hereditary Mutism",
			SPECIES_PERK_DESC = "Slugcats' vocal chords are almost completely deteriorated after untold cycles of hiding from predators, rendering them almost completely mute.",
		),
	)

	return to_add
