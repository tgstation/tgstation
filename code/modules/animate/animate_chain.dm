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
	var/a_tag
	var/command

/datum/animate_chain/proc/get_all_next()
	var/datum/animate_chain/iteration = next
	var/list/datum/animate_chain/all_next = list()
	while(!isnull(iteration))
		all_next += list(iteration)
		iteration = iteration.next
	return all_next

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
		animate_arguments["tag"] = a_tag
	if(!isnull(command))
		animate_arguments["command"] = command

	animate(arglist(animate_arguments))
	next.apply(null) // explicitly do not propagate the target

/datum/animate_chain/serialize_list(list/options, list/semvers)
	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")
	return ..() | list(
		"chain_index" = chain_index,
		"time" = time,
		"loop" = loop,
		"easing" = easing,
		"easing_flags" = easing_flags,
		"flags" = flags,
		"delay" = delay,
		"a_tag" = a_tag,
		"command" = command,
		"next" = next.serialize_list(options, list())
	)

/datum/animate_chain/deserialize_list(list/data, list/options)
	. = ..()
	if(!.)
		return

	chain_index = data["chain_index"]
	time = data["time"]
	loop = data["loop"]
	easing = data["easing"]
	easing_flags = data["easing_flags"]
	flags = data["flags"]
	delay = data["delay"]
	a_tag = data["a_tag"]
	command = data["command"]

	if("next" in data)
		var/datum/animate_chain/next_instance = new
		if(!next_instance.deserialize_list(data["next"], options))
			return FALSE
		next = next_instance

	return TRUE
