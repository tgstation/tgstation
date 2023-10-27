/datum/artifact_origin
	///the path of our icon file used for overwrites
	var/icon_file_large = 'goon/icons/obj/artifacts/artifacts.dmi'
	var/icon_file_medium = 'goon/icons/obj/artifacts/artifactsitem.dmi'
	var/icon_file_small =  'goon/icons/obj/artifacts/artifactsitemS.dmi'
	///the amount of small items we got
	var/max_item_icons_small = 1
	///the base name of the sprite
	var/sprite_name = "null"

/datum/artifact_origin/wizard
	max_icons = 7
	max_item_icons = 7
	max_item_icons_small = 7
	sprite_name = "wizard"
	activation_sounds = list('goon/sounds/machines/ArtifactWiz1.ogg')

/datum/artifact_origin/narsie
	max_icons = 7
	max_item_icons = 7
	max_item_icons_small = 7
	sprite_name = "eldritch"
	activation_sounds = list('goon/sounds/machines/ArtifactEld1.ogg','goon/sounds/machines/ArtifactEld2.ogg')

/datum/artifact_origin/silicon
	max_icons = 7
	max_item_icons = 7
	max_item_icons_small = 7
	sprite_name = "ancient"

/datum/artifact_origin/precursor
	type_name = ORIGIN_PRECURSOR
	name = "Precursor"
	sprite_name = "precursor"
	activation_sounds = list('goon/sounds/machines/ArtifactPre1.ogg')
	adjectives = list("quirky","metallic","janky","bulky","chunky","cumbersome","unwieldy")
	nouns_large = list("contraption","machine","object","mechanism","artifact","machinery","structure")
	nouns_small = list("widget","thingy","device","appliance","mechanism","accessory","gizmo")
	touch_descriptors = list("It feels warm.","It feels cold.","It is suprisingly pleasant to touch.",
	"You can feel a faint pulsing.")
	destroy_message = "sputters violently, falling apart!"
	max_icons = 7
	max_item_icons = 7
	max_item_icons_small = 7
