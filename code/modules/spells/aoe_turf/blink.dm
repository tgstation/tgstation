/atom/movable/spell/aoe_turf/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."

	school = "abjuration"
	charge_max = 20
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = 7
	inner_radius = 1
	cooldown_min = 5 //4 deciseconds reduction per rank

	smoke_spread = 0
	smoke_amt = 1

	ignore_space = 1 //whether it includes space tiles in possible teleport locations
	ignore_dense = 1

	centcomm_cancast = 0 //prevent people from getting to centcomm

/atom/movable/spell/aoe_turf/blink/cast(var/list/targets, mob/user)
	if(!targets.len)
		return

	var/turf/T = pick(targets)
	if(T)
		if(user.buckled)
			user.buckled.unbuckle()
		user.loc = T

	return