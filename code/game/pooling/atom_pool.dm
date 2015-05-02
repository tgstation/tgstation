
/*
/tg/station13 /atom/movable Pool:
---------------------------------
By RemieRichards

Creation/Deletion is laggy, so let's reduce reuse and recycle!

Locked to /atom/movable and it's subtypes due to Loc being a const var on /atom
but being read&write on /movable due to how they... move.

Usage:

To get a object, just called PoolOrNew(type, list of args to pass to New)

To put a object back in the pool, call place in pool.
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

//Second argument can be a new location
//Or a list of arguments
//Either way it gets passed to new

/proc/PoolOrNew(var/get_type,var/second_arg)
	if(!get_type)
		return

	var/atom/movable/AM
	AM = GetFromPool(get_type,second_arg)

	if(!AM)
		if(ispath(get_type))
			if(islist(second_arg))
				AM = new get_type (arglist(second_arg))
			else
				AM = new get_type (second_arg)

	if(AM)
		return AM



/proc/GetFromPool(var/get_type,var/second_arg)
	if(!get_type)
		return 0

	if(isnull(GlobalPool[get_type]))
		return 0

	if(length(GlobalPool[get_type]) == 0)
		return 0

	var/atom/movable/AM = pick_n_take(GlobalPool[get_type])
	if(AM)
		AM.ResetVars()
		if(islist(second_arg))
			AM.loc = second_arg[1]
			AM.New(arglist(second_arg))
		else
			AM.loc = second_arg
			AM.New(second_arg)
		return AM
	return 0



/proc/PlaceInPool(var/atom/movable/AM, destroy = 1)
	if(!istype(AM))
		return

	if(AM in GlobalPool[AM.type])
		return

	if(!GlobalPool[AM.type])
		GlobalPool[AM.type] = list()

	GlobalPool[AM.type] |= AM

	if (destroy)
		AM.Destroy()

	AM.ResetVars()



/atom/movable/proc/ResetVars()
	var/list/excluded = list("animate_movement", "loc", "locs", "parent_type", "vars", "verbs", "type")

	for(var/V in vars)
		if(V in excluded)
			continue

		vars[V] = initial(vars[V])

	vars["loc"] = null


