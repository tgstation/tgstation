/////////////////////////////////////
//////////Limb Grower Designs ///////
/////////////////////////////////////

/datum/design/leftarm
	name = "Left Arm"
	id = "leftarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/C2/instabitaluri = 25)
	build_path = /obj/item/bodypart/l_arm
	category = list("initial","human","lizard","moth","plasmaman","ethereal")

/datum/design/rightarm
	name = "Right Arm"
	id = "rightarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/C2/instabitaluri = 25)
	build_path = /obj/item/bodypart/r_arm
	category = list("initial","human","lizard","moth","plasmaman","ethereal")

/datum/design/leftleg
	name = "Left Leg"
	id = "leftleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/C2/instabitaluri = 25)
	build_path = /obj/item/bodypart/l_leg
	category = list("initial","human","lizard","moth","plasmaman","ethereal")

/datum/design/rightleg
	name = "Right Leg"
	id = "rightleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/C2/instabitaluri = 25)
	build_path = /obj/item/bodypart/r_leg
	category = list("initial","human","lizard","moth","plasmaman","ethereal")

//Non-limb limb designs

/datum/design/armblade
	name = "Arm Blade"
	id = "armblade"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/C2/instabitaluri = 75)
	build_path = /obj/item/melee/synthetic_arm_blade
	category = list("other","emagged")
