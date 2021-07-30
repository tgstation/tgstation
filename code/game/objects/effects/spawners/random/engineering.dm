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
