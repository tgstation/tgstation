/*
 * Experimental procs by ESwordTheCat.
 */

/*
 * Get index of last char occurence to string.
 *
 * @args
 * A, string to be search
 * B, char used for search
 *
 * @return
 * >0, index of char at string
 *  0, char not found
 * -1, parameter B is not a char
 * -2, parameter A is not a string
 */
/proc/EgijkAeN(const/A, const/B)
	if (istext(A) == 0 || length(A) < 1)
		return -2

	if (istext(B) == 0 || length(B) > 1)
		return -1

	var/i = findtext(A, B)

	if (0 == i)
		return 0

	while (i)
		. = i
		i = findtext(A, B, i + 1)

/**
 * Object pooling.
 *
 * If this file is named experimental,
 * well treat this implementation as experimental experimental (redundancy intended).
 *
 * REMINDER TO MYSELF: Ignore fireaxe deletion for now.
 */

#define DEBUG_OBJECT_POOL 1

// List reference for pools.
var/list/shardPool
var/list/plasmaShardPool
var/list/grillePool

#define STARTING_OBJECT_POOL_COUNT 20
/proc/setupPool()
	world << "\red \b Creating Object Pool..."

	shardPool = new /list()
	plasmaShardPool = new /list()
	grillePool = new /list()

	for (var/i = 0; i < STARTING_OBJECT_POOL_COUNT; i++)
		shardPool = shardPool + new /obj/item/weapon/shard()
		plasmaShardPool = plasmaShardPool + new /obj/item/weapon/shard/plasma()
		grillePool = grillePool + new /obj/structure/grille()

	world << "\red \b Object Pool Creation Complete!"
#undef STARTING_OBJECT_POOL_COUNT

/*
 * @args
 * A, type path
 */
#define FIRST_OBJECT 1
/proc/getFromPool(A)
	switch (A)
		if (/obj/item/weapon/shard)
			if (isnull(shardPool))
				#if DEBUG_OBJECT_POOL
				world << "New proc has been called (/obj/item/weapon/shard)."
				#endif
				return new /obj/item/weapon/shard()

			. = shardPool[FIRST_OBJECT]
			shardPool = shardPool - .

			if (0 == shardPool.len)
				shardPool = null
		if (/obj/item/weapon/shard/plasma)
			if (isnull(plasmaShardPool))
				#if DEBUG_OBJECT_POOL
				world << "New proc has been called (obj/item/weapon/shard/plasma)."
				#endif
				return new /obj/item/weapon/shard/plasma()

			. = plasmaShardPool[FIRST_OBJECT]
			plasmaShardPool = plasmaShardPool - .

			if (0 == plasmaShardPool.len)
				plasmaShardPool = null
		if (/obj/structure/grille)
			if (isnull(grillePool))
				#if DEBUG_OBJECT_POOL
				world << "New proc has been called (/obj/structure/grille)."
				#endif
				return new /obj/structure/grille()

			. = grillePool[FIRST_OBJECT]
			grillePool = grillePool - .

			if (0 == grillePool.len)
				grillePool = null
#undef FIRST_OBJECT

/*
 * @args
 * A, datum
 */
/proc/returnToPool(datum/A)
	switch(A.type)
		if (/obj/item/weapon/shard)
			if (isnull(shardPool))
				#if DEBUG_OBJECT_POOL
				world << "Shard pool is empty, recreating list."
				#endif
				shardPool = new /list()

			var /obj/item/weapon/shard/Shard = A

			Shard.loc = initial(Shard.loc)

			shardPool = shardPool + Shard
		if (/obj/item/weapon/shard/plasma)
			if (isnull(plasmaShardPool))
				#if DEBUG_OBJECT_POOL
				world << "Plasma shard pool is empty, recreating list."
				#endif
				plasmaShardPool = new /list()

			var /obj/item/weapon/shard/plasma/Plasma = A

			Plasma.loc = initial(Plasma.loc)

			plasmaShardPool = plasmaShardPool + Plasma
		if (/obj/structure/grille)
			if (isnull(grillePool))
				#if DEBUG_OBJECT_POOL
				world << "Grille pool is empty, recreating list."
				#endif
				grillePool = new /list()

			var /obj/structure/grille/Grille = A

			Grille.loc = initial(Grille.loc)
			Grille.icon_state = initial(Grille.icon_state)
			Grille.density = initial(Grille.density)
			Grille.destroyed = initial(Grille.destroyed)
			Grille.health = initial(Grille.health)

			grillePool = grillePool + Grille

#undef DEBUG_OBJECT_POOL
