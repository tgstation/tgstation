///Lists related to quirk selection

///Types of glasses that can be selected at character selection with the Nearsighted quirk
GLOBAL_LIST_INIT(nearsighted_glasses, list(
	"Regular" = /obj/item/clothing/glasses/regular,
	"Circle" = /obj/item/clothing/glasses/regular/circle,
	"Hipster" = /obj/item/clothing/glasses/regular/hipster,
	"Thin" = /obj/item/clothing/glasses/regular/thin,
	"Jamjar" = /obj/item/clothing/glasses/regular/jamjar,
	"Binoclard" = /obj/item/clothing/glasses/regular/kim,
))

///Options for the prosthetic limb quirk to choose from
GLOBAL_LIST_INIT(limb_choice, list(
	"Left arm" = /obj/item/bodypart/arm/left/robot/surplus,
	"Right arm" = /obj/item/bodypart/arm/right/robot/surplus,
	"Left leg" = /obj/item/bodypart/leg/left/robot/surplus,
	"Right leg" = /obj/item/bodypart/leg/right/robot/surplus,
))

///Transhumanist quirk
GLOBAL_LIST_INIT(limb_choice_transhuman, list(
	"Left Arm" = /obj/item/bodypart/arm/left/robot,
	"Right Arm" = /obj/item/bodypart/arm/right/robot,
	"Left Leg" = /obj/item/bodypart/leg/left/robot,
	"Right Leg" = /obj/item/bodypart/leg/right/robot,
))

///Options for the Junkie quirk to choose from
GLOBAL_LIST_INIT(possible_junkie_addictions, setup_junkie_addictions(list(
		/datum/reagent/drug/blastoff,
		/datum/reagent/drug/krokodil,
		/datum/reagent/medicine/morphine,
		/datum/reagent/drug/happiness,
		/datum/reagent/drug/methamphetamine,
	)))

///Options for the Smoker quirk to choose from
GLOBAL_LIST_INIT(possible_smoker_addictions, setup_junkie_addictions(list(
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/fancy/cigarettes/cigpack_midori,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
		/obj/item/storage/fancy/cigarettes/cigpack_carp,
		/obj/item/storage/fancy/cigarettes/cigars,
		/obj/item/storage/fancy/cigarettes/cigars/cohiba,
		/obj/item/storage/fancy/cigarettes/cigars/havana,
	)))

///Options for the Alcoholic quirk to choose from
GLOBAL_LIST_INIT(possible_alcoholic_addictions, setup_junkie_addictions(list(
		/obj/item/reagent_containers/cup/glass/bottle/whiskey,
		/obj/item/reagent_containers/cup/glass/bottle/vodka,
		/obj/item/reagent_containers/cup/glass/bottle/ale,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/reagent_containers/cup/glass/bottle/hcider,
		/obj/item/reagent_containers/cup/glass/bottle/wine,
		/obj/item/reagent_containers/cup/glass/bottle/sake,
	)))

///Options for Prosthetic Organ
GLOBAL_LIST_INIT(organ_choice, list(
	"Heart" = ORGAN_SLOT_HEART,
	"Lungs" = ORGAN_SLOT_LUNGS,
	"Liver" = ORGAN_SLOT_LIVER,
	"Stomach" = ORGAN_SLOT_STOMACH,
))
