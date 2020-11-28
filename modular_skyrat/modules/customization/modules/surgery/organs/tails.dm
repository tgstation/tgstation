/obj/item/organ/tail
	mutantpart_key = "tail"
	mutantpart_info = list(MUTANT_INDEX_NAME = "Smooth", MUTANT_INDEX_COLOR_LIST = list("FFF"))
	var/can_wag = TRUE
	var/wagging = FALSE

/obj/item/organ/tail/cat
	mutantpart_info = list(MUTANT_INDEX_NAME = "Cat", MUTANT_INDEX_COLOR_LIST = list("FA0"))

/obj/item/organ/tail/lizard
	mutantpart_info = list(MUTANT_INDEX_NAME = "Smooth", MUTANT_INDEX_COLOR_LIST = list("DFD"))

/obj/item/organ/tail/fluffy
	name = "fluffy tail"

/obj/item/organ/tail/fluffy/no_wag
	name = "fluffy tail"
	can_wag = FALSE
