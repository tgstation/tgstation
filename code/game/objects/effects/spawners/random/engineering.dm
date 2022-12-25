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
	loot_subtype_path = /obj/item/vending_refill
	loot = list()

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
