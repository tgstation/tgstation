/datum/component/beetlejuice
	var/keyword
	var/list/first_heard
	var/list/count
	var/min_delay = 3 SECONDS //How fast they need to be said
	var/min_count = 3
	var/cooldown = 30 SECONDS //Delay between teleports
	var/active = TRUE

/datum/component/beetlejuice/Initialize()
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE

	first_heard = list()
	count = list()

	var/atom/movable/O = parent
	keyword = O.name
	if(ismob(O))
		var/mob/M = parent
		keyword = M.real_name

	RegisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL, .proc/say_react)

/datum/component/beetlejuice/proc/say_react(datum/source, mob/speaker,message)
	if(!speaker || !message || !active)
		return
	var/found = findtext(message,keyword)
	if(found)
		var/occurences = 0
		while(found > 0)
			occurences++
			found = findtext(message,keyword,found + length(keyword) + 1)

		if(!first_heard[speaker] || (first_heard[speaker] + min_delay < world.time))
			first_heard[speaker] = world.time
			count[speaker] = 0
		count[speaker] += occurences
		if(count[speaker] >= min_count)
			first_heard -= speaker
			count -= speaker
			apport(speaker)


/datum/component/beetlejuice/proc/apport(atom/target)
	var/atom/movable/AM = parent
	do_teleport(AM,get_turf(target))
	active = FALSE
	addtimer(VARSET_CALLBACK(src, active, TRUE), cooldown)