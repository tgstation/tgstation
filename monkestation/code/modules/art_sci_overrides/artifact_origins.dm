/datum/artifact_origin
	///the path of our icon file used for overwrites
	var/icon_file_large = 'goon/icons/obj/artifacts/artifacts.dmi'
	var/icon_file_medium = 'goon/icons/obj/artifacts/artifactsitem.dmi'
	var/icon_file_small =  'goon/icons/obj/artifacts/artifactsitemS.dmi'
	///the amount of small items we got
	var/max_item_icons_small = 1
	/// amount of sprites we have for this origin
	var/max_icons = 1
	/// amount of sprites we have for this origins items
	var/max_item_icons = 1

	///the base name of the sprite
	var/sprite_name = "generic-sprite"
	var/type_name = "Generic Origin"
	var/name = "unknown"

	//sounds
	var/list/activation_sounds = list()
	var/list/deactivation_sounds = list()

	///stored array of all naming vars for this origin prevents making new vars for new naming storage. And allows us to access without making a new var inside procs
	var/list/name_vars = list(
		"adjectives" = list(),
		"small-nouns" = list(),
		"large-nouns" = list(),
	)
	var/touch_descriptors = list()
	var/destroy_message = ""

	//visual lists
	var/list/overlays_reds = list(225, 255)
	var/list/overlays_greens = list(225, 255)
	var/list/overlays_blues = list(225, 255)
	var/list/overlays_alpha = list(225, 255)

/datum/artifact_origin/proc/generate_name()
	return FALSE

/datum/artifact_origin/wizard
	max_icons = 7
	max_item_icons = 7
	max_item_icons_small = 7
	sprite_name = "wizard"
	activation_sounds = list(
		'goon/sounds/machines/ArtifactWiz1.ogg'
	)
	type_name = ORIGIN_WIZARD
	name = "Wizard"

	name_vars = list(
		"adjectives" = list(
			"imposing",
			"regal",
			"majestic",
			"beautiful",
			"shiny",
		),
		"large-nouns" = list(
			"jewel",
			"crystal",
			"sculpture",
			"statue",
			"ornament",
		),
		"small-nouns" = list(
			"staff",
			"pearl",
			"rod",
			"cane",
			"wand",
			"trophy",
		),
		"jewels" = list(
			"diamond",
			"pearl",
			"topaz",
			"ruby",
			"sapphire",
			"opal",
		),
		"object" = list(
			"crown",
			"trophy",
			"staff",
			"boon",
			"token",
			"amulet",
		),
		"aspect" = list(
			"Yendor",
			"wonder",
			"eminence",
			"grace",
			"plenty",
			"mystery",
		),
	)
	touch_descriptors = list("It feels warm.", "Its pleasant to touch.", "It feels smooth.")
	destroy_message = "shatters, and disintegrates!"

	overlays_reds = list(40, 130)
	overlays_greens = list(130, 255)
	overlays_blues = list(130, 255)
	overlays_alpha = list(130, 255)

/datum/artifact_origin/wizard/generate_name()
	return "[pick(name_vars["jewels"])] [pick(name_vars["object"])] of [pick(name_vars["aspect"])]"

/datum/artifact_origin/narsie
	max_icons = 7
	max_item_icons = 7
	max_item_icons_small = 7
	sprite_name = "eldritch"
	activation_sounds = list(
		'goon/sounds/machines/ArtifactEld1.ogg',
		'goon/sounds/machines/ArtifactEld2.ogg'
	)
	type_name = ORIGIN_NARSIE
	name = "Eldritch"
	name_vars = list(
		"adjectives" = list(
			"imposing",
			"sharp-edged",
			"terrifying",
			"jagged",
			"dark",
		),
		"large-nouns" = list(
			"obelisk",
			"altar",
			"sculpture",
			"statue",
			"ornament",
		),
		"small-nouns" = list(
			"staff",
			"pearl",
			"rod",
			"cane",
			"wand",
			"trophy",
		),
	)
	touch_descriptors = list("It feels cold.", "Its rough to the touch.", "You prick yourself on its rough surface!")
	destroy_message = "warps on itself, vanishing from sight!"
	overlays_reds = list(40, 255)
	overlays_greens = list(40, 255)
	overlays_blues = list(40, 255)

/datum/artifact_origin/silicon
	max_icons = 7
	max_item_icons = 7
	max_item_icons_small = 7
	sprite_name = "ancient"
	type_name = ORIGIN_SILICON
	name = "Ancient"
	activation_sounds = list(
		'goon/sounds/machines/ArtifactAnc1.ogg'
	)
	name_vars = list(
		"adjectives" = list(
			"cold",
			"smooth",
			"humming",
			"droning",
		),
		"large-nouns" = list(
			"monolith",
			"slab",
			"obelisk",
			"pylon",
		),
		"small-nouns" = list(
			"mechanism",
			"apparatus",
			"device",
			"implement",
			"doohickey",
		),
	)
	touch_descriptors = list("It feels cold.","Touching it makes you feel uneasy..","It feels smooth.")
	destroy_message = "sputters violently, falling apart!"

/datum/artifact_origin/silicon/generate_name()
	return "Unit-[pick(GLOB.phonetic_alphabet)] [pick(GLOB.phonetic_alphabet)] [rand(0,9000)]"

/datum/artifact_origin/precursor
	type_name = ORIGIN_PRECURSOR
	name = "Precursor"
	sprite_name = "precursor"
	activation_sounds = list(
		'goon/sounds/machines/ArtifactPre1.ogg'
	)
	name_vars = list(
		"adjectives" = list(
			"quirky",
			"janky",
			"bulky",
			"chunky",
			"cumbersome",
		),
		"large-nouns" = list(
			"contraption",
			"mechanism",
			"structure",
			"machinery",
		),
		"small-nouns" = list(
			"gizmo",
			"appliance",
			"device",
			"widget",
			"thingy",
		),
	)

	touch_descriptors = list("It feels warm.","It feels cold.","It is suprisingly pleasant to touch.",
	"You can feel a faint pulsing.")
	destroy_message = "sputters violently, falling apart!"
	max_icons = 7
	max_item_icons = 7
	max_item_icons_small = 7

/datum/artifact_origin/martian
	type_name = ORIGIN_MARTIAN
	sprite_name = "martian"
	name = "Martian"
	activation_sounds = list(
		'goon/sounds/machines/ArtifactMar1.ogg',
		'goon/sounds/machines/ArtifactMar2.ogg'
	)
	name_vars = list(
		"adjectives" = list(
			"squishy",
			"gooey",
			"quivering",
			"fleshy",
			"twitching",
		),
		"large-nouns" = list(
			"organ",
			"pile",
			"heap",
			"glob",
		),
		"small-nouns" = list(
			"lump",
			"nugget",
			"cluster",
			"clod",
			"organiod",
		),
		"doctor-prefix" = list(
			"cardio",
			"neuro",
			"physio",
			"brachio",
			"bronchi",
			"dermo"
		),
		"medical-lingo" = list(
			"genetic",
			"metabolic",
			"vascular",
			"muscular",
		),
		"erators" = list(
			"suppressor",
			"regenerator",
			"depressor",
			"compressor",
		),
	)
	touch_descriptors = list(
		"It feels warm.",
		"It feels gross.", 
		"It feels incredibly slimy", 
		"You can feel it pulsating"
	)
	max_icons = 7
	max_item_icons = 7
	max_item_icons_small = 7
	// for name generation


/datum/artifact_origin/martian/generate_name()
	return "[pick(name_vars["doctor-prefix"])][pick(name_vars["medical-lingo"])] [pick(name_vars["erators"])]"
