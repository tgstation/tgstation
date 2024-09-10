/**
 * One proc for easy spawning of pods in the code to drop off items before whizzling (please don't proc call this in game, it will destroy you)
 *
 * Arguments:
 * * specifications: special mods to the pod, see non var edit specifications for details on what you should fill this with
 * Non var edit specifications:
 * * target = where you want the pod to drop
 * * path = a special specific pod path if you want, this can save you a lot of var edits
 * * style = style of the pod, defaults to the normal pod
 * * spawn = spawned path or a list of the paths spawned, what you're sending basically
 * Returns the pod spawned, in case you want to spawn items yourself and modify them before putting them in.
 */
/proc/podspawn(specifications)
	//get non var edit specifications
	var/turf/landing_location = specifications["target"]
	var/spawn_type = specifications["path"]
	var/style = specifications["style"]
	var/list/paths_to_spawn = specifications["spawn"]

	//setup pod, add contents
	if(!isturf(landing_location))
		landing_location = get_turf(landing_location)
	if(!spawn_type)
		spawn_type = /obj/structure/closet/supplypod/podspawn
	var/obj/structure/closet/supplypod/podspawn/pod = new spawn_type(null, style)
	if(paths_to_spawn && !islist(paths_to_spawn))
		paths_to_spawn = list(paths_to_spawn)
	for(var/atom/movable/path as anything in paths_to_spawn)
		if(!ispath(path))
			path.forceMove(pod)
		else
			var/amount_to_spawn = paths_to_spawn[path] || 1
			if(!isnum(amount_to_spawn))
				stack_trace("amount to spawn for path \"[path]\" is not a number, defaulting to 1")
				amount_to_spawn = 1

			for(var/item_number in 1 to amount_to_spawn)
				new path(pod)

	//remove non var edits from specifications
	specifications -= "target"
	specifications -= "style"
	specifications -= "path"
	specifications -= "spawn" //list, we remove the key

	//rest of specificiations are edits on the pod
	for(var/variable_name in specifications)
		var/variable_value = specifications[variable_name]
		if(!pod.vv_edit_var(variable_name, variable_value))
			stack_trace("WARNING! podspawn vareditting \"[variable_name]\" to \"[variable_value]\" was rejected by the pod!")
	new /obj/effect/pod_landingzone(landing_location, pod)
	return pod
