/datum/species/human
	name = "Human"
	id = SPECIES_HUMAN
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,HAS_FLESH,HAS_BONE)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_CAN_USE_FLIGHT_POTION,
	)
	mutant_bodyparts = list("wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW | CLOTH
	liked_food = JUNKFOOD | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 1

	pref_species_desc = "Humans are the dominant species in the known galaxy. \
		Their kind extend from old Earth to the edges of known space."

	pref_species_lore = "These primate-descended creatures, originating from the mostly harmless Earth, \
		have long-since outgrown their home and semi-benign designation. \
		The space age has taken humans out of their solar system and into the galaxy-at-large. \
		In traditional human fashion, this near-record pace from terra firma to the final frontier spat \
		in the face of other races they now shared a stage with. \
		This included the lizards - if anyone was offended by these upstarts, it was certainly lizardkind. \
		Humanity never managed to find the kind of peace to fully unite under one banner like other species. \
		The pencil and paper pushing of the UN bureaucrat lives on in the mosaic that is TerraGov; \
		a composite of the nation-states that still live on in human society. \
		The human spirit of opportunity and enterprise continues on in its peak form: \
		the hypercorporation. Acting outside of TerraGov's influence, literally and figuratively, \
		hypercorporations buy the senate votes they need and establish territory far past the Earth Government's reach. \
		In hypercorporation territory company policy is law, giving new meaning to \"employee termination\".",

/datum/species/human/New()
	if(CONFIG_GET(number/default_laws) == 0)
		ADD_PREF_PERK(pref_species_positives, "robot", "Asimov Superiority", \
			"The AI and their cyborgs are, by default, subservient only \
			to humans. As a human, silicons are required to both protect and obey you." \
		)

	if(CONFIG_GET(flag/enforce_human_authority))
		ADD_PREF_PERK(pref_species_positives, "bullhorn", "Chain of Command","Nanotrasen only recognizes humans for command roles, such as Captain.")

	return ..()

/datum/species/human/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hairstyle = "Business Hair"
	human.hair_color = "#bb9966" // brown
	human.update_hair()

/datum/species/human/get_scream_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		if(prob(1))
			return 'sound/voice/human/wilhelm_scream.ogg'
		return pick('sound/voice/human/malescream_1.ogg',
					'sound/voice/human/malescream_2.ogg',
					'sound/voice/human/malescream_3.ogg',
					'sound/voice/human/malescream_4.ogg',
					'sound/voice/human/malescream_5.ogg',
					'sound/voice/human/malescream_6.ogg')
	return pick('sound/voice/human/femalescream_1.ogg',
				'sound/voice/human/femalescream_2.ogg',
				'sound/voice/human/femalescream_3.ogg',
				'sound/voice/human/femalescream_4.ogg',
				'sound/voice/human/femalescream_5.ogg')
