// Tech storage circuit board spawners
/obj/effect/spawner/random/techstorage
	name = "generic circuit board spawner"
	lootdoubles = FALSE
	fan_out_items = TRUE
	lootcount = INFINITY

/obj/effect/spawner/random/techstorage/data_disk
	name = "data disk spawner"
	lootcount = 1
	loot = list(
		/obj/item/disk/data = 49,
		/obj/item/disk/nuclear/fake/obvious = 1,
	)
