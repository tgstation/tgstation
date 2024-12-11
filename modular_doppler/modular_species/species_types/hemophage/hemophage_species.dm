/// Some starter text sent to the Hemophage initially, because Hemophages have shit to do to stay alive.
#define HEMOPHAGE_SPAWN_TEXT "You are an [span_danger("Hemophage")]. You will slowly but constantly lose blood if outside of a closet-like object. If inside a closet-like object, or in pure darkness, you will slowly heal, at the cost of blood. You may gain more blood by grabbing a live victim and using your drain ability."


/datum/species/human/genemod/hemophage
	name = "Hemophage"
	id = SPECIES_HEMOPHAGE
	preview_outfit = /datum/outfit/hemophage_preview
	inherent_traits = list(
		TRAIT_NOHUNGER,
		TRAIT_NOBREATH,
		TRAIT_OXYIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_LITERATE,
		TRAIT_DRINKS_BLOOD,
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_HUMANOID | MOB_ORGANIC
	exotic_bloodtype = "U"
	mutantheart = /obj/item/organ/heart/hemophage
	mutantliver = /obj/item/organ/liver/hemophage
	mutantstomach = /obj/item/organ/stomach/hemophage
	mutanttongue = /obj/item/organ/tongue/hemophage
	mutantlungs = null
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	examine_limb_id = SPECIES_HUMAN
	skinned_type = /obj/item/stack/sheet/animalhide/human

/datum/species/human/genemod/hemophage/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE

	return ..()

/datum/species/human/genemod/hemophage/on_species_gain(mob/living/carbon/human/new_hemophage, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	to_chat(new_hemophage, HEMOPHAGE_SPAWN_TEXT)
	new_hemophage.update_body()

/datum/species/human/genemod/hemophage/get_species_description()
	return "Oftentimes feared or pushed out of society for the predatory nature of their condition, \
		Hemophages are typically mixed around various Frontier populations, keeping their true nature hidden while \
		reaping both the benefits and easy access to prey, enjoying unpursued existences on the Frontier."


/datum/species/human/genemod/hemophage/get_species_lore()
	return list(
		"Though known by many other names, 'Hemophages' are those that have found themselves the host of a bloodthirsty infection. 'Natural' hemophages have their infection first overtake their body through the bloodstream, though methods vary; \
		Hemophages thought to be a dense cluster of tightly related but distinct strains and variants. It will first take root in the chest, making alterations to the cells making up the host's organs to rapidly expand and take them over. \
		Lungs will deflate into nothingness, the liver becomes wrapped up and filled with corrupted tissue and the digestive organs will gear themselves towards the intake of the only meal they can have; blood. The host's heart will almost triple in size from this 'cancerous' tissue, forming an overgrown coal-black tumor that now keeps their body standing.",

		"The initial infection process in someone becoming a Hemophage can have varied effects and impacts, though there is a sort of timeline that crops up in the vast majority of cases. The process often begins with the steady decline of the host's heartrate into severe bradycardial agony as it begins to become choked with tumor tissue, chest pains and lightheadedness signaling the first stretch. \
		Fatigue, exercise intolerance, and near-fainting persist and worsen as the host's lungs slowly begin to atrophy; the second organ to normally be 'attacked' by the process. Coughing and hemoptysis will worsen and worsen until it suddenly stops, alongside the Hemophage's ability and need to continue breathing altogether.",

		"The ability to eat normal food becomes psychologically intolerable quickly after the infection fully takes root in their central nervous system, the tumor no longer holding interest in anything it cannot derive nutrients from. Foods once enjoyed by the host begin to taste completely revolting, many quickly developing an aversion to even try chewing it. \
		However, new desires quickly begin to form, the host's whole suite of senses rapidly adapting to a keen interest in blood. Hyperosmia in specific kicks in, the iron-tinged scent of a bleeder provoking and agitating hunger like the smell of any fresh cooking would for a human. \
		Not all blood aids the host the same. Its currently thought that a Hemophage is capable at a subconscious level of recognizing and differentiating different sources of blood, and the tumor within hijacking their psychology to prioritize blood from creatures it is able to reproduce inside of. \
		Blood from animals is reported to 'be like trying to subsist on milk or whipped cream or heavily fluffed up bread,' harder to digest, taste, or enjoy, necessitating the Hemophage to drink far more of it just to get the same value from a relatively small amount of human blood. \
		'Storebought' blood, like from refrigerated medical blood bags, is reported to 'taste thin,' like a heavily watered down drink. Only the physical, predatory act of drinking blood fresh from another humanoid is enough to properly 'sate' the tumor, ticking the right psychological and physiological boxes to be fully digested and enjoyed. \
		The sensation is like nothing else, being extremely pleasurable for the host; even if they don't want it to be.",

		"Photosensitivity of the skin develops. While light artificial or not won't harm them, it's noted that Hemophages seem to be far more comfortable in any level of darkness, their skin and eyes far more sensitive than before to UV. \
		When taken away from it, and ideally isolated from higher-than-average levels of radiation such as found in orbital habitats, it's noted that the host's body will begin to reconstruct with aid from the tumor inside. Flesh will knit back together, burns will rapidly cast off, and even scar tissue will properly regenerate into normal tissue. \
		It's thought that this process is even delicate enough to work at the host's DNA, prolonging epigenetic maintenance and ensuring biological systems remain healthy and youthful for far longer than normal. \
		Given that Hemophages are converted and kept alive by their infection, it will ruthlessly fight off foreign bacteria, viruses, and tissues, repurposing or annihilating them to ensure there's no 'competition' over its host. \
		Notably, the host's blood will turn almost black like ink due to their blood becoming more 'dense', yet no longer carrying nearly as much oxygen. Due to this hemophages are known to look more 'ashen', their lips often turning to a dark gray, and their skin going more pale than it normally would be. \
		Their tongues, not an organ the tumor spares, additionally turn a pure black; in some cases, the sclera in their eyes might even turn significantly dark especially when bloodshot.",

		"The psychology of Hemophages is well-studied in the psychiatric field. Over time, hemophages have developed a plethora of conditioned responses and quirks just as humans, their prey, have. \
		The first few years after a Hemophage is 'changed' is often enough to drive them over the edge. In some cases, the first few days. The process of being turned is a series of traumas in quick succession as the host is often made to murder. \
		The lucky have a 'moral' source of blood at hand and whoever 'converted' them to guide them through it; the unlucky have to scramble to maintain their sense of self as they become something else. \
		The physical sensation of first infection is often painful, often terrifying, and often grotesque to experience as the host feels their body shocked with vicious tumor tissue and their mind warped by near-death stretching over potentially days. \
		Some snap, some grow stone-hard, but it's rare to actually meet a Hemophage that remembers the process. Some hemophages are born into their condition; the infection staying dormant until the child is a few months to a year old, ensuring their stability in being able to handle the tumor. \
		These hosts tend to live extremely tumultuous childhoods, simply not being strong enough to feed on anything but the weakest of creatures, and trending towards immense loneliness from the high visibility of their condition's treatment during youth.",

		"The hunger is the main driver for these sordid creatures. From the very moment they wake back up from the process of being 'changed,' a powerful hunger is awakened. It twists and throbs in their heart, drowning out coherent thought. \
		During the 'semi-starvation' phase in humans, the changes are dramatic. Significant decreases in strength and stamina, body temperature, heart rate, and obsession with food. Dreaming and fantasizing about it, reading and talking about it, and savoring what little meals they can get access to; hoarding it for themselves and eating to the last crumb. \
		In Hemophages, this response is heavily similar, but turned outwards. The hunger of a Hemophage is psychologically pressing in nearly every way, detracting from all other concerns in an urge to be dealt with as soon as it can be. \
		Panic easily sets in during these times of famine, the host instinctually knowing that it must be sated or the tumor within them will soon run out of blood to feed on, which would result in their mutual death. \
		Even the very sight and smell of fresh blood can push a Hemophage into this kind of state if they haven't fed in awhile, only drinking from a living creature or intense meditation and concentration being able to push it down.",

		"Socially, Hemophages are mostly solitary hunters. It is extremely easy for them to recognize each other; the unique smell of their blackened ichor, the subtle details of their body and the way it moves, the shallow or nonexistant breathing, or even the likely smell of multiple victims' blood on their breath. \
		Even normal humans report talking to known Hemophages being psychologically unsettling, linked to being armed with the knowledge that they've likely taken several lives and might take theirs. \
		This predatory aura surrounding them tends to leave them operating primarily solitarily; always passively running threat analysis on others of their kind, especially given the higher 'value' of their more nutrient-rich blood. \
		When they do choose to work together, Hemophages gather in groups of no more than ten. Any more, and their activities would surely be impossible to disguise.",

		"'Conversion' tends to be uncommon for Hemophages. The typical line of thought is that one 'wouldn't want to raise a kid every time they go out for dinner,' as the 'creation' of a new Hemophage involves, essentially, becoming an on-site therapist and mentor for an unspecified amount of time. \
		It's often not worth the risk to potentially allow a fresh 'convert' to gain access to a Hemophage's identity if they're attempting to 'blend', and to potentially turn on them and expose their illegal activities. \
		However the infection which creates them, like any living creature, has a drive to procreate regardless; often the urge to spread it overtakes a hemophage's sensibilities anyway, and some are known to serially infect others simply to 'stir the pot.",

		"In terms of human society, it's known for Hemophages to be passively strangled by the law itself. In 'civilized' places like Sol, Hemophages that attack or kill humans for their blood are prosecuted heavily; almost disproportionately compared to if the same crimes were committed by a normal person. \
		Artificial sources of blood are intentionally kept rare by pharmaceutical companies, and those that do end up getting an easier access to such sources seem to almost always be working in the Medical field. \
		Even adopting pets is made nigh-on-impossible for them. Those that don't leave to places like frontier systems typically end up part of oft-ephemeral networks of others of their kind, offering time-sensitive advice on where certain 'low-risk' or 'less-than-legal' meals may be found and forcing themselves to work past their base instincts to cooperate to an extent; anything else would mean death."
	)


/datum/outfit/hemophage_preview
	name = "Hemophage (Species Preview)"
	uniform = /obj/item/clothing/under/suit/black_really/skirt

/datum/species/human/genemod/hemophage/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features["mcolor"] = skintone2hex("albino")
	human.dna.features["horns"] = "Lifted"
	human.dna.features["horns_color_1"] = "#52435e"
	human.dna.ear_type = HUMANOID
	human.dna.features["ears"] = "Elf (wide)"
	human.dna.features["ears_color_1"] = "#F7D1C3"
	human.hair_color = "#f1cc9c"
	human.lip_style = "lipstick"
	human.lip_color = COLOR_BLACK
	human.hairstyle = "Long Gloomy Bangs"
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body(TRUE)

/datum/species/human/genemod/hemophage/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Darkness Affinity",
			SPECIES_PERK_DESC = "A Hemophage is only at home in the darkness, the infection \
								within a Hemophage seeking to return them to a healthy state \
								whenever it can be in the shadow. However, light artificial or \
								otherwise irritates their bodies and the cancer keeping them alive, \
								not harming them but keeping them from regenerating. Modern \
								Hemophages have been known to use lockers as a convenient \
								source of darkness, while the extra protection they provide \
								against background radiations allows their tumor to avoid \
								having to expend any blood to maintain minimal bodily functions \
								so long as their host remains stationary in said locker.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Viral Symbiosis",
			SPECIES_PERK_DESC = "Hemophages, due to their condition, cannot get infected by \
								other viruses and don't actually require an external source of oxygen \
								to stay alive.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "The Thirst",
			SPECIES_PERK_DESC = "In place of eating, Hemophages suffer from the Thirst, caused by their tumor. \
								Thirst of what? Blood! Their tongue allows them to grab people and drink \
								their blood, and they will suffer severe consequences if they run out. As a note, \
								it doesn't matter whose blood you drink, it will all be converted into your blood \
								type when consumed. That being said, the blood of other sentient humanoids seems \
								to quench their Thirst for longer than otherwise-acquired blood would.",
		),
	)

	return to_add


/datum/species/human/genemod/hemophage/create_pref_blood_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "tint",
		SPECIES_PERK_NAME = "Universal Blood",
		SPECIES_PERK_DESC = "[plural_form] have blood that appears to be an amalgamation of all other \
							blood types, made possible thanks to some special antigens produced by \
							their tumor, making them able to receive blood of any other type, so \
							long as it is still human-like blood.",
		),
	)

	return to_add

/datum/species/human/genemod/hemophage/get_cry_sound(mob/living/carbon/human/hemophage)
	var/datum/species/human/human_species = GLOB.species_prototypes[/datum/species/human]
	return human_species.get_cry_sound(hemophage)

// We don't need to mention that they're undead, as the perks that come from it are otherwise already explicited, and they might no longer be actually undead from a gameplay perspective, eventually.
/datum/species/human/genemod/hemophage/create_pref_biotypes_perks()
	return


#undef HEMOPHAGE_SPAWN_TEXT
