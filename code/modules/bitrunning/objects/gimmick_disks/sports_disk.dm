
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

/obj/item/storage/cans/sixenergydrink
	name = "energy drink bottle ring"
	desc = "Holds six energy drink cans. Remember to recycle when you're done!"

	/// Pool of energy drinks tm we may add from
	var/list/energy_drink_options = list(
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 50,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy = 30,
		/obj/item/reagent_containers/cup/soda_cans/volt_energy = 15,
		/obj/item/reagent_containers/cup/soda_cans/thirteenloko = 5, 
	)

/obj/item/storage/cans/sixenergydrink/PopulateContents()
	for(var/i in 1 to 6)
		var/obj/item/chosen_energy_drink = pick_weight(energy_drink_options)
		new chosen_energy_drink(src)


/datum/bitrunning_gimmick/archer
	name = "Archer"

	granted_items = list(
		/obj/item/clothing/under/costume/kimono,
		/obj/item/clothing/shoes/sandal/alt,
		/obj/item/storage/bag/quiver/endless,
		/obj/item/gun/ballistic/bow/longbow,
		/obj/item/ammo_casing/arrow/holy/blazing,
	)

/obj/item/storage/bag/quiver/endless
	name = "endless quiver"
	desc = "Holds arrows for your bow. A deep digital void is contained within."
	max_slots = 1

/obj/item/storage/bag/quiver/endless/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(handle_removed))

/obj/item/storage/bag/quiver/endless/PopulateContents()
	. = ..()
	new arrow_path(src)

/obj/item/storage/bag/quiver/endless/proc/handle_removed(datum/source, obj/item/gone)
	new arrow_path(src)


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

/obj/item/storage/cans/sixgamerdrink
	name = "gamer drink bottle ring"
	desc = "Holds six gamer drink cans. Remember to recycle when you're done!"

	/// Pool of gamer drinks tm we may add from
	var/list/gamer_drink_options = list(
		/obj/item/reagent_containers/cup/soda_cans/pwr_game = 55,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 15,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy = 15,
		/obj/item/reagent_containers/cup/soda_cans/volt_energy = 10,
		/obj/item/reagent_containers/cup/soda_cans/thirteenloko = 5, 
	)

/obj/item/storage/cans/sixgamerdrink/PopulateContents()
	for(var/i in 1 to 6)
		var/obj/item/chosen_gamer_drink = pick_weight(gamer_drink_options)
		new chosen_gamer_drink(src)

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
