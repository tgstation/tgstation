/datum/species/avalari
	// Teshari/Avali, SPRITED BESPOKE.  FLEXING FLEXING FLEXING
	name = "\improper Avali"
	plural_form = "Avali"
	id = SPECIES_AVALARI
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_TACKLING_TAILED_DEFENDER,
		USE_TRICOLOR_ALPHA,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	species_language_holder = /datum/language_holder/teshvali

	mutant_bodyparts = list("bodymarks_avalari" = "Underbelly")
	external_organs = list(
		/obj/item/organ/external/horns/avalari = "Upright",
		/obj/item/organ/external/snout/avalari = "Standard",
		/obj/item/organ/external/tail/avalari = "Fluffy",
		///obj/item/organ/external/frills/avalari = "None",
	)
	mutanteyes = /obj/item/organ/internal/eyes/avalari

	coldmod = 0.25
	heatmod = 1.5
	payday_modifier = 1 //we're going to be doing a master_files override to universally set payday mod to 1 bcuz it's still some serious wtfery

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	//disliked_food = SEAFOOD | JUNKFOOD
	//liked_food = GORE | MEAT
	//normal digilegs vs. non-digilegs do not apply here since teshis have completely unique legs

	ass_image = 'icons/ass/asslizard.png' //not even bothering to change this, fuck you

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/avalari,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/avalari,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/avalari,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/avalari,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/avalari,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/avalari,
	)

/datum/species/avalari/random_name(gender,unique,lastname)
	return "The Undefined"

/datum/species/avalari/randomize_features(mob/living/carbon/human/human_mob)
	/*human_mob.undershirt = random_undershirt(human_mob.gender)
	human_mob.underwear = random_underwear(human_mob.gender)
	human_mob.socks = random_socks(human_mob.gender)
	human_mob.hairstyle = random_hairstyle(human_mob.gender)*/
	randomize_external_organs(human_mob)

/datum/species/avalari/get_scream_sound(mob/living/carbon/human/lizard)
	return pick(
		'modular_skyraptor/modules/species_teshvali/sounds/teshvali_scream1.ogg',
	)

/datum/species/avalari/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load)
	//i don't think we need this right now
	/*var/mob/living/carbon/human/human_being = carbon_being
	if(human_being)
		to_chat(carbon_being, span_notice("The mark of communication be upon you."))
		if(!human_being.has_quirk(/datum/quirk/item_quirk/signer))
			human_being.add_quirk(/datum/quirk/item_quirk/signer)
		else
			to_chat(carbon_being, span_danger("You can't seem to sign any more than you already can.  (Did you take a duplicate Signer?)"))
		if(!human_being.has_quirk(/datum/quirk/mute))
			human_being.add_quirk(/datum/quirk/mute)
		else
			to_chat(carbon_being, span_danger("You can't seem to get any more mute.  (Did you take a duplicate Mute?)"))*/
	return ..()

/datum/species/avalari/on_species_loss(mob/living/carbon/human/human_being, datum/species/old_species, pref_load)
	/*if(human_being.client)
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
					to_chat(human_being, span_notice("You were never mute!  Whew."))*/
	return ..()


/// Pretty UI stuff goes here.
/datum/species/avalari/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	//previews Saint
	/*human_for_preview.hairstyle = "Messy"
	human_for_preview.hair_color = "#365904"
	human_for_preview.dna.features["mcolor"] = "#87a629"
	human_for_preview.eye_color_left = "#39c9e6"
	human_for_preview.eye_color_right = "#ffd659"*/
	world.log << "SKYRAPTOR ALERT: SETTING UP AVALARI PREVIEW"
	var/obj/item/organ/external/snout_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/snout/avalari)
	if(snout_tmp)
		snout_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/snouts/avalari/standard)
		snout_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/snouts/avalari/standard() //do NOT do this this is bad and ugly
	var/obj/item/organ/external/horns_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/horns/avalari)
	if(horns_tmp)
		horns_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/horns/avalari/upright)
		horns_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/horns/avalari/upright()
	var/obj/item/organ/external/tail_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/tail/avalari)
	if(tail_tmp)
		tail_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/tails/avalari/fluffy)
		tail_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/tails/avalari/fluffy()
	human_for_preview.update_body_parts()

/datum/species/avalari/get_species_description()
	return "Small of stature but bold of spirit, the Avali hail from a distant icemoon and whoop ass with technological superiority.  Lore to be determined."

/datum/species/avalari/get_species_lore()
	return list(
		"TODO: AVALI LORE",
	)

/datum/species/avalari/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Mighty Wingspan",
			SPECIES_PERK_DESC = "These raptors' wings are capable of flight in low to no gravity environments with sufficient atmosphere, such as during gravgen failures or on the surface of moons.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Custom Tailored",
			SPECIES_PERK_DESC = "Not everybody tailors for these tiny raptors' unique bodytype!  Certain undersuits, oversuits, shoes, armor, etc, will be unable to fit on your body - you'll have to find substitutions that do!",
		),
	)

	return to_add
