/datum/species/vox
	// Bird-like humanoids
	name = "Vox"
	id = "vox"
	eyes_icon = 'modular_skyrat/modules/customization/icons/mob/species/vox_eyes.dmi'
	limbs_icon = 'modular_skyrat/modules/customization/icons/mob/species/vox_parts_greyscale.dmi'
	say_mod = "shrieks"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAIR,FACEHAIR)
	inherent_traits = list(TRAIT_RESISTCOLD)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutantlungs = /obj/item/organ/lungs/vox
	mutantbrain = /obj/item/organ/brain/vox
	breathid = "n2"
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("legs" = "Digitigrade Legs", "snout" = "Vox", "tail" = "Vox", "spines" = ACC_RANDOM)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	liked_food = MEAT | FRIED
	outfit_important_for_life = /datum/outfit/vox
	species_language_holder = /datum/language_holder/vox
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/vox/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/datum/outfit/vox/O = new /datum/outfit/vox
	H.equipOutfit(O, visualsOnly)
	H.internal = H.get_item_for_held_index(2)
	H.update_internals_hud_icon(1)

/datum/species/vox/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_vox_name()

	var/randname = vox_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/vox/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	returned["mcolor"] = pick("7D8", "7DA", "7CD", "7DC")
	returned["mcolor2"] = pick("ED8", "EC8")
	returned["mcolor3"] = pick("222", "4EF", "4FB", "84F", "323")
	return returned

/datum/species/vox/get_random_body_markings(list/passed_features)
	var/name = pick("Vox", "Vox Hive", "Vox Nightling", "Vox Heart", "Vox Tiger")
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings
