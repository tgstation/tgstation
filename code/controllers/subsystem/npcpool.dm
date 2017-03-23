var/datum/controller/subsystem/npcpool/SSnpc

/datum/controller/subsystem/npcpool
	name = "NPC Pool"
	init_order = 17
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_NO_TICK_CHECK
	priority = 25

	var/list/canBeUsed = list()
	var/list/canBeUsed_non = list()
	var/list/needsDelegate = list()
	var/list/needsAssistant = list()
	var/list/needsHelp_non = list()
	var/list/botPool_l = list() //list of all npcs using the pool
	var/list/botPool_l_non = list() //list of all non SNPC mobs using the pool

	var/NPCsToSpawn = 15
	var/populated_centcom = FALSE
	var/list/spawned_npcs = list()

/datum/controller/subsystem/npcpool/proc/insertBot(toInsert)
	if(istype(toInsert,/mob/living/carbon/human/interactive))
		botPool_l |= toInsert

/datum/controller/subsystem/npcpool/New()
	NEW_SS_GLOBAL(SSnpc)

/datum/controller/subsystem/npcpool/stat_entry()
	..("T:[botPool_l.len + botPool_l_non.len]|D:[needsDelegate.len]|A:[needsAssistant.len + needsHelp_non.len]|U:[canBeUsed.len + canBeUsed_non.len]")


/datum/controller/subsystem/npcpool/proc/cleanNull()
		//cleanup nulled bots
	listclearnulls(botPool_l)
	listclearnulls(needsDelegate)
	listclearnulls(canBeUsed)
	listclearnulls(needsAssistant)


/datum/controller/subsystem/npcpool/fire()
	//bot delegation and coordination systems
	//General checklist/Tasks for delegating a task or coordinating it (for SNPCs)
	// 1. Bot proximity to task target: if too far, delegate, if close, coordinate
	// 2. Bot Health/status: check health with bots in local area, if their health is higher, delegate task to them, else coordinate
	// 3. Process delegation: if a bot (or bots) has been delegated, assign them to the task.
	// 4. Process coordination: if a bot(or bots) has been asked to coordinate, assign them to help.
	// 5. Do all assignments: goes through the delegated/coordianted bots and assigns the right variables/tasks to them.
	var/npcCount = 1

	cleanNull()

	if(!populated_centcom && ticker.current_state >= GAME_STATE_FINISHED)
		PopulateCentcom(FALSE)		

	//SNPC handling
	for(var/mob/living/carbon/human/interactive/check in botPool_l)
		if(!check)
			botPool_l.Cut(npcCount,npcCount+1)
			continue
		var/checkInRange = view(MAX_RANGE_FIND,check)
		if(!(locate(check.TARGET) in checkInRange))
			needsDelegate |= check

		else if(check.IsDeadOrIncap(FALSE))
			needsDelegate |= check

		else if(check.doing & FIGHTING)
			needsAssistant |= check

		else
			canBeUsed |= check
		npcCount++

	if(needsDelegate.len)

		needsDelegate -= pick(needsDelegate) // cheapo way to make sure stuff doesn't pingpong around in the pool forever. delegation runs seperately to each loop so it will work much smoother

		npcCount = 1 //reset the count
		for(var/mob/living/carbon/human/interactive/check in needsDelegate)
			if(!check)
				needsDelegate.Cut(npcCount,npcCount+1)
				continue
			if(canBeUsed.len)
				var/mob/living/carbon/human/interactive/candidate = pick(canBeUsed)
				var/facCount = 0
				var/helpProb = 0
				for(var/C in check.faction)
					for(var/D in candidate.faction)
						if(D == C)
							helpProb = min(100,helpProb + 25)
						facCount++
				if(facCount == 1 && helpProb > 0)
					helpProb = 100
				if(prob(helpProb))
					if(candidate.takeDelegate(check))
						needsDelegate -= check
						canBeUsed -= candidate
						candidate.eye_color = "red"
						candidate.update_icons()
			npcCount++

	if(needsAssistant.len)

		needsAssistant -= pick(needsAssistant)

		npcCount = 1 //reset the count
		for(var/mob/living/carbon/human/interactive/check in needsAssistant)
			if(!check)
				needsAssistant.Cut(npcCount,npcCount+1)
				continue
			if(canBeUsed.len)
				var/mob/living/carbon/human/interactive/candidate = pick(canBeUsed)
				var/facCount = 0
				var/helpProb = 0
				for(var/C in check.faction)
					for(var/D in candidate.faction)
						if(D == C)
							helpProb = min(100,helpProb + 25)
						facCount++
				if(facCount == 1 && helpProb > 0)
					helpProb = 100
				if(prob(helpProb))
					if(candidate.takeDelegate(check,FALSE))
						needsAssistant -= check
						canBeUsed -= candidate
						candidate.eye_color = "yellow"
						candidate.update_icons()
			npcCount++

/datum/controller/subsystem/npcpool/Recover()
	if (istype(SSnpc.botPool_l))
		botPool_l = SSnpc.botPool_l
	if (istype(SSnpc.botPool_l_non))
		botPool_l_non = SSnpc.botPool_l_non

/datum/controller/subsystem/npcpool/proc/PopulateCentcom(skip_roundend_check = TRUE)
	set waitfor = FALSE
	populated_centcom = TRUE

	var/list/centcom_areas = list()
	for(var/area/centcom/evac/D in sortedAreas)
		centcom_areas += D
		CHECK_TICK
	
	if(!centcom_areas.len)
		return

	var/list/spawn_locs = list()

	for(var/I in 1 to NPCsToSpawn)
		var/list/candidates = get_area_turfs(pick(centcom_areas))
		if(!LAZYLEN(candidates))
			break
		
		while(candidates.len)
			var/turf/T = pick(candidates)
			if(!is_blocked_turf(T) && !spawn_locs[T])
				spawn_locs[T] = 
				break
			else
				candidates -= T
		if(!candidates.len)
			break
		if(!populated_centcom)
			return
		CHECK_TICK
	
	if(!skip_roundend_check)
		UNTIL(populated_centcom && ticker.current_state == GAME_STATE_FINISHED)
	
	if(NPCsToSpawn.len)
		for(var/I in spawn_locs)
			spawned_npcs += new /mob/living/carbon/human/interactive(I)

/datum/controller/subsystem/npcpool/Shutdown()
	DepopulateCentcom()

/datum/controller/subsystem/npcpool/proc/DepopulateCentcom()
	populated_centcom = FALSE
	NPCsToSpawn = 0
	sleep(1)	//wait for the loop to end
	for(var/I in spawned_npcs)
		qdel(I)
	LAZYCLEARLIST(spawned_npcs)
