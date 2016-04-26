//This was made pretty explicity for atmospherics devices which could not delete their datums properly
//Make sure you go around and null out those references to the datum
//It was also pretty explicitly and shamelessly stolen from regular object pooling, thanks esword

//#define DEBUG_DATUM_POOL

#define MAINTAINING_OBJECT_POOL_COUNT 500

// Read-only or compile-time vars and special exceptions.
/var/list/exclude = list("inhand_states", "loc", "locs", "parent_type", "vars", "verbs", "type", "x", "y", "z","group", "animate_movement")

/var/global/list/masterdatumPool = new
/var/global/list/pooledvariables = new

/*
 * @args : datum type, normal arguments
 * Example call: getFromPool(/datum/pipeline, args)
 */
/proc/getFromPool(var/type, ...)
	var/list/B = (args - type)

	if(length(masterdatumPool[type]) <= 0)

		#ifdef DEBUG_DATUM_POOL
		if(ticker)
			to_chat(world, text("DEBUG_DATUM_POOL: new proc has been called ([] | []).", type, list2params(B)))
		#endif

		//so the GC knows we're pooling this type.
		if(isnull(masterdatumPool[type]))
			masterdatumPool[type] = list()

		if(B && B.len)
			return new type(arglist(B))
		else
			return new type()

	var/datum/O = masterdatumPool[type][1]
	masterdatumPool[type] -= O

	#ifdef DEBUG_DATUM_POOL
	to_chat(world, text("DEBUG_DATUM_POOL: getFromPool([]) [] left arglist([]).", type, length(masterdatumPool[type]), list2params(B)))
	#endif

	if(!O || !istype(O))
		O = new type(arglist(B))
	else
		if(istype(O, /atom/movable) && B.len) // B.len check so we don't OoB.
			var/atom/movable/AM = O
			AM.loc = B[1]

		if(B && B.len)
			O.New(arglist(B))
		else
			O.New()

		O.disposed = null //Set to process once again
	return O

/*
 * @args
 * D, datum instance
 *
 * Example call: returnToPool(src)
 */

/proc/returnToPool(const/datum/D)
	ASSERT(D)

	if(istype(D, /atom/movable) && length(masterdatumPool[D.type]) > MAINTAINING_OBJECT_POOL_COUNT)
		#ifdef DEBUG_DATUM_POOL
		to_chat(world, text("DEBUG_DATUM_POOL: returnToPool([]) exceeds [] discarding...", D.type, MAINTAINING_OBJECT_POOL_COUNT))
		#endif

		qdel(D)
		return

	if(isnull(masterdatumPool[D.type]))
		masterdatumPool[D.type] = list()

	D.Destroy()
	D.resetVariables()
	D.disposed = 1 //Set to stop processing while pooled

	#ifdef DEBUG_DATUM_POOL
	if(D in masterdatumPool[D.type])
		to_chat(world, text("returnToPool has been called twice for the same datum of type [] time to panic.", D.type))
	#endif

	masterdatumPool[D.type] |= D

	#ifdef DEBUG_DATUM_POOL
	to_chat(world, text("DEBUG_DATUM_POOL: returnToPool([]) [] left.", D.type, length(masterdatumPool[D.type])))
	#endif

#undef MAINTAINING_DATUM_POOL_COUNT

#ifdef DEBUG_DATUM_POOL
#undef DEBUG_DATUM_POOL
#endif

/datum/proc/createVariables()
	pooledvariables[type] = new/list()
	var/list/exclude = global.exclude + args

	for(var/key in vars)
		if(key in exclude)
			continue
		pooledvariables[type][key] = initial(vars[key])

//RETURNS NULL WHEN INITIALIZED AS A LIST() AND POSSIBLY OTHER DISCRIMINATORS
//IF YOU ARE USING SPECIAL VARIABLES SUCH A LIST() INITIALIZE THEM USING RESET VARIABLES
//SEE http://www.byond.com/forum/?post=76850 AS A REFERENCE ON THIS

/datum/proc/resetVariables()
	if(!pooledvariables[type])
		createVariables(args)

	for(var/key in pooledvariables[type])
		vars[key] = pooledvariables[type][key]

/proc/isInTypes(atom/Object, types)
	if(!Object)
		return 0
	var/prototype = Object.type
	Object = null

	for (var/type in params2list(types))
		if (ispath(prototype, text2path(type)))
			return 1

	return 0
