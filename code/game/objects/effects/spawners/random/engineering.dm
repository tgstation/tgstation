/obj/effect/spawner/random/engineering
	name = "engineering loot spawner"
	desc = "All engineering related spawners go here"
	icon_state = "toolbox"

/obj/effect/spawner/random/engineering/tool
	name = "Tool spawner"
	icon_state = "wrench"
	loot = list(
		/obj/item/wrench = 2,
		/obj/item/wirecutters = 2,
		/obj/item/screwdriver = 2,
		/obj/item/crowbar = 2,
		/obj/item/weldingtool = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/analyzer = 2,
		/obj/item/t_scanner = 2,
		/obj/item/multitool = 1,
		/obj/item/clothing/glasses/meson = 1,
		/obj/item/storage/belt/utility = 1,
		/obj/item/clothing/head/utility/welding = 1,
	)

/obj/effect/spawner/random/engineering/tool_advanced
	name = "Advanced tool spawner"
	icon_state = "wrench"
	loot = list( // Mail loot spawner. Some sort of random and rare building tool. No alien tech here.
		/obj/item/wrench/caravan,
		/obj/item/wirecutters/caravan,
		/obj/item/screwdriver/caravan,
		/obj/item/crowbar/red/caravan,
		/obj/item/weldingtool/largetank,
	)

/obj/effect/spawner/random/engineering/tool_alien
	name = "Rare tool spawner"
	icon_state = "wrench"
	loot = list(
		/obj/item/wrench/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/screwdriver/abductor,
		/obj/item/crowbar/abductor,
		/obj/item/weldingtool/abductor,
		/obj/item/multitool/abductor,
	)

/obj/effect/spawner/random/engineering/material_cheap
	name = "Cheap material spawner"
	icon_state = "cardboard"
	loot = list(
		/obj/item/stack/sheet/mineral/wood{amount = 30},
		/obj/item/stack/sheet/cardboard{amount = 30},
		/obj/item/stack/sheet/mineral/sandstone/thirty,
	)

/obj/effect/spawner/random/engineering/material
	name = "Material spawner"
	icon_state = "metal"
	loot = list(
		/obj/item/stack/sheet/iron/fifty = 5,
		/obj/item/stack/sheet/glass/fifty = 5,
		/obj/item/stack/rods/fifty = 3,
		/obj/item/stack/sheet/rglass{amount = 30} = 2,
	)

/obj/effect/spawner/random/engineering/material_rare
	name = "Rare material spawner"
	icon_state = "diamond"
	spawn_loot_count = 3
	loot = list( // Space loot spawner. Random selecton of a few rarer materials.
		/obj/item/stack/sheet/runed_metal/ten = 20,
		/obj/item/stack/sheet/mineral/diamond{amount = 15} = 15,
		/obj/item/stack/sheet/mineral/uranium{amount = 15} = 15,
		/obj/item/stack/sheet/mineral/plasma{amount = 15} = 15,
		/obj/item/stack/sheet/mineral/gold{amount = 15} = 15,
		/obj/item/stack/sheet/plastic/fifty = 5,
		/obj/item/stack/sheet/runed_metal/fifty = 5,
	)

/obj/effect/spawner/random/engineering/toolbox
	name = "toolbox spawner"
	icon_state = "toolbox"
	loot = list(
		/obj/item/storage/toolbox/emergency = 4,
		/obj/item/storage/toolbox/electrical = 2,
		/obj/item/storage/toolbox/mechanical = 2,
	)

/obj/effect/spawner/random/engineering/flashlight
	name = "flashlight spawner"
	icon_state = "flashlight"
	loot = list(
		/obj/item/flashlight = 20,
		/obj/item/flashlight/flare = 10,
		/obj/effect/spawner/random/decoration/glowstick = 10,
		/obj/item/flashlight/lantern = 5,
		/obj/item/flashlight/seclite = 4,
		/obj/item/flashlight/lantern/jade = 1,
	)

/obj/effect/spawner/random/engineering/canister
	name = "air canister spawner"
	icon_state = "canister"
	loot = list( // use this for emergency storage areas and maint
		/obj/machinery/portable_atmospherics/canister/air = 4,
		/obj/machinery/portable_atmospherics/canister/oxygen = 1,
	)

/obj/effect/spawner/random/engineering/tank
	name = "tank spawner"
	icon_state = "tank"
	loot = list( // use this for emergency storage areas and maint
		/obj/structure/reagent_dispensers/fueltank = 5,
		/obj/structure/reagent_dispensers/watertank = 4,
		/obj/structure/reagent_dispensers/watertank/high = 1,
	)

/obj/effect/spawner/random/engineering/vending_restock
	name = "vending restock spawner"
	icon_state = "vending_restock"
	loot = list(
		/obj/effect/spawner/random/engineering/vending_restock/common = 935,
		/obj/effect/spawner/random/engineering/vending_restock/rare = 60,
		/obj/effect/spawner/random/engineering/vending_restock/oddity = 5,
	)

/obj/effect/spawner/random/engineering/vending_restock/wardrobe
	name = "wardrobe vending restock spawner"
	icon_state = "vending_restock"
	loot = list(
		/obj/item/vending_refill/wardrobe/det_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/medi_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/chem_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/viro_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/sec_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/science_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/robo_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/gene_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/engi_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/atmos_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/cargo_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/hydro_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/chap_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/chef_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/chap_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/curator_wardrobe= 1,
		/obj/item/vending_refill/wardrobe/jani_wardrobe = 1,
		/obj/item/vending_refill/wardrobe/law_wardrobe = 1,

	)


/obj/effect/spawner/random/engineering/vending_restock/food_and_drink
	name = "food & drink vending restock spawner"
	icon_state = "vending_restock"
	loot = list(
		/obj/item/vending_refill/cigarette = 1,
		/obj/item/vending_refill/cola = 1,
		/obj/item/vending_refill/coffee = 1,
		/obj/item/vending_refill/snack = 1,
		/obj/item/vending_refill/boozeomat = 1,
		/obj/item/vending_refill/sustenance = 1,
		/obj/item/vending_refill/sovietsoda = 1,
		/obj/item/vending_refill/cola/shamblers = 1,
	)

/obj/effect/spawner/random/engineering/vending_restock/medical
	name = "medical vending restock spawner"
	icon_state = "vending_restock"
	loot = list(
		/obj/item/vending_refill/wallmed = 1,
		/obj/item/vending_refill/medical = 1,
		/obj/item/vending_refill/drugs = 1,
	)

/obj/effect/spawner/random/engineering/vending_restock/engineering
	name = "engineering vending restock spawner"
	icon_state = "vending_restock"
	loot = list(
		/obj/item/vending_refill/engivend = 1,
		/obj/item/vending_refill/engineering = 1,
		/obj/item/vending_refill/youtool = 1,
		/obj/item/vending_refill/modularpc = 1,
		/obj/item/vending_refill/robotics = 1,
		/obj/item/vending_refill/assist = 1,
	)

//common everyday vendors
/obj/effect/spawner/random/engineering/vending_restock/common
	name = "common vending restock spawner"
	icon_state = "vending_restock"
	loot = list(
		/obj/effect/spawner/random/engineering/vending_restock/wardrobe = 8, //roughtly reduced to half weight due to lameness of drobe contents
		/obj/effect/spawner/random/engineering/vending_restock/food_and_drink = 8,
		/obj/effect/spawner/random/engineering/vending_restock/engineering = 6,
		/obj/effect/spawner/random/engineering/vending_restock/medical = 3,
		/obj/item/vending_refill/cart = 1,
		/obj/item/vending_refill/clothing = 1,
		/obj/item/vending_refill/autodrobe = 1,
		/obj/item/vending_refill/security = 1,
		/obj/item/vending_refill/custom = 1,
		/obj/item/vending_refill/dinnerware = 1,
		/obj/item/vending_refill/cytopro = 1,
		/obj/item/vending_refill/hydronutrients = 1,
		/obj/item/vending_refill/hydroseeds = 1,
		/obj/item/vending_refill/games = 1,
	)

//vendors that should feel rare and special but are unlikely to warp the shift too much
/obj/effect/spawner/random/engineering/vending_restock/rare
	name = "rare vending restock spawner"
	icon_state = "vending_restock"
	loot = list(
		/obj/item/vending_refill/syndichem = 1,
		/obj/item/vending_refill/cigarette/syndicate = 1,
		/obj/item/vending_refill/plasmaresearch = 1,
		/obj/item/vending_refill/donksnackvendor = 1,
		/obj/item/vending_refill/donksoft = 1,
		/obj/item/vending_refill/hotdog = 1,
	)

//high chance to derail the shift, use cautiously
/obj/effect/spawner/random/engineering/vending_restock/oddity
	name = "oddity vending restock spawner"
	icon_state = "vending_restock"
	loot = list(

		/obj/item/vending_refill/magivend = 1,
		/obj/item/vending_refill/liberation = 1,
		/obj/item/vending_refill/wardrobe/cent_wardrobe = 1,

	)

/obj/effect/spawner/random/engineering/atmospherics_portable
	name = "portable atmospherics machine spawner"
	icon_state = "heater"
	loot = list(
		/obj/machinery/space_heater = 8,
		/obj/machinery/shieldgen = 3,
		/obj/machinery/portable_atmospherics/pump = 1,
		/obj/machinery/portable_atmospherics/scrubber = 1,
	)

/obj/effect/spawner/random/engineering/tracking_beacon
	name = "tracking beacon spawner"
	icon_state = "beacon"
	spawn_loot_chance = 35
	loot = list(/obj/item/beacon)
