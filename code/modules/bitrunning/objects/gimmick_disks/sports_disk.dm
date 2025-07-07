
/**
 * Bitrunning gimmick loadouts themed around sports.
 * Mostly for fun, have niche or little advantages.
 */
/obj/item/bitrunning_disk/gimmick/sports
	name = "bitrunning gimmick: sports"
	selectable_loadouts = list(
		/datum/bitrunning_gimmick/boxer,
		/datum/bitrunning_gimmick/skater,
		/datum/bitrunning_gimmick/archer,
		/datum/bitrunning_gimmick/fisher,
		/datum/bitrunning_gimmick/gamer,
	)


/datum/bitrunning_gimmick/boxer
	name = "Boxer"

	granted_items = list(
		/obj/item/clothing/gloves/boxing/evil,
		/obj/item/clothing/under/shorts/red,
		/obj/item/reagent_containers/condiment/protein,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/protein_blend,
	)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/protein_blend
	name = "Protein Blend"
	list_reagents = list(/datum/reagent/consumable/ethanol/protein_blend = 50)


/datum/bitrunning_gimmick/skater
	name = "Skater"

	granted_items = list(
		/obj/item/clothing/shoes/wheelys,
		/obj/item/melee/skateboard,
		/obj/item/clothing/suit/costume/wellworn_shirt/graphic,
		/obj/item/clothing/head/soft/black,
		/obj/item/clothing/shoes/sneakers/black,
		/obj/item/storage/cans/sixenergydrink,
	)

/datum/bitrunning_gimmick/archer
	name = "Archer"

	granted_items = list(
		/obj/item/clothing/under/costume/kimono,
		/obj/item/clothing/shoes/sandal/alt,
		/obj/item/storage/bag/quiver/endless,
		/obj/item/gun/ballistic/bow/longbow,
		/obj/item/ammo_casing/arrow/holy/blazing,
	)

/datum/bitrunning_gimmick/fisher
	name = "Fisher"

	granted_items = list(
		/obj/item/clothing/under/misc/overalls,
		/obj/item/clothing/suit/jacket/miljacket,
		/obj/item/clothing/head/soft/black,
		/obj/item/clothing/shoes/jackboots,
		/obj/item/storage/toolbox/fishing/small,
		/obj/item/bait_can/worm/premium,
		/obj/item/grenade/iedcasing/spawned,
		/obj/item/stock_parts/power_store/cell/lead,
		/obj/item/reagent_containers/cup/glass/bottle/beer/light,
	)


/datum/bitrunning_gimmick/gamer
	name = "Gamer"

	granted_items = list(
		/obj/item/clothing/under/suit/black_really,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/modular_computer/laptop/gamer,
		/obj/item/storage/cans/sixgamerdrink,
	)

/obj/item/modular_computer/laptop/gamer
	desc = "A high-end laptop often used for metagaming."
	device_theme = PDA_THEME_TERMINAL
	starting_programs = list(
		/datum/computer_file/program/themeify,
		/datum/computer_file/program/filemanager,
		/datum/computer_file/program/notepad,
		/datum/computer_file/program/arcade/eazy,
		/datum/computer_file/program/mafia,
	)
	start_open = FALSE

/obj/item/modular_computer/laptop/gamer/install_default_programs()
	// Only install starting programs, we don't want the software downloading program from default programs
	for(var/programs as anything in starting_programs)
		var/datum/computer_file/program/program_type = new programs
		store_file(program_type)
