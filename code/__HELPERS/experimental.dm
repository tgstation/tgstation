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
 */

// We put the pools on a place that's very hard to find.
var/turf/sekrit = locate(1, 1, CENTCOMM_Z)

// List reference for pools.
var/list/shardPool
var/list/plasmaShardPool
var/list/grillePool

/*
 * @args
 * A, type path
 */
#define FIRST_OBJECT 1
/proc/getFromPool(A)
	switch (A)
		if (/obj/item/weapon/shard)
			if (isnull(shardPool))
				return new /obj/item/weapon/shard()

			. = shardPool[FIRST_OBJECT]
			shardPool = shardPool - .

			if (0 == shardPool.len)
				shardPool = null
		if (/obj/item/weapon/shard/plasma)
			if (isnull(plasmaShardPool))
				return new /obj/item/weapon/shard/plasma()

			. = plasmaShardPool[FIRST_OBJECT]
			plasmaShardPool = plasmaShardPool - .

			if (0 == plasmaShardPool.len)
				plasmaShardPool = null
		if (/obj/structure/grille)
			if (isnull(grillePool))
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
				shardPool = new /list()

			var /obj/item/weapon/shard/Shard = A
			Shard.loc = sekrit
			shardPool = shardPool + Shard
		if (/obj/item/weapon/shard/plasma)
			if (isnull(plasmaShardPool))
				plasmaShardPool = new /list()

			var /obj/item/weapon/shard/plasma/Plasma = A
			Plasma.loc = sekrit
			plasmaShardPool = plasmaShardPool + Plasma
		if (/obj/structure/grille)
			if (isnull(grillePool))
				grillePool = new /list()

			var /obj/structure/grille/Grille = A
			Grille.loc = sekrit

			Grille.icon_state = initial(Grille.icon_state)
			Grille.destroyed = initial(Grille.destroyed)

			grillePool = grillePool + Grille
