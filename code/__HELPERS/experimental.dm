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
/proc/strpos(const/A, const/B)
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
 * WARNING, only supports /atom/movable (/mob and /obj)
 */

// Uncomment to show debug messages.
//#define DEBUG_OBJECT_POOL

#define MAINTAINING_OBJECT_POOL_COUNT 20

var/list/masterPool = list()

// Read-only or compile-time vars and special exceptions.
var/list/exclude = list("loc", "locs", "parent_type", "vars", "verbs", "type")

/*
 * @args
 * A, object type
 * B, location to spawn
 *
 * Example call: getFromPool(/obj/item/weapon/shard, loc)
 */
/proc/getFromPool(const/A, const/B)
	if (isnull(masterPool[A]))
		#ifdef DEBUG_OBJECT_POOL
		world << "DEBUG_OBJECT_POOL: new proc has been called ([A])."
		#endif

		return new A(B)

	var/atom/movable/O = masterPool[A][1]
	masterPool[A] -= O
	var/objectLength = length(masterPool[A])

	#ifdef DEBUG_OBJECT_POOL
	world << "DEBUG_OBJECT_POOL: getFromPool([A]) [objectLength] left."
	#endif

	if (!objectLength)
		masterPool[A] = null

	O.loc = B
	return O

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
	if (!istype(A, /atom/movable))
		return -1

	var/atom/movable/O = A
	O.resetVariables()

	switch (length(masterPool[O.type]))
		if (MAINTAINING_OBJECT_POOL_COUNT to 1.#INF)
			#ifdef DEBUG_OBJECT_POOL
			world << "DEBUG_OBJECT_POOL: returnToPool([O.type]) exceeds [MAINTAINING_OBJECT_POOL_COUNT] discarding..."
			#endif

			return
		if (0) // In a numeric context (like a mathematical operation), null evaluates to 0.
			#ifdef DEBUG_OBJECT_POOL
			world << "DEBUG_OBJECT_POOL: [O.type] pool is empty, recreating pool."
			#endif

			masterPool[O.type] = list()

	masterPool[O.type] += O

	#ifdef DEBUG_OBJECT_POOL
	world << "DEBUG_OBJECT_POOL: returnToPool([O.type]) [length(masterPool[O.type])] left."
	#endif

#undef MAINTAINING_OBJECT_POOL_COUNT

#ifdef DEBUG_OBJECT_POOL
#undef DEBUG_OBJECT_POOL
#endif

/*
 * Override this if the object variables needed to reset.
 *
 * Example: see, code\game\objects\items\stacks\sheets\glass.dm
 *				 /obj/item/weapon/shard/resetVariables()
 */
/atom/movable/proc/resetVariables()
	var/list/exclude = global.exclude + args // Explicit var exclusion.

	var/key

	for (key in vars)
		if (key in exclude)
			continue

		vars[key] = initial(vars[key])

	vars["loc"] = null // Making sure the loc is null not a compile-time var value.
