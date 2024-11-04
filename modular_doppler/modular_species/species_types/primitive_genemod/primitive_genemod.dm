/mob/living/carbon/human/species/genemod/primitive
	race = /datum/species/human/genemod/primitive

/datum/language_holder/primitive_genemod
	understood_languages = list(
		/datum/language/primitive_genemod = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/primitive_genemod = list(LANGUAGE_ATOM),
	)
	selected_language = /datum/language/primitive_genemod

/datum/species/human/genemod/primitive
	name = "Hearthkin"
	id = SPECIES_GENEMOD_PRIMITIVE
	preview_outfit = /datum/outfit/genemod_primitive_preview

	mutantlungs = /obj/item/organ/lungs/icebox_adapted
	mutanteyes = /obj/item/organ/eyes/low_light_adapted

	species_language_holder = /datum/language_holder/primitive_genemod
	language_prefs_whitelist = list(/datum/language/primitive_genemod)

	bodytemp_normal = 270 // If a normal human gets hugged by one it's gonna feel cold
	bodytemp_heat_damage_limit = 283 // To them normal station atmos would be sweltering
	bodytemp_cold_damage_limit = 213 // Man up bro it's not even that cold out here

	inherent_traits = list(
		TRAIT_ANIMALISTIC,
		TRAIT_VIRUSIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_MUTANT_COLORS,
	)

/datum/outfit/genemod_primitive_preview
	name = "Primitive Gene-Mod (Species Preview)"
	uniform = /obj/item/clothing/under/dress/skirt/primitive_genemod_body_wraps
	neck = /obj/item/clothing/neck/scarf/primitive_genemod_scarf
	back = /obj/item/forging/reagent_weapon/axe/fake_copper

/datum/species/human/genemod/primitive/on_species_gain(mob/living/carbon/new_primitive, datum/species/old_species, pref_load)
	. = ..()
	var/mob/living/carbon/human/hearthkin = new_primitive
	if(!istype(hearthkin))
		return
	hearthkin.dna.add_mutation(/datum/mutation/human/olfaction, MUT_NORMAL)
	hearthkin.dna.activate_mutation(/datum/mutation/human/olfaction)

    	// >mfw I take mutadone and my nose clogs
	var/datum/mutation/human/olfaction/mutation = locate() in hearthkin.dna.mutations
	mutation.mutadone_proof = TRUE
	mutation.instability = 0

/datum/species/human/genemod/primitive/on_species_loss(mob/living/carbon/former_primitive, datum/species/new_species, pref_load)
	. = ..()
	var/mob/living/carbon/human/hearthkin = former_primitive
	if(!istype(hearthkin))
		return
	hearthkin.dna.remove_mutation(/datum/mutation/human/olfaction)

/datum/species/human/genemod/primitive/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.dna.ear_type = CAT
	human_for_preview.dna.features["ears"] = "Coeurl"
	human_for_preview.dna.features["ears_color_1"] = "#e9eff5"
	human_for_preview.dna.features["ears_color_2"] = "#f5afaf"
	human_for_preview.dna.features["ears_color_3"] = "#222222"
	human_for_preview.set_haircolor("#E9EFF5", update = FALSE)
	human_for_preview.set_hairstyle("Fluffy long", update = TRUE)
	human_for_preview.dna.features["mcolor"] = skintone2hex("albino")
	human_for_preview.eye_color_left = "#96dbe7"
	human_for_preview.eye_color_right = "#96dbe7"
	regenerate_organs(human_for_preview)
	human_for_preview.update_body(is_creating = TRUE)

/datum/species/human/genemod/primitive/get_species_description()
	return list(
		"Genetically modified humanoids believed to be descendants of a now centuries old colony \
			ship from the pre-bluespace travel era. Still having at least some human traits, they \
			are most comparable to today's felinids with most sporting features likely spliced from \
			the icemoon's many fauna."
	)

/datum/species/human/genemod/primitive/get_species_lore()
	return list(
		"The Hearthkin are a culture of disparate Scandinavian groups all sharing a common origin \
			as descendents from demihuman genemodders aboard the good ship Stjarndrakkr, or Star Dragon; \
			an enormous colony ship almost 40km tall. This ship first reached the orbit of its last \
			resting place three hundred years ago, before the advent of bluespace travel; coming from \
			a world known to the Hearthkin as 'Asgard.' When it reached the atmosphere of the ice moon, \
			or 'Niflheim' as they consider it, the vessel detonated in low orbit for unknown reasons. \
			Large sections of the Star Dragon broke up and sealed themselves, \
			coming to a rest all over the moon itself.",

		"At first, life was incredibly difficult for the would-be colonists. Generations were very short, \
			and most of the personnel able to even fix the vessel had died either on impact, or later on. \
			While their genetic modifications and pre-existing comfort in frozen climates somewhat helped them, \
			the Ancestors were said to have made one last desperate move to put all their resources together to \
			fully modify and adapt themselves to the climes of Niflheim; forever.",

		"Nowadays, the Hearthkin are removed from the original culture of the Ancestors, building one all of their own. \
			Many of the original, largest segments of the Star Dragon are buried under ice and snow, and the Hearthkin have \
			created a culture of building separate dwellings to keep them secret. Dwelling in longhouses and sleeping in the \
			warm undergrounds of Niflheim, and hunting native creatures and those coming from portals to the moon's planet; \
			Muspelheim. Their pagan faith has strengthened over the centuries, from occasional prayers for a blizzard to end \
			soon, to now full-on worship and sacrifices to their various Gods. Hearthkin still hold immense reverence for their \
			Ancestors, but tend to have varying opinions and speculation on what exactly they were like, and why they came to \
			Niflheim in the first place.",

		"Their names are two-part; a birth name, and a title. Their birth names still hold resemblance to 'Asgardian' culture, \
			typically a Nordic name such as 'Solveig Helgasdottir,' or 'Bjorn Lukasson.' However, their last name is then exchanged \
			for a 'Title' when the Hearthkin is no longer 'Unproven.' These are a two-parter, based on either great deeds, \
			embarrassing moments, or aspects of the person's personality. Some examples would be 'Soul-Drowner' after the night of \
			a Hearthkin drinking herself half-dead, or one might be known as 'Glacier-Shaped' for being abnormally large. \
			These titles are always given by ones' kin.",

		"The Hearth itself is an area that the kindred hold incredibly sacred, primarily hating Outsiders for more \
			practical reasons. They think themselves as having been there first, many of them knowing they were 'promised' \
			Niflheim by the Ancestors. Unlike the Ashwalkers of Muspelheim, the Hearthkin are a more technologically \
			advanced society; having use for not only metal, but gold and silver for accessory. They are known to employ \
			artifacts thought to be of either the planet their moon orbits, or leftovers from their Ancestors; however, for \
			a variety of reasons from Kin to Kin, they tend to shy away from using modern human technology.",

		"Physically, the Hearthkin always come in the form of demihumans; appearing similar to normal Earthlings, \
			but with the tails, ears, and sometimes limbs of various arctic animals; wolves, bears, and felines to only name a few. \
			They seem perfectly adapted to their lands of ice and mist, but find even the mild controlled temperatures of \
			Port Authority stations to be swelteringly hot. Their view of 'station' genemodders is that of 'halflings': \
			Ancestral bodies, but with the blood and spirit of the humans of Midgard, \
			tending to look down on them even more than other aliens.",
	)
