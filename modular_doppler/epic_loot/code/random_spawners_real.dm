/obj/effect/spawner/random/epic_loot
	name = "extraction loot spawner"
	desc = "Gods please let there be nobody extract camping."
	icon = 'modular_doppler/epic_loot/icons/epic_loot.dmi'
	icon_state = null

// Jacket pocket contents

// Actual pocket items spawner

/obj/effect/spawner/random/epic_loot/pocket_sized_items
	name = "random pocket sized items"
	icon_state = "random_pocket_valuable"
	loot = list(
		/obj/effect/spawner/random/epic_loot/pocket_valuable = 1,
		/obj/effect/spawner/random/epic_loot/pocket_medical = 1,
		/obj/effect/spawner/random/epic_loot/pocket_da_money = 1,
	)

// Chainlet, good or not good, call it

/obj/effect/spawner/random/epic_loot/pocket_valuable
	name = "random pocket valuable"
	icon_state = "random_chain"
	loot = list(
		/obj/item/epic_loot/silver_chainlet = 3,
		/obj/item/epic_loot/press_pass = 2,
		/obj/item/epic_loot/military_flash = 2,
		/obj/item/epic_loot/slim_diary = 2,
		/obj/item/epic_loot/gold_chainlet = 1,
	)

// Pocket meds

/obj/effect/spawner/random/epic_loot/pocket_medical
	name = "random pocket medical item"
	icon_state = "random_med_stack"
	loot = list(
		/obj/item/storage/pill_bottle/iron = 2,
		/obj/item/storage/pill_bottle/painkiller = 2,
		/obj/item/storage/pill_bottle/ondansetron = 1,
		/obj/item/stack/medical/bandage = 2,
		/obj/item/stack/medical/bandage/makeshift = 2,
		/obj/item/stack/medical/aloe = 2,
		/obj/item/stack/medical/ointment/red_sun = 1,
		/obj/item/stack/medical/bruise_pack = 1,
		/obj/item/stack/medical/gauze/sterilized = 1,
	)

// Pocket da money

/obj/effect/spawner/random/epic_loot/pocket_da_money
	name = "random pocket money"
	icon_state = "random_pocket_valuable"
	loot = list(
		/obj/effect/spawner/random/entertainment/money_small = 2,
		/obj/effect/spawner/random/entertainment/money = 1,
		/obj/effect/spawner/random/entertainment/cigarette_pack = 1,
		/obj/effect/spawner/random/entertainment/cigarette = 2,
		/obj/effect/spawner/random/entertainment/wallet_lighter = 2,
	)

// Medical related spawners

// The medical everything spawner

/obj/effect/spawner/random/epic_loot/medical_everything
	name = "random medical anything"
	icon_state = "random_med_stack"
	loot = list(
		/obj/effect/spawner/random/epic_loot/medical_stack_item = 2,
		/obj/effect/spawner/random/epic_loot/medical_stack_item_advanced = 1,
		/obj/effect/spawner/random/epic_loot/chemical = 1,
		/obj/effect/spawner/random/epic_loot/medical_tools = 2,
		/obj/effect/spawner/random/epic_loot/medkit = 1,
		/obj/effect/spawner/random/epic_loot/medpens = 2,
		/obj/effect/spawner/random/epic_loot/medpens_combat_based_redpilled = 1,
	)

// Basic healing items

/obj/effect/spawner/random/epic_loot/medical_stack_item
	name = "random medical item"
	icon_state = "random_med_stack"
	loot = list(
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/gauze = 3,
		/obj/item/stack/medical/gauze/sterilized = 2,
		/obj/item/stack/medical/suture/emergency = 3,
		/obj/item/stack/medical/suture/coagulant = 2,
		/obj/item/stack/medical/suture/bloody = 1,
		/obj/item/stack/medical/ointment = 3,
		/obj/item/stack/medical/ointment/red_sun = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/stack/medical/aloe = 2,
		/obj/item/stack/medical/bone_gel/one = 2,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/medical/bandage/makeshift = 3,
		/obj/item/stack/medical/bandage = 2,
		/obj/item/stack/sticky_tape/surgical = 2,
		/obj/item/reagent_containers/blood/random = 1,
		/obj/item/stack/medical/gauze/alu_splint = 2,
		// Pill bottles
		/obj/item/storage/pill_bottle/iron = 2,
		/obj/item/storage/pill_bottle/potassiodide = 2,
		/obj/item/storage/pill_bottle/painkiller = 2,
		/obj/item/storage/pill_bottle/probital = 2,
		/obj/item/storage/pill_bottle/happinesspsych = 1,
		/obj/item/storage/pill_bottle/lsdpsych = 1,
		/obj/item/storage/pill_bottle/mannitol = 2,
		/obj/item/storage/pill_bottle/multiver = 2,
		/obj/item/storage/pill_bottle/mutadone = 1,
		/obj/item/storage/pill_bottle/neurine = 1,
		/obj/item/storage/pill_bottle/ondansetron = 1,
		/obj/item/storage/pill_bottle/psicodine = 1,
		/obj/item/storage/pill_bottle/sansufentanyl = 1,
	)

// More advanced healing items

/obj/effect/spawner/random/epic_loot/medical_stack_item_advanced
	name = "random advanced medical item"
	icon_state = "random_med_stack_adv"
	loot = list(
		/obj/item/stack/medical/gauze/sterilized = 2,
		/obj/item/stack/medical/suture = 3,
		/obj/item/stack/medical/suture/coagulant = 3,
		/obj/item/stack/medical/suture/bloody = 2,
		/obj/item/stack/medical/suture/medicated = 1,
		/obj/item/stack/medical/ointment/red_sun = 3,
		/obj/item/stack/medical/mesh = 3,
		/obj/item/stack/medical/mesh/bloody = 2,
		/obj/item/stack/medical/mesh/advanced = 1,
		/obj/item/stack/medical/aloe = 2,
		/obj/item/stack/medical/bone_gel = 2,
		/obj/item/stack/medical/bandage = 2,
		/obj/item/stack/sticky_tape/surgical = 2,
		/obj/item/stack/medical/poultice = 1,
		/obj/item/stack/medical/gauze/alu_splint = 2,
		/obj/item/reagent_containers/blood/random = 2,
		// Medigels
		/obj/item/reagent_containers/medigel/libital = 2,
		/obj/item/reagent_containers/medigel/aiuri = 2,
		/obj/item/reagent_containers/medigel/sterilizine = 2,
		/obj/item/reagent_containers/medigel/synthflesh = 1,
		// Pill bottles
		/obj/item/storage/pill_bottle/iron = 2,
		/obj/item/storage/pill_bottle/potassiodide = 2,
		/obj/item/storage/pill_bottle/painkiller = 2,
		/obj/item/storage/pill_bottle/probital = 2,
		/obj/item/storage/pill_bottle/happinesspsych = 1,
		/obj/item/storage/pill_bottle/lsdpsych = 1,
		/obj/item/storage/pill_bottle/mannitol = 2,
		/obj/item/storage/pill_bottle/multiver = 2,
		/obj/item/storage/pill_bottle/mutadone = 1,
		/obj/item/storage/pill_bottle/neurine = 1,
		/obj/item/storage/pill_bottle/ondansetron = 1,
		/obj/item/storage/pill_bottle/psicodine = 1,
		/obj/item/storage/pill_bottle/sansufentanyl = 1,
	)

// Chems and whatnot

/obj/effect/spawner/random/epic_loot/chemical
	name = "random chemical"
	icon_state = "random_med_stack_adv"
	loot = list(
		// Chemjaks
		/obj/item/reagent_containers/cup/bottle/epinephrine = 1,
		/obj/item/reagent_containers/cup/bottle/morphine = 2,
		/obj/item/reagent_containers/cup/bottle/mannitol = 1,
		/obj/item/reagent_containers/cup/bottle/multiver = 2,
		/obj/item/reagent_containers/cup/bottle/ammoniated_mercury = 2,
		/obj/item/reagent_containers/cup/bottle/syriniver = 2,
		/obj/item/reagent_containers/cup/bottle/synaptizine = 2,
		/obj/item/reagent_containers/cup/bottle/fentanyl = 2,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 1,
		/obj/item/reagent_containers/cup/bottle/diphenhydramine = 1,
		/obj/item/reagent_containers/cup/bottle/potass_iodide = 2,
		/obj/item/reagent_containers/cup/bottle/salglu_solution = 3,
		/obj/item/reagent_containers/cup/bottle/atropine = 2,
		/obj/item/reagent_containers/cup/bottle/capsaicin = 2,
		/obj/item/reagent_containers/cup/bottle/fentanyl = 1,
		/obj/item/reagent_containers/cup/bottle/leadacetate = 1,
		/obj/item/reagent_containers/cup/bottle/thermite = 1,
		/obj/item/reagent_containers/cup/bottle/ethanol = 2,
		/obj/item/reagent_containers/syringe = 2,
		// Medigels
		/obj/item/reagent_containers/medigel/libital = 2,
		/obj/item/reagent_containers/medigel/aiuri = 2,
		/obj/item/reagent_containers/medigel/sterilizine = 2,
		/obj/item/reagent_containers/medigel/synthflesh = 1,
	)

// Medical tools spawner

/obj/effect/spawner/random/epic_loot/medical_tools
	name = "random medical tools"
	icon_state = "random_med_tools"
	loot = list(
		/obj/item/bonesetter = 2,
		/obj/item/cautery = 2,
		/obj/item/cautery/cruel = 1,
		/obj/item/clothing/neck/stethoscope = 2,
		/obj/item/flashlight/pen = 2,
		/obj/item/flashlight/pen/paramedic = 2,
		/obj/item/healthanalyzer = 1,
		/obj/item/healthanalyzer/simple = 2,
		/obj/item/healthanalyzer/simple/disease = 2,
		/obj/item/hemostat = 2,
		/obj/item/storage/box/bandages = 1,
		/obj/item/bodybag = 2,
		/obj/item/blood_filter = 2,
		/obj/item/circular_saw = 2,
		/obj/item/clothing/gloves/latex/nitrile = 2,
		/obj/item/clothing/mask/surgical = 2,
		/obj/item/retractor = 2,
		/obj/item/scalpel = 2,
		/obj/item/shears = 1,
		/obj/item/surgical_drapes = 2,
		/obj/item/surgicaldrill = 2,
		/obj/item/epic_loot/vein_finder = 1,
		/obj/item/epic_loot/eye_scope = 1,
		/obj/item/reagent_containers/dropper = 2,
		/obj/item/reagent_containers/cup/beaker = 2,
		/obj/item/reagent_containers/cup/beaker/large = 1,
		/obj/item/reagent_containers/cup/bottle = 2,
		/obj/item/reagent_containers/cup/tube = 2,
		/obj/item/reagent_containers/syringe = 2,
		/obj/item/defibrillator = 1,
		/obj/item/defibrillator/loaded = 1,
		/obj/item/emergency_bed = 2,
		/obj/item/storage/epic_loot_medical_case = 1,
	)

// Random medkits

/obj/effect/spawner/random/epic_loot/medkit
	name = "random medkit"
	icon_state = "random_medkit"
	loot = list(
		/obj/item/storage/medkit/civil_defense/stocked = 2,
		/obj/item/storage/medkit/civil_defense/comfort/stocked = 2,
		/obj/item/storage/medkit/civil_defense/the_big_cheese = 1,
		/obj/item/storage/medkit/frontier/stocked = 2,
		/obj/item/storage/medkit/combat_surgeon/stocked = 2,
		/obj/item/storage/medkit/robotic_repair/stocked = 2,
		/obj/item/storage/medkit/robotic_repair/preemo/stocked = 1,
		/obj/item/storage/backpack/duffelbag/deforest_medkit/stocked = 1,
		/obj/item/storage/backpack/duffelbag/deforest_surgical/stocked = 1,
		/obj/item/storage/epic_loot_medpen_case = 2,
	)

// Random medpens for healing yourself

/obj/effect/spawner/random/epic_loot/medpens
	name = "random autoinjectors"
	icon_state = "random_medpen_spawner"
	loot = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/occuisate = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/adrenaline = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/morpital = 3,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lipital = 3,
		/obj/item/reagent_containers/hypospray/medipen/deforest/meridine = 3,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synephrine = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/calopine = 3,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/krotozine = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/psifinil = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/halobinin = 2,
	)

// Random medpens for fighting other people

/obj/effect/spawner/random/epic_loot/medpens_combat_based_redpilled
	name = "random combat autoinjectors"
	icon_state = "random_medpen_advanced"
	loot = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/adrenaline = 3,
		/obj/item/reagent_containers/hypospray/medipen/deforest/morpital = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lipital = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synephrine = 3,
		/obj/item/reagent_containers/hypospray/medipen/deforest/calopine = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/krotozine = 3,
		/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/twitch = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/demoneye = 1,
		/obj/item/reagent_containers/hypospray/medipen/deforest/aranepaine = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/pentibinin = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synalvipitol = 2,
	)

// Tool and supply spawners

/obj/effect/spawner/random/epic_loot/random_engineering
	name = "random engineering thing"
	icon_state = "random_component"
	loot = list(
		/obj/effect/spawner/random/epic_loot/random_components = 1,
		/obj/effect/spawner/random/epic_loot/random_computer_parts = 1,
		/obj/effect/spawner/random/epic_loot/random_tools = 1,
		/obj/effect/spawner/random/epic_loot/random_construction = 1,
	)

// Sellable components

/obj/effect/spawner/random/epic_loot/random_components
	name = "random components"
	icon_state = "random_component"
	loot = list(
		/obj/item/epic_loot/water_filter = 2,
		/obj/item/epic_loot/thermometer = 2,
		/obj/item/epic_loot/nail_box = 2,
		/obj/item/epic_loot/cold_weld = 2,
		/obj/item/epic_loot/electric_motor = 1,
		/obj/item/epic_loot/current_converter = 1,
		/obj/item/epic_loot/signal_amp = 1,
		/obj/item/epic_loot/thermal_camera = 1,
		/obj/item/epic_loot/shuttle_gyro = 1,
		/obj/item/epic_loot/phased_array = 1,
		/obj/item/epic_loot/shuttle_battery = 1,
		/obj/item/epic_loot/fuel_conditioner = 2,
		/obj/item/epic_loot/display = 1,
		/obj/item/epic_loot/display_broken = 2,
		/obj/item/epic_loot/civilian_circuit = 2,
	)

// Random computer parts

/obj/effect/spawner/random/epic_loot/random_computer_parts
	name = "random computer parts"
	icon_state = "random_electronic_part"
	loot = list(
		/obj/item/epic_loot/signal_amp = 2,
		/obj/item/epic_loot/device_fan = 2,
		/obj/item/epic_loot/graphics = 1,
		/obj/item/epic_loot/military_circuit = 1,
		/obj/item/epic_loot/civilian_circuit = 2,
		/obj/item/epic_loot/processor = 2,
		/obj/item/epic_loot/power_supply = 2,
		/obj/item/epic_loot/disk_drive = 2,
		/obj/item/epic_loot/ssd = 1,
		/obj/item/epic_loot/hdd = 1,
		/obj/item/epic_loot/military_flash = 1,
	)

// Random tools

/obj/effect/spawner/random/epic_loot/random_tools
	name = "random tools and supplies"
	icon_state = "random_tool"
	loot = list(
		// Wrench
		/obj/item/wrench = 3,
		/obj/item/wrench/bolter = 2,
		/obj/item/wrench/caravan = 1,
		/obj/item/wrench/combat = 1,
		// Screwdriver
		/obj/item/screwdriver = 3,
		/obj/item/screwdriver/omni_drill = 2,
		/obj/item/screwdriver/caravan = 1,
		// Crowbar
		/obj/item/crowbar = 3,
		/obj/item/crowbar/large/doorforcer = 2,
		/obj/item/crowbar/red/caravan = 1,
		/obj/item/fireaxe/metal_h2_axe = 1,
		// Wirecutters
		/obj/item/wirecutters = 3,
		/obj/item/wirecutters/caravan = 1,
		// Welder
		/obj/item/weldingtool = 3,
		/obj/item/weldingtool/largetank = 3,
		/obj/item/weldingtool/arc_welder = 2,
		/obj/item/weldingtool/experimental = 1,
		// Multitool
		/obj/item/multitool = 2,
		/obj/item/multitool/ai_detect = 1,
		// Rapid whatever tools
		/obj/item/pipe_dispenser = 1,
		/obj/item/construction/rcd = 1,
		/obj/item/construction/rtd = 1,
		// Misc tools and related items
		/obj/item/stack/cable_coil = 3,
		/obj/item/flashlight = 2,
		/obj/item/flashlight/flare = 3,
		/obj/item/grenade/chem_grenade/metalfoam = 2,
		/obj/item/geiger_counter = 2,
		/obj/item/analyzer = 2,
		// Various methods of insulation
		/obj/item/clothing/gloves/color/yellow = 2,
		/obj/item/clothing/gloves/chief_engineer = 1,
		/obj/item/clothing/gloves/atmos = 1,
		// Misc utility clothing
		/obj/item/clothing/gloves/tinkerer = 1,
		/obj/item/clothing/head/utility/welding = 2,
		/obj/item/clothing/head/utility/hardhat/welding = 1,
		/obj/item/clothing/glasses/meson = 3,
		/obj/item/clothing/glasses/meson/engine = 2,
		/obj/item/storage/belt/utility = 2,
		/obj/item/clothing/shoes/magboots = 2,
		// Tapes
		/obj/item/stack/sticky_tape = 2,
		/obj/item/stack/sticky_tape/super = 1,
		// Cells
		/obj/item/stock_parts/power_store/cell/upgraded = 1,
		/obj/item/stock_parts/power_store/cell/crap = 2,
		/obj/item/stock_parts/power_store/battery/upgraded = 1,
		/obj/item/stock_parts/power_store/battery/crap = 2,
		// Masks
		/obj/item/clothing/mask/gas = 3,
		/obj/item/clothing/mask/gas/welding = 2,
		/obj/item/clothing/mask/gas/atmos/frontier_colonist = 2,
		// Air tanks
		/obj/item/tank/internals/nitrogen/belt = 1,
		/obj/item/tank/internals/emergency_oxygen/engi = 2,
		/obj/item/tank/internals/emergency_oxygen/double = 1,
		// stuff
		/obj/item/storage/epic_loot_cooler = 1,
		/obj/item/storage/epic_loot_money_case = 1,
	)

// Random construction stuff

/obj/effect/spawner/random/epic_loot/random_construction
	name = "random constructions"
	icon_state = "random_tool"
	loot = list(
		// Sheets
		/obj/item/stack/sheet/iron/twenty = 2,
		/obj/item/stack/sheet/iron/ten = 3,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/plastic/five = 3,
		/obj/item/stack/sheet/plastic_wall_panel/ten = 2,
		/obj/item/stack/rods/twentyfive = 2,
		/obj/item/stack/sheet/tinumium/three = 2,
		/obj/item/stack/sheet/mineral/silver = 2,
		/obj/item/stack/sheet/mineral/gold = 2,
		/obj/item/stack/sheet/mineral/plasma/five = 2,
		// Flatpack machines
		/obj/item/flatpacked_machine = 1,
		/obj/item/flatpacked_machine/airlock_kit = 2,
		/obj/item/flatpacked_machine/airlock_kit_manual = 2,
		/obj/item/flatpacked_machine/arc_furnace = 1,
		/obj/item/flatpacked_machine/co2_cracker = 2,
		/obj/item/flatpacked_machine/frontier_griddle = 1,
		/obj/item/flatpacked_machine/frontier_range = 1,
		/obj/item/flatpacked_machine/fuel_generator = 1,
		/obj/item/flatpacked_machine/gps_beacon = 2,
		/obj/item/flatpacked_machine/hydro_synth = 1,
		/obj/item/flatpacked_machine/large_station_battery = 1,
		/obj/item/flatpacked_machine/macrowave = 1,
		/obj/item/flatpacked_machine/ore_silo = 1,
		/obj/item/flatpacked_machine/ore_thumper = 1,
		/obj/item/flatpacked_machine/organics_printer = 2,
		/obj/item/flatpacked_machine/organics_ration_printer = 2,
		/obj/item/flatpacked_machine/recycler = 2,
		/obj/item/flatpacked_machine/rtg = 2,
		/obj/item/flatpacked_machine/shutter_kit = 1,
		/obj/item/flatpacked_machine/solar = 2,
		/obj/item/flatpacked_machine/solar_tracker = 1,
		/obj/item/flatpacked_machine/station_battery = 1,
		/obj/item/flatpacked_machine/stirling_generator = 1,
		/obj/item/flatpacked_machine/sustenance_machine = 2,
		/obj/item/flatpacked_machine/thermomachine = 1,
		/obj/item/flatpacked_machine/water_synth = 2,
		/obj/item/flatpacked_machine/wind_turbine = 2,
		/obj/item/folded_navigation_gigabeacon = 1,
		/obj/item/wallframe/cell_charger_multi = 2,
		/obj/item/wallframe/wall_heater = 2,
		/obj/item/wallframe/digital_clock = 1,
		// Other things
		/obj/item/door_seal = 2,
	)

// Things from a safe

// Documents and whatnot

/obj/effect/spawner/random/epic_loot/random_documents
	name = "random documents"
	icon_state = "random_documents"
	loot = list(
		/obj/item/folder/white = 2,
		/obj/item/folder/red = 2,
		/obj/item/folder/blue = 2,
		/obj/item/folder/ancient_paperwork = 2,
		/obj/item/epic_loot/intel_folder = 2,
		/obj/item/epic_loot/corpo_folder = 2,
		/obj/item/epic_loot/slim_diary = 2,
		/obj/item/epic_loot/diary = 2,
		/obj/item/computer_disk/maintenance = 2,
		/obj/item/computer_disk/black_market = 1,
		/obj/item/computer_disk/virus = 1,
		/obj/item/clipboard = 2,
		/obj/item/pen/fountain/captain = 1,
		/obj/item/pen/fountain = 2,
		/obj/item/pen/screwdriver = 1,
		/obj/item/pen/red = 2,
		/obj/item/pen/blue = 2,
		/obj/item/pen/fourcolor = 2,
		/obj/item/pen/survival = 1,
		/obj/item/storage/epic_loot_docs_case = 1,
		/obj/item/book/granter/crafting_recipe/dusting/smoothbore_disabler_prime = 1,
		/obj/item/book/granter/crafting_recipe/dusting/laser_musket_prime = 1,
		/obj/item/book/granter/crafting_recipe/dusting/pipegun_prime = 1,
		/obj/item/book/granter/crafting_recipe/death_sandwich = 1,
		/obj/item/book/granter/crafting_recipe/trash_cannon = 1,
		/obj/item/book/granter/crafting_recipe/donk_secret_recipe = 1,
	)

// Stuff that comes in strongboxes specifically

/obj/effect/spawner/random/epic_loot/random_strongbox_loot
	name = "random strongbox loot"
	icon_state = "random_strongbox_loot"
	loot = list(
		/obj/item/epic_loot/ssd = 1,
		/obj/item/epic_loot/hdd = 1,
		/obj/effect/spawner/random/epic_loot/pocket_valuable = 2,
		/obj/effect/spawner/random/epic_loot/random_documents = 2,
	)

// Unsorted yeah

// "Military" loot

/obj/effect/spawner/random/epic_loot/random_other_military_loot
	name = "random military loot"
	desc = "Automagically transforms into some kind of misc. military loot item."
	icon_state = "random_loot_military"
	loot = list(
		/obj/item/clothing/mask/gas/sechailer = 3,
		/obj/item/clothing/mask/gas = 2,
		/obj/item/clothing/mask/gas/atmos/frontier_colonist = 2,
		/obj/item/folder/ancient_paperwork = 2,
		/obj/item/epic_loot/intel_folder = 3,
		/obj/item/epic_loot/slim_diary = 3,
		/obj/item/epic_loot/ssd = 2,
		/obj/item/epic_loot/hdd = 2,
		/obj/item/epic_loot/military_flash = 2,
		/obj/item/computer_disk/maintenance = 2,
		/obj/item/computer_disk/black_market = 1,
		/obj/item/epic_loot/plasma_explosive = 1,
		/obj/item/epic_loot/grenade_fuze = 3,
		/obj/item/epic_loot/signal_amp = 3,
		/obj/item/epic_loot/thermal_camera = 2,
		/obj/item/epic_loot/shuttle_gyro = 2,
		/obj/item/epic_loot/phased_array = 2,
		/obj/item/epic_loot/shuttle_battery = 2,
		/obj/item/epic_loot/military_circuit = 3,
		/obj/item/storage/epic_loot_medpen_case = 2,
		/obj/item/storage/epic_loot_docs_case = 2,
		/obj/item/storage/epic_loot_org_pouch = 2,
	)

// Random food for transport
/obj/effect/spawner/random/epic_loot/random_provisions
	name = "random provisions"
	icon_state = "random_food"
	loot = list(
		/obj/item/food/sustenance_bar = 3,
		/obj/item/food/sustenance_bar/cheese = 2,
		/obj/item/food/sustenance_bar/mint = 2,
		/obj/item/food/sustenance_bar/neapolitan = 2,
		/obj/item/food/vendor_snacks/mothmallow = 1,
		/obj/item/food/vendor_snacks/moth_bag = 3,
		/obj/item/food/vendor_snacks/moth_bag/cheesecake = 2,
		/obj/item/food/vendor_snacks/moth_bag/cheesecake/honey = 2,
		/obj/item/food/vendor_snacks/moth_bag/fuel_jack = 3,
		/obj/item/food/vendor_tray_meal/side/cornbread = 2,
		/obj/item/food/vendor_tray_meal/side/moffin = 2,
		/obj/item/food/vendor_tray_meal/side/roasted_seeds = 2,
		/obj/item/food/brain_pate = 2,
		/obj/item/food/branrequests = 3,
		/obj/item/food/breadslice/corn = 2,
		/obj/item/food/breadslice/reispan = 2,
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/breadslice/root = 2,
		/obj/item/food/butter = 3,
		/obj/item/food/candy = 3,
		/obj/item/food/canned/beans = 3,
		/obj/item/food/canned/peaches = 3,
		/obj/item/food/canned/tomatoes = 3,
		/obj/item/food/canned/chap = 3,
		/obj/item/food/canned/desert_snails = 2,
		/obj/item/food/canned/envirochow = 1,
		/obj/item/food/canned/jellyfish = 2,
		/obj/item/food/canned/larvae = 2,
		/obj/item/food/canned/pine_nuts = 2,
		/obj/item/food/canned/squid_ink = 1,
		/obj/item/food/cheese/firm_cheese_slice = 2,
		/obj/item/food/cheese/firm_cheese = 1,
		/obj/item/food/chocolatebar = 2,
		/obj/item/food/cnds/random = 3,
		/obj/item/food/colonial_course/pljeskavica = 1,
		/obj/item/food/colonial_course/nachos = 1,
		/obj/item/food/colonial_course/blins = 1,
		/obj/item/food/cornchips/random = 2,
		/obj/item/food/peanuts/random = 2,
		/obj/item/food/ready_donk = 1,
		/obj/item/food/ready_donk/donkhiladas = 1,
		/obj/item/food/ready_donk/donkrange_chicken = 1,
		/obj/item/food/ready_donk/mac_n_cheese = 1,
		/obj/item/food/ready_donk/nachos_grandes = 1,
		/obj/item/food/ready_donk/country_chicken = 1,
		/obj/item/food/ready_donk/salisbury_steak = 1,
		/obj/item/food/semki = 3,
		/obj/item/food/spacers_sidekick = 2,
		/obj/item/food/sticko/random = 3,
		// Ingredients
		/obj/item/reagent_containers/cup/glass/bottle/juice/limejuice = 2,
		/obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice = 2,
		/obj/item/reagent_containers/cup/glass/bottle/juice/pineapplejuice = 2,
		/obj/item/reagent_containers/condiment/milk = 1,
		/obj/item/reagent_containers/condiment/sugar/small_ration = 2,
		/obj/item/reagent_containers/condiment/flour/small_ration = 2,
		/obj/item/reagent_containers/condiment/small_ration_korta_flour = 2,
		/obj/item/reagent_containers/condiment/cherryjelly = 1,
		/obj/item/reagent_containers/condiment/rice/small_ration = 2,
		/obj/item/reagent_containers/condiment/soymilk/small_ration = 2,
		/obj/item/reagent_containers/condiment/cornmeal = 1,
		/obj/item/reagent_containers/condiment/grounding_solution = 1,
		/obj/item/reagent_containers/condiment/bbqsauce = 2,
		/obj/item/reagent_containers/condiment/chocolate = 1,
		/obj/item/reagent_containers/condiment/coconut_milk = 2,
		/obj/item/reagent_containers/condiment/curry_powder = 2,
		/obj/item/reagent_containers/condiment/dashi_concentrate = 1,
		/obj/item/reagent_containers/condiment/donksauce = 1,
		/obj/item/reagent_containers/condiment/vegetable_oil = 2,
		/obj/item/reagent_containers/condiment/worcestershire = 1,
		/obj/item/reagent_containers/condiment/enzyme = 1,
		/obj/item/reagent_containers/condiment/honey = 1,
		/obj/item/reagent_containers/condiment/hotsauce = 1,
		/obj/item/reagent_containers/condiment/ketchup = 1,
		/obj/item/reagent_containers/condiment/mayonnaise = 1,
		/obj/item/reagent_containers/condiment/peanut_butter = 1,
		/obj/item/reagent_containers/condiment/protein = 1,
		/obj/item/reagent_containers/condiment/red_bay = 2,
		/obj/item/reagent_containers/condiment/vinegar = 1,
		/obj/item/reagent_containers/condiment/coldsauce = 1,
		/obj/item/storage/box/spaceman_ration/meats = 1,
		/obj/item/storage/box/spaceman_ration/meats/lizard = 1,
		/obj/item/storage/box/spaceman_ration/meats/fish = 1,
		/obj/item/storage/box/spaceman_ration/plants = 2,
		/obj/item/storage/box/spaceman_ration/plants/alternate = 2,
		/obj/item/storage/box/spaceman_ration/plants/lizard = 2,
		/obj/item/storage/box/spaceman_ration/plants/mothic = 2,
		/obj/item/storage/box/papersack/ration_bread_slice = 1,
		/obj/item/storage/box/colonial_rations = 1,
		// Da cooler
		/obj/item/storage/epic_loot_cooler = 2,
	)

// Da money

/obj/effect/spawner/random/entertainment/money/one
	spawn_loot_count = 1

/obj/effect/spawner/random/entertainment/money_small/one
	spawn_loot_count = 1

// Maint structure spawner

/obj/effect/spawner/random/epic_loot/random_maint_loot_structure
	name = "random maintenance loot structure"
	desc = "Automagically transforms into a random loot structure that spawns in maint."
	icon = 'modular_doppler/epic_loot/icons/loot_structures.dmi'
	icon_state = "random_maint_structure"
	loot = list(
		/obj/structure/maintenance_loot_structure/ammo_box/random,
		/obj/structure/maintenance_loot_structure/computer_tower/random,
		/obj/structure/maintenance_loot_structure/file_cabinet/random,
		/obj/structure/maintenance_loot_structure/grenade_box/random,
		/obj/structure/maintenance_loot_structure/gun_box/random,
		/obj/effect/spawner/random/epic_loot/random_supply_crate,
		/obj/structure/maintenance_loot_structure/medbox/random,
		/obj/structure/maintenance_loot_structure/military_case/random,
		/obj/structure/maintenance_loot_structure/register/random,
		/obj/structure/maintenance_loot_structure/desk_safe/random,
		/obj/structure/maintenance_loot_structure/toolbox/random,
		/obj/structure/maintenance_loot_structure/wall_jacket/random,
	)
