/datum/animate_chain
	var/chain_index = 1

	var/datum/animate_chain/next
	var/list/var_list
	var/mutable_appearance/appearance
	var/time
	var/loop
	var/easing
	var/easing_flags
	var/flags
	var/delay
	var/tag
	var/command

/datum/animate_chain/proc/animate_param_ids()
	return list(
		"var_list",
		"appearance",
		"time",
		"loop",
		"easing",
		"easing_flags",
		"flags",
		"delay",
		"tag",
		"command",
	)

/datum/animate_chain/proc/apply(target)
	var/list/animate_arguments = list()

	if(!isnull(target))
		animate_arguments["Object"] = target
	if(!isnull(var_list))
		animate_arguments["var_list"] = var_list
	if(!isnull(appearance))
		animate_arguments["appearance"] = appearance
	if(!isnull(time))
		animate_arguments["time"] = time
	if(!isnull(loop))
		animate_arguments["loop"] = loop
	if(!isnull(easing))
		animate_arguments["easing"] = easing
	if(!isnull(easing_flags))
		animate_arguments["easing_flags"] = easing_flags
	if(!isnull(flags))
		animate_arguments["flags"] = flags
	if(!isnull(delay))
		animate_arguments["delay"] = delay
	if(!isnull(tag))
		animate_arguments["tag"] = tag
	if(!isnull(command))
		animate_arguments["command"] = command

	animate(arglist(animate_arguments))
	next.apply(null) // explicitly do not propagate the target

/datum/animate_chain/serialize_list(list/options, list/semvers)
	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")
	return ..() | list(
		"index" = chain_index,
		"time" = time,
		"loop" = loop,
		"easing" = easing,
		"easing_flags" = easing_flags,
		"flags" = flags,
		"delay" = delay,
		"tag" = tag,
		"command" = command,
	)
