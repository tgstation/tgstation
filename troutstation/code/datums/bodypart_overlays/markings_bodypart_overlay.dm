/datum/bodypart_overlay/simple/body_marking/anteater
	dna_feature_key = FEATURE_ANTEATER_MARKINGS
	applies_to = list(/obj/item/bodypart/chest)

/datum/bodypart_overlay/simple/body_marking/anteater/get_accessory(name)
	return SSaccessories.anteater_markings_list[name]
