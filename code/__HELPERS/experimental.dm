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

/obj/machinery/proc/getArea()
	var/area/A = loc.loc

	if (A != myArea)
		myArea = A

	. = myArea

/**
 * Object pooling.
 *
 * If this file is named experimental,
 * well treat this implementation as experimental experimental (redundancy intended).
 *
 * WARNING, only supports /mob and /obj.
 */

#define DEBUG_OBJECT_POOL 0
#define STARTING_OBJECT_POOL_COUNT 20

var/list/masterPool

/proc/setupPool()
	world << "\red \b Creating Object Pool..."

	masterPool = list()

	initializePool(list(\
		/obj/item/weapon/shard,\
		/obj/item/weapon/shard/plasma,\
		/obj/structure/grille))

	world << "\red \b Object Pool Creation Complete!"

/*
 * Dynamic pool initialization, mostly used on setupPool()
 *
 * @args
 * A, list of object types
 *
 * Example call: initializePool(list(/obj/item/weapon/shard))
 */
/proc/initializePool(const/A)
	if (istype(A, /list) == 0)
		return

	var/list/Objects

	for (var/objectType in A)
		Objects = list()

		for (var/i = 1 to STARTING_OBJECT_POOL_COUNT)
			Objects += new objectType()

		// Don't make reference.
		masterPool[objectType] = Objects.Copy()

#undef STARTING_OBJECT_POOL_COUNT

/*
 * @args
 * A, object type
 * B, location to spawn
 *
 * @return
 * -1, if B is not a location
 *
 * Example call: getFromPool(/obj/item/weapon/shard, loc)
 */
/proc/getFromPool(const/A, const/B)
	if (isloc(B) == 0)
		return -1

	if (isnull(masterPool[A]))
		#if DEBUG_OBJECT_POOL
		world << "DEBUG_OBJECT_POOL: new proc has been called ([A])."
		#endif

		return new A(B)

	var/atom/movable/Object = masterPool[A][1]
	masterPool[A] -= Object

	#if DEBUG_OBJECT_POOL
	world << "DEBUG_OBJECT_POOL: getFromPool([A]) [length(masterPool[A])]"
	#endif

	if (0 == length(masterPool[A]))
		masterPool[A] = null

	Object.loc = B
	return Object

/*
 * @args
 * A, object instance
 *
 * @return
 * -1, if A is not a movable atom
 *
 * Example call: returnToPool(src)
 */
/proc/returnToPool(const/A)
	if (istype(A, /atom/movable) == 0)
		return -1

	var/atom/movable/Object = A

	if (isnull(masterPool[Object.type]))
		#if DEBUG_OBJECT_POOL
		world << "DEBUG_OBJECT_POOL: [Object.type] pool is empty, recreating list."
		#endif

		masterPool[Object.type] = list()

	Object.resetVariables()

	Object.loc = null

	masterPool[Object.type] += Object

	#if DEBUG_OBJECT_POOL
	world << "DEBUG_OBJECT_POOL: returnToPool([Object.type]) [length(masterPool[Object.type])]"
	#endif

#undef DEBUG_OBJECT_POOL

/*
 * Override this if the object variables needed to reset.
 *
 * Example: see, code\game\objects\structures\grille.dm
 */
/atom/movable/proc/resetVariables()
