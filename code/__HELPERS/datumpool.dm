//This was made pretty explicity for atmospherics devices which could not delete their datums properly
//Make sure you go around and null out those references to the datum
//It was also pretty explicitly and shamelessly stolen from regular object pooling, thanks esword

//#define DEBUG_DATUM_POOL

#define MAINTAINING_DATUM_POOL_COUNT 100
var/global/list/masterdatumPool = new

/*
 * @args : datum type, normal arguments
 * Example call: getFromPool(/datum/pipeline, args)
 */
/proc/getFromDPool()
	var/A = args[1]
	var/list/B = list()
	B += (args - A)
	if(length(masterdatumPool["[A]"]) <= 0)
		#ifdef DEBUG_DATUM_POOL
		world << text("DEBUG_DATUM_POOL: new proc has been called ([] | []).", A, list2params(B))
		#endif
		//so the GC knows we're pooling this type.
		if(isnull(masterdatumPool["[A]"]))
			masterdatumPool["[A]"] = list(new A)
		if(B && B.len)
			return new A(arglist(B))
		else
			return new A()

	var/datum/O = masterdatumPool["[A]"][1]
	masterdatumPool["[A]"] -= O

	#ifdef DEBUG_DATUM_POOL
	world << text("DEBUG_DATUM_POOL: getFromPool([]) [] left arglist([]).", A, length(masterdatumPool[A]), list2params(B))
	#endif
	if(!O || !istype(O))
		O = new A(arglist(B))
	else
		if(B && B.len)
			O.New(arglist(B))
		else
			O.New()
		O.disposed = null //Set to process once again
	return O

/*
 * @args
 * A, datum instance
 *
 * @return
 * -1, if A is not a movable atom
 *
 * Example call: returnToDPool(src)
 */
/proc/returnToDPool(const/datum/D)
	if(!D)
		return
	if(length(masterdatumPool["[D.type]"]) > MAINTAINING_DATUM_POOL_COUNT)
		#ifdef DEBUG_DATUM_POOL
		world << text("DEBUG_DATUM_POOL: returnToPool([]) exceeds [] discarding...", D.type, MAINTAINING_DATUM_POOL_COUNT)
		#endif
		del(D)
		return
	if(isnull(masterdatumPool["[D.type]"]))
		masterdatumPool["[D.type]"] = list()
	D.Destroy()
	D.resetVariables()
	D.disposed = 1 //Set to stop processing while pooled
	#ifdef DEBUG_DATUM_POOL
	if(D in masterdatumPool["[D.type]"])
		world << text("returnToPool has been called twice for the same datum of type [] time to panic.", D.type)
	#endif
	masterdatumPool["[D.type]"] += D

	#ifdef DEBUG_DATUM_POOL
	world << text("DEBUG_DATUM_POOL: returnToPool([]) [] left.", D.type, length(masterdatumPool["[D.type]"]))
	#endif

#undef MAINTAINING_DATUM_POOL_COUNT

#ifdef DEBUG_DATUM_POOL
#undef DEBUG_DATUM_POOL
#endif

//RETURNS NULL WHEN INITIALIZED AS A LIST() AND POSSIBLY OTHER DISCRIMINATORS
//IF YOU ARE USING SPECIAL VARIABLES SUCH A LIST() INITIALIZE THEM USING RESET VARIABLES
//SEE http://www.byond.com/forum/?post=76850 AS A REFERENCE ON THIS

/datum/proc/resetVariables()
	var/list/exclude = global.exclude + args // explicit var exclusion
	for(var/key in vars)
		if(key in exclude)
			continue
		vars[key] = initial(vars[key])
