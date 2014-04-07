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

#define DEBUG_OBJECT_POOL 0
#define STARTING_OBJECT_POOL_COUNT 20

var/list/masterPool

/proc/setupPool()
	world << "\red \b Creating Object Pool..."

	masterPool = new /list()

	var/list/shardPool = new /list()
	var/list/plasmaShardPool = new /list()
	var/list/grillePool = new /list()

	for (var/i = 1 to STARTING_OBJECT_POOL_COUNT)
		shardPool = shardPool + new /obj/item/weapon/shard()
		plasmaShardPool = plasmaShardPool + new /obj/item/weapon/shard/plasma()
		grillePool = grillePool + new /obj/structure/grille()

	masterPool[/obj/item/weapon/shard] = shardPool
	masterPool[/obj/item/weapon/shard/plasma] = plasmaShardPool
	masterPool[/obj/structure/grille] = grillePool

	world << "\red \b Object Pool Creation Complete!"

#undef STARTING_OBJECT_POOL_COUNT

/*
 * @args
 * A, type not object instance
 * B, loc
 *
 * Example call: getFromPool(/obj/item/weapon/shard, loc)
 */
/proc/getFromPool(A, B)
	if (isnull(masterPool[A]))
		#if DEBUG_OBJECT_POOL
		world << "DEBUG_OBJECT_POOL: new proc has been called ([A])."
		#endif
		return new A(B)

	var /atom/movable/Object = masterPool[A][1]
	masterPool[A] = masterPool[A] - Object
	Object.loc = B
	. = Object

	#if DEBUG_OBJECT_POOL
	world << "DEBUG_OBJECT_POOL: getFromPool([A.type]) [length(masterPool[A])]"
	#endif

	if (0 == length(masterPool[A]))
		masterPool[A] = null

/*
 * @args
 * A, object instance not type
 *
 * Example call: returnToPool(src)
 */
/proc/returnToPool(atom/movable/A)
	if (isnull(masterPool[A.type]))
		#if DEBUG_OBJECT_POOL
		world << "DEBUG_OBJECT_POOL: [A.type] pool is empty, recreating list."
		#endif
		masterPool[A.type] = new /list()

	var /atom/movable/Object = A
	Object.loc = null

	Object.resetVariables()

	masterPool[A.type] = masterPool[A.type] + Object

	#if DEBUG_OBJECT_POOL
	world << "DEBUG_OBJECT_POOL: returnToPool([A]) [length(masterPool[A.type])]"
	#endif

#undef DEBUG_OBJECT_POOL

/*
 * Override this if the object variables needed to reset.
 *
 * Example: see, code\game\objects\structures\grille.dm
 */
/atom/movable/proc/resetVariables()
