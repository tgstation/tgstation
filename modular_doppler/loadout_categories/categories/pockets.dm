/datum/loadout_category/pocket
	max_allowed = MAX_ALLOWED_MISC_ITEMS

// Because plushes have a second desc var that needs to be updated
/obj/item/toy/plush/on_loadout_custom_described()
	normal_desc = desc

// The wallet loadout item is special, and puts the player's ID and other small items into it on initialize (fancy!)
/datum/loadout_item/pocket_items/wallet
	name = "Wallet"
	item_path = /obj/item/storage/wallet
	additional_displayed_text = list("Auto-Filled")

// We add our wallet manually, later, so no need to put it in any outfits.
/datum/loadout_item/pocket_items/wallet/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only)
	return FALSE

// We didn't spawn any item yet, so nothing to call here.
/datum/loadout_item/pocket_items/wallet/on_equip_item(
	obj/item/equipped_item,
	datum/preferences/preference_source,
	list/preference_list,
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	return FALSE

// We add our wallet at the very end of character initialization (after quirks, etc) to ensure the backpack / their ID is all set by now.
/datum/loadout_item/pocket_items/wallet/post_equip_item(datum/preferences/preference_source, mob/living/carbon/human/equipper)
	var/obj/item/card/id/advanced/id_card = equipper.get_item_by_slot(ITEM_SLOT_ID)
	if(istype(id_card, /obj/item/storage/wallet))
		return

	var/obj/item/storage/wallet/wallet = new(equipper)
	if(istype(id_card))
		equipper.temporarilyRemoveItemFromInventory(id_card, force = TRUE)
		equipper.equip_to_slot_if_possible(wallet, ITEM_SLOT_ID, initial = TRUE)
		id_card.forceMove(wallet)

		if(equipper.back)
			var/list/backpack_stuff = equipper.back.atom_storage?.return_inv(FALSE)
			for(var/obj/item/thing in backpack_stuff)
				if(wallet.contents.len >= 3)
					break
				if(thing.w_class <= WEIGHT_CLASS_SMALL)
					wallet.atom_storage.attempt_insert(src, thing, equipper, TRUE, FALSE)
	else
		if(!equipper.equip_to_slot_if_possible(wallet, slot = ITEM_SLOT_BACKPACK, initial = TRUE))
			wallet.forceMove(equipper.drop_location())

/*
*	LIPSTICK
*/

/datum/loadout_item/pocket_items/lipstick_green
	name = "Green Lipstick"
	item_path = /obj/item/lipstick/green

/datum/loadout_item/pocket_items/lipstick_white
	name = "White Lipstick"
	item_path = /obj/item/lipstick/white

/datum/loadout_item/pocket_items/lipstick_blue
	name = "Blue Lipstick"
	item_path = /obj/item/lipstick/blue

/datum/loadout_item/pocket_items/lipstick_black
	name = "Black Lipstick"
	item_path = /obj/item/lipstick/black

/datum/loadout_item/pocket_items/lipstick_jade
	name = "Jade Lipstick"
	item_path = /obj/item/lipstick/jade

/datum/loadout_item/pocket_items/lipstick_purple
	name = "Purple Lipstick"
	item_path = /obj/item/lipstick/purple

/datum/loadout_item/pocket_items/lipstick_red
	name = "Red Lipstick"
	item_path = /obj/item/lipstick

/*
*	GUM
*/

/datum/loadout_item/pocket_items/gum_pack
	name = "Pack of Gum"
	item_path = /obj/item/storage/box/gum

/datum/loadout_item/pocket_items/gum_pack_nicotine
	name = "Pack of Nicotine Gum"
	item_path = /obj/item/storage/box/gum/nicotine

/datum/loadout_item/pocket_items/gum_pack_hp
	name = "Pack of HP+ Gum"
	item_path = /obj/item/storage/box/gum/happiness

/datum/loadout_item/pocket_items/gum_pack_moth
	name = "Pack of Activin 12 Hour Medicated Gum"
	item_path = /obj/item/storage/box/gum/wake_up

/*
*	MISC
*/

/datum/loadout_item/pocket_items/rag
	name = "Rag"
	item_path = /obj/item/reagent_containers/cup/rag

/datum/loadout_item/pocket_items/mod_painter
	name = "MOD Paint Kit"
	item_path = /obj/item/mod/paint

/datum/loadout_item/pocket_items/super_disk
	name = "Bootleg Computer Programs Disk"
	item_path = /obj/item/computer_disk/all_of_them

/datum/loadout_item/pocket_items/london
	name = "Hunting Knife"
	item_path = /obj/item/knife/hunting

/datum/loadout_item/pocket_items/london_two
	name = "Survival Knife"
	item_path = /obj/item/knife/combat/survival

/datum/loadout_item/pocket_items/etool
	name = "Entrenching Tool"
	item_path = /obj/item/trench_tool

/datum/loadout_item/pocket_items/swisstool
	name = "Spess Knife"
	item_path = /obj/item/spess_knife

/datum/loadout_item/pocket_items/injector_case
	name = "Autoinjector Case"
	item_path = /obj/item/storage/epic_loot_medpen_case

/datum/loadout_item/pocket_items/docs_case
	name = "Documents Case"
	item_path = /obj/item/storage/epic_loot_docs_case

/datum/loadout_item/pocket_items/org_case
	name = "Organizational Pouch"
	item_path = /obj/item/storage/epic_loot_org_pouch

/datum/loadout_item/pocket_items/cheaplighter
	name = "Cheap Lighter"
	item_path = /obj/item/lighter/greyscale

/datum/loadout_item/pocket_items/zippolighter
	name = "Zippo Lighter"
	item_path = /obj/item/lighter

/datum/loadout_item/pocket_items/paicard
	name = "Personal AI Device"
	item_path = /obj/item/pai_card

/datum/loadout_item/pocket_items/link_scryer
	name = "MODlink Scryer"
	item_path = /obj/item/clothing/neck/link_scryer/loaded

/datum/loadout_item/pocket_items/cigarettes
	name = "Cigarette Pack"
	item_path = /obj/item/storage/fancy/cigarettes

/datum/loadout_item/pocket_items/cigar //smoking is bad mkay
	name = "Cigar"
	item_path = /obj/item/cigarette/cigar

/datum/loadout_item/pocket_items/flask
	name = "Flask"
	item_path = /obj/item/reagent_containers/cup/glass/flask

/datum/loadout_item/pocket_items/multipen
	name = "Multicolored Pen"
	item_path = /obj/item/pen/fourcolor

/datum/loadout_item/pocket_items/fountainpen
	name = "Fancy Pen"
	item_path = /obj/item/pen/fountain

/datum/loadout_item/pocket_items/tapeplayer
	name = "Universal Recorder"
	item_path = /obj/item/taperecorder

/datum/loadout_item/pocket_items/tape
	name = "Spare Cassette Tape"
	item_path = /obj/item/tape/random

/datum/loadout_item/pocket_items/newspaper
	name = "Newspaper"
	item_path = /obj/item/newspaper

/datum/loadout_item/pocket_items/clipboard
	name = "Clipboard"
	item_path = /obj/item/clipboard

/datum/loadout_item/pocket_items/folder
	name = "Folder"
	item_path = /obj/item/folder

/datum/loadout_item/pocket_items/gromitmug
	name = "Gromit mug"
	item_path = /obj/item/reagent_containers/cup/glass/mug/gromitmug

/datum/loadout_item/pocket_items/pacification_chip
	name = "Meditative Assistance pacification skillchip"
	item_path = /obj/item/skillchip/pacification

/datum/loadout_item/pocket_items/shock_collar
	name = "Shock collar"
	item_path = /obj/item/electropack/shockcollar
	additional_displayed_text = list("Zap.")

/*
*	UTILITY
*/

/datum/loadout_item/pocket_items/moth_mre
	name = "Mothic Rations Pack"
	item_path = /obj/item/storage/box/mothic_rations

/datum/loadout_item/pocket_items/six_beer
	name = "Beer Six-Pack"
	item_path = /obj/item/storage/cans/sixbeer

/datum/loadout_item/pocket_items/six_soda
	name = "Soda Six-Pack"
	item_path = /obj/item/storage/cans/sixsoda

/datum/loadout_item/pocket_items/power_cell
	name = "Standard Power Cell"
	item_path = /obj/item/stock_parts/power_store/cell/crap

/datum/loadout_item/pocket_items/soap
	name = "Bar of Soap"
	item_path = /obj/item/soap/deluxe

/datum/loadout_item/pocket_items/mini_extinguisher
	name = "Mini Fire Extinguisher"
	item_path = /obj/item/extinguisher/mini

/datum/loadout_item/pocket_items/binoculars
	name = "Pair of Binoculars"
	item_path = /obj/item/binoculars

/datum/loadout_item/pocket_items/painkillers
	name = "Amollin Pill Bottle"
	item_path = /obj/item/storage/pill_bottle/painkiller

/datum/loadout_item/pocket_items/drugs_happy
	name = "Prescription Stimulant Bottle"
	item_path = /obj/item/storage/pill_bottle/prescription_stimulant

/datum/loadout_item/pocket_items/drugs_blastoff
	name = "bLaSToFF Ampoule"
	item_path = /obj/item/reagent_containers/cup/blastoff_ampoule

/datum/loadout_item/pocket_items/drugs_sandy
	name = "T-WITCH Vial"
	item_path = /obj/item/reagent_containers/hypospray/medipen/deforest/twitch

/datum/loadout_item/pocket_items/drugs_kronkus
	name = "Kronkus Vine Seeds"
	item_path = /obj/item/seeds/kronkus

/*
*	MEDICAL
*/

/datum/loadout_item/pocket_items/civil_defense
	name = "Civil Defense Med-kit"
	item_path = /obj/item/storage/medkit/civil_defense/stocked

/datum/loadout_item/pocket_items/medkit
	name = "First-Aid Kit"
	item_path = /obj/item/storage/medkit/regular

/datum/loadout_item/pocket_items/pocket_medkit
	name = "Colonial First Aid Kit"
	item_path = /obj/item/storage/pouch/cin_medkit

/datum/loadout_item/pocket_items/pocket_medpens_evil
	name = "Colonial Medipen Pouch"
	item_path = /obj/item/storage/pouch/cin_medipens

// Job equipment straps

/datum/loadout_item/pocket_items/generic_suit_strap
	name = "Generic Equipment Strap"
	item_path = /obj/item/job_equipment_strap

/datum/loadout_item/pocket_items/service_suit_strap
	name = "Service Equipment Strap"
	item_path = /obj/item/job_equipment_strap/service

/datum/loadout_item/pocket_items/medical_suit_strap
	name = "Medical Equipment Strap"
	item_path = /obj/item/job_equipment_strap/medical

/datum/loadout_item/pocket_items/engineering_suit_strap
	name = "Engineering Equipment Strap"
	item_path = /obj/item/job_equipment_strap/engineering

/datum/loadout_item/pocket_items/science_suit_strap
	name = "Science Equipment Strap"
	item_path = /obj/item/job_equipment_strap/science

/datum/loadout_item/pocket_items/supply_suit_strap
	name = "Supply Equipment Strap"
	item_path = /obj/item/job_equipment_strap/supply

/datum/loadout_item/pocket_items/security_suit_strap
	name = "Security Equipment Strap"
	item_path = /obj/item/job_equipment_strap/security

//PDAs

/datum/loadout_item/pocket_items/pda_neko
	name = "Neko PDA"
	item_path = /obj/item/modular_computer/pda/cat

/datum/loadout_item/pocket_items/pda_g3
	name = "G3 PDA"
	item_path = /obj/item/modular_computer/pda/g3

/datum/loadout_item/pocket_items/pda_rugged
	name = "Rugged PDA"
	item_path = /obj/item/modular_computer/pda/rugged

/datum/loadout_item/pocket_items/pda_slimline
	name = "Slimline PDA"
	item_path = /obj/item/modular_computer/pda/slimline

/datum/loadout_item/pocket_items/pda_ultraslim
	name = "Ultraslim PDA"
	item_path = /obj/item/modular_computer/pda/ultraslim
