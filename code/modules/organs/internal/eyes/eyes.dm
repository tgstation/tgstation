
/datum/organ/internal/eyes
	name = "eyes"
	parent_organ = "head"
	removed_type = /obj/item/organ/eyes

	var/welding_proof=0
	var/eyeprot=0
	var/see_in_dark=2

/datum/organ/internal/eyes/process() //Eye damage replaces the old eye_stat var.
	if(is_bruised())
		owner.eye_blurry = 20
	if(is_broken())
		owner.eye_blind = 20


/datum/organ/internal/eyes/tajaran
	name = "feline eyes"
	see_in_dark=8
	removed_type = /obj/item/organ/eyes/tajaran

/datum/organ/internal/eyes/grey
	name = "huge eyes"
	see_in_dark=5
	removed_type = /obj/item/organ/eyes/grey

/datum/organ/internal/eyes/muton
	name = "muton eyes"
	see_in_dark=1
	removed_type = /obj/item/organ/eyes/muton

///////////////
// BIONIC EYES
///////////////

/datum/organ/internal/eyes/adv_1
	name = "advanced eyes"
	welding_proof=1
	see_in_dark=5
	removed_type = /obj/item/organ/eyes/adv_1