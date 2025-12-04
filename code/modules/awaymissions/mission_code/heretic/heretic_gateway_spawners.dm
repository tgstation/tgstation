/obj/effect/spawner/random/heretic_gateway
	name = "random heretic keycard spawn"
	desc = "Spawns a random keycard, but probably trash."
	loot = list(
		/obj/item/keycard/cbrn_area = 5,
		/obj/item/keycard/biological_anomalies = 20,
		/obj/item/keycard/misc_anomalies = 20,
		/obj/item/keycard/weapon_anomalies = 20,
		/obj/effect/spawner/random/trash/deluxe_garbage = 35
	)

/obj/effect/spawner/random/heretic_gateway_low
	name = "random heretic keycard spawn"
	desc = "Spawns a random keycard, but definitely just trash."
	loot = list(
		/obj/item/keycard/cbrn_area = 0.5,
		/obj/item/keycard/biological_anomalies = 5,
		/obj/item/keycard/misc_anomalies = 5,
		/obj/item/keycard/weapon_anomalies = 4,
		/obj/effect/spawner/random/trash/deluxe_garbage = 85.5
	)
