///this spawner generates a random statue
/obj/effect/statue_spawner
	icon = 'icons/obj/statue.dmi'
	icon_state = "random_statue"
	///This is the loot table for the spawner. Try to make sure the weights add up to 1000, so it is easy to understand.
	var/list/statue_table = list(
		// 15% chance of a bronze/marble statue (45% total)
		/obj/structure/statue/bronze/marx = 150,
		/obj/item/statuebust = 150,
		/obj/item/statuebust/hippocratic = 150,
		// 12.5% chance of a sandstone statue (25% total)
		/obj/structure/statue/sandstone/assistant = 125,
		/obj/structure/statue/sandstone/venus = 125,
		// 3% chance of silver statue (15% total)
		/obj/structure/statue/silver/md = 30,
		/obj/structure/statue/silver/janitor = 30,
		/obj/structure/statue/silver/sec = 30,
		/obj/structure/statue/silver/secborg = 30,
		/obj/structure/statue/silver/medborg = 30,
		// 5% chance of a plasma statue (10% total)
		/obj/structure/statue/plasma/scientist = 50,
		/obj/structure/statue/plasma/xeno = 50,
		// 0.8% chance of gold statue (4% total)
		/obj/structure/statue/gold/hos = 8,
		/obj/structure/statue/gold/hop = 8,
		/obj/structure/statue/gold/cmo = 8,
		/obj/structure/statue/gold/ce = 8,
		/obj/structure/statue/gold/rd = 8,
		// The exotic materials below combined have a 1% total spawn chance
		// 0.3% chance of bananium statue (0.3% total)
		/obj/structure/statue/bananium/clown = 3,
		// 0.2% chance of metal hydrogen statue (0.2% total)
		/obj/structure/statue/elder_atmosian = 2,
		// 0.1% chance of a uranium statue (0.2% total)
		/obj/structure/statue/uranium/nuke = 1,
		/obj/structure/statue/uranium/eng = 1,
		// 0.1% chance of diamond statue  (0.3% total)
		/obj/structure/statue/diamond/captain = 1,
		/obj/structure/statue/diamond/ai1 = 1,
		/obj/structure/statue/diamond/ai2 = 1)


/obj/effect/loot_site_spawner/Initialize()
	..()
	if(!length(statue_table))
		return INITIALIZE_HINT_QDEL

	var/spawned_object = pickweight(statue_table)
	new spawned_object(get_turf(src))

	return INITIALIZE_HINT_QDEL
