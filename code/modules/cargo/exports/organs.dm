/datum/export/organ
	include_subtypes = FALSE //CentCom doesn't need organs from non-humans.

/datum/export/organ/heart
	cost = CARGO_CRATE_VALUE * 0.2 //For the man who has everything and nothing.
	unit_name = "humanoid heart"
	export_types = list(/obj/item/organ/heart)

/datum/export/organ/eyes
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "humanoid eyes"
	export_types = list(/obj/item/organ/eyes)

/datum/export/organ/ears
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "humanoid ears"
	export_types = list(/obj/item/organ/ears)

/datum/export/organ/liver
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "humanoid liver"
	export_types = list(/obj/item/organ/liver)

/datum/export/organ/lungs
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "humanoid lungs"
	export_types = list(/obj/item/organ/lungs)

/datum/export/organ/stomach
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "humanoid stomach"
	export_types = list(/obj/item/organ/stomach)

/datum/export/organ/tongue
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "humanoid tounge"
	export_types = list(/obj/item/organ/tongue)

/datum/export/organ/tail/lizard
	cost = CARGO_CRATE_VALUE * 1.25
	unit_name = "lizard tail"
	export_types = list(/obj/item/organ/tail/lizard)


/datum/export/organ/tail/cat
	cost = CARGO_CRATE_VALUE * 1.5
	unit_name = "cat tail"
	export_types = list(/obj/item/organ/tail/cat)

/datum/export/organ/ears/cat
	cost = CARGO_CRATE_VALUE
	unit_name = "cat ears"
	export_types = list(/obj/item/organ/ears/cat)

