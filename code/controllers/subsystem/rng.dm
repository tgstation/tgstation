//If we do rand_seed(1); prob(50); rand(1, 10); rand(1, 100)
//and then rand_seed(1); rand(); rand(1, 10); rand(1, 100)

//Both rand(1, 10) and rand(1, 100) calls will return the same result, every time
//This is why we care about the total offset, so we know where we are in the chain

SUBSYSTEM_DEF(rng)
	name = "RNG"
	init_order = INIT_ORDER_RNG
	flags = SS_NO_FIRE|SS_NO_INIT

	var/total_offset = 0
	var/seed = -1 //if this is -1, we haven't initialized yet. Range is 24 bit precision, 0 to 2**24-1

/datum/controller/subsystem/rng/PreInit()
	set_seed()

/datum/controller/subsystem/rng/proc/set_seed(_seed)
	if(!isnum(_seed) || !(_seed in 0 to 16777215))
		_seed = rand(0, 16777215)
	seed = _seed
	rand_seed(seed)
	total_offset = 0

//This proc is going to be fairly slow; be conservative with it
/datum/controller/subsystem/rng/proc/set_offset(_offset)
	if(_offset == total_offset || !isnum(_offset) || _offset < 0)
		return
	else if(_offset < total_offset)
		set_seed(seed) //total_offset is now 0
	if(!total_offset && seed == -1)
		set_seed()
	while(total_offset < _offset)
		random()

//Only tests the seed if total_offset == 0 while incrementing it
#define VALIDATE_SEED(procname) \
	if(!total_offset++ && seed == -1) {\
		total_offset = 0;\
		stack_trace("SSrng.[##procname]() was called BEFORE a seed was set");\
	}

/datum/controller/subsystem/rng/proc/random(lower, upper) //replaces rand()
	VALIDATE_SEED("random")
	if(lower != null || upper != null)
		return rand(lower, upper)
	else
		return rand()

/datum/controller/subsystem/rng/proc/probability(chance) //replaces prob()
	VALIDATE_SEED("probability")
	return prob(chance)

/datum/controller/subsystem/rng/proc/pick_from_list() //replaces pick()
	VALIDATE_SEED("pick_from_list")
	if(args.len == 1)
		return pick(args[1])
	else
		return pick(args)

#undef VALIDATE_SEED

/datum/controller/subsystem/rng/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("seed")
			if(istext(var_value)) //being fed a hex value, probably
				var_value = hex2num(var_value)
			set_seed(var_value)
			return TRUE
		if("total_offset")
			set_offset(var_value)
			return TRUE
	return ..()