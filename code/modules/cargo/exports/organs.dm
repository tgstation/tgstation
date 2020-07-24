/datum/export/organ
	include_subtypes = FALSE	//CentCom doesn't need organs from non-humans.
	export_category = EXPORT_CONTRABAND

/datum/export/organ/heart
	cost = 10 //For the man who has everything and nothing.
	unit_name = "humanoid heart"
	export_types = list(/obj/item/organ/heart)

/datum/export/organ/eyes
	cost = 5
	unit_name = "humanoid eyes"
	export_types = list(/obj/item/organ/eyes)

/datum/export/organ/ears
	cost = 5
	unit_name = "humanoid ears"
	export_types = list(/obj/item/organ/ears)

/datum/export/organ/liver
	cost = 5
	unit_name = "humanoid liver"
	export_types = list(/obj/item/organ/liver)

/datum/export/organ/lungs
	cost = 5
	unit_name = "humanoid lungs"
	export_types = list(/obj/item/organ/lungs)

/datum/export/organ/stomach
	cost = 5
	unit_name = "humanoid stomach"
	export_types = list(/obj/item/organ/stomach)

/datum/export/organ/tongue
	cost = 5
	unit_name = "humanoid tounge"
	export_types = list(/obj/item/organ/tongue)
