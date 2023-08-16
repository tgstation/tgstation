/datum/supply_pack/emergency/weedcontrol_reverse
	name = "Weed Out-of-Control Crate"
	desc = "Supplise for when the botanists have smoked all the blunts and eaten all the food, contains rolling papers, snacks, and paraphernalia."
	cost = 420
	contraband = TRUE
	contains = list(/obj/item/storage/fancy/rollingpapers,
					/obj/item/storage/fancy/rollingpapers,
					/obj/item/storage/box/matches,
					/obj/item/clothing/mask/vape,
					/obj/item/clothing/mask/bandana/green,
					/obj/item/storage/belt/fannypack/green,
					/obj/item/food/chips,
					/obj/item/food/sosjerky)
	crate_name = "weed crate"

/datum/supply_pack/emergency/pest_control
	name = "Pest Control Crate"
	desc = "Additional traps for handling rodents of both ordinary and unusual size."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/storage/box/mousetraps = 2,
					/obj/item/restraints/legcuffs/beartrap = 2)
	crate_name = "pest control crate"

/datum/supply_pack/emergency/pest_control_reverse
	name = "Pest Out-of-Control Crate"
	desc = "Due to space-winter, a number of rodents have migrated into this crate"
	cost = CARGO_CRATE_VALUE * 3.5
	contraband = TRUE
	contains = list(/mob/living/basic/mouse = 4)
	crate_name = "pest crate"
