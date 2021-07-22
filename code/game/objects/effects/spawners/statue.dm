///this spawner generates a random statue
/obj/effect/spawner/lootdrop/statue
	icon = 'icons/obj/statue.dmi'
	icon_state = "random_statue"
	lootdoubles = FALSE
	loot = list( // total weight is 1000 for all statues
		// bronze/marble statues 45% total
		/obj/structure/statue/bronze/marx = 150,
		/obj/item/statuebust = 150,
		/obj/item/statuebust/hippocratic = 150,
		// sandstone statues 25% total
		/obj/structure/statue/sandstone/assistant = 125,
		/obj/structure/statue/sandstone/venus = 125,
		// silver statues 15% total
		/obj/structure/statue/silver/md = 30,
		/obj/structure/statue/silver/janitor = 30,
		/obj/structure/statue/silver/sec = 30,
		/obj/structure/statue/silver/secborg = 30,
		/obj/structure/statue/silver/medborg = 30,
		// plasma statues 10% total
		/obj/structure/statue/plasma/scientist = 50,
		/obj/structure/statue/plasma/xeno = 50,
		// gold statues 4% total
		/obj/structure/statue/gold/hos = 8,
		/obj/structure/statue/gold/hop = 8,
		/obj/structure/statue/gold/cmo = 8,
		/obj/structure/statue/gold/ce = 8,
		/obj/structure/statue/gold/rd = 8,
		// The exotic materials below combined have a 1% total spawn chance
		// bananium statue 0.3% total
		/obj/structure/statue/bananium/clown = 3,
		// metal hydrogen statue 0.2% total
		/obj/structure/statue/elder_atmosian = 2,
		// uranium statues 0.2% total
		/obj/structure/statue/uranium/nuke = 1,
		/obj/structure/statue/uranium/eng = 1,
		// diamond statues 0.3% total
		/obj/structure/statue/diamond/captain = 1,
		/obj/structure/statue/diamond/ai1 = 1,
		/obj/structure/statue/diamond/ai2 = 1
	)
