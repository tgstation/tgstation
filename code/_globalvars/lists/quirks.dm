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

///Junkie quirk
GLOBAL_LIST_INIT(junkie_drug, list(
	"bLaSToFF" = /datum/reagent/drug/blastoff,
	"Krokodil" = /datum/reagent/drug/krokodil,
	"Morphine" = /datum/reagent/medicine/morphine,
	"Happiness" = /datum/reagent/drug/happiness,
	"Methamphetamine" = /datum/reagent/drug/methamphetamine
))

///Options for the SMOKER quirk to choose from
GLOBAL_LIST_INIT(favorite_brand, list(
	"Space Cigarettes" = /obj/item/storage/fancy/cigarettes,
	"Uplift Smooth" = /obj/item/storage/fancy/cigarettes/cigpack_uplift,
	"Robust Cigarettes" = /obj/item/storage/fancy/cigarettes/cigpack_robust,
	"Robust Gold Cigarettes" = /obj/item/storage/fancy/cigarettes/cigpack_robustgold,
	"Carp Classic" = /obj/item/storage/fancy/cigarettes/cigpack_carp,
	"Midori Tabako" = /obj/item/storage/fancy/cigarettes/cigpack_midori,
	"Syndicate Cigarettes" = /obj/item/storage/fancy/cigarettes/cigpack_syndicate,
	"Premium Cigars" = /obj/item/storage/fancy/cigarettes/cigars,
	"Cohiba Cigars" = /obj/item/storage/fancy/cigarettes/cigars/cohiba,
	"Havanian Cigars" = /obj/item/storage/fancy/cigarettes/cigars/havana,
))

///The third and final junkie subtype: ALCOHOL
GLOBAL_LIST_INIT(favorite_alcohol, list(
	"Whiskey" = /obj/item/reagent_containers/cup/glass/bottle/whiskey,
	"Vodka" = /obj/item/reagent_containers/cup/glass/bottle/vodka,
	"Ale" = /obj/item/reagent_containers/cup/glass/bottle/ale,
	"Beer" = /obj/item/reagent_containers/cup/glass/bottle/beer,
	"Hard Cider" = /obj/item/reagent_containers/cup/glass/bottle/hcider,
	"Wine" = /obj/item/reagent_containers/cup/glass/bottle/wine,
	"Sake" = /obj/item/reagent_containers/cup/glass/bottle/sake,

))
///Options for hemiplegic quirk
GLOBAL_LIST_INIT(hemiplegic_side, list(
	"Left side" = /datum/brain_trauma/severe/paralysis/hemiplegic/left,
	"Right side" = /datum/brain_trauma/severe/paralysis/hemiplegic/right
))

