
/*
/tg/station13 /datum Pool:
---------------------------------
By RemieRichards

Creation/Deletion is laggy, so let's reduce reuse and recycle!

Usage:

To get a object, just call
 - PoolOrNew(type, arg) if you only want to pass one argument to New(), usually loc
 - PoolOrNew(type, list) if you want to pass multiple arguments to New()

To put a object back in the pool, call PlaceInPool(object)
This will call destroy on the object, set its loc to null,
and reset all of its vars to their default

You can override your object's destroy to return QDEL_HINT_PLACEINPOOL
to ensure its always placed in this pool (this will only be acted on if qdel calls destroy, and destroy will not get called twice)

*/

var/global/list/GlobalPool = list()

//You'll be using this proc 90% of the time.
//It grabs a type from the pool if it can
//And if it can't, it creates one
//The pool is flexible and will expand to fit
//The new created atom when it eventually
//Goes into the pool

//Second argument can be a single arg
//Or a list of arguments
//Either way it gets passed to new

/proc/PoolOrNew(get_type,second_arg)
	if(!get_type)
		return

	. = GetFromPool(get_type,second_arg)

	if(!.)
		if(ispath(get_type))
			if(islist(second_arg))
				. = new get_type (arglist(second_arg))
			else
				. = new get_type (second_arg)


/proc/GetFromPool(get_type,second_arg)
	if(!get_type)
		return

	if(isnull(GlobalPool[get_type]))
		return

	if(length(GlobalPool[get_type]) == 0)
		return

	var/datum/pooled = pop(GlobalPool[get_type])
	if(pooled)
		pooled.ResetVars()
		var/atom/movable/AM
		if(istype(pooled, /atom/movable))
			AM = pooled

		if(islist(second_arg))
			if(AM)
				AM.loc = second_arg[1] //we need to do loc setting explicetly before even calling New() to replicate new()'s behavior
			pooled.New(arglist(second_arg))

		else
			if(AM)
				AM.loc = second_arg
			pooled.New(second_arg)

		return pooled


/proc/PlaceInPool(datum/diver, destroy = 1)
	if(!istype(diver))
		return

	if(diver in GlobalPool[diver.type])
		return

	if(!GlobalPool[diver.type])
		GlobalPool[diver.type] = list()

	GlobalPool[diver.type] |= diver

	if (destroy)
		diver.Destroy()

	diver.ResetVars()


/datum/proc/ResetVars()
	var/list/excluded = list("animate_movement", "contents", "loc", "locs", "parent_type", "vars", "verbs", "type")

	for(var/V in vars)
		if(V in excluded)
			continue

		vars[V] = initial(vars[V])

/atom/movable/ResetVars()
	..()
	loc = null
	contents = initial(contents) //something is really wrong if this object still has stuff in it by this point

/image/ResetVars()
	..()
	loc = null