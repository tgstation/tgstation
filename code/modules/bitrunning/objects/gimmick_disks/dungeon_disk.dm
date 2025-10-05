
/**
 * Bitrunning gimmick loadouts themed around dungeon crawling.
 * Mostly for fun, have niche but not insignificant advantages.
 */
/obj/item/bitrunning_disk/gimmick/dungeon
	name = "bitrunning gimmick: dungeon crawling"
	selectable_loadouts = list(
		/datum/bitrunning_gimmick/alchemist,
		/datum/bitrunning_gimmick/rogue,
		/datum/bitrunning_gimmick/healer,
		/datum/bitrunning_gimmick/wizard,
	)


/datum/bitrunning_gimmick/alchemist
	name = "Alchemist"

	granted_items = list(
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
		/obj/item/clothing/mask/gas/plaguedoctor,
		/obj/item/clothing/head/bio_hood/plague,
		/obj/item/storage/box/alchemist_basic_chems,
		/obj/item/storage/box/alchemist_basic_chems,
		/obj/item/storage/box/alchemist_random_chems,
		/obj/item/storage/box/alchemist_chemistry_kit,
	)

/obj/item/reagent_containers/cup/bottle/alchemist_basic
	name = "unlabeled bottle"
	desc = "A small bottle. You don't remember what you put in it."

	/// List of possible reagents we may pick from
	var/static/list/possible_reagents = list(
		/datum/reagent/aluminium, // Basic chems
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel,
		/datum/reagent/toxin/leadacetate, // Funny chems
		/datum/reagent/consumable/liquidgibs,
		/datum/reagent/consumable/nutriment,
		/datum/reagent/consumable/coffee,
	)

/obj/item/reagent_containers/cup/bottle/alchemist_basic/add_initial_reagents()
	var/our_reagent = pick(possible_reagents)
	reagents.add_reagent(our_reagent, 50)

/obj/item/reagent_containers/cup/bottle/alchemist_random
	name = "skull-labeled bottle"
	desc = "A small bottle. You don't remember what you put in it."

	/// List of random adjectives this bottle may have
	var/static/list/possible_adjectives = list(
		"unlabeled",
		"skull-labeled", // Labels
		"heart-labeled",
		"explosion-labeled",
		"fish-labeled",
		"smiley-labeled",
		"frown-labeled",
		"interrobang-labeled",
		"plus-labeled",
		"d20-labeled",
		"unreadably-labeled",
		"black-labeled",
		"empty-labeled",
		"age-yellowed", // Qualities
		"blood-tinged",
		"ash-marred",
		"claw-scratched",
		"marker-marked",
		"cracked",
		"ominous", // Abstract
	)

/obj/item/reagent_containers/cup/bottle/alchemist_random/Initialize(mapload)
	. = ..()
	name = "[pick(possible_adjectives)] bottle"

/obj/item/reagent_containers/cup/bottle/alchemist_random/add_initial_reagents()
	var/our_reagent = get_random_reagent_id()
	var/our_amount = rand(20, 50)
	reagents.add_reagent(our_reagent, our_amount)

/datum/bitrunning_gimmick/rogue
	name = "Rogue"

	granted_items = list(
		/obj/item/clothing/under/color/black,
		/obj/item/clothing/shoes/sneakers/black/rogue,
		/obj/item/clothing/mask/facescarf/rogue,
		/obj/item/clothing/glasses/eyepatch/rogue,
		/obj/item/bedsheet/black/rogue_cape,
		/obj/item/storage/belt/fannypack/black/rogue,
		/obj/item/knife/combat/survival,
	)

/obj/item/clothing/shoes/sneakers/black/rogue
	name = "sneaker of SNEAKING"

/obj/item/clothing/mask/facescarf/rogue
	name = "cloth of DOOM"
	icon_state = "/obj/item/clothing/mask/facescarf/rogue"
	greyscale_colors = "#292929"

/obj/item/clothing/glasses/eyepatch/rogue
	name = "eyepatch of SEALING"

/obj/item/bedsheet/black/rogue_cape
	name = "cape of DARKNESS"

/datum/bitrunning_gimmick/healer
	name = "Healer"

	granted_items = list(
		/obj/item/clothing/under/costume/singer/yellow,
		/obj/item/clothing/shoes/singery,
		/obj/item/rod_of_asclepius,
		/obj/item/storage/medkit/surgery,
		/obj/item/emergency_bed,
		/obj/item/food/canned/larvae,
		/obj/item/reagent_containers/dropper,
	)


/datum/bitrunning_gimmick/wizard
	name = "Wizard"

	granted_items = list(
		/obj/item/clothing/head/wizard/fake,
		/obj/item/clothing/suit/wizrobe/fake,
		/obj/item/clothing/glasses/eyepatch/medical/chuuni,
		/obj/item/staff,
		/obj/item/toy/eightball,
		/obj/item/storage/fancy/cigarettes/cigpack_cannabis,
		/obj/item/storage/box/matches,
	)

	granted_actions = list(
		/datum/action/cooldown/spell/pointed/untie_shoes/digital,
		/datum/action/cooldown/spell/smoke/digital,
	)

/datum/action/cooldown/spell/pointed/untie_shoes/digital
	name = "Untie Digi-Shoes"
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB

/datum/action/cooldown/spell/smoke/digital
	name = "Digi-Smoke"
	desc = "This spell spawns a small cloud of smoke at your location."

	school = SCHOOL_CONJURATION
	cooldown_time = 36 SECONDS
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB

	smoke_type = /datum/effect_system/fluid_spread/smoke
	smoke_amt = 2
