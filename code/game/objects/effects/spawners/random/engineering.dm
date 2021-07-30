/obj/effect/spawner/random/engineering
	name = "engineering loot spawner"
	desc = "All engineering related spawners go here"

/obj/effect/spawner/random/engineering/tool
	name = "Tool spawner"
	loot = list(
		/obj/item/wrench,
		/obj/item/wirecutters,
		/obj/item/screwdriver,
		/obj/item/crowbar,
		/obj/item/weldingtool,
		/obj/item/multitool,
	)

/obj/effect/spawner/random/engineering/tool_advanced
	name = "Advanced tool spawner"
	loot = list( // Mail loot spawner. Some sort of random and rare building tool. No alien tech here.
		/obj/item/wrench/caravan,
		/obj/item/wirecutters/caravan,
		/obj/item/screwdriver/caravan,
		/obj/item/crowbar/red/caravan,
	)

/obj/effect/spawner/random/engineering/material_rare
	name = "Rare material spawner"
	lootcount = 3
	loot = list( // Space loot spawner. Random selecton of a few rarer materials.
		/obj/item/stack/sheet/runed_metal/ten = 20,
		/obj/item/stack/sheet/mineral/diamond{amount = 15} = 15,
		/obj/item/stack/sheet/mineral/uranium{amount = 15} = 15,
		/obj/item/stack/sheet/mineral/plasma{amount = 15} = 15,
		/obj/item/stack/sheet/mineral/gold{amount = 15} = 15,
		/obj/item/stack/sheet/plastic/fifty = 5,
		/obj/item/stack/sheet/runed_metal/fifty = 5,
	)
