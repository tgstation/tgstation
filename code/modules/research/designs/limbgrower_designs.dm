/////////////////////////////////////
//////////Limb Grower Designs ///////
/////////////////////////////////////

/datum/design/leftarm
	name = "Left Arm"
	id = "leftarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/l_arm
	category = list(CATEGORY_INITIAL,CATEGORY_HUMAN,CATEGORY_LIZARD,CATEGORY_MOTH,CATEGORY_PLASMAMAN,CATEGORY_ETHEREAL)

/datum/design/rightarm
	name = "Right Arm"
	id = "rightarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/r_arm
	category = list(CATEGORY_INITIAL,CATEGORY_HUMAN,CATEGORY_LIZARD,CATEGORY_MOTH,CATEGORY_PLASMAMAN,CATEGORY_ETHEREAL)

/datum/design/leftleg
	name = "Left Leg"
	id = "leftleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/l_leg
	category = list(CATEGORY_INITIAL,CATEGORY_HUMAN,CATEGORY_LIZARD,CATEGORY_MOTH,CATEGORY_PLASMAMAN,CATEGORY_ETHEREAL)

/datum/design/rightleg
	name = "Right Leg"
	id = "rightleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/r_leg
	category = list(CATEGORY_INITIAL,CATEGORY_HUMAN,CATEGORY_LIZARD,CATEGORY_MOTH,CATEGORY_PLASMAMAN,CATEGORY_ETHEREAL)

//Non-limb limb designs

/datum/design/heart
	name = "Heart"
	id = "heart"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 30)
	build_path = /obj/item/organ/heart
	category = list(CATEGORY_OTHER,CATEGORY_INITIAL)

/datum/design/lungs
	name = "Lungs"
	id = "lungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/lungs
	category = list(CATEGORY_OTHER,CATEGORY_INITIAL)

/datum/design/liver
	name = "Liver"
	id = "liver"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/liver
	category = list(CATEGORY_OTHER,CATEGORY_INITIAL)

/datum/design/stomach
	name = "Stomach"
	id = "stomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 15)
	build_path = /obj/item/organ/stomach
	category = list(CATEGORY_OTHER,CATEGORY_INITIAL)

/datum/design/appendix
	name = "Appendix"
	id = "appendix"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 5) //why would you need this
	build_path = /obj/item/organ/appendix
	category = list(CATEGORY_OTHER,CATEGORY_INITIAL)

/datum/design/eyes
	name = "Eyes"
	id = "eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/eyes
	category = list(CATEGORY_OTHER,CATEGORY_INITIAL)

/datum/design/ears
	name = "Ears"
	id = "ears"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/ears
	category = list(CATEGORY_OTHER,CATEGORY_INITIAL)

/datum/design/tongue
	name = "Tongue"
	id = "tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/tongue
	category = list(CATEGORY_OTHER,CATEGORY_INITIAL)

/datum/design/armblade
	name = "Arm Blade"
	id = "armblade"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 75)
	build_path = /obj/item/melee/synthetic_arm_blade
	category = list(CATEGORY_OTHER,CATEGORY_EMAGGED)
