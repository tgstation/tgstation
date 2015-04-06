
//**************************************************************
// Map Datum -- Dorf Fort
//**************************************************************

/datum/map/active
	nameShort = "dorf"
	nameLong = "Dorf Fort"
	map_dir = "dorffort"
	dorf = 1
	tDomeX = 128
	tDomeY = 69
	tDomeZ = 2
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "spaceOldSat" ;
			},
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "spacePirateShip" ;
			},
		)
	New()

/proc/make_dorf_secret()
	var/turf/T = null
	var/sanity = 0
	var/list/turfs = null

	turfs = get_area_turfs(/area/mine/unexplored)

	if(!turfs.len)
		return 0

	while(1)
		sanity++
		if(sanity > 100)
			testing("Tried to place complex too many times.  Aborting.")
			return 0

		T=pick(turfs)

		var/complex_type=pick(mining_surprises)
		var/mining_surprise/complex = new complex_type

		if(complex.spawn_complex(T))
			spawned_surprises += complex
			return 1

	return 0

//**************************************************************
// Departmental Mining Surprises! -- Dorf Fort
//**************************************************************
/obj/item/toy/gooncode
	origin_tech = "materials=10;plasmatech=5;syndicate=3;programming=10;bluespace=5;power=5"



/mining_surprise/dorf/medbay
	name= "Abandoned Medbay"
	max_richness = 9
	floortypes = list(
		/turf/simulated/floor/airless=85,
		/turf/simulated/floor/plating/airless=15
	)
	walltypes = list(
		/turf/simulated/wall=100
	)
	spawntypes = list(
		/obj/structure/closet/secure_closet/medical1	= 10,
		/obj/machinery/chem_dispenser					= 6,
		/obj/machinery/chem_master						= 6,
		/obj/machinery/atmospherics/unary/cryo_cell		= 5,
		/obj/machinery/dna_scannernew					= 5,
		/obj/machinery/clonepod							= 1,
		/obj/machinery/bioprinter						= 2,
		/obj/machinery/computer/cloning					= 3,
		/obj/machinery/bot/medbot/mysterious			= 1,
	)

	fluffitems = list(
		/obj/machinery/computer/crew					= 1,
		/obj/item/weapon/storage/bag/chem				= 2,
		/obj/effect/decal/cleanable/blood				= 1,
		/obj/effect/decal/cleanable/blood/gibs			= 2,
		/obj/item/weapon/melee/defibrillator			= 1,
		/obj/structure/closet/secure_closet/medical3	= 2,
		/obj/structure/closet/secure_closet/medical2	= 2,
		/obj/structure/stool/bed/roller					= 3,
		/obj/item/device/mass_spectrometer/adv			= 1,
		/obj/item/clothing/glasses/hud/health			= 1,
	)

	complex_max_size=1
	room_size_max = 10
	flags = CONTIGUOUS_WALLS

	postProcessComplex()
		..()
		for(var/surprise_room/room in rooms)
			var/list/w_cand=room.GetTurfs(TURF_FLOOR)
			for(var/turf/simulated/floor/airless/F in w_cand)
				if(!istype(F)) continue
				F.icon_state = "barber"

/obj/structure/closet/crate/secure/engisec/PA
	name = "Particle Accelerator crate"
	req_access = list(access_engine)
	New()
		new /obj/structure/particle_accelerator/fuel_chamber(src)
		new /obj/machinery/particle_accelerator/control_box(src)
		new /obj/structure/particle_accelerator/particle_emitter/center(src)
		new /obj/structure/particle_accelerator/particle_emitter/left(src)
		new /obj/structure/particle_accelerator/particle_emitter/right(src)
		new /obj/structure/particle_accelerator/power_box(src)
		new /obj/structure/particle_accelerator/end_cap(src)
		..()
/mining_surprise/dorf/engineering
	name= "Abandoned Engine Room"
	max_richness = 9
	floortypes = list(
		/turf/simulated/floor/engine/airless=100
	)
	walltypes = list(
		/turf/simulated/wall=100
	)
	spawntypes = list(
		/obj/structure/closet/crate/secure/large/reinforced/shard		= 1,
		/obj/machinery/the_singularitygen								= 2,
		/obj/machinery/portable_atmospherics/canister/plasma			= 3,
		/obj/machinery/suit_storage_unit/engie							= 3,
		/obj/machinery/power/emitter									= 5,
		/obj/machinery/suit_storage_unit/elite							= 1,
		/obj/machinery/atmospherics/miner/air							= 1,
		/obj/structure/closet/secure_closet/engineering_atmos			= 2,
		/obj/structure/closet/crate/secure/engisec/PA					= 1,
	)

	fluffitems = list(
		/obj/item/weapon/cell/hyper/empty								= 3,
		/obj/item/weapon/cell/hyper										= 1,
		/obj/item/stack/sheet/mineral/plasma							= 2,
		/obj/structure/dispenser										= 2,
		/obj/item/weapon/circuitboard/smes								= 1,
		/obj/structure/closet/secure_closet/engineering_electrical		= 1,
		/obj/structure/closet/secure_closet/engineering_welding			= 2,
		/obj/item/weapon/rcd											= 1,
		/obj/item/weapon/pipe_dispenser									= 1,
	)

	complex_max_size=2
	room_size_max = 7
	flags = CONTIGUOUS_WALLS

/mining_surprise/dorf/hydroponics
	name= "Abandoned Hydroponics"
	max_richness = 9
	floortypes = list(
		/turf/simulated/floor/grass = 100
	)
	walltypes = list(
		/obj/structure/window/full/plasma		= 100
	)
	spawntypes = list(
		/obj/machinery/portable_atmospherics/hydroponics				= 5,
		/obj/machinery/seed_extractor									= 2,
		/obj/machinery/biogenerator										= 2,
		/obj/machinery/vending/hydronutrients							= 2,
		/obj/machinery/vending/hydroseeds								= 2,
		/obj/machinery/botany/editor									= 1,
		/obj/machinery/botany/extractor									= 1,
	)

	fluffitems = list(
		/obj/structure/closet/secure_closet/hydroponics					= 2,
		/obj/structure/closet/crate/hydroponics							= 2,
		/obj/item/weapon/reagent_containers/spray/plantbgone			= 3,
		/obj/structure/vendomatpack/hydroseeds							= 1,
		/obj/item/seeds/random											= 2,
		/obj/item/weapon/storage/fancy/egg_box							= 2,
		/mob/living/simple_animal/chicken								= 1,
		/mob/living/simple_animal/cow									= 1
	)

	complex_max_size=1
	room_size_max = 8
	flags = CONTIGUOUS_WALLS

/mining_surprise/dorf/research
	name= "Abandoned Research"
	max_richness = 9
	floortypes = list(
		/turf/simulated/floor/airless = 100
	)
	walltypes = list(
		/turf/simulated/wall/r_wall		= 100
	)
	spawntypes = list(
		/obj/machinery/computer/rdconsole/core				= 2,
		/obj/machinery/r_n_d/fabricator/circuit_imprinter	= 2,
		/obj/machinery/r_n_d/destructive_analyzer			= 2,
		/obj/item/toy/gooncode								= 1,
		/obj/machinery/r_n_d/fabricator/mech				= 2,
		/obj/machinery/computer/scan_consolenew				= 1,
	)

	fluffitems = list(
		/obj/item/device/mmi/posibrain						= 2,
		/obj/item/device/flash/synthetic					= 3,
		/obj/item/device/transfer_valve						= 1,
		/obj/item/device/mmi								= 2,
		/mob/living/carbon/slime/adult						= 1,
		/obj/machinery/mommi_spawner/dorf					= 1,
		/obj/item/weapon/storage/box/monkeycubes			= 3,

	)

	complex_max_size=1
	room_size_max = 8
	flags = CONTIGUOUS_WALLS

/mining_surprise/dorf/cargo
	name= "Abandoned Cache"
	max_richness = 5
	floortypes = list(
		/turf/simulated/floor/plating/airless = 100
	)
	walltypes = list(
		/turf/simulated/wall/r_wall		= 100
	)

	spawntypes = list(
		/obj/mecha/working/ripley/mining			= 1,
		/obj/item/weapon/pickaxe/jackhammer			= 1,
		/obj/item/weapon/pickaxe/drill/diamond		= 1,
		/obj/structure/closet/syndicate/resources	= 2,
		/obj/structure/closet/cash_closet			= 3,
	)

	fluffitems = list(
		/obj/effect/decal/cleanable/blood								= 3,
		/obj/effect/decal/remains/human									= 1,
		/obj/item/clothing/under/overalls								= 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili		= 1,
		/obj/item/weapon/tank/oxygen/red								= 2,
		/obj/item/weapon/gun/projectile/mateba							= 1
	)

	complex_max_size=3
	room_size_max=7
	flags = CONTIGUOUS_WALLS

////////////////////////////////////////////////////////////////
#include "tgstation.dmm"
