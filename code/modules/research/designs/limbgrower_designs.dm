/////////////////////////////////////
//////////Limb Grower Designs ///////
/////////////////////////////////////

/datum/design/leftarm
	name = "Left Arm"
	id = "leftarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/l_arm
	category = list("initial",SPECIES_HUMAN,SPECIES_LIZARD,SPECIES_MOTH,SPECIES_PLASMAMAN,SPECIES_ETHEREAL)

/datum/design/rightarm
	name = "Right Arm"
	id = "rightarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/r_arm
	category = list("initial",SPECIES_HUMAN,SPECIES_LIZARD,SPECIES_MOTH,SPECIES_PLASMAMAN,SPECIES_ETHEREAL)

/datum/design/leftleg
	name = "Left Leg"
	id = "leftleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/l_leg
	category = list("initial",SPECIES_HUMAN,SPECIES_LIZARD,SPECIES_MOTH,SPECIES_PLASMAMAN,SPECIES_ETHEREAL)

/datum/design/rightleg
	name = "Right Leg"
	id = "rightleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 25)
	build_path = /obj/item/bodypart/r_leg
	category = list("initial",SPECIES_HUMAN,SPECIES_LIZARD,SPECIES_MOTH,SPECIES_PLASMAMAN,SPECIES_ETHEREAL)

/datum/design/digi_leftleg
	name = "Digitigrade Left Leg"
	id = "digi_leftleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 30)
	build_path = /obj/item/bodypart/l_leg/digitigrade
	category = list(SPECIES_LIZARD)

/datum/design/digi_rightleg
	name = "Digitigrade Right Leg"
	id = "digi_rightleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 30)
	build_path = /obj/item/bodypart/r_leg/digitigrade
	category = list(SPECIES_LIZARD)

//Non-limb limb designs

/datum/design/heart
	name = "Heart"
	id = "heart"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 30)
	build_path = /obj/item/organ/heart
	category = list(SPECIES_HUMAN,"initial")

/datum/design/lungs
	name = "Lungs"
	id = "lungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/lungs
	category = list(SPECIES_HUMAN,"initial")

/datum/design/liver
	name = "Liver"
	id = "liver"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/liver
	category = list(SPECIES_HUMAN,"initial")

/datum/design/stomach
	name = "Stomach"
	id = "stomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 15)
	build_path = /obj/item/organ/stomach
	category = list(SPECIES_HUMAN,"initial")

/datum/design/appendix
	name = "Appendix"
	id = "appendix"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 5) //why would you need this
	build_path = /obj/item/organ/appendix
	category = list(SPECIES_HUMAN,"initial")

/datum/design/eyes
	name = "Eyes"
	id = "eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/eyes
	category = list(SPECIES_HUMAN,"initial")

/datum/design/ears
	name = "Ears"
	id = "ears"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/ears
	category = list(SPECIES_HUMAN,"initial")

/datum/design/tongue
	name = "Tongue"
	id = "tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/tongue
	category = list(SPECIES_HUMAN,"initial")

// Grows a fake lizard tail - not usable in lizard wine and other similar recipes.
/datum/design/lizard_tail
	name = "Lizard Tail"
	id = "liztail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/tail/lizard/fake
	category = list(SPECIES_LIZARD)

/datum/design/lizard_tongue
	name = "Forked Tongue"
	id = "liztongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/tongue/lizard
	category = list(SPECIES_LIZARD)

/datum/design/monkey_tail
	name = "Monkey Tail"
	id = "monkeytail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/tail/monkey
	category = list("other","initial")

/datum/design/cat_tail
	name = "Cat Tail"
	id = "cattail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/tail/cat
	category = list(SPECIES_HUMAN)

/datum/design/cat_ears
	name = "Cat Ears"
	id = "catears"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/ears/cat
	category = list(SPECIES_HUMAN)

/datum/design/plasmaman_lungs
	name = "Plasma Filter"
	id = "plasmamanlungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/lungs/plasmaman
	category = list(SPECIES_PLASMAMAN)

/datum/design/plasmaman_tongue
	name = "Plasma Bone Tongue"
	id = "plasmamantongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/tongue/bone/plasmaman
	category = list(SPECIES_PLASMAMAN)

/datum/design/plasmaman_liver
	name = "Reagent Processing Crystal"
	id = "plasmamanliver"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/liver/plasmaman
	category = list(SPECIES_PLASMAMAN)

/datum/design/plasmaman_stomach
	name = "Digestive Crystal"
	id = "plasmamanstomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/stomach/bone/plasmaman
	category = list(SPECIES_PLASMAMAN)

/datum/design/ethereal_stomach
	name = "Biological Battery"
	id = "etherealstomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/consumable/liquidelectricity/enriched = 20)
	build_path = /obj/item/organ/stomach/ethereal
	category = list(SPECIES_ETHEREAL)

/datum/design/ethereal_tongue
	name = "Electrical Discharger"
	id = "etherealtongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/consumable/liquidelectricity/enriched = 20)
	build_path = /obj/item/organ/tongue/ethereal
	category = list(SPECIES_ETHEREAL)

/datum/design/ethereal_lungs
	name = "Aeration Reticulum"
	id = "ethereallungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/consumable/liquidelectricity/enriched = 20)
	build_path = /obj/item/organ/lungs/ethereal
	category = list(SPECIES_ETHEREAL)

// Intentionally not growable by normal means - for balance conerns.
/datum/design/ethereal_heart
	name = "Crystal Core"
	id = "etherealheart"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10, /datum/reagent/consumable/liquidelectricity/enriched = 20)
	build_path = /obj/item/organ/heart/ethereal
	category = list(SPECIES_ETHEREAL)

/datum/design/armblade
	name = "Arm Blade"
	id = "armblade"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 75)
	build_path = /obj/item/melee/synthetic_arm_blade
	category = list("other","emagged")

/// Design disks and designs - for adding limbs and organs to the limbgrower.
/obj/item/disk/design_disk/limbs
	name = "Limb Design Disk"
	desc = "A disk containing limb and organ designs for a limbgrower."
	icon_state = "datadisk1"
	/// List of all limb designs this disk contains.
	var/list/limb_designs = list()

/obj/item/disk/design_disk/limbs/Initialize(mapload)
	. = ..()
	max_blueprints = limb_designs.len
	for(var/design in limb_designs)
		var/datum/design/new_design = design
		blueprints += new new_design

/datum/design/limb_disk
	name = "Limb Design Disk"
	desc = "Contains designs for various limbs."
	id = "limbdesign_parent"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	build_path = /obj/item/disk/design_disk/limbs
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/obj/item/disk/design_disk/limbs/felinid
	name = "Felinid Limb Design Disk"
	limb_designs = list(/datum/design/cat_tail, /datum/design/cat_ears)

/datum/design/limb_disk/felinid
	name = "Felinid Limb Design Disk"
	desc = "Contains designs for felinid bodyparts for the limbgrower - Felinid ears and tail."
	id = "limbdesign_felinid"
	build_path = /obj/item/disk/design_disk/limbs/felinid

/obj/item/disk/design_disk/limbs/lizard
	name = "Lizard Limb Design Disk"
	limb_designs = list(/datum/design/lizard_tail, /datum/design/lizard_tongue, /datum/design/digi_leftleg, /datum/design/digi_rightleg)

/datum/design/limb_disk/lizard
	name = "Lizard Limb Design Disk"
	desc = "Contains designs for lizard bodyparts for the limbgrower - Lizard tongue, tail, and digitigrade legs."
	id = "limbdesign_lizard"
	build_path = /obj/item/disk/design_disk/limbs/lizard

/obj/item/disk/design_disk/limbs/plasmaman
	name = "Plasmaman Limb Design Disk"
	limb_designs = list(/datum/design/plasmaman_stomach, /datum/design/plasmaman_liver, /datum/design/plasmaman_lungs, /datum/design/plasmaman_tongue)

/datum/design/limb_disk/plasmaman
	name = "Plasmaman Limb Design Disk"
	desc = "Contains designs for plasmaman organs for the limbgrower - Plasmaman tongue, liver, stomach, and lungs."
	id = "limbdesign_plasmaman"
	build_path = /obj/item/disk/design_disk/limbs/plasmaman

/obj/item/disk/design_disk/limbs/ethereal
	name = "Ethereal Limb Design Disk"
	limb_designs = list(/datum/design/ethereal_stomach, /datum/design/ethereal_tongue, /datum/design/ethereal_lungs)

/datum/design/limb_disk/ethereal
	name = "Ethereal Limb Design Disk"
	desc = "Contains designs for ethereal organs for the limbgrower - Ethereal tongue and stomach."
	id = "limbdesign_ethereal"
	build_path = /obj/item/disk/design_disk/limbs/ethereal
